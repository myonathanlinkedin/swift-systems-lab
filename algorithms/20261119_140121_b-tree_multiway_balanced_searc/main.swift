import Foundation

// Simple assertion helper.
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    if a != b {
        fatalError("Assertion failed: \(message) Expected \(b), got \(a)")
    }
}

// Test 1: Insert keys that cause root split.
func testRootSplit() {
    var tree = BTree<Int>(minDegree: 2) // Max 3 keys per node.
    let keys = [10, 20, 5, 6, 12, 30, 7, 17]
    for k in keys {
        tree.insert(k)
    }
    // After these insertions, the B-Tree of minDegree 2 should have root with 2 keys.
    let rootKeys = tree.traverse()
    let expected = [5,6,7,10,12,17,20,30]
    assertEqual(rootKeys, expected, "In-order traversal after root split")
}

// Test 2: Verify search works.
func testSearch() {
    var tree = BTree<String>(minDegree: 3)
    let words = ["delta", "alpha", "epsilon", "beta", "gamma"]
    for w in words {
        tree.insert(w)
    }
    assertEqual(tree.search("beta"), true, "Search existing key")
    assertEqual(tree.search("zeta"), false, "Search non‑existing key")
}

// Test 3: Deep split (multiple levels).
func testDeepSplit() {
    var tree = BTree<Int>(minDegree: 3) // Max 5 keys per node.
    // Insert enough keys to force splits at depth 2.
    for i in 1...30 {
        tree.insert(i * 2) // even numbers 2..60
    }
    // Verify total count and ordering.
    let traversed = tree.traverse()
    let expected = (1...30).map { $0 * 2 }
    assertEqual(traversed, expected, "Deep split traversal")
}

// Run all tests.
func runTests() {
    testRootSplit()
    testSearch()
    testDeepSplit()
    print("All B-Tree tests passed.")
}

runTests()
