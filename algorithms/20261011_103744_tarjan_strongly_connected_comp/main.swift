import Foundation

func testEmptyGraph() {
    var g = Graph(vertexCount: 0)
    var algo = TarjanSCC(graph: g)
    let scc = algo.run()
    assert(scc.isEmpty, "Empty graph should yield no components")
}

func testSingleVertexNoEdges() {
    var g = Graph(vertexCount: 1)
    var algo = TarjanSCC(graph: g)
    let scc = algo.run()
    assert(scc.count == 1 && scc[0] == [0], "Single vertex without edges should be its own SCC")
}

func testSelfLoop() {
    var g = Graph(vertexCount: 1, edges: [(0, 0)])
    var algo = TarjanSCC(graph: g)
    let scc = algo.run()
    assert(scc.count == 1 && scc[0] == [0], "Self-loop vertex should be its own SCC")
}

func testTwoVerticesOneDirection() {
    var g = Graph(vertexCount: 2, edges: [(0, 1)])
    var algo = TarjanSCC(graph: g)
    let scc = algo.run()
    let expected = [[0], [1]]
    assert(scc == expected, "Two vertices with one directed edge should be separate SCCs")
}

func testTwoVerticesMutual() {
    var g = Graph(vertexCount: 2, edges: [(0, 1), (1, 0)])
    var algo = TarjanSCC(graph: g)
    let scc = algo.run()
    assert(scc.count == 1 && scc[0] == [0, 1], "Mutually reachable vertices should form one SCC")
}

func testComplexGraph() {
    // Classic example graph
    // 0→1, 1→2, 2→0, 2→3, 3→4, 4→5, 5→3, 6→5, 6→7, 7→8, 8→6, 8→9
    let edges = [(0,1),(1,2),(2,0),(2,3),(3,4),(4,5),(5,3),(6,5),(6,7),(7,8),(8,6),(8,9)]
    var g = Graph(vertexCount: 10, edges: edges)
    var algo = TarjanSCC(graph: g)
    let scc = algo.run()
    let expected = [[0,1,2],[3,4,5],[6,7,8],[9]]
    assert(scc == expected, "Complex graph SCCs mismatch")
}

func runAllTests() {
    testEmptyGraph()
    testSingleVertexNoEdges()
    testSelfLoop()
    testTwoVerticesOneDirection()
    testTwoVerticesMutual()
    testComplexGraph()
    print("All Tarjan SCC tests passed.")
}

runAllTests()
