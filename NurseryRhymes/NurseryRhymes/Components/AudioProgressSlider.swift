import SwiftUI

/// AudioProgressSlider displays the elapsed time, total duration, and interactive scrubber track.
public struct AudioProgressSlider: View {
    public let currentTime: TimeInterval
    public let duration: TimeInterval
    public let isEnabled: Bool
    public let onSeek: (TimeInterval) -> Void

    @State private var dragPosition: CGFloat? = nil

    public init(
        currentTime: TimeInterval,
        duration: TimeInterval,
        isEnabled: Bool = true,
        onSeek: @escaping (TimeInterval) -> Void
    ) {
        self.currentTime = currentTime
        self.duration = duration
        self.isEnabled = isEnabled
        self.onSeek = onSeek
    }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return max(0, min(1, currentTime / duration))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time > 0 else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Elapsed Time
            Text(formatTime(currentTime))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.darkNavy)
                .frame(width: 38, alignment: .leading)

            // Scrubber Track
            GeometryReader { geo in
                let width = geo.size.width
                let currentProgress = dragPosition != nil ? max(0, min(1, Double(dragPosition! / width))) : progress

                ZStack(alignment: .leading) {
                    // Background rail
                    Capsule()
                        .fill(Color(red: 226/255, green: 220/255, blue: 210/255))
                        .frame(height: 6)

                    // Active progress fill
                    Capsule()
                        .fill(AppTheme.skyBlueGradient)
                        .frame(width: max(0, width * CGFloat(currentProgress)), height: 6)

                    // Thumb Knob
                    Circle()
                        .fill(AppTheme.skyBlue)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(color: AppTheme.skyBlue.opacity(0.4), radius: 3, x: 0, y: 1)
                        .offset(x: max(0, min(width - 18, (width * CGFloat(currentProgress)) - 9)))
                }
                .frame(height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard isEnabled && duration > 0 else { return }
                            dragPosition = value.location.x
                        }
                        .onEnded { value in
                            guard isEnabled && duration > 0 else { return }
                            let finalProgress = max(0, min(1, value.location.x / width))
                            let targetTime = Double(finalProgress) * duration
                            dragPosition = nil
                            onSeek(targetTime)
                        }
                )
            }
            .frame(height: 24)

            // Total Duration
            Text(duration > 0 ? formatTime(duration) : "--:--")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.darkNavy)
                .frame(width: 38, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}
