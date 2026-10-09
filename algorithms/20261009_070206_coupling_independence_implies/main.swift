import Foundation

// Helper to generate a deterministic pseudo‑random Double in (0,1).
func deterministicRandom(seed: inout UInt64) -> Double {
    // Xorshift64*
    seed ^= seed >> 12
    seed ^= seed << 25
    seed ^= seed >> 27
    let result = seed &* 2685821657736338717
    return Double(result % 1_000_000) / 1_000_000.0 + 1e-6 // avoid exact 0 or 1
}

// Unit test: Positive interval zero‑freeness.
func testPositiveZeroFreeness() {
    var seed: UInt64 = 0xDEADBEEFCAFEBABE
    for _ in 0..<20 {
        // Build a random family of size 5‑10.
        let size = Int(deterministicRandom(seed: &seed) * 6) + 5
        var probs: [Double] = []
        for _ in 0..<size {
            probs.append(deterministicRandom(seed: &seed))
        }
        let family = IndependentBernoulliFamily(probabilities: probs)
        // Verify G(z) > 0 for all z in [0, 10].
        assert(family.isZeroFree(in: 0.0...10.0), "Family should be zero‑free on positive reals.")
    }
}

// Unit test: Zeros are exactly the negative reciprocals.
func testNegativeZeros() {
    let probs: [Double] = [0.2, 0.5, 0.8]
    let family = IndependentBernoulliFamily(probabilities: probs)
    let zeros = family.zeros()
    for (p, z) in zip(probs, zeros) {
        // Expected zero location.
        let expected = -(1.0 - p) / p
        assert(abs(z - expected) < 1e-12, "Zero computation mismatch.")
        // Evaluate polynomial at the zero; should be (approximately) zero.
        let val = family.evaluate(at: z)
        assert(abs(val) < 1e-9, "Polynomial not zero at expected root.")
        // Ensure zero is negative.
        assert(z < 0.0, "All zeros must be negative for independent Bernoulli family.")
    }
}

// Unit test: Coefficient correctness via direct evaluation.
func testCoefficientConsistency() {
    let probs: [Double] = [0.3, 0.6]
    let family = IndependentBernoulliFamily(probabilities: probs)
    let coeffs = family.generatingPolynomialCoefficients()
    // G(z) = (0.7 + 0.3z)(0.4 + 0.6z) = 0.28 + (0.42+0.12)z + 0.18z^2 = 0.28 + 0.54z + 0.18z^2
    let expected: [Double] = [0.28, 0.54, 0.18]
    for i in 0..<expected.count {
        assert(abs(coeffs[i] - expected[i]) < 1e-12, "Coefficient mismatch at degree \(i).")
    }
}

// Execute all tests.
func runAllTests() {
    testPositiveZeroFreeness()
    testNegativeZeros()
    testCoefficientConsistency()
    print("All tests passed.")
}

runAllTests()
