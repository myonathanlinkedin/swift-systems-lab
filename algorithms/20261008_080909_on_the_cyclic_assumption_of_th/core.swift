import Foundation

/// Simulates the classic Cow‑Path search on an infinite line.
/// The searcher starts at position 0, does not know the direction of the target,
/// and alternates directions while doubling the travel distance each turn.
///
/// The algorithm guarantees that the total distance travelled is at most 9 × |target|.
public struct CowPathSearch {
    /// The (signed) integer position of the hidden target.
    public var target: Int

    /// Result of a simulation run.
    public struct Result {
        /// Total distance walked until the target is reached.
        public var totalDistance: Int
        /// Number of full legs (complete moves before the final partial leg) performed.
        public var fullLegs: Int
        /// The competitive ratio `totalDistance / optimalDistance` (optimal = |target|, 0 → 0).
        public var competitiveRatio: Double
    }

    /// Runs the search simulation and returns a `Result`.
    /// - Returns: The simulation outcome.
    public func run() -> Result {
        // Trivial case: target already at origin.
        if target == 0 {
            return Result(totalDistance: 0, fullLegs: 0, competitiveRatio: 0.0)
        }

        var position = 0               // Current location.
        var total = 0                  // Accumulated distance.
        var step = 1                   // Length of the next leg.
        var direction = 1              // 1 = right, -1 = left.
        var legs = 0                   // Count of completed full legs.

        while true {
            let nextPos = position + direction * step

            // Check whether the target lies on the segment from `position` to `nextPos`.
            // The product being ≤ 0 means the target is between (inclusive).
            if (target - position) * (target - nextPos) <= 0 {
                // Final partial leg: only walk the needed distance.
                total += abs(target - position)
                break
            } else {
                // Full leg: walk the whole step.
                total += step
                position = nextPos
                direction *= -1          // Reverse direction.
                step *= 2                // Double the step length.
                legs += 1
            }
        }

        let optimal = abs(target)
        let ratio = optimal == 0 ? 0.0 : Double(total) / Double(optimal)

        return Result(totalDistance: total, fullLegs: legs, competitiveRatio: ratio)
    }
}
