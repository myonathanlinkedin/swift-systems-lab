import Foundation

// MARK: - Unit Tests

func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    if lhs != rhs {
        fatalError("Assertion failed: \(lhs) != \(rhs). \(message)")
    }
}

func assertTrue(_ condition: Bool, _ message: String = "") {
    if !condition {
        fatalError("Assertion failed: condition is false. \(message)")
    }
}

func testTreapInsertionAndInorder() {
    var treap = Treap<Int, String>()
    let items = [(5, "five"), (3, "three"), (7, "seven"), (2, "two"),
                 (4, "four"), (6, "six"), (8, "eight")]
    for (k, v) in items { treap.insert(k, value: v) }

    let inorder = treap.inorder()
    let expectedKeys = [2,3,4,5,6,7,8]
    let actualKeys = inorder.map { $0.0 }
    assertEqual(actualKeys, expectedKeys, "Inorder keys mismatch after insertion")

    // Verify heap property: each node's priority <= children's priorities
    func checkHeap(_ node: Treap<Int, String>.Node?) -> Bool {
        guard let node = node else { return true }
        if let left = node.left {
            assertTrue(left.priority >= node.priority, "Heap violation at left child")
        }
        if let right = node.right {
            assertTrue(right.priority >= node.priority, "Heap violation at right child")
        }
        return checkHeap(node.left) && checkHeap(node.right)
    }
    assertTrue(checkHeap(treap.root), "Heap property violated after insertion")
}

func testTreapDeletion() {
    var treap = Treap<Int, String>()
    let items = [(5, "five"), (3, "three"), (7, "seven"), (2, "two"),
                 (4, "four"), (6, "six"), (8, "eight")]
    for (k, v) in items { treap.insert(k, value: v) }

    treap.delete(4)
    let inorder = treap.inorder()
    let expectedKeys = [2,3,5,6,7,8]
    let actualKeys = inorder.map { $0.0 }
    assertEqual(actualKeys, expectedKeys, "Inorder keys mismatch after deletion")

    // Ensure deleted key is absent
    assertTrue(treap.find(4) == nil, "Deleted key still present")
}

func testTreapFind() {
    var treap = Treap<Int, String>()
    treap.insert(10, value: "ten")
    treap.insert(20, value: "twenty")
    treap.insert(5, value: "five")

    assertEqual(treap.find(10), "ten", "Find failed for key 10")
    assertEqual(treap.find(20), "twenty", "Find failed for key 20")
    assertEqual(treap.find(5), "five", "Find failed for key 5")
    assertTrue(treap.find(15) == nil, "Find returned value for non-existent key")
}

func testTreapEmpty() {
    var treap = Treap<Int, String>()
    assertTrue(treap.inorder().isEmpty, "Inorder not empty for empty treap")
    assertTrue(treap.find(1) == nil, "Find returned value for empty treap")
    treap.delete(1) // Should not crash
}

func runAllTests() {
    testTreapInsertionAndInorder()
    testTreapDeletion()
    testTreapFind()
    testTreapEmpty()
    print("All tests passed.")
}

runAllTests()
