import SwiftUI

/// User preferences and playback settings.
public final class AppSettings: ObservableObject {
    @AppStorage("autoplayNext") public var autoplayNext: Bool = true
    @AppStorage("repeatEnabled") public var repeatEnabled: Bool = false
    @AppStorage("soundEffectsEnabled") public var soundEffectsEnabled: Bool = true
    @AppStorage("reduceMotionPreference") public var reduceMotionPreference: Bool = false

    public static let shared = AppSettings()

    public init() {}

    public let appVersion: String = "1.0.0"
    public let buildNumber: String = "1"
    public let appTitle: String = "Storybook Nursery Rhymes"
    public let aboutDescription: String = """
    A cheerful, wholesome nursery rhymes player crafted with warm storybook illustrations, gentle music, and toddler-friendly controls. Designed for safe, joyful discovery on iPhone and iPad.
    """
}
