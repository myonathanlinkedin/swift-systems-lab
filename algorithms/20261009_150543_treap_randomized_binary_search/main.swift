import Foundation

// Helper to assert conditions with messages
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
    Swift.assert(condition(), message)
}

// Unit tests for Treap
func runTests() {
    // Test 1: Basic insertion and find
    var treap = Treap<Int, String>(seed: 12345)
    treap.insert(key: 5, value: "five")
    treap.insert(key: 2, value: "two")
    treap.insert(key: 8, value: "eight")
    treap.insert(key: 1, value: "one")
    treap.insert(key: 3, value: "three")
    treap.insert(key: 7, value: "seven")
    treap.insert(key: 9, value: "nine")

    assert(treap.find(key: 5) == "five", "Find 5")
    assert(treap.find(key: 1) == "one", "Find 1")
    assert(treap.find(key: 9) == "nine", "Find 9")
    assert(treap.find(key: 4) == nil, "Find missing key")

    // Test 2: In‑order traversal yields sorted keys
    let sorted = treap.inorderKeys()
    assert(sorted == [1, 2, 3, 5, 7, 8, 9], "Inorder sorted")

    // Test 3: Structural validation (BST + heap)
    assert(treap.validate(), "Treap validates after insertions")

    // Test 4: Delete leaf node
    treap.delete(key: 1)
    assert(treap.find(key: 1) == nil, "Deleted leaf")
    assert(treap.inorderKeys() == [2, 3, 5, 7, 8, 9], "Inorder after leaf delete")
    assert(treap.validate(), "Validate after leaf delete")

    // Test 5: Delete node with one child
    treap.delete(key: 8) // 8 has right child 9
    assert(treap.find(key: 8) == nil, "Deleted node with one child")
    assert(treap.inorderKeys() == [2, 3, 5, 7, 9], "Inorder after one‑child delete")
    assert(treap.validate(), "Validate after one‑child delete")

    // Test 6: Delete node with two children
    treap.delete(key: 5) // root with children 2 and 7
    assert(treap.find(key: 5) == nil, "Deleted node with two children")
    assert(treap.inorderKeys() == [2, 3, 7, 9], "Inorder after two‑children delete")
    assert(treap.validate(), "Validate after two‑children delete")

    // Test 7: Delete non‑existent key (should be no‑op)
    treap.delete(key: 42)
    assert(treap.inorderKeys() == [2, 3, 7, 9], "No change after deleting missing key")
    assert(treap.validate(), "Validate after missing delete")

    // Test 8: Insert duplicate key replaces value
    treap.insert(key: 3, value: "THREE")
    assert(treap.find(key: 3) == "THREE", "Duplicate key replacement")
    assert(treap.validate(), "Validate after duplicate insertion")

    // Test 9: Empty treap behavior
    var emptyTreap = Treap<Int, Int>()
    assert(emptyTreap.find(key: 0) == nil, "Find on empty")
    assert(emptyTreap.inorderKeys().isEmpty, "Inorder empty")
    assert(emptyTreap.validate(), "Validate empty")

    // Test 10: Large random insertion set (deterministic due to seed)
    var largeTreap = Treap<Int, Int>(seed: 999)
    let count = 1000
    for i in 0..<count {
        largeTreap.insert(key: i, value: i * i)
    }
    // Verify all keys present and values correct
    for i in 0..<count {
        assert(largeTreap.find(key: i) == i * i, "Large find \(i)")
    }
    // Verify ordering
    assert(largeTreap.inorderKeys() == Array(0..<count), "Large inorder")
    assert(largeTreap.validate(), "Validate large treap")
}

// Execute tests
runTests()
print("All Treap tests passed.")
