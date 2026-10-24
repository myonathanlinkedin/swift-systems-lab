import Foundation

// Unit Test Helpers
func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    if lhs != rhs {
        fatalError("Assertion failed: \(message) Expected \(rhs), got \(lhs)")
    }
}

func assertTrue(_ condition: Bool, _ message: String = "") {
    if !condition {
        fatalError("Assertion failed: \(message)")
    }
}

// MARK: - Tests for BubbleSort

func testBubbleSortBasic() {
    let unsorted = [5, 2, 9, 1, 5, 6]
    var sorter = BubbleSort(array: unsorted)
    let steps = sorter.run()
    
    // Final step must be sorted
    guard let finalStep = steps.last else {
        fatalError("No steps recorded")
    }
    let expectedSorted = unsorted.sorted()
    assertEqual(finalStep.array, expectedSorted, "BubbleSort final array not sorted")
    
    // Each step must preserve length
    for step in steps {
        assertEqual(step.array.count, unsorted.count, "Step array length mismatch")
    }
    
    // At least one swap should have been recorded for a non‑trivial input
    assertTrue(steps.count > 1, "Expected multiple steps for unsorted input")
}

func testBubbleSortAlreadySorted() {
    let sorted = [1, 2, 3, 4, 5]
    var sorter = BubbleSort(array: sorted)
    let steps = sorter.run()
    
    // Should record initial and final (identical) states only
    assertTrue(steps.count == 2, "Already sorted array should produce exactly two steps")
    assertEqual(steps.first?.array, sorted, "Initial step mismatch")
    assertEqual(steps.last?.array, sorted, "Final step mismatch")
}

// MARK: - Tests for BinarySearch

func testBinarySearchFound() {
    let data = [1, 3, 5, 7, 9, 11, 13]
    var search = BinarySearch(array: data, target: 7)
    let result = search.run()
    
    assertTrue(result.found, "Target should be found")
    assertEqual(result.index, 3, "Incorrect index for found target")
    // Verify that steps recorded at least one iteration
    assertTrue(result.steps.count >= 1, "Expected at least one step")
    // Verify that the last recorded step marks found = true
    guard let last = result.steps.last else {
        fatalError("No steps recorded")
    }
    assertTrue(last.found == true, "Last step should indicate found")
}

func testBinarySearchNotFound() {
    let data = [2, 4, 6, 8, 10]
    var search = BinarySearch(array: data, target: 5)
    let result = search.run()
    
    assertTrue(!result.found, "Target should not be found")
    assertEqual(result.index, nil, "Index should be nil when not found")
    // Verify that the final step records found = false
    guard let last = result.steps.last else {
        fatalError("No steps recorded")
    }
    assertTrue(last.found == false, "Last step should indicate not found")
}

// MARK: - Execute Tests

func runAllTests() {
    testBubbleSortBasic()
    testBubbleSortAlreadySorted()
    testBinarySearchFound()
    testBinarySearchNotFound()
    print("All tests passed.")
}

runAllTests()
