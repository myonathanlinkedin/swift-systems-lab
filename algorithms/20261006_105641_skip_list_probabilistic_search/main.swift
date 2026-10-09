import Foundation

func runTests() {
    // Test 1: Insert ascending values and search
    var list1 = SkipList<Int>()
    for i in 1...10 {
        list1.insert(i)
    }
    for i in 1...10 {
        assert(list1.search(i), "Should find \(i)")
    }
    assert(!list1.search(0), "Should not find 0")
    assert(!list1.search(11), "Should not find 11")
    assert(list1.count == 10, "Count should be 10")

    // Test 2: Insert random values and search
    var list2 = SkipList<Int>()
    let values = [5, 3, 9, 1, 7, 2, 8, 6, 4]
    for v in values {
        list2.insert(v)
    }
    for v in values {
        assert(list2.search(v), "Should find \(v)")
    }
    assert(!list2.search(10), "Should not find 10")
    assert(list2.count == values.count, "Count should match inserted values")

    // Test 3: Duplicate insertion
    var list3 = SkipList<Int>()
    list3.insert(42)
    list3.insert(42)
    list3.insert(42)
    assert(list3.search(42), "Should find 42")
    assert(list3.count == 3, "Count should be 3 for duplicates")

    // Test 4: Level does not exceed maxLevel
    var list4 = SkipList<Int>(maxLevel: 4)
    for i in 0..<100 {
        list4.insert(i)
    }
    assert(list4.currentLevel <= 4, "Level should not exceed maxLevel")

    // Test 5: Search in empty list
    var list5 = SkipList<Int>()
    assert(!list5.search(1), "Empty list should not find any value")

    // Benchmark: Insert 10,000 elements
    var listBench = SkipList<Int>()
    let start = Date()
    for i in 0..<10_000 {
        listBench.insert(i)
    }
    var _instance_duration = Date()
        let duration = _instance_duration.timeIntervalSince(start)
    print("Inserted 10,000 elements in \(duration) seconds. Count: \(listBench.count)")

    print("All tests passed.")
}

runTests()
