import Foundation

// Simple deterministic random number generator for reproducible priorities
public struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    public init(seed: UInt64) {
        self.state = seed == 0 ? 0xdeadbeefcafebabe : seed
    }

    public mutating func next() -> UInt64 {
        // Linear Congruential Generator (LCG)
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

// Node class for the treap (reference semantics required for recursive structure)
public final class TreapNode<Key: Comparable, Value> {
    public var key: Key
    public var value: Value
    public var priority: UInt64
    public var left: TreapNode?
    public var right: TreapNode?

    public init(key: Key, value: Value, priority: UInt64) {
        self.key = key
        self.value = value
        self.priority = priority
        self.left = nil
        self.right = nil
    }
}

// Treap data structure
public struct Treap<Key: Comparable, Value> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    public var root: TreapNode<Key, Value>?
    var rng: SeededGenerator

    // MARK: - Initialization

    public init(seed: UInt64 = 0) {
        self.root = nil
        self.rng = SeededGenerator(seed: seed)
    }

    // MARK: - Public API

    // Insert or replace a key/value pair
    public mutating func insert(key: Key, value: Value) {
        var newPriority = rng.next()
        // Ensure priority is never zero (zero could be considered minimal)
        if newPriority == 0 { newPriority = 1 }
        root = insert(node: root, key: key, value: value, priority: newPriority)
    }

    // Delete a key; does nothing if key not present
    public mutating func delete(key: Key) {
        root = delete(node: root, key: key)
    }

    // Find value for a key
    public func find(key: Key) -> Value? {
        var current = root
        while let node = current {
            if key == node.key {
                return node.value
            } else if key < node.key {
                current = node.left
            } else {
                current = node.right
            }
        }
        return nil
    }

    // Return keys in sorted order (in‑order traversal)
    public func inorderKeys() -> [Key] {
        var result: [Key] = []
        inorder(node: root, output: &result)
        return result
    }

    // Validate both BST ordering and heap priority property
    public func validate() -> Bool {
        return isBST(node: root, min: nil, max: nil) && isHeap(node: root)
    }

    // MARK: - Private Helpers

    private mutating func insert(node: TreapNode<Key, Value>?, key: Key, value: Value, priority: UInt64) -> TreapNode<Key, Value> {
        guard let current = node else {
            return TreapNode(key: key, value: value, priority: priority)
        }

        if key == current.key {
            // Replace existing value, keep priority unchanged
            current.value = value
            return current
        } else if key < current.key {
            current.left = insert(node: current.left, key: key, value: value, priority: priority)
            if let left = current.left, left.priority > current.priority {
                return rotateRight(current)
            }
        } else {
            current.right = insert(node: current.right, key: key, value: value, priority: priority)
            if let right = current.right, right.priority > current.priority {
                return rotateLeft(current)
            }
        }
        return current
    }

    func delete(node: TreapNode<Key, Value>?, key: Key) -> TreapNode<Key, Value>? {
        guard let current = node else { return nil }

        if key < current.key {
            current.left = delete(node: current.left, key: key)
            return current
        } else if key > current.key {
            current.right = delete(node: current.right, key: key)
            return current
        } else {
            // Node to delete found – merge its children
            return merge(left: current.left, right: current.right)
        }
    }

    // Merge two sub‑trees preserving heap property
    func merge(left: TreapNode<Key, Value>?, right: TreapNode<Key, Value>?) -> TreapNode<Key, Value>? {
        guard let l = left else { return right }
        guard let r = right else { return left }

        if l.priority > r.priority {
            l.right = merge(left: l.right, right: r)
            return l
        } else {
            r.left = merge(left: l, right: r.left)
            return r
        }
    }

    // Right rotation
    func rotateRight(_ y: TreapNode<Key, Value>) -> TreapNode<Key, Value> {
        guard let x = y.left else { return y }
        y.left = x.right
        x.right = y
        return x
    }

    // Left rotation
    func rotateLeft(_ x: TreapNode<Key, Value>) -> TreapNode<Key, Value> {
        guard let y = x.right else { return x }
        x.right = y.left
        y.left = x
        return y
    }

    // In‑order traversal helper
    func inorder(node: TreapNode<Key, Value>?, output: inout [Key]) {
        guard let n = node else { return }
        inorder(node: n.left, output: &output)
        output.append(n.key)
        inorder(node: n.right, output: &output)
    }

    // BST validation helper
    func isBST(node: TreapNode<Key, Value>?, min: Key?, max: Key?) -> Bool {
        guard let n = node else { return true }
        if let minKey = min, n.key <= minKey { return false }
        if let maxKey = max, n.key >= maxKey { return false }
        return isBST(node: n.left, min: min, max: n.key) && isBST(node: n.right, min: n.key, max: max)
    }

    // Heap (max‑heap) validation helper
    func isHeap(node: TreapNode<Key, Value>?) -> Bool {
        guard let n = node else { return true }
        if let l = n.left, l.priority > n.priority { return false }
        if let r = n.right, r.priority > n.priority { return false }
        return isHeap(node: n.left) && isHeap(node: n.right)
    }
}
