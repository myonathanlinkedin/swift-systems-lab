import Foundation

// Helper to compare two arrays irrespective of order (used for set equality)
func arraysEqual<T: Comparable>(_ a: [T], _ b: [T]) -> Bool {
    return a == b
}

// Test 1: Basic insertion and inorder traversal
var treap = Treap<Int>(seed: 42)
let keysToInsert = [5, 3, 8, 1, 4, 7, 9]
for k in keysToInsert {
    treap.insert(k)
}
let inorderResult = treap.inorder()
let expectedInorder = keysToInsert.sorted()
assert(arraysEqual(inorderResult, expectedInorder), "Inorder traversal does not match expected sorted order.")

// Test 2: Duplicate insertion should be ignored
treap.insert(5) // duplicate
assert(arraysEqual(treap.inorder(), expectedInorder), "Duplicate insertion altered the tree.")

// Test 3: Contains checks
assert(treap.contains(4) == true, "Contains failed for existing key.")
assert(treap.contains(10) == false, "Contains incorrectly returned true for missing key.")

// Test 4: Deletion of leaf, internal node, and non‑existent key
treap.delete(1) // leaf
treap.delete(8) // internal node with two children
treap.delete(100) // non‑existent
let afterDelete = treap.inorder()
let expectedAfterDelete = [3, 4, 5, 7, 9]
assert(arraysEqual(afterDelete, expectedAfterDelete), "Deletion did not produce expected inorder sequence.")

// Test 5: Delete all elements one by one
var fullTreap = Treap<Int>(seed: 123)
let fullSet = Array(0..<20)
for v in fullSet {
    fullTreap.insert(v)
}
for v in fullSet {
    fullTreap.delete(v)
}
assert(fullTreap.inorder().isEmpty, "Treap should be empty after deleting all elements.")

// Test 6: Large random dataset (deterministic due to fixed seed)
var largeTreap = Treap<Int>(seed: 999)
var randomSet = Set<Int>()
var generator = LCG(seed: 555)
for _ in 0..<1000 {
    let value = Int(truncatingIfNeeded: generator.next() % 5000)
    randomSet.insert(value)
    largeTreap.insert(value)
}
let largeInorder = largeTreap.inorder()
let sortedSet = randomSet.sorted()
assert(arraysEqual(largeInorder, sortedSet), "Large random dataset inorder mismatch.")

// Demo output (optional, not required for verification)
print("All treap unit tests passed. Final inorder of demo treap:", treap.inorder())
