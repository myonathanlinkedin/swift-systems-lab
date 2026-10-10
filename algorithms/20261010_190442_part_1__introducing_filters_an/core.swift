import Foundation

public struct BloomFilter {
    public let size: Int               // Number of bits in the filter
    public let hashCount: Int          // Number of hash functions (k)
    var bits: [UInt64]         // Bit array stored as UInt64 words

    /// Initializes a Bloom filter for an expected number of elements `n`
    /// and a desired false‑positive probability `p` (0 < p < 1).
    /// The size `m` (bits) and hash count `k` are computed using the
    /// optimal formulas:
    ///   m = -n * ln(p) / (ln 2)^2
    ///   k = (m / n) * ln 2
    public init(expectedElements n: Int, falsePositiveRate p: Double) {
        precondition(n > 0, "expectedElements must be > 0")
        precondition(p > 0 && p < 1, "falsePositiveRate must be between 0 and 1")
        let ln2 = log(2.0)
        let mDouble = -Double(n) * log(p) / (ln2 * ln2)
        let kDouble = (mDouble / Double(n)) * ln2
        self.size = max(1, Int(ceil(mDouble)))               // at least one bit
        self.hashCount = max(1, Int(round(kDouble)))        // at least one hash
        let wordCount = (size + 63) / 64                     // ceil(size/64)
        self.bits = Array(repeating: 0, count: wordCount)
    }

    /// Generates `hashCount` deterministic indices in the range `[0, size)`.
    /// Uses double‑hashing:  h_i = (hash1 + i * hash2) mod m
    func indices(of element: UInt64) -> [Int] {
        var result = [Int]()
        let hash1 = element
        // A large odd constant; ensures hash2 is odd and thus relatively prime to many m.
        let hash2 = element &* 0x9e3779b97f4a7c15 &+ 0x85ebca6b
        for i in 0..<hashCount {
            let combined = hash1 &+ UInt64(i) &* hash2
            let idx = Int(combined % UInt64(size))
            result.append(idx)
        }
        return result
    }

    /// Inserts `element` into the filter.
    public mutating func add(_ element: UInt64) {
        for idx in indices(of: element) {
            let wordIdx = idx / 64
            let bitPos = idx % 64
            bits[wordIdx] |= (1 << bitPos)
        }
    }

    /// Returns `true` if `element` may be in the set, `false` if it is definitely not.
    public func mightContain(_ element: UInt64) -> Bool {
        for idx in indices(of: element) {
            let wordIdx = idx / 64
            let bitPos = idx % 64
            if (bits[wordIdx] & (1 << bitPos)) == 0 {
                return false
            }
        }
        return true
    }
}
