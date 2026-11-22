import Foundation

// Instantiate the list.
var list = OptimisticLockCouplingList()

// Helper to assert conditions; crashes on failure.
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
    if !condition() {
        fatalError("Assertion failed: \(message)")
    }
}

// ---------- Basic Insertions ----------
assert(list.insert(10) == true, "Insert 10 should succeed")
assert(list.insert(5) == true, "Insert 5 should succeed")
assert(list.insert(20) == true, "Insert 20 should succeed")
assert(list.insert(10) == false, "Duplicate insert of 10 should fail")

// Verify ordering.
assert(list.toArray() == [5, 10, 20], "List should be sorted after inserts")

// ---------- Contains ----------
assert(list.contains(5) == true, "List should contain 5")
assert(list.contains(15) == false, "List should not contain 15")
assert(list.contains(20) == true, "List should contain 20")

// ---------- Deletions ----------
assert(list.remove(5) == true, "Remove 5 should succeed")
assert(list.remove(5) == false, "Removing 5 again should fail")
assert(list.remove(15) == false, "Removing non‑existent 15 should fail")
assert(list.remove(20) == true, "Remove 20 should succeed")

// Verify remaining elements.
assert(list.toArray() == [10], "Only 10 should remain after deletions")

// ---------- Stress Test ----------
let keysToInsert = (1...1000).shuffled()
for k in keysToInsert {
    assert(list.insert(k) == true, "Insert \(k) should succeed")
}
assert(list.toArray().count == 1000, "List should contain 1000 unique keys")

// Random deletions.
let keysToDelete = (1...500).shuffled()
for k in keysToDelete {
    assert(list.remove(k) == true, "Remove \(k) should succeed")
}
assert(list.toArray().count == 500, "List should contain 500 keys after deletions")

// Verify that the remaining keys are exactly the complement set.
let remainingSet = Set(list.toArray())
let expectedSet = Set(501...1000)
assert(remainingSet == expectedSet, "Remaining keys must match expected set")

// ---------- Edge Cases ----------
assert(list.insert(Int.min) == true, "Insert sentinel low key should succeed")
assert(list.insert(Int.max) == true, "Insert sentinel high key should succeed")
assert(list.contains(Int.min) == true, "List should contain Int.min")
assert(list.contains(Int.max) == true, "List should contain Int.max")
assert(list.remove(Int.min) == true, "Remove Int.min should succeed")
assert(list.remove(Int.max) == true, "Remove Int.max should succeed")
assert(list.contains(Int.min) == false, "Int.min should be gone")
assert(list.contains(Int.max) == false, "Int.max should be gone")

print("All tests passed.")
