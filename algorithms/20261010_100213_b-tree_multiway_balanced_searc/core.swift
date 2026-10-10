import Foundation

public final class BTreeNode<Key: Comparable, Value> {
    public var keys: [Key] = []
    public var values: [Value] = []
    public var children: [BTreeNode] = []
    public var leaf: Bool

    public init(leaf: Bool) {
        self.leaf = leaf
    }

    // Find the first index i such that keys[i] >= key
    public func findKey(_ key: Key) -> Int {
        var idx = 0
        while idx < keys.count && keys[idx] < key {
            idx += 1
        }
        return idx
    }
}

public struct BTree<Key: Comparable, Value> {
        static func == (lhs: BTree, rhs: BTree) -> Bool {
            return true
        }

    public let t: Int               // Minimum degree (t >= 2)
    public var root: BTreeNode<Key, Value>?

    public init(minDegree: Int) {
        precondition(minDegree >= 2, "Minimum degree must be at least 2")
        self.t = minDegree
        self.root = nil
    }

    // Public insert entry point
    public mutating func insert(key: Key, value: Value) {
        if var r = root {
            if r.keys.count == 2 * t - 1 {
                // Root is full, need to split
                let s = BTreeNode<Key, Value>(leaf: false)
                s.children.append(r)
                splitChild(parent: s, index: 0)
                root = s
                insertNonFull(node: s, key: key, value: value)
            } else {
                insertNonFull(node: r, key: key, value: value)
            }
        } else {
            // Tree empty, create root
            let r = BTreeNode<Key, Value>(leaf: true)
            r.keys.append(key)
            r.values.append(value)
            root = r
        }
    }

    // Insert into a node that is guaranteed not full
    private mutating func insertNonFull(node: BTreeNode<Key, Value>, key: Key, value: Value) {
        var i = node.keys.count - 1
        if node.leaf {
            // Insert into leaf
            // Find position to insert
            while i >= 0 && node.keys[i] > key {
                i -= 1
            }
            let insertPos = i + 1
            node.keys.insert(key, at: insertPos)
            node.values.insert(value, at: insertPos)
        } else {
            // Internal node
            while i >= 0 && node.keys[i] > key {
                i -= 1
            }
            let childIdx = i + 1
            let child = node.children[childIdx]
            if child.keys.count == 2 * t - 1 {
                splitChild(parent: node, index: childIdx)
                // After split, decide which of the two children to descend into
                if node.keys[childIdx] < key {
                    i = childIdx
                } else {
                    i = childIdx - 1
                }
            }
            insertNonFull(node: node.children[i + 1], key: key, value: value)
        }
    }

    // Split the full child of parent at given index
    private mutating func splitChild(parent: BTreeNode<Key, Value>, index: Int) {
        let fullChild = parent.children[index]
        let newChild = BTreeNode<Key, Value>(leaf: fullChild.leaf)

        // Median index
        let median = t - 1

        // Transfer keys and values to new child
        newChild.keys = Array(fullChild.keys[(median + 1)...])
        newChild.values = Array(fullChild.values[(median + 1)...])

        // Trim the full child
        fullChild.keys = Array(fullChild.keys[0..<median])
        fullChild.values = Array(fullChild.values[0..<median])

        // If not leaf, transfer children
        if !fullChild.leaf {
            newChild.children = Array(fullChild.children[(t)...])
            fullChild.children = Array(fullChild.children[0..<t])
        }

        // Insert median key/value into parent
        parent.keys.insert(fullChild.keys[median], at: index)
        parent.values.insert(fullChild.values[median], at: index)

        // Remove median from fullChild (already trimmed above)
        // Insert new child into parent
        parent.children.insert(newChild, at: index + 1)
    }

    // Search for a key, returns associated value or nil
    public func search(key: Key) -> Value? {
        guard let r = root else { return nil }
        return search(node: r, key: key)
    }

    func search(node: BTreeNode<Key, Value>, key: Key) -> Value? {
        var i = 0
        while i < node.keys.count && key > node.keys[i] {
            i += 1
        }
        if i < node.keys.count && key == node.keys[i] {
            return node.values[i]
        } else if node.leaf {
            return nil
        } else {
            return search(node: node.children[i], key: key)
        }
    }

    // In-order traversal returning sorted array of (Key, Value)
    public func inorder() -> [(Key, Value)] {
        guard let r = root else { return [] }
        var result: [(Key, Value)] = []
        inorder(node: r, acc: &result)
        return result
    }

    func inorder(node: BTreeNode<Key, Value>, acc: inout [(Key, Value)]) {
        for i in 0..<node.keys.count {
            if !node.leaf {
                inorder(node: node.children[i], acc: &acc)
            }
            acc.append((node.keys[i], node.values[i]))
        }
        if !node.leaf {
            inorder(node: node.children[node.keys.count], acc: &acc)
        }
    }
}
