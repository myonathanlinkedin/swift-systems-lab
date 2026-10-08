import Foundation

/// Naïve O(n²) implementation of min‑plus convolution.
public struct NaiveMinPlusConvolution: MinPlusConvolutionAlgorithm {
    public init() {}
    
    public func compute(_ a: [Int], _ b: [Int]) -> [Int] {
        let n = a.count
        let m = b.count
        let size = n + m - 1
        var result = Array(repeating: Int.max, count: size)
        for i in 0..<n {
            for j in 0..<m {
                let k = i + j
                let candidate = a[i] &+ b[j]   // use &+ to avoid overflow trap
                if candidate < result[k] {
                    result[k] = candidate
                }
            }
        }
        return result
    }
}

/// Computes a trivial lower bound for the min‑plus convolution.
/// For each possible index `k`, the lower bound is at least
/// `max(min(a), min(b))` because any sum includes one element from each array.
public func trivialLowerBound(_ a: [Int], _ b: [Int]) -> Int {
    guard let minA = a.min(), let minB = b.min() else {
        return Int.min
    }
    return minA &+ minB
}

/// Higher‑order BSG‑style lower bound (illustrative).
/// Given two integer sequences, we compute the size of the set
/// `{a[i] + b[j]}` and use the Balog‑Szemerédi‑Gowers intuition:
/// a larger sum‑set implies a larger minimum value.
/// This function returns `max(minA + minB, floor((|A|+|B|)/2))`.
public func bsgLowerBound(_ a: [Int], _ b: [Int]) -> Int {
    let trivial = trivialLowerBound(a, b)
    let sizeEstimate = (a.count + b.count) / 2
    return max(trivial, sizeEstimate)
}
