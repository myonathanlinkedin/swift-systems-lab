import Foundation

// MARK: - Mock size functions (deterministic, monotonic decreasing)

/// Linear relationship: size = 2000 − 10 × quality
func linearSize(quality: Int) -> Int {
    return 2000 - quality * 10
}

/// Quadratic relationship: size = 3000 − quality²
func quadraticSize(quality: Int) -> Int {
    return 3000 - quality * quality
}

// MARK: - Unit‑test suite

struct JPEGQualitySearcherTests {
    static func runAll() {
        testLinearExactMatch()
        testLinearWithTolerance()
        testLinearNoExactMatch()
        testLinearOutOfBoundsHigh()
        testLinearOutOfBoundsLow()
        testQuadraticExactMatch()
        testQuadraticBestQualityPreference()
        print("All JPEGQualitySearcher tests passed.")
    }

    // Helper to assert optional equality.
    private static func assertEqual<T: Equatable>(_ lhs: T?, _ rhs: T?, _ message: String = "") {
        assert(lhs == rhs, message.isEmpty ? "Assertion failed: \(String(describing: lhs)) != \(String(describing: rhs))" : message)
    }

    // MARK: Test Cases

    private static func testLinearExactMatch() {
        let searcher = JPEGQualitySearcher(sizeForQuality: linearSize)
        // size = 2000 - 10*q ; target 1500 → q = 50
        let result = searcher.search(targetSize: 1500)
        assertEqual(result, 50, "Linear exact match failed")
    }

    private static func testLinearWithTolerance() {
        let searcher = JPEGQualitySearcher(sizeForQuality: linearSize)
        // Target 1495 with tolerance 5 → size 1500 (q=50) is acceptable.
        let result = searcher.search(targetSize: 1495, tolerance: 5)
        assertEqual(result, 50, "Linear with tolerance failed")
    }

    private static func testLinearNoExactMatch() {
        let searcher = JPEGQualitySearcher(sizeForQuality: linearSize)
        // Target 1499 cannot be hit exactly with step size 10.
        let result = searcher.search(targetSize: 1499)
        assertEqual(result, nil, "Linear no exact match should be nil")
    }

    private static func testLinearOutOfBoundsHigh() {
        let searcher = JPEGQualitySearcher(sizeForQuality: linearSize)
        // Maximum size at quality 0 is 2000. Anything larger is impossible.
        let result = searcher.search(targetSize: 2100)
        assertEqual(result, nil, "Linear out‑of‑bounds high should be nil")
    }

    private static func testLinearOutOfBoundsLow() {
        let searcher = JPEGQualitySearcher(sizeForQuality: linearSize)
        // Minimum size at quality 100 is 2000 - 1000 = 1000.
        let result = searcher.search(targetSize: 900)
        assertEqual(result, nil, "Linear out‑of‑bounds low should be nil")
    }

    private static func testQuadraticExactMatch() {
        let searcher = JPEGQualitySearcher(sizeForQuality: quadraticSize)
        // size = 3000 - q² ; target 2600 → q² = 400 → q = 20
        let result = searcher.search(targetSize: 2600)
        assertEqual(result, 20, "Quadratic exact match failed")
    }

    private static func testQuadraticBestQualityPreference() {
        let searcher = JPEGQualitySearcher(sizeForQuality: quadraticSize)
        // target 2590, tolerance 10 → both q=20 (size 2600) and q=21 (size 2559) are within tolerance.
        // The algorithm should return the higher quality (21).
        let result = searcher.search(targetSize: 2590, tolerance: 10)
        assertEqual(result, 21, "Quadratic best‑quality preference failed")
    }
}

// MARK: - Entry point

JPEGQualitySearcherTests.runAll()
