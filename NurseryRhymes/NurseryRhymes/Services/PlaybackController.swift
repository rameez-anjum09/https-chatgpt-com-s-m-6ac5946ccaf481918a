import Foundation
import AVFoundation
import Combine
import SwiftUI

public enum PlayerDisplayMode: String, CaseIterable, Identifiable {
    case watch = "Watch"
    case lyrics = "Lyrics"

    public var id: String { rawValue }
}

/// Single source of truth for audio playback using AVFoundation.
public final class PlaybackController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published public var currentRhyme: Rhyme?
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var isSeeking: Bool = false
    @Published public var displayMode: PlayerDisplayMode = .watch
    @Published public var isRepeatEnabled: Bool = false
    @Published public var playbackError: String?

    public private(set) var activeQueue: [Rhyme] = []

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private let settings = AppSettings.shared

    private let lastRhymeIdKey = "last_played_rhyme_id"
    private let lastPositionKey = "last_played_rhyme_position"

    public static let shared = PlaybackController()

    public override init() {
        super.init()
        setupAudioSession()
        setupInterruptionNotifications()
        restoreLastSession()
    }

    deinit {
        stopProgressTimer()
        audioPlayer?.stop()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func setupInterruptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            if isPlaying {
                pause()
            }
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) && settings.autoplayNext {
                    play()
                }
            }
        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        if reason == .oldDeviceUnavailable {
            // e.g. headphones unplugged
            pause()
        }
    }

    // MARK: - Queue & Playback Control
    public func setQueue(_ queue: [Rhyme]) {
        self.activeQueue = queue
    }

    public func loadAndPlay(rhyme: Rhyme, queue: [Rhyme]? = nil, autoPlay: Bool = true) {
        if let queue = queue {
            self.activeQueue = queue
        } else if !self.activeQueue.contains(where: { $0.id == rhyme.id }) {
            self.activeQueue = [rhyme]
        }

        // Release previous player
        stopProgressTimer()
        audioPlayer?.stop()
        audioPlayer = nil

        self.currentRhyme = rhyme
        self.currentTime = 0
        self.playbackError = nil

        UserDefaults.standard.set(rhyme.id, forKey: lastRhymeIdKey)

        guard rhyme.hasAudio, let fileName = rhyme.audioFileName else {
            // Honest state: No audio bundled
            self.duration = 0
            self.isPlaying = false
            return
        }

        let nameWithoutExt = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        guard let soundURL = Bundle.main.url(forResource: nameWithoutExt, withExtension: ext) else {
            self.duration = rhyme.audioDuration
            self.isPlaying = false
            self.playbackError = "Media file '\(fileName)' not found in app bundle."
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.delegate = self
            player.prepareToPlay()
            self.audioPlayer = player
            self.duration = player.duration

            if autoPlay {
                play()
            } else {
                self.isPlaying = false
            }
        } catch {
            self.duration = 0
            self.isPlaying = false
            self.playbackError = "Unable to load audio track: \(error.localizedDescription)"
        }
    }

    public func play() {
        guard let player = audioPlayer else {
            // If rhyme has audio file but player wasn't initialized, try reloading
            if let rhyme = currentRhyme, rhyme.hasAudio {
                loadAndPlay(rhyme: rhyme, autoPlay: true)
            }
            return
        }

        player.play()
        isPlaying = true
        startProgressTimer()
    }

    public func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
        persistResumePosition()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    public func seek(to time: TimeInterval) {
        let clamped = max(0, min(duration, time))
        currentTime = clamped
        if let player = audioPlayer {
            player.currentTime = clamped
        }
        persistResumePosition()
    }

    public func nextTrack() {
        guard let current = currentRhyme, !activeQueue.isEmpty else { return }
        guard let currentIndex = activeQueue.firstIndex(where: { $0.id == current.id }) else {
            if let first = activeQueue.first {
                loadAndPlay(rhyme: first, autoPlay: isPlaying)
            }
            return
        }

        let nextIndex = (currentIndex + 1) % activeQueue.count
        loadAndPlay(rhyme: activeQueue[nextIndex], autoPlay: true)
    }

    public func previousTrack() {
        guard let current = currentRhyme, !activeQueue.isEmpty else { return }

        // If played more than 3 seconds, restart current track
        if currentTime > 3.0 {
            seek(to: 0)
            return
        }

        guard let currentIndex = activeQueue.firstIndex(where: { $0.id == current.id }) else {
            return
        }

        let prevIndex = (currentIndex - 1 + activeQueue.count) % activeQueue.count
        loadAndPlay(rhyme: activeQueue[prevIndex], autoPlay: true)
    }

    public func toggleRepeat() {
        isRepeatEnabled.toggle()
    }

    // MARK: - Progress Timer
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, !self.isSeeking else { return }
            self.currentTime = player.currentTime
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopProgressTimer()
        currentTime = 0

        if isRepeatEnabled {
            play()
        } else if settings.autoplayNext {
            nextTrack()
        }
    }

    // MARK: - Session Persistence
    private func persistResumePosition() {
        if let current = currentRhyme {
            UserDefaults.standard.set(current.id, forKey: lastRhymeIdKey)
            UserDefaults.standard.set(currentTime, forKey: lastPositionKey)
        }
    }

    private func restoreLastSession() {
        if let savedId = UserDefaults.standard.string(forKey: lastRhymeIdKey),
           let rhyme = RhymeCatalog.shared.rhyme(for: savedId) {
            let savedPos = UserDefaults.standard.double(forKey: lastPositionKey)
            loadAndPlay(rhyme: rhyme, autoPlay: false)
            if savedPos > 0 && savedPos < duration {
                seek(to: savedPos)
            }
        }
    }
}
