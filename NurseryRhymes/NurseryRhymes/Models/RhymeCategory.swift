import Foundation

/// Nursery rhyme categories for discovery and filtering.
public enum RhymeCategory: String, CaseIterable, Identifiable, Codable {
    case all = "All"
    case animals = "Animals"
    case bedtime = "Bedtime"
    case action = "Action & Movement"
    case playful = "Playful"

    public var id: String { rawValue }

    public var displayName: String { rawValue }

    public var iconName: String {
        switch self {
        case .all: return "sparkles"
        case .animals: return "pawprint.fill"
        case .bedtime: return "moon.stars.fill"
        case .action: return "figure.dance"
        case .playful: return "face.smiling.fill"
        }
    }
}
