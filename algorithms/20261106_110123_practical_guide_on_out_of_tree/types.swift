public struct TimeInterval: Comparable, Equatable {
    public var start: Int
    public var end: Int   // inclusive bounds

    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }

    // Comparable: order by start, then by end
    public static func < (lhs: TimeInterval, rhs: TimeInterval) -> Bool {
        if lhs.start != rhs.start {
            return lhs.start < rhs.start
        }
        return lhs.end < rhs.end
    }

    // Equatable: field‑by‑field equality
    public static func == (lhs: TimeInterval, rhs: TimeInterval) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }

    // Helper: does the interval contain a point?
    public func contains(_ point: Int) -> Bool {
        return point >= start && point <= end
    }
}
