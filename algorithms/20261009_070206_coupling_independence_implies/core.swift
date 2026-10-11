import Foundation

/// Represents a collection of independent Bernoulli random variables.
/// The probability generating function (PGF) is:
///   G(z) = ∏_{i} ((1 - p_i) + p_i * z)
public struct IndependentBernoulliFamily {
    /// Success probabilities for each Bernoulli variable (0 < p < 1).
    public var probabilities: [Double]

    /// Creates a new family, validating that each probability lies strictly between 0 and 1.
    public init(probabilities: [Double]) {
        for p in probabilities {
            precondition(p > 0.0 && p < 1.0, "Probabilities must be in (0,1). Found \(p).")
        }
        self.probabilities = probabilities
    }

    /// Returns the coefficients of the generating polynomial G(z) as an array.
    /// `coeffs[d]` corresponds to the coefficient of z^d.
    public func generatingPolynomialCoefficients() -> [Double] {
        // Start with constant polynomial 1.
        var coeffs: [Double] = [1.0]

        for p in probabilities {
            // Linear factor: (1 - p) + p * z
            let a = 1.0 - p   // constant term
            let b = p         // coefficient of z

            // Convolve current coeffs with [a, b]
            var newCoeffs = Array(repeating: 0.0, count: coeffs.count + 1)
            for i in 0..<coeffs.count {
                newCoeffs[i] += coeffs[i] * a
                newCoeffs[i + 1] += coeffs[i] * b
            }
            coeffs = newCoeffs
        }
        return coeffs
    }

    /// Evaluates the generating polynomial G(z) at a given real point `z`.
    /// Uses the product form for numerical stability.
    public func evaluate(at z: Double) -> Double {
        var result = 1.0
        for p in probabilities {
            result *= (1.0 - p) + p * z
        }
        return result
    }

    /// Returns the explicit zeros of G(z). For independent Bernoulli variables,
    /// each linear factor contributes a single real zero at `-(1-p)/p`.
    public func zeros() -> [Double] {
        return probabilities.map { p in
            -(1.0 - p) / p
        }
    }

    /// Checks whether G(z) is non‑zero throughout a closed interval.
    /// The interval is sampled uniformly at `samples` points.
    /// Returns `true` if every sampled value has absolute value > ε.
    public func isZeroFree(in interval: ClosedRange<Double>, samples: Int = 1_024, epsilon: Double = 1e-12) -> Bool {
        precondition(samples > 0, "Number of samples must be positive.")
        let lo = interval.lowerBound
        let hi = interval.upperBound
        for i in 0...samples {
            let t = Double(i) / Double(samples)
            let x = lo + t * (hi - lo)
            let val = evaluate(at: x)
            if abs(val) <= epsilon {
                return false
            }
        }
        return true
    }
}
