import Foundation

/// A probabilistic data structure for set membership testing with configurable false‑positive rate.
/// Implements a Bloom filter using double hashing based on Swift's `Hasher`.
public struct BloomFilter<Element: Hashable> {
    // MARK: - Public immutable configuration
    
    /// Number of bits in the filter (size of the bit array).
    public let bitCount: Int
    /// Number of hash functions used.
    public let hashFunctionCount: Int
    /// Expected number of inserted elements (used for sizing, not enforced).
    public let expectedElementCount: Int
    
    // MARK: - Private mutable storage
    
    /// Bit array stored as bytes; each bit represents a slot.
    var bits: [UInt8]
    /// Current number of distinct elements added (approximate, duplicates ignored).
    var insertedCount: Int = 0
    
    // MARK: - Initialization
    
    /// Creates a Bloom filter sized for the given expected element count and desired false‑positive probability.
    /// - Parameters:
    ///   - expectedElements: Anticipated number of distinct elements to be stored.
    ///   - falsePositiveProbability: Desired upper bound on false‑positive rate (0 < p < 1).
    public init(expectedElements: Int, falsePositiveProbability: Double) {
        precondition(expectedElements > 0, "expectedElements must be > 0")
        precondition(falsePositiveProbability > 0.0 && falsePositiveProbability < 1.0,
                     "falsePositiveProbability must be in (0,1)")
        
        self.expectedElementCount = expectedElements
        
        // Optimal size m = -(n * ln(p)) / (ln2)^2
        let ln2 = log(2.0)
        let mDouble = -Double(expectedElements) * log(falsePositiveProbability) / (ln2 * ln2)
        self.bitCount = max(1, Int(ceil(mDouble)))
        
        // Optimal number of hash functions k = (m/n) * ln2
        let kDouble = (Double(self.bitCount) / Double(expectedElements)) * ln2
        self.hashFunctionCount = max(1, Int(round(kDouble)))
        
        // Allocate enough bytes to hold `bitCount` bits.
        let byteCount = (self.bitCount + 7) / 8
        self.bits = [UInt8](repeating: 0, count: byteCount)
    }
    
    // MARK: - Public API
    
    /// Inserts an element into the filter.
    /// - Parameter element: The element to add.
    public mutating func add(_ element: Element) {
        let positions = self.computeHashPositions(for: element)
        var alreadyPresent = true
        for pos in positions {
            if !self.getBit(at: pos) {
                alreadyPresent = false
                self.setBit(at: pos)
            }
        }
        if !alreadyPresent {
            self.insertedCount += 1
        }
    }
    
    /// Tests whether an element is possibly in the filter.
    /// - Parameter element: The element to query.
    /// - Returns: `true` if the element may be present, `false` if it is definitely absent.
    public func contains(_ element: Element) -> Bool {
        let positions = self.computeHashPositions(for: element)
        for pos in positions {
            if !self.getBit(at: pos) {
                return false
            }
        }
        return true
    }
    
    /// Returns the current estimated false‑positive probability based on the number of inserted elements.
    /// Uses the standard Bloom filter formula: (1 - e^{-k * n / m})^k
    /// - Returns: Estimated false‑positive rate as a value in [0,1].
    public func estimatedFalsePositiveRate() -> Double {
        guard self.bitCount > 0 else { return 1.0 }
        let m = Double(self.bitCount)
        let k = Double(self.hashFunctionCount)
        let n = Double(self.insertedCount)
        let exponent = -k * n / m
        let prob = pow(1.0 - exp(exponent), k)
        return prob
    }
    
    // MARK: - Private helpers
    
    /// Computes the `hashFunctionCount` distinct bit positions for a given element using double hashing.
    func computeHashPositions(for element: Element) -> [Int] {
        // First hash
        var hasher1 = Hasher()
        hasher1.combine(element)
        let hash1 = UInt64(bitPattern: Int64(hasher1.finalize()))
        
        // Second hash with a constant salt to ensure independence
        var hasher2 = Hasher()
        hasher2.combine(0x9e3779b97f4a7c15 as UInt64) // large odd constant (golden ratio)
        hasher2.combine(element)
        let hash2 = UInt64(bitPattern: Int64(hasher2.finalize()))
        
        var positions = [Int]()
        positions.reserveCapacity(self.hashFunctionCount)
        for i in 0..<self.hashFunctionCount {
            // Double hashing: (hash1 + i * hash2) mod m
            let combined = hash1 &+ UInt64(i) &* hash2
            let pos = Int(combined % UInt64(self.bitCount))
            positions.append(pos)
        }
        return positions
    }
    
    /// Sets the bit at the given position to 1.
    private mutating func setBit(at index: Int) {
        let byteIndex = index / 8
        let bitOffset = index % 8
        bits[byteIndex] |= (1 << bitOffset)
    }
    
    /// Retrieves the bit value at the given position.
    func getBit(at index: Int) -> Bool {
        let byteIndex = index / 8
        let bitOffset = index % 8
        return (bits[byteIndex] & (1 << bitOffset)) != 0
    }
}
