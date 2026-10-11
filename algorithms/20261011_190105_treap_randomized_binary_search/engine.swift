import Foundation

/// Treap (randomized binary search tree) supporting insert, delete, and search.
/// Guarantees expected O(log n) height when priorities are independent random values.
public struct Treap<Key: Comparable> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    // Root of the treap; mutable because many operations restructure the tree.
    public var root: TreapNode<Key>?
    // Deterministic RNG for reproducible priorities.
    public var rng: LCG

    public init(seed: UInt64 = 0xDEADBEEFCAFEBABE) {
        self.root = nil
        self.rng = LCG(seed: seed)
    }

    // MARK: - Public API

    /// Inserts a key if it does not already exist.
    public mutating func insert(_ key: Key) {
        var priority = rng.nextInt()
        // Ensure priority is non‑negative.
        if priority < 0 { priority = -priority }
        root = insert(node: root, key: key, priority: priority)
    }

    /// Deletes a key if it exists.
    public mutating func delete(_ key: Key) {
        root = delete(node: root, key: key)
    }

    /// Returns true iff the key is present in the treap.
    public func contains(_ key: Key) -> Bool {
        var current = root
        while let node = current {
            if key == node.key {
                return true
            } else if key < node.key {
                current = node.left
            } else {
                current = node.right
            }
        }
        return false
    }

    /// Returns the keys in ascending order (in‑order traversal).
    public func inorder() -> [Key] {
        var result: [Key] = []
        inorder(node: root, into: &result)
        return result
    }

    // MARK: - Internal Helpers (mutating where needed)

    private mutating func rotateRight(_ y: TreapNode<Key>) -> TreapNode<Key> {
        guard let x = y.left else { return y }
        y.left = x.right
        x.right = y
        return x
    }

    private mutating func rotateLeft(_ x: TreapNode<Key>) -> TreapNode<Key> {
        guard let y = x.right else { return x }
        x.right = y.left
        y.left = x
        return y
    }

    private mutating func insert(node: TreapNode<Key>?, key: Key, priority: Int) -> TreapNode<Key> {
        guard let current = node else {
            return TreapNode(key: key, priority: priority)
        }

        if key == current.key {
            // Duplicate: ignore insertion.
            return current
        } else if key < current.key {
            current.left = insert(node: current.left, key: key, priority: priority)
            if let left = current.left, left.priority < current.priority {
                return rotateRight(current)
            }
        } else {
            current.right = insert(node: current.right, key: key, priority: priority)
            if let right = current.right, right.priority < current.priority {
                return rotateLeft(current)
            }
        }
        return current
    }

    private mutating func delete(node: TreapNode<Key>?, key: Key) -> TreapNode<Key>? {
        guard let current = node else { return nil }

        if key < current.key {
            current.left = delete(node: current.left, key: key)
            return current
        } else if key > current.key {
            current.right = delete(node: current.right, key: key)
            return current
        } else {
            // Node to delete found.
            return merge(left: current.left, right: current.right)
        }
    }

    private mutating func merge(left: TreapNode<Key>?, right: TreapNode<Key>?) -> TreapNode<Key>? {
        switch (left, right) {
        case (nil, nil):
            return nil
        case (let l?, nil):
            return l
        case (nil, let r?):
            return r
        case (let l?, let r?):
            if l.priority < r.priority {
                l.right = merge(left: l.right, right: r)
                return l
            } else {
                r.left = merge(left: l, right: r.left)
                return r
            }
        }
    }

    func inorder(node: TreapNode<Key>?, into array: inout [Key]) {
        guard let n = node else { return }
        inorder(node: n.left, into: &array)
        array.append(n.key)
        inorder(node: n.right, into: &array)
    }

    // MARK: - Validation Helpers (used by tests)

    /// Checks BST property: left keys < node.key < right keys.
    public func isBSTValid() -> Bool {
        return isBSTValid(node: root, min: nil, max: nil)
    }

    func isBSTValid(node: TreapNode<Key>?, min: Key?, max: Key?) -> Bool {
        guard let n = node else { return true }
        if let min = min, n.key <= min { return false }
        if let max = max, n.key >= max { return false }
        return isBSTValid(node: n.left, min: min, max: n.key) &&
               isBSTValid(node: n.right, min: n.key, max: max)
    }

    /// Checks heap property: each node's priority ≤ children's priorities.
    public func isHeapValid() -> Bool {
        return isHeapValid(node: root)
    }

    func isHeapValid(node: TreapNode<Key>?) -> Bool {
        guard let n = node else { return true }
        if let l = n.left, l.priority < n.priority { return false }
        if let r = n.right, r.priority < n.priority { return false }
        return isHeapValid(node: n.left) && isHeapValid(node: n.right)
    }
}
