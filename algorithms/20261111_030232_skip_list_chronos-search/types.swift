import Foundation

public final class SkipNode<Key: Comparable, Value> {
    public var key: Key
    public var value: Value
    public var forward: [SkipNode?]

    public init(key: Key, value: Value, level: Int) {
        self.key = key
        self.value = value
        // forward array size equals level (0...level-1)
        self.forward = Array(repeating: nil, count: level)
    }
}

// Deterministic pseudo‑random generator for reproducible level selection
public final class DeterministicRandom {
    var state: UInt64

    public init(seed: UInt64 = 0xDEADBEEF) {
        self.state = seed
    }

    // Linear Congruential Generator (LCG)
    func next() -> UInt64 {
        // Parameters from Numerical Recipes
        state = (state &* 6364136223846793005 &+ 1) & 0xFFFFFFFFFFFFFFFF
        return state
    }

    // Returns a Double in [0,1)
    public func nextDouble() -> Double {
        return Double(next() & 0xFFFFFFFFFFFFF) / Double(0x1000000000000)
    }
}
