import Foundation

public struct Canvas {
    public var version: Int = 0
    // History maps a point to a chronologically ordered list of (version, color)
    public var history: [Point: [(Int, Color)]] = [:]

    public init() {}

    // Draw a color at a point, advancing the global version.
    // Returns the new version number.
    public mutating func draw(at point: Point, color: Color) -> Int {
        version += 1
        var entries = history[point] ?? []
        entries.append((version, color))
        history[point] = entries
        return version
    }

    // Retrieve the color of a point at a specific version.
    // Returns nil if the point had never been painted up to that version.
    public func color(at point: Point, version queryVersion: Int) -> Color? {
        guard let entries = history[point] else { return nil }
        // Binary search for the latest entry whose version <= queryVersion
        var low = 0
        var high = entries.count - 1
        var result: Color? = nil
        while low <= high {
            let mid = (low + high) / 2
            let (v, c) = entries[mid]
            if v == queryVersion {
                return c
            } else if v < queryVersion {
                result = c
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return result
    }

    // Revert the canvas to a previous version, discarding later history.
    public mutating func revert(to targetVersion: Int) {
        for (point, entries) in history {
            let filtered = entries.filter { $0.0 <= targetVersion }
            if filtered.isEmpty {
                history[point] = nil
            } else {
                history[point] = filtered
            }
        }
        version = targetVersion
    }
}
