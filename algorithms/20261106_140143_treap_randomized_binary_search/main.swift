import Foundation

// Helper assertion function
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
    if !condition() {
        fatalError("Assertion failed: \(message)")
    }
}

// Test 1: Basic insert and inorder traversal
var treap = Treap()
let sequence = [5, 3, 7, 2, 4, 6, 8]
for key in sequence {
    treap.insert(key)
}
let inorderResult = treap.inorder()
assert(inorderResult == [2, 3, 4, 5, 6, 7, 8], "Inorder traversal incorrect after insertions")

// Test 2: Heap property
assert(treap.isHeapPropertySatisfied(), "Heap property violated after insertions")

// Test 3: Search existing and non-existing keys
assert(treap.search(4), "Search failed for existing key 4")
assert(!treap.search(10), "Search incorrectly found non-existing key 10")

// Test 4: Delete a key
treap.delete(5)
assert(!treap.search(5), "Key 5 still found after deletion")
assert(treap.size() == 6, "Size incorrect after deletion")
let inorderAfterDelete = treap.inorder()
assert(inorderAfterDelete == [2, 3, 4, 6, 7, 8], "Inorder incorrect after deletion")

// Test 5: Delete all keys
for key in [2, 3, 4, 6, 7, 8] {
    treap.delete(key)
}
assert(treap.size() == 0, "Treap not empty after deleting all keys")
assert(treap.inorder().isEmpty, "Inorder not empty after deleting all keys")

// Test 6: Duplicate keys
var dupTreap = Treap()
dupTreap.insert(5)
dupTreap.insert(5)
dupTreap.insert(5)
assert(dupTreap.size() == 3, "Size incorrect for duplicate keys")
assert(dupTreap.inorder() == [5, 5, 5], "Inorder incorrect for duplicate keys")
assert(dupTreap.search(5), "Search failed for duplicate key 5")
dupTreap.delete(5)
assert(dupTreap.size() == 2, "Size incorrect after deleting one duplicate")
assert(dupTreap.inorder() == [5, 5], "Inorder incorrect after deleting one duplicate")

// Test 7: Delete non-existing key (should be no-op)
dupTreap.delete(10)
assert(dupTreap.size() == 2, "Size changed after deleting non-existing key")

// Test 8: Randomized stress test
var randomTreap = Treap()
var randomKeys: [Int] = []
for _ in 0..<1000 {
    let key = Int.random(in: 0...10000)
    randomKeys.append(key)
    randomTreap.insert(key)
}
assert(randomTreap.size() == 1000, "Size mismatch after random insertions")
let sortedRandomKeys = randomKeys.sorted()
assert(randomTreap.inorder() == sortedRandomKeys, "Inorder mismatch after random insertions")
assert(randomTreap.isHeapPropertySatisfied(), "Heap property violated after random insertions")

// Delete half of the keys
for key in randomKeys.prefix(500) {
    randomTreap.delete(key)
}
assert(randomTreap.size() == 500, "Size mismatch after random deletions")
let remainingKeys = Set(randomKeys.dropFirst(500))
let inorderAfterRandomDelete = randomTreap.inorder()
assert(Set(inorderAfterRandomDelete) == remainingKeys, "Inorder mismatch after random deletions")
assert(randomTreap.isHeapPropertySatisfied(), "Heap property violated after random deletions")

print("All tests passed successfully.")
