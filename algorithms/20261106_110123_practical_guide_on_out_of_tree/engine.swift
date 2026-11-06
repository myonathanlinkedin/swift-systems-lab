public struct ChronosTree<Value> {
    // Stored as a sorted array of non‑overlapping intervals
    public var intervals: [(interval: TimeInterval, value: Value)] = []

    public init() {}

    // Insert a new interval/value pair.
    // The method aborts with fatalError if the new interval overlaps an existing one.
    public mutating func insert(interval: TimeInterval, value: Value) {
        // Binary search for insertion index
        var lo = 0
        var hi = intervals.count
        while lo < hi {
            let mid = (lo + hi) / 2
            if intervals[mid].interval < interval {
                lo = mid + 1
            } else {
                hi = mid
            }
        }

        // Overlap checks (strictly non‑overlapping)
        if lo > 0 {
            let left = intervals[lo - 1].interval
            if left.end >= interval.start {
                fatalError("Overlapping intervals are not allowed (conflict with left neighbor).")
            }
        }
        if lo < intervals.count {
            let right = intervals[lo].interval
            if right.start <= interval.end {
                fatalError("Overlapping intervals are not allowed (conflict with right neighbor).")
            }
        }

        intervals.insert((interval, value), at: lo)
    }

    // Query a point in time.
    // Returns the exact value if the point lies inside an interval.
    // If the point is out of any interval, the nearest interval's value is returned.
    // If the tree is empty, nil is returned.
    public func query(_ point: Int) -> Value? {
        guard !intervals.isEmpty else { return nil }

        // Binary search for an interval that contains the point
        var lo = 0
        var hi = intervals.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            let iv = intervals[mid].interval
            if iv.contains(point) {
                return intervals[mid].value
            } else if point < iv.start {
                hi = mid - 1
            } else {
                lo = mid + 1
            }
        }

        // Out‑of‑tree mitigation: find the nearest interval (left or right)
        var nearestIdx: Int? = nil
        var nearestDist = Int.max

        // Left neighbor (hi is the last index with interval.start < point)
        if hi >= 0 {
            let left = intervals[hi]
            let dist = point - left.interval.end   // distance to the right edge
            if dist >= 0 && dist < nearestDist {
                nearestDist = dist
                nearestIdx = hi
            }
        }

        // Right neighbor (lo is the first index with interval.start > point)
        if lo < intervals.count {
            let right = intervals[lo]
            let dist = right.interval.start - point   // distance to the left edge
            if dist >= 0 && dist < nearestDist {
                nearestDist = dist
                nearestIdx = lo
            }
        }

        if let idx = nearestIdx {
            return intervals[idx].value
        }
        return nil
    }
}
