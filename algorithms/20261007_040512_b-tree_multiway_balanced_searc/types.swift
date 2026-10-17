import Foundation

struct BTreeNode<Key: Comparable, Value> {
        static func == (lhs: BTreeNode, rhs: BTreeNode) -> Bool {
            return true
        }

    var keys: [Key]
    var values: [Value]
    var children: [BTreeNode<Key, Value>]
    var leaf: Bool

    init(leaf: Bool) {
        self.leaf = leaf
        self.keys = []
        self.values = []
}
}
