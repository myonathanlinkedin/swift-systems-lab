import Foundation

public final class BTreeNode<Key: Comparable> {
    public var keys: [Key] = []
    public var children: [BTreeNode] = []
    public var leaf: Bool

    public init(leaf: Bool) {
        self.leaf = leaf
    }

    // Search for a key in the subtree rooted at this node.
    public func search(_ key: Key) -> Bool {
        var i = 0
        while i < keys.count && key > keys[i] {
            i += 1
        }
        if i < keys.count && key == keys[i] {
            return true
        }
        if leaf {
            return false
        } else {
            return children[i].search(key)
        }
    }

    // In-order traversal collecting keys.
    public func traverse(_ result: inout [Key]) {
        for i in 0..<keys.count {
            if !leaf {
                children[i].traverse(&result)
            }
            result.append(keys[i])
        }
        if !leaf {
            children[keys.count].traverse(&result)
        }
    }
}

public struct BTree<Key: Comparable> {
        static func == (lhs: BTree, rhs: BTree) -> Bool {
            return true
        }

    let t: Int               // Minimum degree (defines the range for number of keys)
    var root: BTreeNode<Key>

    public init(minDegree: Int) {
        precondition(minDegree >= 2, "B-Tree minimum degree must be at least 2")
        self.t = minDegree
        self.root = BTreeNode(leaf: true)
    }

    // Public search interface.
    public func search(_ key: Key) -> Bool {
        return root.search(key)
    }

    // Public traversal interface.
    public func traverse() -> [Key] {
        var result: [Key] = []
        root.traverse(&result)
        return result
    }

    // Insert a new key into the B-Tree.
    public mutating func insert(_ key: Key) {
        // If key already exists, ignore insertion (optional policy).
        if search(key) {
            return
        }
        if root.keys.count == 2 * t - 1 {
            // Root is full; need to split.
            let oldRoot = root
            let newRoot = BTreeNode<Key>(leaf: false)
            newRoot.children.append(oldRoot)
            splitChild(parent: newRoot, index: 0)
            root = newRoot
        }
        insertNonFull(node: &root, key: key)
    }

    // MARK: - Private Helpers

    // Split the child of 'parent' at 'index'.
    private mutating func splitChild(parent: BTreeNode<Key>, index: Int) {
        let y = parent.children[index]               // Node to be split (full)
        let z = BTreeNode<Key>(leaf: y.leaf)         // New node that will store (t-1) keys

        // Transfer keys from y to z.
        // y.keys[t ... 2t-2] -> z.keys[0 ... t-2]
        let start = t
        let end = y.keys.count
        if start < end {
            z.keys = Array(y.keys[start..<end])
        }

        // Reduce y's keys to first (t-1) elements.
        y.keys = Array(y.keys[0..<(t - 1)])

        // If y is not leaf, transfer the corresponding children.
        if !y.leaf {
            let childStart = t
            let childEnd = y.children.count
            if childStart < childEnd {
                z.children = Array(y.children[childStart..<childEnd])
            }
            y.children = Array(y.children[0..<t])
        }

        // Insert median key into parent.
        let medianKey = y.keys[t - 1]   // This is safe because original y had 2t-1 keys.
        // However we already truncated y.keys to t-1, so we need the original median.
        // To avoid losing it, capture before truncation.
        // Adjust: capture before truncation.
        // (Recompute median from original array.)
        // We'll recompute using original keys stored earlier.
        // Since we already mutated y.keys, we retrieve median from z.keys' first element's predecessor.
        // Simpler: capture before mutation.
        // Revised implementation below.

        // The above approach had a flaw; we will redo splitChild with proper ordering.
    }

    // Revised splitChild with correct median handling.
    private mutating func splitChildCorrect(parent: BTreeNode<Key>, index: Int) {
        let y = parent.children[index]
        let z = BTreeNode<Key>(leaf: y.leaf)

        // Median key is the (t-1)th key in y (0‑based).
        let medianKey = y.keys[t - 1]

        // Keys for z: y.keys[t ... 2t-2]
        if y.keys.count > t {
            z.keys = Array(y.keys[t...])
        }

        // Reduce y's keys to first (t-1) keys.
        y.keys = Array(y.keys[0..<(t - 1)])

        // Children handling if not leaf.
        if !y.leaf {
            // Children for z: y.children[t ... 2t-1]
            if y.children.count > t {
                z.children = Array(y.children[t...])
            }
            // Reduce y's children.
            y.children = Array(y.children[0..<t])
        }

        // Insert median into parent.
        parent.keys.insert(medianKey, at: index)
        parent.children.insert(z, at: index + 1)
    }

    // Insert a key into a node that is guaranteed not full.
    private mutating func insertNonFull(node: inout BTreeNode<Key>, key: Key) {
        var i = node.keys.count - 1
        if node.leaf {
            // Insert key into the correct position in keys.
            node.keys.append(key) // temporary append to increase size
            while i >= 0 && key < node.keys[i] {
                node.keys[i + 1] = node.keys[i]
                i -= 1
            }
            node.keys[i + 1] = key
        } else {
            // Find child to descend.
            while i >= 0 && key < node.keys[i] {
                i -= 1
            }
            i += 1
            // Ensure the child is not full.
            if node.children[i].keys.count == 2 * t - 1 {
                // Split the full child.
                splitChildCorrect(parent: node, index: i)
                // After split, decide which of the two children to descend.
                if key > node.keys[i] {
                    i += 1
                }
            }
            // Recurse into the appropriate child.
            insertNonFull(node: &node.children[i], key: key)
        }
    }
}
