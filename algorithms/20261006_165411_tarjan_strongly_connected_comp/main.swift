import Foundation

func normalize(_ sccs: [[Int]]) -> [[Int]] {
    let sortedComponents = sccs.map { $0.sorted() }
    return sortedComponents.sorted { a, b in
        guard let firstA = a.first, let firstB = b.first else { return false }
        return firstA < firstB
    }
}

// Test 1: Single SCC cycle
var graph1: [[Int]] = [
    [1],    // 0 -> 1
    [2],    // 1 -> 2
    [0]     // 2 -> 0
]
var algo1 = TarjanSCC(graph: graph1)
let result1 = normalize(algo1.run())
assert(result1 == [[0, 1, 2]], "Test 1 failed: \(result1)")

// Test 2: Two SCCs with interconnection
var graph2: [[Int]] = [
    [1],        // 0 -> 1
    [0, 2],     // 1 -> 0, 1 -> 2
    [3],        // 2 -> 3
    [2]         // 3 -> 2
]
var algo2 = TarjanSCC(graph: graph2)
let result2 = normalize(algo2.run())
assert(result2 == [[0, 1], [2, 3]], "Test 2 failed: \(result2)")

// Test 3: No edges
var graph3: [[Int]] = [
    [], [], []
]
var algo3 = TarjanSCC(graph: graph3)
let result3 = normalize(algo3.run())
assert(result3 == [[0], [1], [2]], "Test 3 failed: \(result3)")

// Test 4: Self-loop
var graph4: [[Int]] = [
    [0], // 0 -> 0
    []   // 1
]
var algo4 = TarjanSCC(graph: graph4)
let result4 = normalize(algo4.run())
assert(result4 == [[0], [1]], "Test 4 failed: \(result4)")

// Test 5: Empty graph
var graph5: [[Int]] = []
var algo5 = TarjanSCC(graph: graph5)
let result5 = normalize(algo5.run())
assert(result5.isEmpty, "Test 5 failed: \(result5)")

// Test 6: Larger graph
var graph6: [[Int]] = [
    [1],          // 0 -> 1
    [2],          // 1 -> 2
    [0, 3],       // 2 -> 0, 2 -> 3
    [4],          // 3 -> 4
    [5],          // 4 -> 5
    [3],          // 5 -> 3
    []            // 6 isolated
]
var algo6 = TarjanSCC(graph: graph6)
let result6 = normalize(algo6.run())
assert(result6 == [[0, 1, 2], [3, 4, 5], [6]], "Test 6 failed: \(result6)")

print("All tests passed.")
