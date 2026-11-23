import Foundation

// Unit Test Suite
func testEmptySet() {
    var hll = HyperLogLog(p: 10)
    let estimate = hll.estimate()
    assert(estimate == 0.0, "Empty set estimate should be 0")
}

func testSingleElement() {
    var hll = HyperLogLog(p: 10)
    hll.add(42)
    let estimate = hll.estimate()
    assert(abs(estimate - 1.0) < 0.1, "Single element estimate should be close to 1")
}

func testDuplicateElements() {
    var hll = HyperLogLog(p: 10)
    for _ in 0..<100 {
        hll.add("duplicate")
    }
    let estimate = hll.estimate()
    assert(abs(estimate - 1.0) < 0.1, "Duplicate elements should estimate to 1")
}

func testSmallDistinctSet() {
    var hll = HyperLogLog(p: 10)
    for i in 0..<1000 {
        hll.add(i)
    }
    let estimate = hll.estimate()
    let error = abs(estimate - 1000.0) / 1000.0
    assert(error < 0.05, "Small distinct set estimate error should be <5%")
}

func testLargeDistinctSet() {
    var hll = HyperLogLog(p: 14)
    let count = 1_000_000
    for i in 0..<count {
        hll.add(i)
    }
    let estimate = hll.estimate()
    let error = abs(estimate - Double(count)) / Double(count)
    assert(error < 0.02, "Large distinct set estimate error should be <2%")
}

func testMerge() {
    var hll1 = HyperLogLog(p: 12)
    var hll2 = HyperLogLog(p: 12)
    for i in 0..<500_000 {
        hll1.add(i)
    }
    for i in 500_000..<1_000_000 {
        hll2.add(i)
    }
    var merged = hll1
    merged.merge(with: hll2)
    let estimate = merged.estimate()
    let error = abs(estimate - 1_000_000.0) / 1_000_000.0
    assert(error < 0.02, "Merged estimate error should be <2%")
}

func testStringElements() {
    var hll = HyperLogLog(p: 10)
    let words = ["apple", "banana", "cherry", "date", "elderberry"]
    for word in words {
        hll.add(word)
    }
    let estimate = hll.estimate()
    let error = abs(estimate - Double(words.count)) / Double(words.count)
    assert(error < 0.05, "String elements estimate error should be <5%")
}

func runAllTests() {
    testEmptySet()
    testSingleElement()
    testDuplicateElements()
    testSmallDistinctSet()
    testLargeDistinctSet()
    testMerge()
    testStringElements()
    print("All tests passed.")
}

runAllTests()
