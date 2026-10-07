import Foundation
import SwiftUI
import Combine

/// FavoritesStore manages persisted favorite rhyme identifiers.
public final class FavoritesStore: ObservableObject {
    @Published public private(set) var favoriteIds: Set<String> = []

    private let storageKey = "storybook_favorite_rhyme_ids"
    public static let shared = FavoritesStore()

    public init() {
        loadFavorites()
    }

    private func loadFavorites() {
        if let saved = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            self.favoriteIds = Set(saved)
        } else {
            // Default initial favorites matching the reference design:
            // "Twinkle Twinkle Little Star" and "Baa Baa Black Sheep"
            self.favoriteIds = ["twinkle_twinkle", "baa_baa_black_sheep"]
            saveFavorites()
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: storageKey)
    }

    public func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }

    public func toggleFavorite(id: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            if favoriteIds.contains(id) {
                favoriteIds.remove(id)
            } else {
                favoriteIds.insert(id)
            }
            saveFavorites()
        }
    }

    public func setFavorite(id: String, isFav: Bool) {
        if isFav {
            favoriteIds.insert(id)
        } else {
            favoriteIds.remove(id)
        }
        saveFavorites()
    }

    public func resetFavorites() {
        withAnimation {
            favoriteIds.removeAll()
            saveFavorites()
        }
    }

    /// Retrieve full Rhyme models for favorites in display order
    public func favoriteRhymes(from catalog: [Rhyme]) -> [Rhyme] {
        catalog.filter { favoriteIds.contains($0.id) }
    }
}
