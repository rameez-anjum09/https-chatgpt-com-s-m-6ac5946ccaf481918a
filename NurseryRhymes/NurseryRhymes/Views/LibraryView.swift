import SwiftUI

/// LibraryView recreates Screen 2 in the design reference:
/// Wooden header "Explore Rhymes", search bar, category chips,
/// and adaptive 2-column/multi-column grid of all 50 rhymes.
public struct LibraryView: View {
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

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 14), count: count)
    }

    public var body: some View {
        ZStack {
            // Background with soft foliage accents
            AppTheme.warmIvoryBg
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // MARK: - Wooden Header: "Explore Rhymes"
                WoodenHeader(
                    title: "Explore Rhymes",
                    onBack: {
                        withAnimation {
                            selectedTab = .home
                        }
                    }
                )
                .padding(.top, 4)

                // MARK: - Search Field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.navySubtle)

                    TextField("Find a rhyme", text: $catalog.searchText)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.darkNavy)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if !catalog.searchText.isEmpty {
                        Button(action: {
                            catalog.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.navySubtle)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppTheme.ivoryBorder, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 16)

                // MARK: - Category Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(RhymeCategory.allCases) { category in
                            let isSelected = catalog.selectedCategory == category

                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    catalog.selectedCategory = category
                                }
                            }) {
                                Text(category.displayName)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(isSelected ? .white : AppTheme.darkNavy)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 10)
                                    .background(
                                        isSelected ? AnyView(AppTheme.greenButtonGradient) : AnyView(Color.white)
                                    )
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? Color.white.opacity(0.4) : AppTheme.ivoryBorder, lineWidth: 1.5)
                                    )
                                    .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.05), radius: 3, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                // MARK: - Rhymes Grid
                let filtered = catalog.filteredRhymes

                if filtered.isEmpty {
                    // Empty Results State
                    VStack(spacing: 14) {
                        Spacer().frame(height: 40)
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 54))
                            .foregroundColor(AppTheme.navySubtle.opacity(0.6))

                        Text("No rhymes found")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.darkNavy)

                        Text("Try searching for another rhyme title or clear your filters.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppTheme.navySubtle)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button(action: {
                            withAnimation {
                                catalog.searchText = ""
                                catalog.selectedCategory = .all
                            }
                        }) {
                            Text("Clear Filters")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 10)
                                .background(AppTheme.skyBlueGradient)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filtered) { rhyme in
                                RhymeCardView(
                                    rhyme: rhyme,
                                    isFavorite: favoritesStore.isFavorite(id: rhyme.id),
                                    isPlayingThis: playback.currentRhyme?.id == rhyme.id && playback.isPlaying,
                                    onSelect: {
                                        activeRhymeForPlayer = rhyme
                                        playback.setQueue(filtered)
                                    },
                                    onToggleFavorite: {
                                        favoritesStore.toggleFavorite(id: rhyme.id)
                                    },
                                    onPlayAction: {
                                        if playback.currentRhyme?.id == rhyme.id {
                                            playback.togglePlayPause()
                                        } else {
                                            playback.loadAndPlay(rhyme: rhyme, queue: filtered, autoPlay: true)
                                            activeRhymeForPlayer = rhyme
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 90) // Spacing for floating dock
                    }
                }
            }
        }
    }
}
