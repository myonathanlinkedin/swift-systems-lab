import Foundation

/// Helper to sort SCCs for order‑independent comparison in tests.
func normalized(_ components: [[Int]]) -> [[Int]] {
    return components.map { $0.sorted() }
                     .sorted { (a, b) -> Bool in
                         if a.count != b.count { return a.count < b.count }
                         return a.lexicographicallyPrecedes(b)
                     }
}

func testEmptyGraph() {
    var g = Graph(vertexCount: 0)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    assert(result.isEmpty, "Empty graph should produce no SCCs")
}

func testSingleVertex() {
    var g = Graph(vertexCount: 1)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [[0]]
    assert(normalized(result) == normalized(expected), "Single vertex graph")
}

func testTwoVerticesOneDirection() {
    var g = Graph(vertexCount: 2, edges: [(0, 1)])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [[1], [0]]
    assert(normalized(result) == normalized(expected), "Two vertices, one directed edge")
}

func testThreeVertexCycle() {
    var g = Graph(vertexCount: 3, edges: [(0, 1), (1, 2), (2, 0)])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [[0, 1, 2]]
    assert(normalized(result) == normalized(expected), "Three‑vertex directed cycle")
}

func testComplexGraphSingleSCC() {
    // Classic example where all vertices belong to a single SCC.
    let edges = [
        (0,1),(1,2),(1,3),(2,0),(3,4),(4,5),(4,7),
        (5,6),(5,3),(6,2),(6,5),(7,6),(7,8),(8,7),(8,9),(9,2),(9,3)
    ]
    var g = Graph(vertexCount: 10, edges: edges)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [Array(0..<10)]
    assert(normalized(result) == normalized(expected), "Complex graph with a single SCC")
}

func testMultipleSCCs() {
    // Graph with three distinct SCCs:
    // SCC A: {0,1,2}
    // SCC B: {3,4}
    // SCC C: {5}
    var g = Graph(vertexCount: 6)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)   // cycle 0‑1‑2
    g.addEdge(from: 3, to: 4)   // edge 3→4 (no back edge)
    g.addEdge(from: 5, to: 5)   // self‑loop forms its own SCC
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [[0,1,2], [3], [4], [5]]
    // Note: vertices 3 and 4 are not mutually reachable, so each is its own SCC.
    assert(normalized(result) == normalized(expected), "Graph with multiple SCCs")
}

func runAllTests() {
    testEmptyGraph()
    testSingleVertex()
    testTwoVerticesOneDirection()
    testThreeVertexCycle()
    testComplexGraphSingleSCC()
    testMultipleSCCs()
    print("All Tarjan SCC tests passed.")
}

runAllTests()
