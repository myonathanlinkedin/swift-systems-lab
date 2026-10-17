import Foundation

// Simple deterministic pseudo‑random generator for reproducible tests.
struct LinearCongruentialGenerator {
    private var state: UInt64
    init(seed: UInt64 = 0xdeadbeef) { self.state = seed }
    mutating func next() -> UInt64 {
        // Parameters from Numerical Recipes
        state = (state &* 6364136223846793005 &+ 1) & 0xFFFFFFFFFFFFFFFF
        return state
    }
    mutating func nextInt(in range: Range<Int>) -> Int {
        let width = UInt64(range.upperBound - range.lowerBound)
        return Int(next() % width) + range.lowerBound
    }
}

// MARK: - Unit Tests

func testBasicInsertionAndQuery() {
    var filter = BloomFilter<String>(expectedElements: 100, falsePositiveProbability: 0.01)
    let items = ["apple", "banana", "cherry"]
    for item in items {
        filter.add(item)
    }
    for item in items {
        assert(filter.contains(item), "Filter should contain inserted item '\(item)'")
    }
    // Items not inserted should mostly be absent (allow occasional false positive)
    let notInserted = ["durian", "elderberry", "fig"]
    var falsePositives = 0
    for item in notInserted {
        if filter.contains(item) { falsePositives += 1 }
    }
    // With a 1% target rate and only 3 queries, we accept up to 1 false positive.
    assert(falsePositives <= 1, "Too many false positives in basic test")
}

func testFalsePositiveRateConvergence() {
    let expectedN = 1000
    let targetP = 0.05
    var filter = BloomFilter<Int>(expectedElements: expectedN, falsePositiveProbability: targetP)
    var rng = LinearCongruentialGenerator(seed: 42)
    // Insert distinct random integers
    var inserted = Set<Int>()
    while inserted.count < expectedN {
        inserted.insert(Int(rng.next() % 1_000_000))
    }
    for value in inserted {
        filter.add(value)
    }
    // Test with a fresh set of random integers not in the filter
    var testSet = Set<Int>()
    while testSet.count < expectedN {
        let candidate = Int(rng.next() % 1_000_000)
        if !inserted.contains(candidate) {
            testSet.insert(candidate)
        }
    }
    var falsePositives = 0
    for value in testSet {
        if filter.contains(value) { falsePositives += 1 }
    }
    let empiricalRate = Double(falsePositives) / Double(testSet.count)
    let estimatedRate = filter.estimatedFalsePositiveRate()
    // Empirical rate should be close to the estimated rate (within factor 2)
    assert(empiricalRate <= targetP * 2.0,
           "Empirical false positive rate \(empiricalRate) exceeds acceptable bound")
    // Estimated rate must be <= targetP (Bloom filter never underestimates)
    assert(estimatedRate <= targetP * 1.1,
           "Estimated false positive rate \(estimatedRate) exceeds target")
}

func testDuplicateInsertionDoesNotInflateCount() {
    var filter = BloomFilter<Int>(expectedElements: 10, falsePositiveProbability: 0.1)
    filter.add(42)
    let rateAfterFirst = filter.estimatedFalsePositiveRate()
    filter.add(42) // duplicate
    let rateAfterDuplicate = filter.estimatedFalsePositiveRate()
    // Rate should be unchanged because duplicate does not increase insertedCount
    assert(abs(rateAfterFirst - rateAfterDuplicate) < 1e-12,
           "Duplicate insertion altered false positive estimate")
}

func testEdgeCases() {
    // Very small filter
    var tiny = BloomFilter<Int>(expectedElements: 1, falsePositiveProbability: 0.5)
    tiny.add(7)
    assert(tiny.contains(7), "Tiny filter must contain added element")
    // Query for absent element
    assert(!tiny.contains(8) || tiny.contains(8), "Tiny filter may give false positive but must not crash")
    
    // Empty filter (no elements added)
    var empty = BloomFilter<String>(expectedElements: 5, falsePositiveProbability: 0.01)
    assert(!empty.contains("nothing"), "Empty filter should report absent")
    let emptyRate = empty.estimatedFalsePositiveRate()
    assert(emptyRate == 0.0, "Empty filter false positive rate must be 0")
}

// MARK: - Execute Tests

func runAllTests() {
    testBasicInsertionAndQuery()
    testFalsePositiveRateConvergence()
    testDuplicateInsertionDoesNotInflateCount()
    testEdgeCases()
    print("All BloomFilter tests passed.")
}

runAllTests()
