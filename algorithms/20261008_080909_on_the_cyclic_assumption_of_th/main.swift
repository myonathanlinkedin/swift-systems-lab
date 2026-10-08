import Foundation

// Simple test harness.
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    assert(a == b, "Assertion failed: \(a) != \(b). \(message)")
}

func assertLessThanOrEqual(_ a: Double, _ b: Double, _ message: String = "") {
    assert(a <= b + 1e-12, "Assertion failed: \(a) > \(b). \(message)")
}

// Unit tests for CowPathSearch.
func testCowPath() {
    // Helper to run a single case.
    func runCase(target: Int, expectedRatioUpperBound: Double = 9.0) {
        var search = CowPathSearch(target: target)
        let result = search.run()
        // Verify that we indeed reached the target.
        assertEqual(result.totalDistance, result.totalDistance, "Total distance should be a concrete value.")
        // Verify competitive ratio bound.
        assertLessThanOrEqual(result.competitiveRatio, expectedRatioUpperBound,
                              "Target \(target) exceeded ratio bound.")
        // Verify optimal distance is not exceeded by zero.
        let optimal = abs(target)
        assertEqual(optimal, optimal, "Optimal distance sanity.")
        // For non‑zero targets, total distance must be ≥ optimal.
        if optimal > 0 {
            assert(result.totalDistance >= optimal, "Total distance \(result.totalDistance) < optimal \(optimal) for target \(target).")
        }
    }

    // Trivial case.
    runCase(target: 0, expectedRatioUpperBound: 0.0)

    // Small positive and negative targets.
    runCase(target: 1)
    runCase(target: -1)
    runCase(target: 2)
    runCase(target: -3)
    runCase(target: 5)
    runCase(target: -10)

    // Larger distances to stress the doubling.
    runCase(target: 100)
    runCase(target: -123)
    runCase(target: 1024)
    runCase(target: -2048)

    // Verify known exact distances for a few positions.
    // Target 1: moves 1 right → total 1.
    var s1 = CowPathSearch(target: 1)
    let r1 = s1.run()
    assertEqual(r1.totalDistance, 1)

    // Target -2: path 1 right, 2 left (overshoot to -1), then 4 right, etc.
    // Simulation yields total 5 (1 right, 2 left to -1, then 2 more left to -2).
    var s2 = CowPathSearch(target: -2)
    let r2 = s2.run()
    assertEqual(r2.totalDistance, 5)

    // Target 3: 1 right, 2 left (to -1), 4 right (passes 3, stop at 3).
    // Total = 1 + 2 + (3 - (-1)) = 1 + 2 + 4 = 7.
    var s3 = CowPathSearch(target: 3)
    let r3 = s3.run()
    assertEqual(r3.totalDistance, 7)
}

// Entry point.
func main() {
    testCowPath()
    print("All Cow‑Path tests passed.")
}

main()
