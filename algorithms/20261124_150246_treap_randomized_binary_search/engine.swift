import Foundation

extension Treap {
    // MARK: - Core Helpers

    /// Merges two treaps where all keys in `left` are < all keys in `right`.
    func merge(_ left: TreapNode<Key>?, _ right: TreapNode<Key>?) -> TreapNode<Key>? {
        guard let left = left else { return right }
        guard let right = right else { return left }

        if left.priority > right.priority {
            left.right = merge(left.right, right)
            return left
        } else {
            right.left = merge(left, right.left)
            return right
        }
    }

    /// Splits `node` into two treaps: keys < `key` and keys ≥ `key`.
    func split(_ node: TreapNode<Key>?, _ key: Key) -> (less: TreapNode<Key>?, greaterOrEqual: TreapNode<Key>?) {
        guard let node = node else { return (nil, nil) }

        if node.key < key {
            let (l, r) = split(node.right, key)
            node.right = l
            return (node, r)
        } else {
            let (l, r) = split(node.left, key)
            node.left = r
            return (l, node)
        }
    }

    // MARK: - Public API

    /// Inserts `key` into the treap. Duplicate keys are ignored.
    public mutating func insert(_ key: Key) {
        // If key already exists, do nothing.
        if search(key) { return }

        var priority = rng.nextInt()
        // Ensure priority is positive.
        if priority < 0 { priority = -priority }

        let newNode = TreapNode(key: key, priority: priority)
        let (less, greaterOrEqual) = split(root, key)
        let mergedLeft = merge(less, newNode)
        root = merge(mergedLeft, greaterOrEqual)
    }

    /// Deletes `key` from the treap. If key does not exist, nothing happens.
    public mutating func delete(_ key: Key) {
        root = delete(node: root, key: key)
    }

    func delete(node: TreapNode<Key>?, key: Key) -> TreapNode<Key>? {
        guard let node = node else { return nil }

        if key == node.key {
            // Merge children to remove this node.
            return merge(node.left, node.right)
        } else if key < node.key {
            node.left = delete(node: node.left, key: key)
        } else {
            node.right = delete(node: node.right, key: key)
        }
        return node
    }

    /// Returns true iff `key` exists in the treap.
    public func search(_ key: Key) -> Bool {
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

    /// Returns the number of nodes in the treap.
    public func size() -> Int {
        return count(node: root)
    }

    func count(node: TreapNode<Key>?) -> Int {
        guard let node = node else { return 0 }
        return 1 + count(node: node.left) + count(node: node.right)
    }

    /// Returns an in‑order array of keys (sorted ascending).
    public func inorder() -> [Key] {
        var result: [Key] = []
        inorder(node: root, into: &result)
        return result
    }

    func inorder(node: TreapNode<Key>?, into array: inout [Key]) {
        guard let node = node else { return }
        inorder(node: node.left, into: &array)
        array.append(node.key)
        inorder(node: node.right, into: &array)
    }

    // MARK: - Validation

    /// Checks BST property (in‑order sorted) and heap property (parent priority ≥ children priority).
    public func validate() -> Bool {
        // BST check via inorder traversal.
        let sorted = inorder()
        for i in 1..<sorted.count {
            if !(sorted[i - 1] < sorted[i]) {
                return false
            }
        }
        // Heap check via recursion.
        return validateHeap(node: root)
    }

    func validateHeap(node: TreapNode<Key>?) -> Bool {
        guard let node = node else { return true }
        if let left = node.left {
            if left.priority > node.priority { return false }
            if !validateHeap(node: left) { return false }
        }
        if let right = node.right {
            if right.priority > node.priority { return false }
            if !validateHeap(node: right) { return false }
        }
        return true
    }
}
