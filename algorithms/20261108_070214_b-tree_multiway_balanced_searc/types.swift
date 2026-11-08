import Foundation

/// A node in a B-Tree. Uses a class to allow recursive references.
public final class BTreeNode<Key: Comparable> {
    /// The keys stored in this node, kept in sorted order.
    public var keys: [Key] = []
    /// Child pointers. For a leaf node this array is empty.
    public var children: [BTreeNode] = []
    /// Indicates whether this node is a leaf.
    public var leaf: Bool

    /// Creates a new node.
    /// - Parameter leaf: true if the node should be a leaf.
    public init(leaf: Bool) {
        self.leaf = leaf
    }

    /// Returns the number of keys currently stored.
    public var keyCount: Int {
        return keys.count
    }

    /// Returns the number of children currently stored.
    public var childCount: Int {
        return children.count
    }
}
