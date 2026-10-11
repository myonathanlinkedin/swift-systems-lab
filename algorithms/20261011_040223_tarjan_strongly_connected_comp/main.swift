import Foundation

// Helper to compare two SCC collections irrespective of ordering.
func assertSCCsEqual(_ computed: [[Int]], _ expected: [[Int]], file: StaticString = #file, line: UInt = #line) {
    // Normalise both sides: sort vertices inside each component and then sort the list.
    let normComputed = computed.map { $0.sorted() }.sorted(by: { $0.lexicographicallyPrecedes($1) })
    let normExpected = expected.map { $0.sorted() }.sorted(by: { $0.lexicographicallyPrecedes($1) })
    assert(normComputed == normExpected, "SCC mismatch. Computed: \(normComputed), Expected: \(normExpected)", file: file, line: line)
}

// Test 1: Empty graph.
do {
    let g = Graph(vertexCount: 0)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    assertSCCsEqual(sccs, [])
}

// Test 2: Single vertex, no edges.
do {
    let g = Graph(vertexCount: 1)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    assertSCCsEqual(sccs, [[0]])
}

// Test 3: Two vertices with a single directed edge (no cycle).
do {
    var g = Graph(vertexCount: 2)
    g.addEdge(from: 0, to: 1)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    // Expected: each vertex alone.
    assertSCCsEqual(sccs, [[0], [1]])
}

// Test 4: Simple cycle of three vertices.
do {
    var g = Graph(vertexCount: 3)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    assertSCCsEqual(sccs, [[0, 1, 2]])
}

// Test 5: Graph with two separate cycles and a bridge.
do {
    var g = Graph(vertexCount: 6)
    // Cycle A: 0 → 1 → 2 → 0
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)
    // Cycle B: 3 → 4 → 5 → 3
    g.addEdge(from: 3, to: 4)
    g.addEdge(from: 4, to: 5)
    g.addEdge(from: 5, to: 3)
    // Bridge from A to B (does not create a larger SCC)
    g.addEdge(from: 2, to: 3)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    assertSCCsEqual(sccs, [[0, 1, 2], [3, 4, 5]])
}

// Test 6: Self‑loop vertex.
do {
    var g = Graph(vertexCount: 2)
    g.addEdge(from: 0, to: 0) // self loop
    g.addEdge(from: 0, to: 1)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    // Vertex 0 forms its own SCC because it cannot reach back from 1.
    assertSCCsEqual(sccs, [[0], [1]])
}

// Test 7: Complex graph from classic textbook example.
do {
    var g = Graph(vertexCount: 8)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)
    g.addEdge(from: 2, to: 3)
    g.addEdge(from: 3, to: 4)
    g.addEdge(from: 4, to: 5)
    g.addEdge(from: 5, to: 3)
    g.addEdge(from: 6, to: 5)
    g.addEdge(from: 6, to: 7)
    g.addEdge(from: 7, to: 6)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    // Expected SCCs: {0,1,2}, {3,4,5}, {6,7}
    assertSCCsEqual(sccs, [[0,1,2], [3,4,5], [6,7]])
}

// Demo: print SCCs of a sample graph (optional, not part of assertions)
do {
    var g = Graph(vertexCount: 5)
    g.addEdge(from: 0, to: 1)
    g.addEdge(from: 1, to: 2)
    g.addEdge(from: 2, to: 0)
    g.addEdge(from: 2, to: 3)
    g.addEdge(from: 3, to: 4)
    var algo = TarjanSCC(graph: g)
    let sccs = algo.run()
    print("Strongly Connected Components:", sccs)
}

// If execution reaches this point without triggering an assertion, all tests have passed.
print("All Tarjan SCC unit tests passed.")
