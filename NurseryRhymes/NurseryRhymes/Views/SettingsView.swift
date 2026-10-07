import SwiftUI

/// SettingsView manages autoplay, repeat mode, reduce motion, reset favorites, and about details.
public struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var favoritesStore: FavoritesStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResetAlert = false

    public init(favoritesStore: FavoritesStore) {
        self.favoritesStore = favoritesStore
    }

    public var body: some View {
        NavigationView {
            ZStack {
                AppTheme.warmIvoryBg
                    .ignoresSafeArea()

                Form {
                    // Playback Section
                    Section(header: Text("Playback Preferences").font(.system(size: 14, weight: .bold, design: .rounded))) {
                        Toggle(isOn: $settings.autoplayNext) {
                            HStack(spacing: 12) {
                                Image(systemName: "forward.end.circle.fill")
                                    .foregroundColor(AppTheme.brightGreen)
                                Text("Autoplay Next Rhyme")
                                    .font(.system(size: 16, design: .rounded))
                            }
                        }

                        Toggle(isOn: $settings.repeatEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "repeat.circle.fill")
                                    .foregroundColor(AppTheme.pinkAction)
                                Text("Continuous Repeat")
                                    .font(.system(size: 16, design: .rounded))
                            }
                        }

                        Toggle(isOn: $settings.soundEffectsEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.wave.2.circle.fill")
                                    .foregroundColor(AppTheme.skyBlue)
                                Text("Sound Effects")
                                    .font(.system(size: 16, design: .rounded))
                            }
                        }
                    }

                    // Accessibility & Polish Section
                    Section(header: Text("Appearance & Motion").font(.system(size: 14, weight: .bold, design: .rounded))) {
                        Toggle(isOn: $settings.reduceMotionPreference) {
                            HStack(spacing: 12) {
                                Image(systemName: "figure.walk.motion")
                                    .foregroundColor(AppTheme.purpleAction)
                                Text("Reduce Animations")
                                    .font(.system(size: 16, design: .rounded))
                            }
                        }
                    }

                    // Data Management Section
                    Section(header: Text("Favorites Management").font(.system(size: 14, weight: .bold, design: .rounded))) {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                                Text("Reset Saved Favorites")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                        }
                    }

                    // About & Version Section
                    Section(header: Text("About").font(.system(size: 14, weight: .bold, design: .rounded))) {
                        HStack {
                            Text("Application")
                                .font(.system(size: 15, design: .rounded))
                            Spacer()
                            Text(settings.appTitle)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.navySubtle)
                        }

                        HStack {
                            Text("Version")
                                .font(.system(size: 15, design: .rounded))
                            Spacer()
                            Text("\(settings.appVersion) (\(settings.buildNumber))")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(AppTheme.navySubtle)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Storybook Quality Promise")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.darkNavy)

                            Text(settings.aboutDescription)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(AppTheme.navySubtle)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.purpleAction)
                }
            }
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset Favorites?"),
                    message: Text("Are you sure you want to remove all saved favorites?"),
                    primaryButton: .destructive(Text("Reset")) {
                        favoritesStore.resetFavorites()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
