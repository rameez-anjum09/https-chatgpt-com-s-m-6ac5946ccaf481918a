import Foundation

/// Primary data model representing a nursery rhyme.
public struct Rhyme: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let category: RhymeCategory
    public let assetName: String
    public let fullAssetName: String?
    public let audioFileName: String?
    public let videoFileName: String?
    public let audioDuration: TimeInterval
    public let lyrics: String?
    public let timedLyrics: [LyricSegment]

    public init(
        id: String,
        title: String,
        category: RhymeCategory,
        assetName: String,
        fullAssetName: String? = nil,
        audioFileName: String? = nil,
        videoFileName: String? = nil,
        audioDuration: TimeInterval = 0,
        lyrics: String? = nil,
        timedLyrics: [LyricSegment] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.assetName = assetName
        self.fullAssetName = fullAssetName ?? assetName
        self.audioFileName = audioFileName
        self.videoFileName = videoFileName
        self.audioDuration = audioDuration
        self.lyrics = lyrics
        self.timedLyrics = timedLyrics
    }

    public var hasAudio: Bool {
        guard let name = audioFileName else { return false }
        return !name.isEmpty
    }

    public var hasVideo: Bool {
        guard let name = videoFileName else { return false }
        return !name.isEmpty
    }

    public var hasTimedLyrics: Bool {
        return !timedLyrics.isEmpty
    }

    /// Formatted mm:ss string
    public var formattedDuration: String {
        guard audioDuration > 0 else { return "--:--" }
        let minutes = Int(audioDuration) / 60
        let seconds = Int(audioDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Two preview lyric lines for the player overview
    public var previewLyrics: (line1: String, line2: String) {
        guard let lyrics = lyrics, !lyrics.isEmpty else {
            return ("Sing along together", "With love and delight")
        }
        let lines = lyrics.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if lines.count >= 2 {
            return (lines[0], lines[1])
        } else if lines.count == 1 {
            return (lines[0], "")
        }
        return ("Sing along together", "")
    }
}
