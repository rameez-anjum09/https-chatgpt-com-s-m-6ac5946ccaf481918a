import SwiftUI

/// PlayerView recreates Screen 3 in the design reference:
/// Wooden header with back navigation and favorite heart, large rounded artwork area,
/// full title and lyrics, Watch/Lyrics mode toggle, real elapsed & duration seek bar,
/// wooden playback panel (prev, play/pause, next, repeat), and "More Rhymes" button.
public struct PlayerView: View {
    let rhyme: Rhyme
    @ObservedObject var playback: PlaybackController
    @ObservedObject var favoritesStore: FavoritesStore
    @Binding var activeRhymeForPlayer: Rhyme?
    @Binding var selectedTab: NavigationTab

    @Environment(\.presentationMode) var presentationMode

    public init(
        rhyme: Rhyme,
        playback: PlaybackController,
        favoritesStore: FavoritesStore,
        activeRhymeForPlayer: Binding<Rhyme?>,
        selectedTab: Binding<NavigationTab>
    ) {
        self.rhyme = rhyme
        self.playback = playback
        self.favoritesStore = favoritesStore
        self._activeRhymeForPlayer = activeRhymeForPlayer
        self._selectedTab = selectedTab
    }

    private var activeRhyme: Rhyme {
        playback.currentRhyme ?? rhyme
    }

    private var isFavorite: Bool {
        favoritesStore.isFavorite(id: activeRhyme.id)
    }

    public var body: some View {
        ZStack {
            // Background with soft pastel gradients and meadow flora
            LinearGradient(
                colors: [
                    Color(red: 254/255, green: 249/255, blue: 238/255),
                    Color(red: 255/255, green: 253/255, blue: 245/255),
                    Color(red: 235/255, green: 247/255, blue: 228/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // MARK: - 1. Wooden Header
                WoodenHeader(
                    title: activeRhyme.title.components(separatedBy: " ").prefix(2).joined(separator: " "),
                    onBack: {
                        activeRhymeForPlayer = nil
                    },
                    trailingContent: AnyView(
                        RoundIconButton(
                            iconName: isFavorite ? "heart.fill" : "heart",
                            gradient: AppTheme.pinkButtonGradient,
                            size: 44,
                            iconSize: 20,
                            accessibilityLabel: isFavorite ? "Remove favorite" : "Add favorite",
                            action: {
                                favoritesStore.toggleFavorite(id: activeRhyme.id)
                            }
                        )
                    )
                )
                .padding(.top, 4)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        // MARK: - 2. Large Rounded Artwork Area
                        ZStack(alignment: .bottom) {
                            Image(activeRhyme.fullAssetName ?? activeRhyme.assetName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 480)
                                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.14), radius: 10, x: 0, y: 5)

                            // Missing Audio Banner (Honest State)
                            if !activeRhyme.hasAudio {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(AppTheme.amberAction)
                                    Text("Audio not added yet • See media checklist")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.darkNavy)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.92))
                                .clipShape(Capsule())
                                .padding(.bottom, 12)
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - 3. Full Title
                        Text(activeRhyme.title)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.darkNavy)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        // MARK: - 4. Lyrics Preview Area
                        if playback.displayMode == .watch {
                            VStack(spacing: 6) {
                                let preview = activeRhyme.previewLyrics
                                Text(preview.line1)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.darkNavy)

                                if !preview.line2.isEmpty {
                                    Text(preview.line2)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppTheme.darkNavy)
                                }
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 4)
                        } else {
                            // Full Scrollable Lyrics Mode
                            VStack(spacing: 8) {
                                if let lyrics = activeRhyme.lyrics {
                                    ForEach(lyrics.components(separatedBy: "\n"), id: \.self) { line in
                                        if !line.isEmpty {
                                            Text(line)
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(AppTheme.darkNavy)
                                        } else {
                                            Spacer().frame(height: 4)
                                        }
                                    }
                                } else {
                                    Text("Lyrics coming soon!")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(AppTheme.navySubtle)
                                }
                            }
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .background(AppTheme.ivoryCard)
                            .cornerRadius(18)
                            .padding(.horizontal, 20)
                        }

                        // MARK: - 5. Segmented Mode Tabs (Watch / Lyrics)
                        HStack(spacing: 12) {
                            // Watch Tab
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    playback.displayMode = .watch
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 15, weight: .bold))
                                    Text("Watch")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(playback.displayMode == .watch ? .white : AppTheme.darkNavy)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(
                                    playback.displayMode == .watch ?
                                    AnyView(AppTheme.skyBlueGradient) : AnyView(Color.white)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(playback.displayMode == .watch ? Color.white.opacity(0.3) : AppTheme.ivoryBorder, lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(playback.displayMode == .watch ? 0.12 : 0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Lyrics Tab
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    playback.displayMode = .lyrics
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 15, weight: .bold))
                                    Text("Lyrics")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(playback.displayMode == .lyrics ? .white : AppTheme.darkNavy)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                                .background(
                                    playback.displayMode == .lyrics ?
                                    AnyView(AppTheme.skyBlueGradient) : AnyView(Color.white)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(playback.displayMode == .lyrics ? Color.white.opacity(0.3) : AppTheme.ivoryBorder, lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(playback.displayMode == .lyrics ? 0.12 : 0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)

                        // MARK: - 6. Elapsed Time, Slider Rail, Duration
                        AudioProgressSlider(
                            currentTime: playback.currentTime,
                            duration: playback.duration > 0 ? playback.duration : activeRhyme.audioDuration,
                            isEnabled: activeRhyme.hasAudio,
                            onSeek: { targetTime in
                                playback.seek(to: targetTime)
                            }
                        )

                        // MARK: - 7. Wooden Playback Controls Panel
                        WoodenPlaybackControls(
                            isPlaying: playback.isPlaying,
                            isRepeatEnabled: playback.isRepeatEnabled,
                            isEnabled: activeRhyme.hasAudio,
                            onPrevious: {
                                playback.previousTrack()
                            },
                            onPlayPause: {
                                playback.togglePlayPause()
                            },
                            onNext: {
                                playback.nextTrack()
                            },
                            onToggleRepeat: {
                                playback.toggleRepeat()
                            }
                        )
                        .padding(.top, 4)

                        // MARK: - 8. "More Rhymes" Bottom Button
                        Button(action: {
                            activeRhymeForPlayer = nil
                            selectedTab = .rhymes
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.darkNavy)

                                Text("More Rhymes")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.darkNavy)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .heavy))
                                    .foregroundColor(AppTheme.darkNavy)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.ivoryCard)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.ivoryBorder, lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}
