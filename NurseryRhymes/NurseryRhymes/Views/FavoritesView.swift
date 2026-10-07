import SwiftUI

/// FavoritesView displays the user's saved favorite nursery rhymes in a responsive grid
/// with playback support and a friendly empty state.
public struct FavoritesView: View {
    @ObservedObject var catalog: RhymeCatalog
    @ObservedObject var favoritesStore: FavoritesStore
    @ObservedObject var playback: PlaybackController
    @Binding var selectedTab: NavigationTab
    @Binding var activeRhymeForPlayer: Rhyme?

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(
        catalog: RhymeCatalog,
        favoritesStore: FavoritesStore,
        playback: PlaybackController,
        selectedTab: Binding<NavigationTab>,
        activeRhymeForPlayer: Binding<Rhyme?>
    ) {
        self.catalog = catalog
        self.favoritesStore = favoritesStore
        self.playback = playback
        self._selectedTab = selectedTab
        self._activeRhymeForPlayer = activeRhymeForPlayer
    }

    private var favoriteRhymes: [Rhyme] {
        favoritesStore.favoriteRhymes(from: catalog.rhymes)
    }

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 14), count: count)
    }

    public var body: some View {
        ZStack {
            AppTheme.warmIvoryBg
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // Header
                WoodenHeader(
                    title: "Your Favorites",
                    onBack: {
                        withAnimation {
                            selectedTab = .home
                        }
                    }
                )
                .padding(.top, 4)

                if favoriteRhymes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 50)
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.pinkAction.opacity(0.6))

                        Text("No Favorites Yet")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.darkNavy)

                        Text("Explore the rhymes library and tap the heart icon on any rhyme to save it to your favorites.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(AppTheme.navySubtle)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)

                        Button(action: {
                            withAnimation {
                                selectedTab = .rhymes
                            }
                        }) {
                            Text("Explore Rhymes")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(AppTheme.greenButtonGradient)
                                .clipShape(Capsule())
                                .shadow(color: AppTheme.brightGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(favoriteRhymes) { rhyme in
                                RhymeCardView(
                                    rhyme: rhyme,
                                    isFavorite: true,
                                    isPlayingThis: playback.currentRhyme?.id == rhyme.id && playback.isPlaying,
                                    onSelect: {
                                        activeRhymeForPlayer = rhyme
                                        playback.setQueue(favoriteRhymes)
                                    },
                                    onToggleFavorite: {
                                        favoritesStore.toggleFavorite(id: rhyme.id)
                                    },
                                    onPlayAction: {
                                        if playback.currentRhyme?.id == rhyme.id {
                                            playback.togglePlayPause()
                                        } else {
                                            playback.loadAndPlay(rhyme: rhyme, queue: favoriteRhymes, autoPlay: true)
                                            activeRhymeForPlayer = rhyme
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 90)
                    }
                }
            }
        }
    }
}
