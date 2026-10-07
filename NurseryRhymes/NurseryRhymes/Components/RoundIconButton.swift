import SwiftUI

/// Tactile, round push button with vibrant 3D jelly styling matching the design.
public struct RoundIconButton: View {
    public let iconName: String
    public let gradient: LinearGradient
    public let size: CGFloat
    public let iconSize: CGFloat
    public let shadowColor: Color
    public let accessibilityLabel: String
    public let action: () -> Void

    @State private var isPressed: Bool = false

    public init(
        iconName: String,
        gradient: LinearGradient,
        size: CGFloat = 44,
        iconSize: CGFloat = 18,
        shadowColor: Color = Color.black.opacity(0.18),
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.gradient = gradient
        self.size = size
        self.iconSize = iconSize
        self.shadowColor = shadowColor
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                // Button base circle
                Circle()
                    .fill(gradient)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                    )
                    .shadow(color: shadowColor, radius: 4, x: 0, y: 3)

                // Highlighting top sheen
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: size - 4, height: size - 4)

                // Icon
                Image(systemName: iconName)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressFeedbackStyle(isPressed: $isPressed))
        .accessibilityLabel(accessibilityLabel)
    }
}

/// Helper button style to detect pressed state for tactile spring animation
public struct PressFeedbackStyle: ButtonStyle {
    @Binding var isPressed: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}
