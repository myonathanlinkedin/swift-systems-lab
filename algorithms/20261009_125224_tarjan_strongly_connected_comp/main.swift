import Foundation

func testEmptyGraph() {
    let g = Graph(vertexCount: 0, edges: [])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    assert(result.isEmpty, "Empty graph should yield no components")
}

func testSingleVertexNoEdges() {
    let g = Graph(vertexCount: 1, edges: [])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    assert(result == [[0]], "Single vertex without edges should be its own SCC")
}

func testTwoVerticesOneDirection() {
    // 0 -> 1
    let g = Graph(vertexCount: 2, edges: [(0, 1)])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    // Expected: each vertex its own SCC
    let expected = [[0], [1]]
    assert(result == expected, "Directed edge should not create a cycle")
}

func testTwoVerticesBidirectional() {
    // 0 <-> 1
    let g = Graph(vertexCount: 2, edges: [(0, 1), (1, 0)])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [[0, 1]]
    assert(result == expected, "Mutual edges should form a single SCC")
}

func testComplexGraph() {
    // Graph from classic Tarjan example
    // 0 → 1 → 2 → 0, 1 → 3, 3 → 4 → 5 → 3, 6 isolated
    let edges = [
        (0,1), (1,2), (2,0), // SCC A: {0,1,2}
        (1,3),               // edge to SCC B
        (3,4), (4,5), (5,3), // SCC B: {3,4,5}
        // vertex 6 isolated
    ]
    let g = Graph(vertexCount: 7, edges: edges)
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    // Expected components sorted by first vertex
    let expected = [
        [0,1,2],
        [3,4,5],
        [6]
    ]
    assert(result == expected, "Complex graph SCC decomposition failed")
}

func testSelfLoop() {
    // Vertex 0 has a self-loop, vertex 1 isolated
    let g = Graph(vertexCount: 2, edges: [(0,0)])
    var algo = TarjanSCC(graph: g)
    let result = algo.run()
    let expected = [[0], [1]]
    assert(result == expected, "Self-loop should keep vertex in its own SCC")
}

// Run all tests
func main() {
    testEmptyGraph()
    testSingleVertexNoEdges()
    testTwoVerticesOneDirection()
    testTwoVerticesBidirectional()
    testComplexGraph()
    testSelfLoop()
    print("All Tarjan SCC tests passed.")
}

main()
