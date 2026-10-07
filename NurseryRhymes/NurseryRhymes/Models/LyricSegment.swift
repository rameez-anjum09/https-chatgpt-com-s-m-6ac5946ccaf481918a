import Foundation

/// Timed lyric segment for synchronized playback and karaoke highlighting.
public struct LyricSegment: Identifiable, Codable, Equatable, Hashable {
    public var id: String { "\(start)-\(end)" }
    public let start: TimeInterval
    public let end: TimeInterval
    public let text: String

    public init(start: TimeInterval, end: TimeInterval, text: String) {
        self.start = start
        self.end = end
        self.text = text
    }

    public func isActive(at time: TimeInterval) -> Bool {
        return time >= start && time < end
    }
}
