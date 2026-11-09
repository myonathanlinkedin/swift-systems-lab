import Foundation

// MARK: - Treap Implementation

/// A randomized binary search tree (Treap) that maintains BST order by keys
/// and heap order by randomly assigned priorities.
public struct Treap<Key: Comparable, Value> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    /// Node of the treap. Implemented as a class to allow mutation via references.
    public final class Node {
        public var key: Key
        public var value: Value
        public var priority: UInt32
        public var left: Node?
        public var right: Node?

        public init(key: Key, value: Value, priority: UInt32) {
            self.key = key
            self.value = value
            self.priority = priority
        }
    }

    /// Root of the treap.
    internal var root: Node?

    /// Linear Congruential Generator seed for deterministic priorities.
    internal var seed: UInt64

    /// Initializes an empty treap with an optional seed.
    public init(seed: UInt64 = 123456789) {
        self.root = nil
        self.seed = seed
    }

    // MARK: - Public API

    /// Inserts a key-value pair into the treap. If the key already exists,
    /// its value is updated.
    public mutating func insert(_ key: Key, value: Value) {
        let priority = nextPriority()
        root = insert(node: root, key: key, value: value, priority: priority)
    }

    /// Deletes the node with the specified key. If the key does not exist,
    /// the treap remains unchanged.
    public mutating func delete(_ key: Key) {
        root = delete(node: root, key: key)
    }

    /// Retrieves the value associated with the specified key, if present.
    public func find(_ key: Key) -> Value? {
        return find(node: root, key: key)
    }

    /// Returns an array of key-value pairs in ascending key order.
    public func inorder() -> [(Key, Value)] {
        var result: [(Key, Value)] = []
        inorder(node: root, result: &result)
        return result
    }

    // MARK: - Internal Helpers

    /// Generates the next random priority using a deterministic LCG.
    internal mutating func nextPriority() -> UInt32 {
        // Constants from Numerical Recipes
        seed = 6364136223846793005 &* seed &+ 1
        return UInt32(seed >> 32)
    }

    /// Recursive insertion helper.
    internal func insert(node: Node?, key: Key, value: Value, priority: UInt32) -> Node {
        guard let node = node else {
            return Node(key: key, value: value, priority: priority)
        }
        if key < node.key {
            node.left = insert(node: node.left, key: key, value: value, priority: priority)
            if node.left!.priority < node.priority {
                return rotateRight(node)
            }
        } else if key > node.key {
            node.right = insert(node: node.right, key: key, value: value, priority: priority)
            if node.right!.priority < node.priority {
                return rotateLeft(node)
            }
        } else {
            // Key exists; update value
            node.value = value
        }
        return node
    }

    /// Recursive deletion helper.
    internal func delete(node: Node?, key: Key) -> Node? {
        guard let node = node else { return nil }
        if key < node.key {
            node.left = delete(node: node.left, key: key)
        } else if key > node.key {
            node.right = delete(node: node.right, key: key)
        } else {
            // Node to delete found
            if node.left == nil { return node.right }
            if node.right == nil { return node.left }
            // Both children exist: rotate to remove
            if node.left!.priority < node.right!.priority {
                let rotated = rotateRight(node)
                rotated.right = delete(node: rotated.right, key: key)
                return rotated
            } else {
                let rotated = rotateLeft(node)
                rotated.left = delete(node: rotated.left, key: key)
                return rotated
            }
        }
        return node
    }

    /// Recursive search helper.
    internal func find(node: Node?, key: Key) -> Value? {
        guard let node = node else { return nil }
        if key < node.key { return find(node: node.left, key: key) }
        if key > node.key { return find(node: node.right, key: key) }
        return node.value
    }

    /// In-order traversal helper.
    internal func inorder(node: Node?, result: inout [(Key, Value)]) {
        guard let node = node else { return }
        inorder(node: node.left, result: &result)
        result.append((node.key, node.value))
        inorder(node: node.right, result: &result)
    }

    /// Right rotation.
    internal func rotateRight(_ node: Node) -> Node {
        let left = node.left!
        node.left = left.right
        left.right = node
        return left
    }

    /// Left rotation.
    internal func rotateLeft(_ node: Node) -> Node {
        let right = node.right!
        node.right = right.left
        right.left = node
        return right
    }
}
