import Foundation

// Simple test harness
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    if a != b {
        fatalError("Assertion failed: \(message) Expected \(b), got \(a)")
    }
}

// Test 1: Insert ascending keys into B-Tree of minimum degree 2
func testInsertionAndTraversal() {
    var tree = BTree<Int, String>(minDegree: 2)
    for i in 1...10 {
        tree.insert(key: i, value: "v\(i)")
    }
    let inorder = tree.inorder()
    // Verify length
    assertEqual(inorder.count, 10, "Inorder count")
    // Verify sorted order and values
    for (idx, pair) in inorder.enumerated() {
        let expectedKey = idx + 1
        assertEqual(pair.0, expectedKey, "Key at position \(idx)")
        assertEqual(pair.1, "v\(expectedKey)", "Value at position \(idx)")
    }
}

// Test 2: Search existing and non-existing keys
func testSearch() {
    var tree = BTree<Int, String>(minDegree: 3)
    let keys = [20, 5, 15, 25, 30, 10]
    for k in keys {
        tree.insert(key: k, value: "val\(k)")
    }
    for k in keys {
        let v = tree.search(key: k)
        assertEqual(v, "val\(k)", "Search existing key \(k)")
    }
    // Non-existing
    assertEqual(tree.search(key: 99), nil, "Search missing key")
}

// Test 3: Root split verification (force multiple splits)
func testRootSplit() {
    var tree = BTree<Int, Int>(minDegree: 2)
    // Insert enough keys to cause several root splits
    for i in 1...20 {
        tree.insert(key: i, value: i * i)
    }
    // Verify that all keys are present and correct
    let inorder = tree.inorder()
    assertEqual(inorder.count, 20, "Root split count")
    for (idx, pair) in inorder.enumerated() {
        let expectedKey = idx + 1
        assertEqual(pair.0, expectedKey, "Root split key \(expectedKey)")
        assertEqual(pair.1, expectedKey * expectedKey, "Root split value \(expectedKey)")
    }
}

// Run tests
func runAllTests() {
    testInsertionAndTraversal()
    testSearch()
    testRootSplit()
    print("All B-Tree tests passed.")
}

runAllTests()
