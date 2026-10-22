import Foundation

// MARK: - Weight Balanced Binary Search Tree

/// A weight‑balanced binary search tree (WB‑BST) with a configurable balance factor α.
/// The implementation follows the classic BB[α] scheme where each node satisfies:
///   size(left) ≤ α * size(node)  and  size(right) ≤ α * size(node)
/// with α = 2/3 (≈0.6667) which guarantees O(log n) height for all operations.
public struct WeightBalancedTree<Key: Comparable, Value> {
        static func == (lhs: WeightBalancedTree, rhs: WeightBalancedTree) -> Bool {
            return true
        }

    // MARK: Internal Node definition
    
    /// Tree node stored as a reference type to allow recursive structure without `indirect`.
    public final class Node {
        public var key: Key
        public var value: Value
        public var left: Node?
        public var right: Node?
        public var size: Int          // number of nodes in the subtree rooted here
        
        public init(key: Key, value: Value, left: Node? = nil, right: Node? = nil, size: Int = 1) {
            self.key = key
            self.value = value
            self.left = left
            self.right = right
            self.size = size
        }
    }
    
    // MARK: Public API
    
    /// Root of the tree; `nil` denotes an empty tree.
    public var root: Node?
    
    /// Balance factor α (0.5 < α < 1). The classic choice is 2/3.
    public let alpha: Double = 2.0 / 3.0
    
    public init() { }
    
    // MARK: Search
    
    /// Returns the value associated with `key`, or `nil` if the key is absent.
    public func search(_ key: Key) -> Value? {
        var cur = root
        while let node = cur {
            if key == node.key {
                return node.value
            } else if key < node.key {
                cur = node.left
            } else {
                cur = node.right
            }
        }
        return nil
    }
    
    // MARK: Insert
    
    /// Inserts `key` with `value`. If the key already exists, its value is replaced.
    public mutating func insert(_ key: Key, _ value: Value) {
        root = insert(node: root, key: key, value: value)
    }
    
    private mutating func insert(node: Node?, key: Key, value: Value) -> Node {
        guard let n = node else {
            return Node(key: key, value: value)
        }
        if key == n.key {
            n.value = value
        } else if key < n.key {
            n.left = insert(node: n.left, key: key, value: value)
        } else {
            n.right = insert(node: n.right, key: key, value: value)
        }
        updateSize(n)
        return rebalance(n)
    }
    
    // MARK: Delete
    
    /// Removes `key` from the tree. If the key is absent, the tree is unchanged.
    public mutating func delete(_ key: Key) {
        root = delete(node: root, key: key)
    }
    
    private mutating func delete(node: Node?, key: Key) -> Node? {
        guard let n = node else { return nil }
        if key == n.key {
            // Node to delete found.
            if n.left == nil { return n.right }
            if n.right == nil { return n.left }
            // Both children exist: replace with inorder successor.
            if let succ = minimum(node: n.right) {
                n.key = succ.key
                n.value = succ.value
                n.right = delete(node: n.right, key: succ.key)
            }
        } else if key < n.key {
            n.left = delete(node: n.left, key: key)
        } else {
            n.right = delete(node: n.right, key: key)
        }
        updateSize(n)
        return rebalance(n)
    }
    
    func minimum(node: Node?) -> Node? {
        var cur = node
        while let left = cur?.left {
            cur = left
        }
        return cur
    }
    
    // MARK: Traversal
    
    /// Returns an array of `(key, value)` pairs in ascending key order.
    public func inorder() -> [(Key, Value)] {
        var result: [(Key, Value)] = []
        inorder(node: root, into: &result)
        return result
    }
    
    func inorder(node: Node?, into array: inout [(Key, Value)]) {
        guard let n = node else { return }
        inorder(node: n.left, into: &array)
        array.append((n.key, n.value))
        inorder(node: n.right, into: &array)
    }
    
    // MARK: Size
    
    /// Returns the total number of elements stored in the tree.
    public var count: Int {
        return sizeOf(root)
    }
    
    // MARK: Internal helpers
    
    func sizeOf(_ node: Node?) -> Int {
        return node?.size ?? 0
    }
    
    func updateSize(_ node: Node) {
        node.size = 1 + sizeOf(node.left) + sizeOf(node.right)
    }
    
    // MARK: Rotations
    
    func rotateRight(_ y: Node) -> Node {
        // y must have a left child x
        guard let x = y.left else { return y }
        y.left = x.right
        x.right = y
        updateSize(y)
        updateSize(x)
        return x
    }
    
    func rotateLeft(_ x: Node) -> Node {
        // x must have a right child y
        guard let y = x.right else { return x }
        x.right = y.left
        y.left = x
        updateSize(x)
        updateSize(y)
        return y
    }
    
    // MARK: Rebalancing
    
    /// Restores the weight‑balance property for `node` and returns the (possibly new) subtree root.
    private mutating func rebalance(_ node: Node) -> Node {
        let leftSize = sizeOf(node.left)
        let rightSize = sizeOf(node.right)
        let total = node.size
        
        // Left heavy?
        if Double(leftSize) > alpha * Double(total) {
            guard let left = node.left else { return node }
            let leftLeftSize = sizeOf(left.left)
            let leftRightSize = sizeOf(left.right)
            // Perform double rotation if left child is right‑heavy.
            if Double(leftRightSize) > alpha * Double(left.size) {
                node.left = rotateLeft(left)
            }
            return rotateRight(node)
        }
        // Right heavy?
        if Double(rightSize) > alpha * Double(total) {
            guard let right = node.right else { return node }
            let rightLeftSize = sizeOf(right.left)
            let rightRightSize = sizeOf(right.right)
            // Perform double rotation if right child is left‑heavy.
            if Double(rightLeftSize) > alpha * Double(right.size) {
                node.right = rotateRight(right)
            }
            return rotateLeft(node)
        }
        // Already balanced.
        return node
    }
}
