import Foundation

// Simple deterministic test data.
let testKeys: [Int] = [50, 20, 70, 10, 30, 60, 80, 25, 35, 65, 75, 85]
let duplicateKeys: [Int] = [20, 70, 10]   // keys that will be re‑inserted with new values.

// MARK: Unit Tests

func testInsertionAndOrder() {
    var tree = WeightBalancedTree<Int, String>()
    for (i, k) in testKeys.enumerated() {
        tree.insert(k, "v\(i)")
    }
    // Verify count.
    assert(tree.count == testKeys.count, "Count mismatch after insertions")
    // Verify in‑order sequence is sorted.
    let inorder = tree.inorder().map { $0.0 }
    let sorted = testKeys.sorted()
    assert(inorder == sorted, "In‑order traversal not sorted")
    // Verify search returns correct values.
    for (i, k) in testKeys.enumerated() {
        let v = tree.search(k)
        assert(v == "v\(i)", "Search returned wrong value for key \(k)")
    }
}

func testDuplicateInsertion() {
    var tree = WeightBalancedTree<Int, String>()
    for (i, k) in testKeys.enumerated() {
        tree.insert(k, "orig\(i)")
    }
    // Re‑insert duplicates with new values.
    for (i, k) in duplicateKeys.enumerated() {
        tree.insert(k, "dup\(i)")
    }
    // Ensure values were overwritten.
    for (i, k) in duplicateKeys.enumerated() {
        let v = tree.search(k)
        assert(v == "dup\(i)", "Duplicate insertion failed for key \(k)")
    }
    // Count must remain unchanged.
    assert(tree.count == testKeys.count, "Count changed after duplicate insertions")
}

func testDeletion() {
    var tree = WeightBalancedTree<Int, String>()
    for (i, k) in testKeys.enumerated() {
        tree.insert(k, "val\(i)")
    }
    // Delete a leaf.
    tree.delete(10)
    assert(tree.search(10) == nil, "Failed to delete leaf node")
    // Delete a node with one child.
    tree.delete(80) // 80 is a leaf in this set, but after previous deletions it may have one child.
    assert(tree.search(80) == nil, "Failed to delete node with one child")
    // Delete a node with two children.
    tree.delete(70)
    assert(tree.search(70) == nil, "Failed to delete node with two children")
    // Verify remaining count.
    let expectedCount = testKeys.count - 3
    assert(tree.count == expectedCount, "Count mismatch after deletions")
    // Verify order of remaining keys.
    let remaining = tree.inorder().map { $0.0 }
    let expected = testKeys.filter { ![10, 70, 80].contains($0) }.sorted()
    assert(remaining == expected, "In‑order after deletions incorrect")
}

func testBalanceProperty() {
    var tree = WeightBalancedTree<Int, Int>()
    // Insert a large number of sequential keys to stress balancing.
    for i in 0..<1000 {
        tree.insert(i, i)
    }
    // Verify height is O(log n) by checking that the deepest leaf depth
    // does not exceed 20 * log2(n) (a generous bound for α = 2/3).
    func maxDepth(_ node: WeightBalancedTree<Int, Int>.Node?) -> Int {
        guard let n = node else { return 0 }
        return 1 + max(maxDepth(n.left), maxDepth(n.right))
    }
    let depth = maxDepth(tree.root)
    let bound = Int(20.0 * log2(Double(tree.count + 1)))
    assert(depth <= bound, "Tree depth \(depth) exceeds expected bound \(bound)")
}

// Execute tests.
testInsertionAndOrder()
testDuplicateInsertion()
testDeletion()
testBalanceProperty()

print("All weight‑balanced tree tests passed.")
