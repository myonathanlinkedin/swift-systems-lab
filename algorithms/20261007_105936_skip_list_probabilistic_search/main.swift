import Foundation

func main() {
    // Test 1: Empty list search
    var skip = SkipList()
    assert(skip.search(key: 10) == nil, "Search in empty list should return nil")

    // Test 2: Insert and search
    let testValues = [3, 6, 7, 9, 12, 19, 17, 26, 21, 25]
    for (index, key) in testValues.enumerated() {
        skip.insert(key: key, value: key * 10)
        let found = skip.search(key: key)
        assert(found == key * 10, "Inserted key \(key) should return value \(key * 10)")
    }

    // Test 3: Search for non-existent key
    assert(skip.search(key: 15) == nil, "Search for missing key should return nil")

    // Test 4: Duplicate key updates value
    skip.insert(key: 19, value: 999)
    assert(skip.search(key: 19) == 999, "Duplicate key should update value to 999")

    // Test 5: Order of keys
    let sortedKeys = testValues.sorted()
    let listKeys = skip.allKeys()
    assert(listKeys == sortedKeys, "Keys in skip list should be sorted")

    // Test 6: Random level distribution (basic sanity check)
    var levelCounts = [Int: Int]()
    for _ in 0..<1000 {
        let lvl = skip.randomLevel()
        levelCounts[lvl, default: 0] += 1
    }
    // Ensure that level 1 occurs most frequently
    let maxLevel = levelCounts.max(by: { $0.value < $1.value })?.key ?? 0
    assert(maxLevel == 1, "Level 1 should be the most common level")

    print("All tests passed.")
}

main()
