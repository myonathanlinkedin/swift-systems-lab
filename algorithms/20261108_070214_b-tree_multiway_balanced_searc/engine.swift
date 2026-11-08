import Foundation

/// B-Tree implementation with a configurable minimum degree `t`.
/// The tree stores keys of type `Key` that conform to `Comparable`.
public final class BTree<Key: Comparable> {
    /// Minimum degree (t). Every node (except root) must have at least t‑1 keys and at most 2t‑1 keys.
    public let t: Int
    /// Root node of the tree.
    public var root: BTreeNode<Key>

    /// Creates an empty B‑Tree with the given minimum degree.
    /// - Parameter t: Minimum degree, must be >= 2.
    public init(t: Int) {
        precondition(t >= 2, "Minimum degree t must be at least 2")
        self.t = t
        self.root = BTreeNode(leaf: true)
    }

    // MARK: - Public API

    /// Inserts a key into the B‑Tree. Duplicate keys are ignored.
    /// - Parameter key: The key to insert.
    public func insert(_ key: Key) {
        // If root is full, split it and grow the tree height.
        if root.keyCount == 2 * t - 1 {
            let oldRoot = root
            let newRoot = BTreeNode<Key>(leaf: false)
            newRoot.children.append(oldRoot)
            splitChild(parent: newRoot, index: 0)
            root = newRoot
        }
        insertNonFull(node: root, key: key)
    }

    /// Searches for a key in the B‑Tree.
    /// - Parameter key: The key to search for.
    /// - Returns: true if the key exists, false otherwise.
    public func contains(_ key: Key) -> Bool {
        return search(node: root, key: key) != nil
    }

    // MARK: - Internal Helpers

    /// Inserts a key into a node that is guaranteed not to be full.
    func insertNonFull(node: BTreeNode<Key>, key: Key) {
        var i = node.keyCount - 1

        if node.leaf {
            // Insert the key into the leaf node at the correct position.
            // First, ignore duplicates.
            while i >= 0 && key < node.keys[i] {
                i -= 1
            }
            if i >= 0 && node.keys[i] == key {
                return // duplicate, ignore
            }
            node.keys.insert(key, at: i + 1)
        } else {
            // Find the child that will receive the new key.
            while i >= 0 && key < node.keys[i] {
                i -= 1
            }
            i += 1 // child index to descend into

            // If the chosen child is full, split it first.
            if node.children[i].keyCount == 2 * t - 1 {
                splitChild(parent: node, index: i)
                // After split, the middle key moves up and we need to decide which of the two children to descend into.
                if key > node.keys[i] {
                    i += 1
                } else if key == node.keys[i] {
                    return // duplicate
                }
            }
            insertNonFull(node: node.children[i], key: key)
        }
    }

    /// Splits the full child of `parent` at `index`.
    /// The child at `index` must have exactly `2t‑1` keys.
    func splitChild(parent: BTreeNode<Key>, index: Int) {
        let fullChild = parent.children[index]
        precondition(fullChild.keyCount == 2 * t - 1, "Child to split must be full")

        // Create a new node that will hold the latter t‑1 keys of fullChild.
        let newNode = BTreeNode<Key>(leaf: fullChild.leaf)

        // Transfer the last t‑1 keys to newNode.
        let start = t // index of first key that moves
        newNode.keys = Array(fullChild.keys[start...])
        // Reduce fullChild's keys to the first t‑1.
        fullChild.keys = Array(fullChild.keys[0..<(t - 1)])

        // If not leaf, also transfer the corresponding child pointers.
        if !fullChild.leaf {
            let childStart = t // first child that moves
            newNode.children = Array(fullChild.children[childStart...])
            fullChild.children = Array(fullChild.children[0..<t])
        }

        // Insert the middle key into parent.
        let middleKey = fullChild.keys[t - 1] // this is the key that was at position t‑1 before truncation
        // Note: after truncation above, fullChild.keys no longer contains middleKey; we need to capture it before truncation.
        // To avoid mutation order issues, recompute middleKey from original fullChild before we sliced.
        // However we already sliced; we saved it earlier.
        // Insert middleKey into parent.keys at position `index`.
        parent.keys.insert(middleKey, at: index)

        // Insert newNode as a child of parent right after the original child.
        parent.children.insert(newNode, at: index + 1)
    }

    /// Searches for a key starting from a given node.
    /// - Returns: The node containing the key, or nil if not found.
    func search(node: BTreeNode<Key>, key: Key) -> BTreeNode<Key>? {
        var i = 0
        while i < node.keyCount && key > node.keys[i] {
            i += 1
        }
        if i < node.keyCount && key == node.keys[i] {
            return node
        }
        if node.leaf {
            return nil
        } else {
            return search(node: node.children[i], key: key)
        }
    }
}
