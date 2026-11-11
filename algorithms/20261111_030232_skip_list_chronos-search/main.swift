import Foundation

// Helper to assert conditions; aborts on failure
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "") {
    if !condition() {
        fatalError("Assertion failed: \(message)")
    }
}

// Unit Tests
func runTests() {
    // Test 1: Basic insertion and search
    var list = SkipList<Int, String>()
    list.insert(10, "ten")
    list.insert(20, "twenty")
    list.insert(5, "five")
    assert(list.search(10) == "ten", "Search 10")
    assert(list.search(5) == "five", "Search 5")
    assert(list.search(20) == "twenty", "Search 20")
    assert(list.search(15) == nil, "Search missing key")

    // Test 2: Duplicate key updates value
    list.insert(10, "TEN")
    assert(list.search(10) == "TEN", "Update duplicate key")

    // Test 3: Deletion
    let removed = list.delete(5)
    assert(removed, "Delete existing key")
    assert(list.search(5) == nil, "Deleted key not found")
    assert(list.allKeys() == [10, 20], "Remaining keys after deletion")

    // Test 4: Delete non‑existent key
    let notRemoved = list.delete(999)
    assert(!notRemoved, "Delete non‑existent key returns false")

    // Test 5: Large number of sequential inserts
    var bigList = SkipList<Int, Int>()
    let count = 1000
    for i in 0..<count {
        bigList.insert(i, i * i)
    }
    // Verify random access
    for i in stride(from: 0, to: count, by: 37) {
        assert(bigList.search(i) == i * i, "Search in big list at \(i)")
    }
    // Verify ordering
    assert(bigList.allKeys() == Array(0..<count), "All keys ordered")

    // Test 6: Delete all elements
    for i in 0..<count {
        assert(bigList.delete(i), "Delete \(i)")
    }
    assert(bigList.allKeys().isEmpty, "List empty after deletions")
    assert(bigList.search(0) == nil, "Search after full deletion")
}

// Execute tests
runTests()
print("All SkipList Chronos‑Search tests passed.")
