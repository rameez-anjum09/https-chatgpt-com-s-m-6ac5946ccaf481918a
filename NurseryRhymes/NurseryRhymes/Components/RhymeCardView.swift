import SwiftUI

/// RhymeCardView displays a nursery rhyme card matching the reference design:
/// Ivory surface, storybook artwork, top-right heart favorite toggle,
/// bottom-center green play button, and readable navy typography.
public struct RhymeCardView: View {
    public let rhyme: Rhyme
    public let isFavorite: Bool
    public let isPlayingThis: Bool
    public let onSelect: () -> Void
    public let onToggleFavorite: () -> Void
    public let onPlayAction: () -> Void

    public init(
        rhyme: Rhyme,
        isFavorite: Bool,
        isPlayingThis: Bool = false,
        onSelect: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void,
        onPlayAction: @escaping () -> Void
    ) {
        self.rhyme = rhyme
        self.isFavorite = isFavorite
        self.isPlayingThis = isPlayingThis
        self.onSelect = onSelect
        self.onToggleFavorite = onToggleFavorite
        self.onPlayAction = onPlayAction
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Top Artwork with controls
                ZStack(alignment: .topTrailing) {
                    // Artwork image
                    Image(rhyme.assetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(18, corners: [.topLeft, .topRight])

                    // Top-right Favorite Heart Button
                    Button(action: onToggleFavorite) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.85))
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)

                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isFavorite ? AppTheme.pinkAction : AppTheme.skyBlue)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(8)
                    .accessibilityLabel(isFavorite ? "Remove \(rhyme.title) from favorites" : "Add \(rhyme.title) to favorites")

                    // Bottom-center Play Button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: onPlayAction) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.greenButtonGradient)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2.5)
                                        )
                                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 3)

                                    Image(systemName: isPlayingThis ? "pause.fill" : "play.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .offset(x: isPlayingThis ? 0 : 2)
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .offset(y: 20)
                            .accessibilityLabel(isPlayingThis ? "Pause \(rhyme.title)" : "Play \(rhyme.title)")
                            Spacer()
                        }
                    }
                }
                .frame(height: 140)

                // Bottom Ivory Surface with Title
                VStack(spacing: 4) {
                    Spacer().frame(height: 18) // Spacing for play button overlap

                    Text(rhyme.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.darkNavy)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                .background(AppTheme.ivoryCard)
                .cornerRadius(18, corners: [.bottomLeft, .bottomRight])
            }
            .background(AppTheme.ivoryCard)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .stroke(AppTheme.ivoryBorder, lineWidth: 1.5)
            )
            .shadow(
                color: AppTheme.softCardShadow.color,
                radius: AppTheme.softCardShadow.radius,
                x: AppTheme.softCardShadow.x,
                y: AppTheme.softCardShadow.y
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tap card to open player")
    }
}

// Extension to support selective corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
