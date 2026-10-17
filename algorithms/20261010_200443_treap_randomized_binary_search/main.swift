import Foundation

// Simple test harness using assertions
func testInsertionAndSearch() {
    var treap = Treap<Int, String>()
    let pairs = [(5, "five"), (3, "three"), (8, "eight"), (1, "one"), (4, "four")]
    for (k, v) in pairs {
        treap.insert(key: k, value: v)
    }
    for (k, v) in pairs {
        let found = treap.find(key: k)
        assert(found == v, "Search failed for key \(k)")
    }
    assert(treap.find(key: 99) == nil, "Non‑existent key returned a value")
}

func testInorderSorted() {
    var treap = Treap<Int, Int>()
    let keys = [42, 7, 13, 99, 0, 55, 23]
    for k in keys {
        treap.insert(key: k, value: k * 10)
    }
    let inorder = treap.inorderKeys()
    let sorted = keys.sorted()
    assert(inorder == sorted, "Inorder traversal not sorted")
}

func testDeletion() {
    var treap = Treap<Int, String>()
    let keys = [10, 20, 30, 40, 50]
    for k in keys {
        treap.insert(key: k, value: "v\(k)")
    }
    treap.delete(key: 30)
    treap.delete(key: 10)
    assert(treap.find(key: 30) == nil, "Deleted key 30 still found")
    assert(treap.find(key: 10) == nil, "Deleted key 10 still found")
    let remaining = treap.inorderKeys()
    let expected = [20, 40, 50]
    assert(remaining == expected, "Remaining keys after deletion incorrect")
}

func testHeapProperty() {
    var treap = Treap<Int, Int>()
    for i in 1...100 {
        treap.insert(key: i, value: i)
    }
    assert(treap.checkHeapProperty(), "Heap property violated")
}

func testDeterministicStructure() {
    var treap1 = Treap<Int, Int>()
    var treap2 = Treap<Int, Int>()
    let keys = [15, 6, 23, 4, 7, 71, 5]
    for k in keys {
        treap1.insert(key: k, value: k)
        treap2.insert(key: k, value: k)
    }
    // Inorder must match
    assert(treap1.inorderKeys() == treap2.inorderKeys(), "Inorder mismatch")
    // Priorities must be identical because generator is deterministic
    func collectPriorities(_ node: TreapNode<Int, Int>?, into arr: inout [UInt64]) {
        guard let n = node else { return }
        collectPriorities(n.left, into: &arr)
        arr.append(n.priority)
        collectPriorities(n.right, into: &arr)
    }
    var p1: [UInt64] = []
    var p2: [UInt64] = []
    collectPriorities(treap1.root, into: &p1)
    collectPriorities(treap2.root, into: &p2)
    assert(p1 == p2, "Deterministic priorities differ")
}

// Execute tests
func runAllTests() {
    testInsertionAndSearch()
    testInorderSorted()
    testDeletion()
    testHeapProperty()
    testDeterministicStructure()
    print("All treap tests passed.")
}

runAllTests()
