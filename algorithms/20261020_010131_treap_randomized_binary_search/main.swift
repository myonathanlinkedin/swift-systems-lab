import Foundation

// Helper to assert a condition with a message
func expect(_ condition: @autoclosure () -> Bool, _ message: String = "Assertion failed") {
    assert(condition(), message)
}

// Unit Tests for Treap
func runTests() {
    // Create a treap with deterministic seed
    var treap = Treap<Int, String>(seed: 123456789)

    // Insert a set of keys
    let keys = [5, 3, 7, 2, 4, 6, 8]
    for k in keys {
        treap.insert(key: k, value: "v\(k)")
    }

    // Verify inorder traversal yields sorted keys
    let inorder = treap.inorder().map { $0.0 }
    expect(inorder == [2, 3, 4, 5, 6, 7, 8], "Inorder not sorted")

    // Verify heap property holds after insertions
    expect(treap.verifyHeapProperty(), "Heap property violated after insertions")

    // Test find operation for existing and missing keys
    expect(treap.find(4) == "v4", "Find failed for existing key")
    expect(treap.find(10) == nil, "Find should return nil for missing key")

    // Test duplicate insertion replaces value
    treap.insert(key: 5, value: "new5")
    expect(treap.find(5) == "new5", "Duplicate insert did not replace value")
    // Ensure no duplicate key appears in inorder
    let keysAfterDup = treap.inorder().map { $0.0 }
    expect(keysAfterDup.filter { $0 == 5 }.count == 1, "Duplicate key present after replacement")

    // Delete a leaf node
    treap.delete(key: 2)
    expect(treap.find(2) == nil, "Delete failed for leaf node")
    expect(treap.inorder().map { $0.0 } == [3, 4, 5, 6, 7, 8], "Inorder incorrect after leaf deletion")
    expect(treap.verifyHeapProperty(), "Heap property violated after leaf deletion")

    // Delete a node with one child
    treap.delete(key: 7) // 7 has child 8
    expect(treap.find(7) == nil, "Delete failed for node with one child")
    expect(treap.inorder().map { $0.0 } == [3, 4, 5, 6, 8], "Inorder incorrect after single-child deletion")
    expect(treap.verifyHeapProperty(), "Heap property violated after single-child deletion")

    // Delete a node with two children
    treap.delete(key: 5) // root may have two children depending on priorities
    expect(treap.find(5) == nil, "Delete failed for node with two children")
    expect(treap.inorder().map { $0.0 } == [3, 4, 6, 8], "Inorder incorrect after two-children deletion")
    expect(treap.verifyHeapProperty(), "Heap property violated after two-children deletion")

    // Stress test: insert many sequential keys and verify properties
    var stressTreap = Treap<Int, Int>(seed: 42)
    let n = 1000
    for i in 0..<n {
        stressTreap.insert(key: i, value: i * i)
    }
    expect(stressTreap.inorder().map { $0.0 } == Array(0..<n), "Stress test inorder mismatch")
    expect(stressTreap.verifyHeapProperty(), "Stress test heap property violated")
    // Random deletions
    for i in stride(from: n - 1, through: 0, by: -2) {
        stressTreap.delete(key: i)
    }
    let remaining = stressTreap.inorder().map { $0.0 }
    expect(remaining == Array(stride(from: 0, to: n, by: 2)), "Stress test after deletions mismatch")
    expect(stressTreap.verifyHeapProperty(), "Stress test heap property after deletions violated")
}

// Entry point
runTests()
print("All Treap tests passed.")
