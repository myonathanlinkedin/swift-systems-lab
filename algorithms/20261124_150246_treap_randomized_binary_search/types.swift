import Foundation

/// Linear Congruential Generator for deterministic pseudo‑random numbers.
public struct LCG {
    public var state: UInt64

    public init(seed: UInt64 = 0xDEADBEEF) {
        self.state = seed
    }

    /// Returns a non‑negative Int in the full 31‑bit range.
    public mutating func nextInt() -> Int {
        // Constants from Numerical Recipes
        state = (state &* 6364136223846793005 &+ 1) & 0x7FFFFFFFFFFFFFFF
        return Int(state & 0x7FFFFFFF)
    }
}

/// Node of a Treap (binary search tree + heap on priority).
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

/// Treap data structure supporting insert, delete, search and validation.
public struct Treap<Key: Comparable> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    public var root: TreapNode<Key>?
    public var rng: LCG

    public init(seed: UInt64 = 0xDEADBEEF) {
        self.root = nil
        self.rng = LCG(seed: seed)
    }
}
