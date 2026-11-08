import Foundation

// Helper to verify B‑Tree invariants recursively.
func verifyNode<Key: Comparable>(_ node: BTreeNode<Key>, t: Int, isRoot: Bool) -> Bool {
    // 1. Keys must be sorted.
    for i in 1..<node.keyCount {
        assert(node.keys[i - 1] < node.keys[i], "Keys are not sorted")
    }

    // 2. Number of children must be either 0 (leaf) or keyCount + 1.
    if node.leaf {
        assert(node.childCount == 0, "Leaf node has children")
    } else {
        assert(node.childCount == node.keyCount + 1, "Internal node child count mismatch")
    }

    // 3. Node degree constraints (except root).
    if !isRoot {
        assert(node.keyCount >= t - 1, "Node has too few keys")
    }
    assert(node.keyCount <= 2 * t - 1, "Node has too many keys")

    // 4. Recursively verify children.
    if !node.leaf {
        for child in node.children {
            _ = verifyNode(child, t: t, isRoot: false)
        }
    }
    return true
}

// Unit tests
func runTests() {
    // Test 1: Insert into empty tree, no split.
    let tree1 = BTree<Int>(t: 2)
    tree1.insert(10)
    assert(tree1.contains(10), "Tree should contain inserted key")
    assert(tree1.root.keyCount == 1, "Root should have one key")
    _ = verifyNode(tree1.root, t: 2, isRoot: true)

    // Test 2: Insert keys that cause a root split.
    let tree2 = BTree<Int>(t: 2) // max 3 keys per node
    let keys2 = [20, 40, 10, 30, 50] // Inserting 5 keys forces root split after 4th insertion.
    for k in keys2 {
        tree2.insert(k)
    }
    // After split, root should have 1 key (the median of first 4 keys) and two children.
    assert(tree2.root.keyCount == 1, "Root should have one key after split")
    assert(tree2.root.childCount == 2, "Root should have two children after split")
    // All keys must be searchable.
    for k in keys2 {
        assert(tree2.contains(k), "Tree should contain key \(k)")
    }
    _ = verifyNode(tree2.root, t: 2, isRoot: true)

    // Test 3: Larger tree with multiple levels.
    let tree3 = BTree<Int>(t: 3) // max 5 keys per node
    let keys3 = Array(1...30) // Insert 30 sequential keys.
    for k in keys3 {
        tree3.insert(k)
    }
    // Verify all keys are present.
    for k in keys3 {
        assert(tree3.contains(k), "Tree should contain key \(k)")
    }
    // Verify structural invariants.
    _ = verifyNode(tree3.root, t: 3, isRoot: true)

    // Test 4: Duplicate insertion should be ignored.
    let tree4 = BTree<Int>(t: 2)
    tree4.insert(15)
    tree4.insert(15) // duplicate
    assert(tree4.root.keyCount == 1, "Duplicate key should not increase key count")
    assert(tree4.contains(15), "Tree should contain the key")
    _ = verifyNode(tree4.root, t: 2, isRoot: true)

    // Test 5: Random insertion order, verify invariants.
    let tree5 = BTree<Int>(t: 4)
    var randomKeys = (1...100).shuffled()
    for k in randomKeys {
        tree5.insert(k)
    }
    for k in 1...100 {
        assert(tree5.contains(k), "Tree should contain key \(k)")
    }
    _ = verifyNode(tree5.root, t: 4, isRoot: true)

    print("All B‑Tree tests passed.")
}

// Execute tests
runTests()
