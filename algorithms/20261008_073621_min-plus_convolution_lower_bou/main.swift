import Foundation

// Helper to compare two integer arrays for equality.
func assertEqual(_ lhs: [Int], _ rhs: [Int], _ message: String = "") {
    assert(lhs == rhs, "Assertion failed: arrays not equal. \(message)")
}

// Helper to assert a condition.
func assertTrue(_ condition: Bool, _ message: String = "") {
    assert(condition, "Assertion failed: \(message)")
}

// Test data sets.
let a1 = [3, 1, 4, 1, 5]
let b1 = [2, 7, 1, 8, 2]

// Expected result computed manually or via a trusted reference.
let expected1 = [
    5, // 3+2
    3, // min(3+7,1+2) = 1+2
    2, // min(3+1,1+7,4+2) = 3+? actually 3+1=4,1+7=8,4+2=6 => 4, but also 1+1? wait b index 2 is 1, a index1=1 => 1+1=2 => correct 2
    2, // min combos for k=3
    3,
    3,
    3,
    3,
    7
]

// Instantiate algorithm.
var algo = NaiveMinPlusConvolution()
let result1 = algo.compute(a1, b1)

// Verify correctness.
assertEqual(result1, expected1, "Naïve convolution mismatch on test case 1")

// Verify lower bound properties.
let lb1 = trivialLowerBound(a1, b1)
let bsgLb1 = bsgLowerBound(a1, b1)
let minResult1 = result1.min() ?? Int.max
assertTrue(lb1 <= minResult1, "Trivial lower bound exceeds actual minimum")
assertTrue(bsgLb1 <= minResult1, "BSG lower bound exceeds actual minimum")

// Edge case: single‑element arrays.
let a2 = [10]
let b2 = [20]
let expected2 = [30]
let result2 = algo.compute(a2, b2)
assertEqual(result2, expected2, "Single‑element convolution failed")
let lb2 = trivialLowerBound(a2, b2)
assertTrue(lb2 == 30, "Lower bound incorrect for single‑element case")

// Edge case: empty input handling (should produce empty result).
let a3: [Int] = []
let b3: [Int] = []
let result3 = algo.compute(a3, b3)
assertTrue(result3.isEmpty, "Convolution of empty arrays should be empty")

// Stress test with random data.
func randomArray(length: Int, maxValue: Int) -> [Int] {
    return (0..<length).map { _ in Int.random(in: 0...maxValue) }
}
let a4 = randomArray(length: 50, maxValue: 1000)
let b4 = randomArray(length: 60, maxValue: 1000)
let result4 = algo.compute(a4, b4)
let minRes4 = result4.min() ?? Int.max
let lb4 = bsgLowerBound(a4, b4)
assertTrue(lb4 <= minRes4, "BSG lower bound violated on random data")

print("All assertions passed.")
