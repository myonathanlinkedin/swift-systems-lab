import Foundation

func normalizeSCCs(_ sccs: [[Int]]) -> [[Int]] {
    let sortedSCCs = sccs.map { $0.sorted() }
    return sortedSCCs.sorted { a, b in
        guard let firstA = a.first, let firstB = b.first else { return a.count < b.count }
        return firstA < firstB
    }
}

func testSingleSCC() {
    var g = Graph(nodeCount: 3)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 1)
    assert(normalized[0] == [0, 1, 2])
}

func testMultipleSCCs() {
    var g = Graph(nodeCount: 5)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 0)
    g.addEdge(from: 2, to: 3)
    g.addEdge(from: 3, to: 4)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 3)
    assert(normalized.contains([0, 1]))
    assert(normalized.contains([2]))
    assert(normalized.contains([3, 4]))
}

func testNoEdges() {
    var g = Graph(nodeCount: 4)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 4)
    for i in 0..<4 {
        assert(normalized.contains([i]))
    }
}

func testSelfLoop() {
    var g = Graph(nodeCount: 2)
    g.addEdge(from: 0, to: 0)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 2)
    assert(normalized.contains([0]))
    assert(normalized.contains([1]))
}

func testLargeCycle() {
    let n = 10
    var g = Graph(nodeCount: n)
    for i in 0..<n-1 {
        g.addEdge(from: i, to: i+1)
    }
    g.addEdge(from: n-1, to: 0)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 1)
    assert(normalized[0] == Array(0..<n))
}

func testDisjointCycles() {
    var g = Graph(nodeCount: 6)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 0)
    g.addEdge(from: 2, to: 3)
    g.addEdge(from: 3, to: 2)
    g.addEdge(from: 4, to: 5)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 3)
    assert(normalized.contains([0, 1]))
    assert(normalized.contains([2, 3]))
    assert(normalized.contains([4, 5]))
}

func testIsolatedNode() {
    var g = Graph(nodeCount: 3)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 0)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let normalized = normalizeSCCs(result)
    assert(normalized.count == 2)
    assert(normalized.contains([0, 1]))
    assert(normalized.contains([2]))
}

func testEmptyGraph() {
    var g = Graph(nodeCount: 0)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    assert(result.isEmpty)
}

func runAllTests() {
    testSingleSCC()
    testMultipleSCCs()
    testNoEdges()
    testSelfLoop()
    testLargeCycle()
    testDisjointCycles()
    testIsolatedNode()
    testEmptyGraph()
    print("All tests passed.")
}

runAllTests()
