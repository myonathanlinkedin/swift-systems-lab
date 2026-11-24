import Foundation

// Helper to assert conditions with a message.
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
    Swift.assert(condition(), message)
}

// Test suite for Treap.
func runTests() {
    // Test 1: Basic insert and search.
    var treap = Treap<Int>(seed: 42)
    for i in 0..<10 {
        treap.insert(i)
    }
    assert(treap.size() == 10, "Size after inserts should be 10")
    for i in 0..<10 {
        assert(treap.search(i), "Key \(i) must be found")
    }
    assert(treap.validate(), "Treap must satisfy BST and heap properties after inserts")

    // Test 2: Duplicate insert ignored.
    treap.insert(5)
    assert(treap.size() == 10, "Duplicate insert should not change size")

    // Test 3: Delete leaf, internal node, and root.
    treap.delete(0)   // leaf
    assert(!treap.search(0), "Key 0 must be deleted")
    assert(treap.size() == 9, "Size after deleting leaf")
    assert(treap.validate(), "Treap valid after leaf deletion")

    treap.delete(5)   // internal node
    assert(!treap.search(5), "Key 5 must be deleted")
    assert(treap.size() == 8, "Size after deleting internal node")
    assert(treap.validate(), "Treap valid after internal deletion")

    // Delete remaining keys one by one.
    for key in [1,2,3,4,6,7,8,9] {
        treap.delete(key)
        assert(!treap.search(key), "Key \(key) must be deleted")
    }
    assert(treap.size() == 0, "Treap should be empty after deleting all keys")
    assert(treap.validate(), "Empty treap is trivially valid")

    // Test 4: Randomized insert order with deterministic RNG.
    var treap2 = Treap<Int>(seed: 12345)
    let shuffled = [7,3,9,1,5,8,2,6,4,0]
    for v in shuffled {
        treap2.insert(v)
    }
    assert(treap2.size() == 10, "Size after shuffled inserts")
    assert(treap2.inorder() == (0...9).map { $0 }, "Inorder must be sorted")
    assert(treap2.validate(), "Treap must be valid after shuffled inserts")

    // Test 5: Search for absent keys.
    assert(!treap2.search(-1), "Negative key not present")
    assert(!treap2.search(10), "Key 10 not present")
}

// Execute tests.
runTests()
print("All Treap tests passed.")
