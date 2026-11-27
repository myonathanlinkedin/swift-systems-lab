import Foundation

func testBasicAccuracy() {
    var hll = HyperLogLog(precision: 10) // 1024 registers
    let n = 10_000
    for i in 0..<n {
        hll.add(i)
    }
    let estimate = hll.estimate()
    let error = abs(estimate - Double(n)) / Double(n)
    // Expect error < 10%
    assert(error < 0.10, "Basic accuracy test failed: error = \(error)")
    print("testBasicAccuracy passed (error = \(error * 100.0)%).")
}

func testMergeFunctionality() {
    var hllA = HyperLogLog(precision: 10)
    var hllB = HyperLogLog(precision: 10)
    let total = 20_000
    for i in 0..<total {
        if i % 2 == 0 {
            hllA.add(i)
        } else {
            hllB.add(i)
        }
    }
    var merged = hllA
    merged.merge(hllB)
    let estimate = merged.estimate()
    let error = abs(estimate - Double(total)) / Double(total)
    assert(error < 0.12, "Merge test failed: error = \(error)")
    print("testMergeFunctionality passed (error = \(error * 100.0)%).")
}

func testSmallCardinality() {
    var hll = HyperLogLog(precision: 8) // 256 registers
    let n = 5
    for i in 0..<n {
        hll.add(i)
    }
    let estimate = hll.estimate()
    let error = abs(estimate - Double(n)) / Double(n)
    // Small sets should be very accurate due to linear counting
    assert(error < 0.25, "Small cardinality test failed: error = \(error)")
    print("testSmallCardinality passed (error = \(error * 100.0)%).")
}

// Execute tests
testBasicAccuracy()
testMergeFunctionality()
testSmallCardinality()
print("All HyperLogLog tests passed.")
