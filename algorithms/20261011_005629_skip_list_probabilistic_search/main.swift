import Swift

// Simple test harness using Swift's built‑in assert
func testEmptySkipList() {
    var list = SkipList<Int>()
    assert(!list.contains(10), "Empty list should not contain any element")
}

func testSingleInsertion() {
    var list = SkipList<Int>()
    list.insert(5)
    assert(list.contains(5), "List should contain inserted element")
    assert(!list.contains(3), "List should not contain non‑inserted element")
}

func testMultipleInsertionsUnordered() {
    var list = SkipList<Int>()
    let values = [42, 7, 19, 3, 27, 15]
    for v in values {
        list.insert(v)
    }
    for v in values {
        assert(list.contains(v), "List should contain \(v) after insertion")
    }
    assert(!list.contains(100), "List should not contain element that was never inserted")
}

func testDuplicateInsertion() {
    var list = SkipList<Int>()
    list.insert(8)
    list.insert(8) // duplicate
    // Insert another distinct value to ensure list still works
    list.insert(12)
    assert(list.contains(8), "List should still contain the original element after duplicate insertion")
    assert(list.contains(12), "List should contain other inserted elements")
}

func testLevelBound() {
    var list = SkipList<Int>(maxLevel: 8, probability: 0.5)
    // Insert many elements to increase chance of higher levels
    for i in 0..<1000 {
        list.insert(i)
    }
    let lvl = list.maxCurrentLevel()
    assert(lvl <= 8, "Current level \(lvl) must not exceed configured maxLevel 8")
}

// Run all tests
func runAllTests() {
    testEmptySkipList()
    testSingleInsertion()
    testMultipleInsertionsUnordered()
    testDuplicateInsertion()
    testLevelBound()
    print("All SkipList tests passed.")
}

// Entry point
runAllTests()
