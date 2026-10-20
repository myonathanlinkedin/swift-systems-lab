import Foundation

// Simple deterministic linear congruential generator for reproducible priorities
struct SimpleRNG {
    var state: UInt64

    mutating func next() -> UInt64 {
        // Constants from Numerical Recipes
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

// Node of the Treap (reference type to allow recursive structure)
final class TreapNode<Key: Comparable, Value> {
    var key: Key
    var value: Value
    var priority: UInt64
    var left: TreapNode?
    var right: TreapNode?

    init(key: Key, value: Value, priority: UInt64) {
        self.key = key
        self.value = value
        self.priority = priority
        self.left = nil
        self.right = nil
    }
}

// Public Treap structure
public struct Treap<Key: Comparable, Value> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    // Root of the treap
    var root: TreapNode<Key, Value>?
    // Deterministic RNG for priorities
    var rng: SimpleRNG

    // Default seed ensures reproducibility across runs
    public init(seed: UInt64 = 0xdeadbeefcafebabe) {
        self.root = nil
        self.rng = SimpleRNG(state: seed)
    }

    // MARK: - Public API

    // Insert a key/value pair; replaces existing value for duplicate keys
    public mutating func insert(key: Key, value: Value) {
        // Remove existing key first to avoid duplicates
        root = delete(root, key)

        let priority = rng.next()
        let newNode = TreapNode(key: key, value: value, priority: priority)
        let (left, right) = split(root, key)
        root = merge(merge(left, newNode), right)
    }

    // Delete a key from the treap; no effect if key absent
    public mutating func delete(key: Key) {
        root = delete(root, key)
    }

    // Find value associated with a key; returns nil if absent
    public func find(_ key: Key) -> Value? {
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

    // Return all key/value pairs in ascending key order
    public func inorder() -> [(Key, Value)] {
        var result: [(Key, Value)] = []
        func dfs(_ node: TreapNode<Key, Value>?) {
            guard let node = node else { return }
            dfs(node.left)
            result.append((node.key, node.value))
            dfs(node.right)
        }
        dfs(root)
        return result
    }

    // Verify heap property: parent priority <= child priority for all nodes
    public func verifyHeapProperty() -> Bool {
        func check(_ node: TreapNode<Key, Value>?) -> Bool {
            guard let node = node else { return true }
            if let left = node.left {
                if left.priority < node.priority { return false }
                if !check(left) { return false }
            }
            if let right = node.right {
                if right.priority < node.priority { return false }
                if !check(right) { return false }
            }
            return true
        }
        return check(root)
    }

    // MARK: - Internal Helpers (recursive)

    // Split tree into (< key) and (>= key) subtrees
    func split(_ node: TreapNode<Key, Value>?, _ key: Key) -> (TreapNode<Key, Value>?, TreapNode<Key, Value>?) {
        guard let node = node else { return (nil, nil) }
        if key <= node.key {
            let (leftSplit, rightSplit) = split(node.left, key)
            node.left = rightSplit
            return (leftSplit, node)
        } else {
            let (leftSplit, rightSplit) = split(node.right, key)
            node.right = leftSplit
            return (node, rightSplit)
        }
    }

    // Merge two treaps assuming all keys in left < all keys in right
    func merge(_ left: TreapNode<Key, Value>?, _ right: TreapNode<Key, Value>?) -> TreapNode<Key, Value>? {
        guard let left = left else { return right }
        guard let right = right else { return left }
        if left.priority < right.priority {
            left.right = merge(left.right, right)
            return left
        } else {
            right.left = merge(left, right.left)
            return right
        }
    }

    // Delete a key from subtree rooted at node
    func delete(_ node: TreapNode<Key, Value>?, _ key: Key) -> TreapNode<Key, Value>? {
        guard let node = node else { return nil }
        if key == node.key {
            return merge(node.left, node.right)
        } else if key < node.key {
            node.left = delete(node.left, key)
            return node
        } else {
            node.right = delete(node.right, key)
            return node
        }
    }
}
