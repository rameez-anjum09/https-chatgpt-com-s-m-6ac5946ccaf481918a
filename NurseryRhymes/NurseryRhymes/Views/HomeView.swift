import SwiftUI

/// HomeView recreates Screen 1 in the design reference:
/// Logo with star, purple settings button, hero meadow illustration with girl and puppy,
/// "Sing, play & discover" cloud banner, green "Start Singing" CTA,
/// and "Your favorites" section with responsive cards.
public struct HomeView: View {
    @ObservedObject var catalog: RhymeCatalog
    @ObservedObject var favoritesStore: FavoritesStore
    @ObservedObject var playback: PlaybackController
    @Binding var selectedTab: NavigationTab
    @Binding var activeRhymeForPlayer: Rhyme?
    @State private var showingSettings: Bool = false

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

    public var body: some View {
        ZStack {
            // Background meadow styling
            LinearGradient(
                colors: [
                    Color(red: 215/255, green: 242/255, blue: 255/255),
                    Color(red: 240/255, green: 250/255, blue: 235/255),
                    Color(red: 220/255, green: 245/255, blue: 200/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // MARK: - Top Header Branding & Settings
                    HStack {
                        Spacer()

                        // Nursery Rhymes Logo
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 255/255, green: 215/255, blue: 0/255))
                                .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)

                            Text("Nursery Rhymes")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(AppTheme.darkNavy)
                        }
                        .offset(x: 22) // balance for settings button

                        Spacer()

                        // Purple Settings Button
                        RoundIconButton(
                            iconName: "gearshape.fill",
                            gradient: AppTheme.purpleButtonGradient,
                            size: 44,
                            iconSize: 20,
                            accessibilityLabel: "Settings",
                            action: {
                                showingSettings = true
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                    // MARK: - Hero Meadow Illustration (Girl, Puppy, Rainbow)
                    ZStack(alignment: .bottom) {
                        Image("hero_girl_puppy")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 480)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)

                        // Cloud Banner: "Sing, play & discover"
                        ZStack {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(Color.white.opacity(0.96))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)

                            HStack(spacing: 12) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 255/255, green: 205/255, blue: 40/255))

                                Text("Sing, play & discover")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(AppTheme.darkNavy)

                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 255/255, green: 205/255, blue: 40/255))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        .offset(y: 18)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // MARK: - "Start Singing" Primary CTA Button
                    Button(action: handleStartSinging) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundColor(.white)

                            Text("Start Singing")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(AppTheme.greenButtonGradient)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.6), lineWidth: 2.5)
                        )
                        .shadow(color: Color(red: 45/255, green: 165/255, blue: 35/255).opacity(0.4), radius: 8, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .accessibilityLabel("Start Singing")

                    // MARK: - "Your favorites" Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your favorites")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.darkNavy)
                            .padding(.horizontal, 8)

                        if favoriteRhymes.isEmpty {
                            // Friendly Empty State
                            VStack(spacing: 12) {
                                Image(systemName: "heart.slash")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.pinkAction.opacity(0.7))
                                    .padding(.top, 8)

                                Text("No favorites saved yet!")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.darkNavy)

                                Text("Tap the heart on any rhyme to save it here for quick singing.")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(AppTheme.navySubtle)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)

                                Button(action: {
                                    withAnimation {
                                        selectedTab = .rhymes
                                    }
                                }) {
                                    Text("Explore Rhymes")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(AppTheme.skyBlueGradient)
                                        .clipShape(Capsule())
                                }
                                .padding(.bottom, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.ivoryCard)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(AppTheme.ivoryBorder, lineWidth: 1.5)
                            )
                        } else {
                            // Responsive 2-column favorite cards row
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 14),
                                    GridItem(.flexible(), spacing: 14)
                                ],
                                spacing: 14
                            ) {
                                ForEach(favoriteRhymes.prefix(2)) { rhyme in
                                    RhymeCardView(
                                        rhyme: rhyme,
                                        isFavorite: favoritesStore.isFavorite(id: rhyme.id),
                                        isPlayingThis: playback.currentRhyme?.id == rhyme.id && playback.isPlaying,
                                        onSelect: {
                                            activeRhymeForPlayer = rhyme
                                            playback.loadAndPlay(rhyme: rhyme, queue: favoriteRhymes, autoPlay: true)
                                        },
                                        onToggleFavorite: {
                                            favoritesStore.toggleFavorite(id: rhyme.id)
                                        },
                                        onPlayAction: {
                                            if playback.currentRhyme?.id == rhyme.id {
                                                playback.togglePlayPause()
                                            } else {
                                                playback.loadAndPlay(rhyme: rhyme, queue: favoriteRhymes, autoPlay: true)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(AppTheme.ivoryDock.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.ivoryBorder, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 16)

                    // Spacing for floating bottom bar
                    Spacer().frame(height: 80)
                }
                .padding(.top, 8)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(favoritesStore: favoritesStore)
        }
    }

    private func handleStartSinging() {
        if let current = playback.currentRhyme, current.hasAudio {
            activeRhymeForPlayer = current
            playback.play()
        } else if let firstPlayable = catalog.rhymes.first(where: { $0.hasAudio }) {
            activeRhymeForPlayer = firstPlayable
            playback.loadAndPlay(rhyme: firstPlayable, queue: catalog.rhymes, autoPlay: true)
        } else {
            // Open library
            withAnimation {
                selectedTab = .rhymes
            }
        }
    }
}
