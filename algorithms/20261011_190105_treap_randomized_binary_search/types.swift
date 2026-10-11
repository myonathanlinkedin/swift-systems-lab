import Foundation

/// Linear Congruential Generator for deterministic pseudo‑random numbers.
/// Provides reproducible priorities for the treap.
public struct LCG {
    var state: UInt64

    public init(seed: UInt64 = 0xDEADBEEFCAFEBABE) {
        self.state = seed
    }

    /// Returns the next random UInt64.
    public mutating func next() -> UInt64 {
        // Constants from Numerical Recipes
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }

    /// Returns a non‑negative Int priority.
    public mutating func nextInt() -> Int {
        // Truncate to 63 bits to stay within positive Int range.
        return Int(truncatingIfNeeded: next() & 0x7FFFFFFFFFFFFFFF)
    }
}

/// Node of a treap. Stored as a reference type to satisfy recursive data‑structure rules.
public final class TreapNode<Key: Comparable> {
    public var key: Key
    public var priority: Int
    public var left: TreapNode?
    public var right: TreapNode?

    public init(key: Key, priority: Int) {
        self.key = key
        self.priority = priority
        self.left = nil
        self.right = nil
    }
}
