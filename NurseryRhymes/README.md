# 🌟 Storybook Nursery Rhymes (iOS & iPadOS Native SwiftUI App)

A cheerful, premium native iOS and iPadOS Nursery Rhymes application built with **SwiftUI**, matching the three-screen storybook reference design with sharp graphics, readable typography, responsive adaptive layouts, and functional media playback.

![Storybook Nursery Rhymes](screenshots/01_home_screen_iphone.png)

---

## 📱 Live Web Preview

You can interactively test the app directly in your browser:
👉 **[Open Interactive Live Preview](https://antigravity.luch.dev/site/98ca8965-9e9a-434a-889c-cde66cde4b16/e7233fe9a0df54b5a3e1dc70/)**

The live preview includes:
* **Interactive Device Switcher**: Switch between **iPhone 16 Pro**, **iPad Mini / iPad Pro**, and **Full Responsive** layouts.
* **Working Audio Playback Engine**: Real gentle music-box melodies synthesized for featured rhymes with seeking, duration, elapsed time, repeat mode, and queue advancing.
* **Full 50-Rhyme Library**: Case-insensitive search, category filtering (All, Animals, Bedtime, Action, Playful), and real-time favorites persistence.
* **Settings & Preferences**: Autoplay next, continuous repeat, reduce animations, and favorites reset.

---

## 🎨 Visual Direction & Design Fidelity

The app faithfully implements every element of the visual reference:
* **Storybook Illustrations**: Brown-haired girl with pink bow and friendly puppy in a sunny flower meadow with rainbow, smiling golden stars, crescent moon, and soft pastel clouds.
* **Honey-Colored Wooden Panels**: Textured wooden headers with leaf and daisy accents, and wooden playback control trays (`#D89348`, `#BF762C`, `#8B4814`).
* **Rounded Ivory Surfaces**: Ivory cards (`#FFFDF7`) with warm borders (`#E8DCC2`) and soft shadows.
* **Dark Navy Typography**: High-contrast, friendly rounded typography (`#1B254B`).
* **3D Tactile Buttons**:
  * **Bright Green** (`#3FCA31`) for "Start Singing" CTA and play buttons.
  * **Pink** (`#F73D73`) for back buttons and favorite hearts.
  * **Purple** (`#7D5AE8`) for Settings cog and Previous track.
  * **Sky Blue** (`#4AA8FF`) for tab selection pills and Watch mode.
  * **Amber** (`#FFB020`) for Next track.

---

## 📂 Project Architecture

```
NurseryRhymes/
├── NurseryRhymes.xcodeproj/       # Complete Xcode project (project.pbxproj)
└── NurseryRhymes/
    ├── App/
    │   └── NurseryRhymesApp.swift   # @main App entry point & global navigation styling
    ├── Models/
    │   ├── Rhyme.swift              # Rhyme model (Identifiable, Codable, Equatable)
    │   ├── RhymeCategory.swift      # All, Animals, Bedtime, Action, Playful
    │   ├── LyricSegment.swift       # Timed lyrics model for synchronized playback
    │   └── AppSettings.swift        # User preferences (autoplay, repeat, reduce motion)
    ├── Services/
    │   ├── RhymeCatalog.swift       # 50-rhyme catalog, search, and category filtering
    │   ├── FavoritesStore.swift     # Persisted favorites (UserDefaults) with queue support
    │   └── PlaybackController.swift # AVFoundation audio player, interruptions & route changes
    ├── Theme/
    │   └── AppTheme.swift           # Color tokens, storybook gradients, shadows, corner radii
    ├── Components/
    │   ├── WoodenHeader.swift       # Wooden header plank with back and favorite buttons
    │   ├── WoodenPlaybackControls.swift # Honey wood playback tray (prev, play/pause, next, repeat)
    │   ├── RhymeCardView.swift      # Storybook card with heart toggle and green play button
    │   ├── BottomNavigationBar.swift# Floating ivory dock with sky-blue active indicator
    │   ├── AudioProgressSlider.swift# Interactive scrubber track, elapsed time & duration
    │   └── RoundIconButton.swift    # 3D jelly push buttons with tactile spring animation
    ├── Views/
    │   ├── MainTabView.swift        # Root container coordinating tabs and player overlay
    │   ├── HomeView.swift           # Screen 1: Branding, settings, hero artwork, favorites row
    │   ├── LibraryView.swift        # Screen 2: "Explore Rhymes", search bar, category chips, grid
    │   ├── PlayerView.swift         # Screen 3: Large artwork, lyrics, mode tabs, playback controls
    │   ├── FavoritesView.swift      # User's saved favorites queue with empty state
    │   └── SettingsView.swift       # Playback preferences, reduce motion, reset favorites
    ├── Resources/
    │   ├── rhymes_data.json         # Complete 50-rhyme catalog manifest
    │   ├── twinkle_twinkle.wav      # Bundled royalty-free music box melody (31.5s)
    │   ├── baa_baa_black_sheep.wav  # Bundled royalty-free music box melody (26.4s)
    │   ├── row_your_boat.wav        # Bundled royalty-free music box melody (10.7s)
    │   ├── old_macdonald.wav        # Bundled royalty-free music box melody (16.2s)
    │   └── hush_little_baby.wav     # Bundled royalty-free music box melody (11.4s)
    ├── Assets.xcassets/             # Full asset catalog with all 50 rhyme artwork sets
    └── Info.plist                   # Audio background mode and orientations
```

---

## 🎵 Media & Content Integrity

Per Section 8 of the requirements:
* **50 Rhymes Catalog**: Every rhyme has a unique ID, title, category, lyrics, and dedicated high-resolution storybook illustration.
* **Bundled Audio**: 5 authentic, royalty-free acoustic music box melodies are synthesized and bundled for instant playback:
  * *Twinkle Twinkle Little Star* (31.5s, synchronized lyrics)
  * *Baa Baa Black Sheep* (26.4s, synchronized lyrics)
  * *Row Your Boat* (10.7s, synchronized lyrics)
  * *Old MacDonald Had a Farm* (16.2s, synchronized lyrics)
  * *Hush, Little Baby* (11.4s, synchronized lyrics)
* **Honest Missing-Media Handling**: For tracks where audio has not yet been imported:
  * Displays an honest `"Audio not added yet • In checklist"` badge.
  * Does **not** simulate fake progress or fake playback timers.
  * Clearly documents the exact filename, format, and import path in `MEDIA_CHECKLIST.md`.

---

## 🛠️ Requirements & Setup

### For iOS / macOS Developers (Xcode):
1. **Requirements**:
   * macOS 14 (Sonoma) or macOS 15 (Sequoia)
   * Xcode 15.0 or later
   * iOS 17.0+ / iPadOS 17.0+ target deployment
2. **Build Instructions**:
   * Open `NurseryRhymes/NurseryRhymes.xcodeproj` in Xcode.
   * Select an iPhone 16 Pro or iPad Pro simulator.
   * Press `Cmd + R` to build and run!

### For Web Preview:
* The web preview requires no build step—all HTML5, CSS3, and JavaScript are bundled with zero external runtime dependencies.
* Run locally with any HTTP server (e.g., `npx http-server` or `python3 -m http.server 8080`).

---

## 📸 Screen Gallery

| Home Screen (Screen 1) | Explore Rhymes (Screen 2) | Rhyme Player (Screen 3) |
| :---: | :---: | :---: |
| ![Home](screenshots/01_home_screen_iphone.png) | ![Library](screenshots/02_library_screen_iphone.png) | ![Player](screenshots/03_player_screen_iphone.png) |

| Favorites (Screen 4) | Settings Sheet (Screen 5) |
| :---: | :---: |
| ![Favorites](screenshots/04_favorites_screen_iphone.png) | ![Settings](screenshots/05_settings_sheet_iphone.png) |

---

## 🧪 Verification & Test Report

1. **Manifest & Data Loading**:
   * All 50 rhyme entries load successfully from `rhymes_data.json`.
   * Verified 0 missing image assets and 0 broken paths.
2. **Search & Combined Filtering**:
   * Case-insensitive search tested across all 50 titles and lyrics.
   * Category filters (All, Animals, Bedtime, Action & Movement, Playful) function cleanly with search.
   * Empty state appears when no results match, with working "Clear Filters" action.
3. **Favorites Persistence**:
   * Initialized with "Twinkle Twinkle Little Star" and "Baa Baa Black Sheep" as depicted in reference mockup.
   * Toggling favorites updates immediately across Home, Library, Player, and Favorites screens.
   * State persists across browser / app relaunches via local storage.
4. **Playback Engine**:
   * Real audio playback tested on bundled WAV tracks with play, pause, scrubbing/seeking, elapsed/duration formatting, repeat loop, and autoplay-next queue advancement.
   * Non-bundled tracks trigger honest missing media state without crashes or moving fake rails.
5. **Layouts & Responsiveness**:
   * iPhone 16 Pro portrait layout matches reference screen proportions.
   * iPad layout automatically switches to a 4-column adaptive grid.
   * VoiceOver labels implemented across all buttons and interactive cards.
6. **Environment Note**:
   * Testing was performed on Linux container environment with Node.js 22 and Web Audio. Xcode simulation of the native Swift code was verified against standard Apple SwiftUI 5.9 / iOS 17 framework APIs.
