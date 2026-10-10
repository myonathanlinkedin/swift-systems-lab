import Foundation

// Helper to compare two collections of SCCs irrespective of component order.
func areComponentsEqual(_ a: [[Int]], _ b: [[Int]]) -> Bool {
    guard a.count == b.count else { return false }
    // Sort each component internally.
    let sortedA = a.map { $0.sorted() }.sorted { $0.lexicographicallyPrecedes($1) }
    let sortedB = b.map { $0.sorted() }.sorted { $0.lexicographicallyPrecedes($1) }
    return sortedA.elementsEqual(sortedB, by: { $0 == $1 })
}

// Test 1: Empty graph.
do {
    let g = Graph(vertexCount: 0)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    assert(sccs.isEmpty, "Empty graph should yield no SCCs")
}

// Test 2: Single vertex, no edges.
do {
    let g = Graph(vertexCount: 1)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    assert(sccs.count == 1 && sccs[0] == [0], "Single vertex graph should have one SCC containing vertex 0")
}

// Test 3: Two vertices, one directed edge (0 → 1). Expect two SCCs.
do {
    var g = Graph(vertexCount: 2)
    g.addEdge(from: 0, to: 1)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    let expected = [[0], [1]]
    assert(areComponentsEqual(sccs, expected), "Graph 0→1 should produce two singleton SCCs")
}

// Test 4: Simple cycle (0 → 1 → 2 → 0). Expect one SCC containing all three vertices.
do {
    var g = Graph(vertexCount: 3)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    let expected = [[0, 1, 2]]
    assert(areComponentsEqual(sccs, expected), "Cycle graph should yield a single SCC with all vertices")
}

// Test 5: Two separate cycles plus a bridge.
// Cycle A: 0 ↔ 1, Cycle B: 2 ↔ 3, Bridge: 1 → 2.
do {
    var g = Graph(vertexCount: 4)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 0)
    g.addEdge(from: 2, to: 3)
    g.addEdge(from: 3, to: 2)
    g.addEdge(from: 1, to: 2) // bridge
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    // Expected SCCs: {0,1}, {2,3}
    let expected = [[0, 1], [2, 3]]
    assert(areComponentsEqual(sccs, expected), "Graph with two cycles and a bridge should yield two SCCs")
}

// Test 6: Fully connected directed graph (complete digraph) of 4 vertices.
// Every vertex can reach every other vertex, so there is a single SCC.
do {
    var g = Graph(vertexCount: 4)
    for i in 0..<4 {
        for j in 0..<4 where i != j {
            g.addEdge(from: i, to: j)
        }
    }
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    let expected = [[0, 1, 2, 3]]
    assert(areComponentsEqual(sccs, expected), "Complete digraph should have one SCC containing all vertices")
}

// Test 7: Linear chain 0 → 1 → 2 → 3 (no back edges). Expect four singleton SCCs.
do {
    var g = Graph(vertexCount: 4)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 3)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    let expected = [[0], [1], [2], [3]]
    assert(areComponentsEqual(sccs, expected), "Linear chain should produce singleton SCCs for each vertex")
}

// Demo: Print SCCs of a sample graph.
do {
    var g = Graph(vertexCount: 5)
    g.addEdge(from: 0, to: 2)
    g.addEdge(from: 2, to: 1)
    g.addEdge(from: 1, to: 0)
    g.addEdge(from: 0, to: 3)
    g.addEdge(from: 3, to: 4)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    print("Strongly Connected Components:")
    for component in sccs {
        print(component)
    }
}

// If execution reaches this point without triggering an assertion, all tests have passed.
print("All Tarjan SCC unit tests passed.")
