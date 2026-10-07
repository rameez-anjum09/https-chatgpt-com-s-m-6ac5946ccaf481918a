import SwiftUI

/// Main container coordinating navigation between Home, Rhymes Library, Favorites, and Player.
public struct MainTabView: View {
    @StateObject private var catalog = RhymeCatalog.shared
    @StateObject private var favoritesStore = FavoritesStore.shared
    @StateObject private var playback = PlaybackController.shared

    @State private var selectedTab: NavigationTab = .home
    @State private var activeRhymeForPlayer: Rhyme? = nil

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main content depending on active bottom tab
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        catalog: catalog,
                        favoritesStore: favoritesStore,
                        playback: playback,
                        selectedTab: $selectedTab,
                        activeRhymeForPlayer: $activeRhymeForPlayer
                    )
                case .rhymes:
                    LibraryView(
                        catalog: catalog,
                        favoritesStore: favoritesStore,
                        playback: playback,
                        selectedTab: $selectedTab,
                        activeRhymeForPlayer: $activeRhymeForPlayer
                    )
                case .favorites:
                    FavoritesView(
                        catalog: catalog,
                        favoritesStore: favoritesStore,
                        playback: playback,
                        selectedTab: $selectedTab,
                        activeRhymeForPlayer: $activeRhymeForPlayer
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Ivory Dock Bottom Bar (hidden when player is open)
            if activeRhymeForPlayer == nil {
                BottomNavigationBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Player View Overlay
            if let activeRhyme = activeRhymeForPlayer {
                PlayerView(
                    rhyme: activeRhyme,
                    playback: playback,
                    favoritesStore: favoritesStore,
                    activeRhymeForPlayer: $activeRhymeForPlayer,
                    selectedTab: $selectedTab
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: activeRhymeForPlayer)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedTab)
    }
}
