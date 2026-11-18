import Foundation

// Simple assertion helper that prints a message on failure.
func assert(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        print("Assertion failed: \(message)")
        exit(1)
    }
}

// Test 1: Zero elements should yield zero estimate.
var hllZero = HyperLogLog(p: 10)
assert(hllZero.count() == 0.0, "Zero elements should give count 0")

// Test 2: Adding a single distinct element.
var hllOne = HyperLogLog(p: 10)
hllOne.add(42)
let estOne = hllOne.count()
assert(abs(estOne - 1.0) / 1.0 < 0.2, "Single element estimate within 20% (got \(estOne))")

// Test 3: Duplicates must not inflate the estimate.
var hllDup = HyperLogLog(p: 10)
for _ in 0..<500 {
    hllDup.add("duplicate")
}
let estDup = hllDup.count()
assert(abs(estDup - 1.0) / 1.0 < 0.2, "Duplicates estimate within 20% (got \(estDup))")

// Test 4: Moderate cardinality (1000 distinct integers) within 10% error.
var hllMedium = HyperLogLog(p: 10)
for i in 0..<1000 {
    hllMedium.add(i)
}
let estMedium = hllMedium.count()
let relErrorMedium = abs(estMedium - 1000.0) / 1000.0
assert(relErrorMedium < 0.10, "Medium cardinality error \(relErrorMedium) exceeds 10% (estimate \(estMedium))")

// Test 5: Small cardinality (5 distinct values) should trigger linear counting.
var hllSmall = HyperLogLog(p: 10)
let smallSet = [7, 13, 42, 99, 123]
for v in smallSet {
    hllSmall.add(v)
}
let estSmall = hllSmall.count()
let relErrorSmall = abs(estSmall - Double(smallSet.count)) / Double(smallSet.count)
assert(relErrorSmall < 0.30, "Small cardinality error \(relErrorSmall) exceeds 30% (estimate \(estSmall))")

// Test 6: Large cardinality (100_000 distinct integers) within 5% error.
var hllLarge = HyperLogLog(p: 12) // m = 4096 registers for better accuracy
for i in 0..<100_000 {
    hllLarge.add(i)
}
let estLarge = hllLarge.count()
let relErrorLarge = abs(estLarge - 100_000.0) / 100_000.0
assert(relErrorLarge < 0.05, "Large cardinality error \(relErrorLarge) exceeds 5% (estimate \(estLarge))")

print("All HyperLogLog tests passed.")
// End of program.
