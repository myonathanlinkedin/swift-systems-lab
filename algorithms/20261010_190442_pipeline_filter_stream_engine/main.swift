import Foundation

// Helper to generate a deterministic pseudo‑random UInt64 sequence.
struct SimpleRNG {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        // Xorshift64*
        var x = state
        x ^= x >> 12
        x ^= x << 25
        x ^= x >> 27
        state = x
        return x &* 2685821657736338717
    }
}

// Unit Test Suite
func testInitialization() {
    let filter = BloomFilter(expectedElements: 1000, falsePositiveRate: 0.01)
    assert(filter.size > 0, "Filter size must be positive")
    assert(filter.hashCount > 0, "Hash count must be positive")
    // Expected theoretical size ~ 9585 bits, k ~ 7
    assert(filter.size >= 9000 && filter.size <= 12000, "Size out of expected range")
    assert(filter.hashCount >= 5 && filter.hashCount <= 10, "Hash count out of expected range")
}

func testBasicInsertionAndQuery() {
    var filter = BloomFilter(expectedElements: 500, falsePositiveRate: 0.05)
    // Insert numbers 0…499
    for i in 0..<500 {
        filter.add(UInt64(i))
    }
    // All inserted elements must be reported as present
    for i in 0..<500 {
        assert(filter.mightContain(UInt64(i)), "Inserted element \(i) reported absent")
    }
    // Elements far outside the inserted range should mostly be absent
    var falsePositives = 0
    let trials = 10_000
    for i in 500..<(500 + trials) {
        if filter.mightContain(UInt64(i)) {
            falsePositives += 1
        }
    }
    let observedRate = Double(falsePositives) / Double(trials)
    // Allow a small margin above the target 5% false‑positive rate
    assert(observedRate < 0.08, "Observed false‑positive rate \(observedRate) exceeds tolerance")
}

func testDuplicateInsertion() {
    var filter = BloomFilter(expectedElements: 100, falsePositiveRate: 0.1)
    let element: UInt64 = 42
    filter.add(element)
    filter.add(element) // duplicate should not corrupt state
    assert(filter.mightContain(element), "Element missing after duplicate insertion")
}

func testRandomizedElements() {
    var rng = SimpleRNG(seed: 0xDEADBEEF)
    var filter = BloomFilter(expectedElements: 2000, falsePositiveRate: 0.02)
    var inserted = Set<UInt64>()
    // Insert 2000 random distinct elements
    while inserted.count < 2000 {
        let val = rng.next()
        if !inserted.contains(val) {
            inserted.insert(val)
            filter.add(val)
        }
    }
    // Verify all inserted elements are reported present
    for val in inserted {
        assert(filter.mightContain(val), "Randomly inserted element missing")
    }
    // Estimate false‑positive rate on 20 000 fresh random values
    var falsePos = 0
    let checks = 20_000
    for _ in 0..<checks {
        let candidate = rng.next()
        if inserted.contains(candidate) { continue } // skip true positives
        if filter.mightContain(candidate) { falsePos += 1 }
    }
    let rate = Double(falsePos) / Double(checks)
    assert(rate < 0.04, "Random test false‑positive rate \(rate) exceeds tolerance")
}

// Execute tests
func runAllTests() {
    testInitialization()
    testBasicInsertionAndQuery()
    testDuplicateInsertion()
    testRandomizedElements()
    print("All BloomFilter tests passed.")
}

runAllTests()
