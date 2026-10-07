import SwiftUI

/// Honey-colored wooden header plank with storybook leaves and floral accents.
public struct WoodenHeader: View {
    public let title: String
    public let onBack: (() -> Void)?
    public let trailingContent: AnyView?

    public init(
        title: String,
        onBack: (() -> Void)? = nil,
        trailingContent: AnyView? = nil
    ) {
        self.title = title
        self.onBack = onBack
        self.trailingContent = trailingContent
    }

    public var body: some View {
        ZStack {
            // Wood plank surface
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 242/255, green: 184/255, blue: 118/255),
                            Color(red: 218/255, green: 148/255, blue: 74/255),
                            Color(red: 165/255, green: 95/255, blue: 32/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // Wood grain line accents
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(Color(red: 145/255, green: 75/255, blue: 18/255).opacity(0.2))
                            .frame(height: 1.5)
                        Rectangle()
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 135/255, green: 70/255, blue: 15/255), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)

            // Header Content
            HStack(spacing: 12) {
                if let onBack = onBack {
                    RoundIconButton(
                        iconName: "chevron.left",
                        gradient: AppTheme.pinkButtonGradient,
                        size: 44,
                        iconSize: 18,
                        accessibilityLabel: "Back",
                        action: onBack
                    )
                } else {
                    Spacer().frame(width: 44)
                }

                Spacer()

                Text(title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.darkNavy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer()

                if let trailingContent = trailingContent {
                    trailingContent
                        .frame(width: 44, height: 44)
                } else {
                    Spacer().frame(width: 44)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 64)
        .padding(.horizontal, 16)
    }
}
