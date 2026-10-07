import SwiftUI

/// AppTheme defines the color palette, typography styles, shadows, and corner radii
/// faithfully matching the three-screen reference design.
public enum AppTheme {
    // MARK: - Brand & Surface Colors
    public static let darkNavy = Color(red: 27/255, green: 37/255, blue: 75/255)
    public static let navySecondary = Color(red: 45/255, green: 55/255, blue: 95/255)
    public static let navySubtle = Color(red: 85/255, green: 95/255, blue: 135/255)

    // Ivory & Cream surfaces
    public static let ivoryCard = Color(red: 255/255, green: 253/255, blue: 247/255)
    public static let ivoryDock = Color(red: 255/255, green: 254/255, blue: 250/255)
    public static let ivoryBorder = Color(red: 236/255, green: 226/255, blue: 205/255)
    public static let warmIvoryBg = Color(red: 253/255, green: 249/255, blue: 239/255)

    // Action Colors
    public static let brightGreen = Color(red: 63/255, green: 203/255, blue: 50/255)
    public static let greenPressed = Color(red: 45/255, green: 175/255, blue: 35/255)

    public static let pinkAction = Color(red: 247/255, green: 61/255, blue: 115/255)
    public static let pinkPressed = Color(red: 220/255, green: 40/255, blue: 95/255)

    public static let purpleAction = Color(red: 125/255, green: 90/255, blue: 232/255)
    public static let skyBlue = Color(red: 74/255, green: 168/255, blue: 255/255)
    public static let amberAction = Color(red: 255/255, green: 176/255, blue: 32/255)

    // Wood Panels
    public static let honeyWood = Color(red: 216/255, green: 147/255, blue: 72/255)
    public static let honeyWoodDark = Color(red: 145/255, green: 79/255, blue: 24/255)
    public static let honeyWoodHighlight = Color(red: 240/255, green: 182/255, blue: 115/255)

    // MARK: - Gradients
    public static let greenButtonGradient = LinearGradient(
        colors: [Color(red: 75/255, green: 218/255, blue: 62/255), Color(red: 50/255, green: 185/255, blue: 38/255)],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let woodGradient = LinearGradient(
        colors: [honeyWoodHighlight, honeyWood, honeyWoodDark],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let skyBlueGradient = LinearGradient(
        colors: [Color(red: 105/255, green: 185/255, blue: 255/255), skyBlue],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let pinkButtonGradient = LinearGradient(
        colors: [Color(red: 255/255, green: 85/255, blue: 135/255), pinkAction],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let purpleButtonGradient = LinearGradient(
        colors: [Color(red: 145/255, green: 110/255, blue: 250/255), purpleAction],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let amberButtonGradient = LinearGradient(
        colors: [Color(red: 255/255, green: 195/255, blue: 65/255), amberAction],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Corner Radii
    public static let cardCornerRadius: CGFloat = 22
    public static let dockCornerRadius: CGFloat = 36
    public static let buttonCornerRadius: CGFloat = 28
    public static let pillCornerRadius: CGFloat = 20

    // MARK: - Shadows
    public static let softCardShadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.08), 8, 0, 4
    )

    public static let buttonDropShadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.18), 6, 0, 4
    )

    public static let woodPanelShadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.14), 10, 0, 5
    )
}

// MARK: - View Modifiers for Storybook Styling
public struct StorybookCardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
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
}

public extension View {
    func storybookCard() -> some View {
        modifier(StorybookCardModifier())
    }
}
