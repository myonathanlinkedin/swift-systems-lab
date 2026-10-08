import Foundation

/// Protocol defining a min‑plus convolution algorithm.
public protocol MinPlusConvolutionAlgorithm {
    /// Computes the min‑plus convolution of `a` and `b`.
    /// - Parameters:
    ///   - a: First input sequence.
    ///   - b: Second input sequence.
    /// - Returns: An array `c` where `c[k] = min_{i+j=k} (a[i] + b[j])`.
    func compute(_ a: [Int], _ b: [Int]) -> [Int]
}

/// Simple container for a convolution result and its lower bound.
public struct ConvolutionResult {
    public var values: [Int]
    public var lowerBound: Int
    
    public init(values: [Int], lowerBound: Int) {
        self.values = values
        self.lowerBound = lowerBound
    }
}
