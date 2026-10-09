import Foundation

public final class Node<T: Comparable> {
    public var key: T
    public var priority: UInt64
    public var left: Node<T>? = nil
    public var right: Node<T>? = nil

    public init(key: T, priority: UInt64) {
        self.key = key
        self.priority = priority
    }
}

public struct LCG {
    public var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    // Linear Congruential Generator (64‑bit)
    public mutating func next() -> UInt64 {
        // Constants from Numerical Recipes
        state = (state &* 2862933555777941757 &+ 3037000493) & 0xFFFFFFFFFFFFFFFF
        return state
    }
}
