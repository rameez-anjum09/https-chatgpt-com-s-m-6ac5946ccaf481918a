import SwiftUI

public enum NavigationTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case rhymes = "Rhymes"
    case favorites = "Favorites"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .rhymes: return "music.note"
        case .favorites: return "heart.fill"
        }
    }
}

/// Floating ivory dock bottom navigation bar matching the design reference.
public struct BottomNavigationBar: View {
    @Binding public var selectedTab: NavigationTab

    public init(selectedTab: Binding<NavigationTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(NavigationTab.allCases) { tab in
                let isSelected = selectedTab == tab

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(
                                isSelected ? AppTheme.darkNavy :
                                tab == .favorites ? AppTheme.pinkAction : AppTheme.navySubtle
                            )

                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? AppTheme.darkNavy : AppTheme.navySubtle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(
                                        Color(red: 204/255, green: 232/255, blue: 255/255)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(Color(red: 175/255, green: 215/255, blue: 255/255), lineWidth: 1)
                                    )
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("\(tab.rawValue) tab")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.ivoryDock)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppTheme.ivoryBorder, lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
}
