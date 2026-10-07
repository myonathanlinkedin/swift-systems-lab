import Foundation

// Simple linear model: size = base - quality * factor, clamped to non‑negative.
func linearSizeModel(base: Int, factor: Int) -> (Int) -> Int {
    return { quality in
        let size = base - quality * factor
        return max(size, 0)
    }
}

// Unit test helpers
func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    assert(lhs == rhs, "Assertion failed: \(lhs) != \(rhs). \(message)")
}

func testExactMatch() {
    let finder = JPEGQualityFinder()
    let sizeForQuality = linearSizeModel(base: 5000, factor: 30) // size decreases 30 bytes per quality step
    
    // Target size that exists (quality 50 => 5000 - 1500 = 3500)
    let target = 3500
    let expectedQuality = 50
    let found = finder.findExactQuality(targetSize: target, sizeForQuality: sizeForQuality)
    assertEqual(found, expectedQuality, "Exact match should be found.")
    
    // Target size that does NOT exist (e.g., 3520)
    let missingTarget = 3520
    let missingFound = finder.findExactQuality(targetSize: missingTarget, sizeForQuality: sizeForQuality)
    assertEqual(missingFound, nil, "No exact match should be returned.")
}

func testBestFit() {
    let finder = JPEGQualityFinder()
    let sizeForQuality = linearSizeModel(base: 8000, factor: 45)
    
    // Target size exactly matches quality 60 (8000 - 2700 = 5300)
    let exactTarget = 5300
    let exactQuality = finder.findBestFitQuality(targetSize: exactTarget, sizeForQuality: sizeForQuality)
    assertEqual(exactQuality, 60, "Exact match should be returned.")
    
    // Target size between qualities 62 (8000-2790=5210) and 63 (8000-2835=5165)
    let betweenTarget = 5180
    let bestQuality = finder.findBestFitQuality(targetSize: betweenTarget, sizeForQuality: sizeForQuality)
    // 62 yields 5210 > target, so we need lower quality (larger size) → quality 63 gives 5165 ≤ target
    assertEqual(bestQuality, 63, "Best fit quality should be the highest quality not exceeding target.")
    
    // Target larger than max size (quality 0)
    let hugeTarget = 9000
    let hugeQuality = finder.findBestFitQuality(targetSize: hugeTarget, sizeForQuality: sizeForQuality)
    assertEqual(hugeQuality, 0, "When target exceeds max size, return quality 0.")
    
    // Target smaller than min size (quality 100)
    let tinyTarget = 0
    let tinyQuality = finder.findBestFitQuality(targetSize: tinyTarget, sizeForQuality: sizeForQuality)
    assertEqual(tinyQuality, 100, "When target is zero, return highest quality that yields size 0.")
}

func testMonotonicityAssumption() {
    // Non‑monotonic closure should still behave, but result is undefined.
    // This test ensures the algorithm does not crash.
    let finder = JPEGQualityFinder()
    let nonMonotonic: (Int) -> Int = { q in
        // Size wiggles: larger quality sometimes larger size, sometimes smaller.
        return 1000 - ((q * q) % 200)
    }
    let _ = finder.findBestFitQuality(targetSize: 800, sizeForQuality: nonMonotonic)
    // No assertion needed; just ensure no runtime error.
}

// Entry point
func main() {
    testExactMatch()
    testBestFit()
    testMonotonicityAssumption()
    print("All tests passed.")
}

main()
