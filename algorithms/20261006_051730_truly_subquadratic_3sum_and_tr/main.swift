import Foundation

// Entry point
func runTests() {
    testThreeSum()
    testAPSP()
    benchmarkThreeSum()
    benchmarkAPSP()
    print("All tests passed.")
}

// MARK: - 3SUM Tests & Benchmark

func testThreeSum() {
    let solver = ThreeSumSolver()
    let case1 = solver.solve([-1, 0, 1, 2, -1, -4])
    let expected1: Set<[Int]> = Set([[ -1, -1, 2 ], [ -1, 0, 1 ]])
    assert(Set(case1) == expected1, "3SUM case1 failed")
    
    let case2 = solver.solve([0, 0, 0, 0])
    let expected2: Set<[Int]> = Set([[0,0,0]])
    assert(Set(case2) == expected2, "3SUM case2 failed")
    
    let case3 = solver.solve([1, 2, 3])
    assert(case3.isEmpty, "3SUM case3 should be empty")
}

// Simple benchmark for 3SUM (n ≈ 2000)
func benchmarkThreeSum() {
    var nums: [Int] = []
    let n = 2000
    for _ in 0..<n {
        nums.append(Int.random(in: -1_000_000...1_000_000))
    }
    let solver = ThreeSumSolver()
    let start = Date()
    _ = solver.solve(nums)
    var _instance_elapsed = Date()
        let elapsed = _instance_elapsed.timeIntervalSince(start)
    print(String(format: "3SUM benchmark (n=%d): %.3f s", n, elapsed))
}

// MARK: - APSP Tests & Benchmark

func testAPSP() {
    var g = Graph(vertexCount: 4)
    g.addEdge(from: 0, to: 1, weight: 5)
    g.addEdge(from: 0, to: 3, weight: 10)
    g.addEdge(from: 1, to: 2, weight: 3)
    g.addEdge(from: 2, to: 3, weight: 1)
    g.addEdge(from: 3, to: 0, weight: 2)
    
    let distances = g.allPairsShortestPaths()
    
    // Expected shortest distances (Manually computed)
    let expected: [[Int?]] = [
        [0, 5, 8, 9],
        [6, 0, 3, 4],
        [3, 8, 0, 1],
        [2, 7, 10, 0]
    ]
    
    for i in 0..<4 {
        for j in 0..<4 {
            assert(distances[i][j] == expected[i][j], "APSP mismatch at (\(i),\(j))")
        }
    }
}

// Benchmark Johnson's algorithm on a sparse random graph
func benchmarkAPSP() {
    let V = 500
    var g = Graph(vertexCount: V)
    let edgeProb = 0.01
    for u in 0..<V {
        for v in 0..<V where u != v && Double.random(in: 0...1) < edgeProb {
            let w = Int.random(in: 1...10)
            g.addEdge(from: u, to: v, weight: w)
        }
    }
    let start = Date()
    _ = g.allPairsShortestPaths()
    var _instance_elapsed = Date()
        let elapsed = _instance_elapsed.timeIntervalSince(start)
    print(String(format: "APSP benchmark (V=%d, E≈%.0f): %.3f s", V, Double(V)*Double(V)*edgeProb, elapsed))
}

// Run
runTests()
