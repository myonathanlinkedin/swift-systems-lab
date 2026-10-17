import Foundation

// Helper to assert a condition with a message.
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
    Swift.assert(condition(), message)
}

// Test suite for Treap implementation.
func runTests() {
    // Test 1: Insert a known sequence and verify ordering and heap property.
    var treap = Treap<Int>(seed: 42) // deterministic seed
    let keysToInsert = [50, 20, 70, 10, 30, 60, 80, 25, 35]
    for key in keysToInsert {
        treap.insert(key)
    }

    // In‑order traversal must be sorted.
    let inorder = treap.inorder()
    assert(inorder == keysToInsert.sorted(), "Inorder traversal should be sorted.")

    // BST and heap invariants must hold.
    assert(treap.isBSTValid(), "BST property violated after insertions.")
    assert(treap.isHeapValid(), "Heap property violated after insertions.")

    // Test 2: Search existing and non‑existing keys.
    assert(treap.contains(30), "Treap should contain key 30.")
    assert(!treap.contains(99), "Treap should not contain key 99.")

    // Test 3: Delete leaf node, internal node with one child, and node with two children.
    var deleteTreap = treap // copy for independent deletions
    // Delete leaf (10)
    deleteTreap.delete(10)
    assert(!deleteTreap.contains(10), "Key 10 should have been deleted.")
    assert(deleteTreap.isBSTValid(), "BST property violated after deleting leaf.")
    assert(deleteTreap.isHeapValid(), "Heap property violated after deleting leaf.")

    // Delete node with one child (70 has children 60 and 80)
    deleteTreap.delete(70)
    assert(!deleteTreap.contains(70), "Key 70 should have been deleted.")
    assert(deleteTreap.isBSTValid(), "BST property violated after deleting node with two children.")
    assert(deleteTreap.isHeapValid(), "Heap property violated after deleting node with two children.")

    // Delete node with two children (20 has children 25 and 30)
    deleteTreap.delete(20)
    assert(!deleteTreap.contains(20), "Key 20 should have been deleted.")
    assert(deleteTreap.isBSTValid(), "BST property violated after deleting node with two children.")
    assert(deleteTreap.isHeapValid(), "Heap property violated after deleting node with two children.")

    // Test 4: Delete non‑existent key (should be no‑op and keep invariants).
    let beforeInorder = deleteTreap.inorder()
    deleteTreap.delete(999)
    assert(deleteTreap.inorder() == beforeInorder, "Deleting non‑existent key altered the treap.")
    assert(deleteTreap.isBSTValid(), "BST property violated after deleting non‑existent key.")
    assert(deleteTreap.isHeapValid(), "Heap property violated after deleting non‑existent key.")

    // Test 5: Insert duplicate keys (should be ignored).
    let duplicateKey = 25
    let countBefore = deleteTreap.inorder().filter { $0 == duplicateKey }.count
    deleteTreap.insert(duplicateKey)
    let countAfter = deleteTreap.inorder().filter { $0 == duplicateKey }.count
    assert(countBefore == countAfter, "Duplicate insertion should not increase count.")

    // Test 6: Stress test with many random insertions and deletions.
    var stressTreap = Treap<Int>(seed: 12345)
    var referenceSet = Set<Int>()
    let totalOps = 10_000
    var rng = LCG(seed: 987654321)

    for _ in 0..<totalOps {
        let op = rng.next() % 2
        let value = Int(rng.next() % 1_000_000)
        if op == 0 {
            // Insert
            stressTreap.insert(value)
            referenceSet.insert(value)
        } else {
            // Delete
            stressTreap.delete(value)
            referenceSet.remove(value)
        }
        // Periodically verify invariants.
        if rng.next() % 1000 == 0 {
            assert(stressTreap.isBSTValid(), "BST invariant failed during stress test.")
            assert(stressTreap.isHeapValid(), "Heap invariant failed during stress test.")
            // Verify that all present keys are searchable.
            for key in referenceSet {
                assert(stressTreap.contains(key), "Key \(key) missing after operations.")
            }
        }
    }

    // Final verification after stress test.
    assert(stressTreap.isBSTValid(), "Final BST invariant failed.")
    assert(stressTreap.isHeapValid(), "Final Heap invariant failed.")
    let finalInorder = stressTreap.inorder()
    let sortedReference = referenceSet.sorted()
    assert(finalInorder == sortedReference, "Final inorder does not match reference set.")
}

// Execute tests.
runTests()
print("All Treap tests passed.")
