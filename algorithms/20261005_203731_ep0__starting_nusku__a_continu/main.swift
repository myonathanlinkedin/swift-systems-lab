import Foundation

func approxEqual(_ a: Double, _ b: Double, epsilon: Double = 1e-9) -> Bool {
    return abs(a - b) < epsilon
}

let engine = ProfilerEngine(capacity: 5)

// Empty buffer statistics should be nil
assert(engine.computeStatistics() == nil, "Statistics must be nil for empty buffer")

// Add initial samples
engine.addSample(value: 10.0, at: 1.0)
engine.addSample(value: 20.0, at: 2.0)
engine.addSample(value: 30.0, at: 3.0)

// Verify count
assert(engine.sampleCount == 3, "Sample count should be 3 after three inserts")

// Compute and validate statistics
if let stats = engine.computeStatistics() {
    assert(stats.count == 3, "Stats count mismatch")
    assert(approxEqual(stats.mean, 20.0), "Mean mismatch")
    assert(approxEqual(stats.min, 10.0), "Min mismatch")
    assert(approxEqual(stats.max, 30.0), "Max mismatch")
    // Variance = ((10-20)^2 + (20-20)^2 + (30-20)^2) / 3 = 66.666...
    assert(approxEqual(stats.variance, 66.66666666666667, epsilon: 1e-6), "Variance mismatch")
} else {
    assertionFailure("Statistics should not be nil after adding samples")
}

// Percentile checks
if let p50 = engine.percentile(50.0) {
    assert(approxEqual(p50, 20.0), "50th percentile mismatch")
}
if let p0 = engine.percentile(0.0) {
    assert(approxEqual(p0, 10.0), "0th percentile mismatch")
}
if let p100 = engine.percentile(100.0) {
    assert(approxEqual(p100, 30.0), "100th percentile mismatch")
}

// Fill buffer to capacity and overflow
engine.addSample(value: 40.0, at: 4.0)
engine.addSample(value: 50.0, at: 5.0)
engine.addSample(value: 60.0, at: 6.0) // This should evict the oldest (10.0)

assert(engine.sampleCount == 5, "Buffer should be full with capacity 5")
let currentValues = engine.getSamples().map { $0.value }
assert(!currentValues.contains(10.0), "Oldest sample must have been evicted")
assert(currentValues.contains(60.0), "Newest sample must be present")

// Statistics after overflow
if let stats2 = engine.computeStatistics() {
    assert(stats2.count == 5, "Stats count after overflow mismatch")
    // Expected values: 20,30,40,50,60
    assert(approxEqual(stats2.mean, 40.0), "Mean after overflow mismatch")
    assert(approxEqual(stats2.min, 20.0), "Min after overflow mismatch")
    assert(approxEqual(stats2.max, 60.0), "Max after overflow mismatch")
}

// Reset engine
engine.reset()
assert(engine.sampleCount == 0, "Sample count must be zero after reset")
assert(engine.computeStatistics() == nil, "Statistics must be nil after reset")

print("All tests passed.")
