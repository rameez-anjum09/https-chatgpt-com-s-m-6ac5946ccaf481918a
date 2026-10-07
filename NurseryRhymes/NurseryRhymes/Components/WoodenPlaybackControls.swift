import SwiftUI

/// Honey wood playback controls tray containing previous, play/pause, next, and repeat buttons.
public struct WoodenPlaybackControls: View {
    public let isPlaying: Bool
    public let isRepeatEnabled: Bool
    public let isEnabled: Bool
    public let onPrevious: () -> Void
    public let onPlayPause: () -> Void
    public let onNext: () -> Void
    public let onToggleRepeat: () -> Void

    public init(
        isPlaying: Bool,
        isRepeatEnabled: Bool,
        isEnabled: Bool = true,
        onPrevious: @escaping () -> Void,
        onPlayPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onToggleRepeat: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        self.isRepeatEnabled = isRepeatEnabled
        self.isEnabled = isEnabled
        self.onPrevious = onPrevious
        self.onPlayPause = onPlayPause
        self.onNext = onNext
        self.onToggleRepeat = onToggleRepeat
    }

    public var body: some View {
        ZStack {
            // Wooden tray surface
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 238/255, green: 178/255, blue: 112/255),
                            Color(red: 215/255, green: 144/255, blue: 72/255),
                            Color(red: 160/255, green: 90/255, blue: 28/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // Subtle wood grain lines
                    VStack(spacing: 12) {
                        Rectangle()
                            .fill(Color(red: 135/255, green: 68/255, blue: 14/255).opacity(0.18))
                            .frame(height: 2)
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color(red: 140/255, green: 72/255, blue: 18/255), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)

            // Button controls inside tray
            HStack(spacing: 22) {
                // 1. Previous Track (Purple)
                RoundIconButton(
                    iconName: "backward.fill",
                    gradient: AppTheme.purpleButtonGradient,
                    size: 52,
                    iconSize: 20,
                    accessibilityLabel: "Previous Rhyme",
                    action: onPrevious
                )
                .disabled(!isEnabled)

                // 2. Play / Pause (Prominent Bright Green)
                Button(action: onPlayPause) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.greenButtonGradient)
                            .frame(width: 68, height: 68)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)

                        // Top shine
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(width: 62, height: 62)

                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundColor(.white)
                            .offset(x: isPlaying ? 0 : 2)
                    }
                }
                .disabled(!isEnabled)
                .accessibilityLabel(isPlaying ? "Pause" : "Play")

                // 3. Next Track (Amber / Yellow)
                RoundIconButton(
                    iconName: "forward.fill",
                    gradient: AppTheme.amberButtonGradient,
                    size: 52,
                    iconSize: 20,
                    accessibilityLabel: "Next Rhyme",
                    action: onNext
                )
                .disabled(!isEnabled)

                // 4. Repeat (Pink)
                RoundIconButton(
                    iconName: "repeat",
                    gradient: AppTheme.pinkButtonGradient,
                    size: 52,
                    iconSize: 20,
                    accessibilityLabel: isRepeatEnabled ? "Repeat Enabled" : "Repeat Disabled",
                    action: onToggleRepeat
                )
                .overlay(
                    // Repeat active dot
                    Group {
                        if isRepeatEnabled {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                                .offset(y: 16)
                        }
                    }
                )
            }
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .frame(height: 84)
        .padding(.horizontal, 16)
    }
}
