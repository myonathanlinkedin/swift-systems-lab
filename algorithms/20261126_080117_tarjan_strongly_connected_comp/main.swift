import Foundation

// Helper to compare SCC results irrespective of ordering inside components
func assertSCCs(_ result: [[Int]], _ expected: [[Int]], file: StaticString = #file, line: UInt = #line) {
    let sortedResult = result.map { $0.sorted() }.sorted { $0.first! < $1.first! }
    let sortedExpected = expected.map { $0.sorted() }.sorted { $0.first! < $1.first! }
    assert(sortedResult == sortedExpected, "SCC mismatch. Got \(sortedResult), expected \(sortedExpected)", file: file, line: line)
}

// Test 1: Empty graph
do {
    var g = Graph(vertexCount: 0)
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assert(scc.isEmpty, "Empty graph should yield no SCCs")
}

// Test 2: Single vertex, no edges
do {
    var g = Graph(vertexCount: 1)
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assertSCCs(scc, [[0]])
}

// Test 3: Two vertices, one direction edge (no cycle)
do {
    var g = Graph(vertexCount: 2, edges: [(0, 1)])
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assertSCCs(scc, [[0], [1]])
}

// Test 4: Simple cycle of three vertices
do {
    var g = Graph(vertexCount: 3, edges: [(0,1), (1,2), (2,0)])
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assertSCCs(scc, [[0,1,2]])
}

// Test 5: Graph with two separate cycles and a bridge
do {
    var g = Graph(vertexCount: 6, edges: [
        (0,1), (1,0),        // SCC A
        (2,3), (3,4), (4,2), // SCC B
        (1,2),               // bridge from A to B
        (5,5)                // SCC C (self-loop)
    ])
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assertSCCs(scc, [[0,1], [2,3,4], [5]])
}

// Test 6: Disconnected vertices
do {
    var g = Graph(vertexCount: 4, edges: [(0,1)])
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assertSCCs(scc, [[0,1], [2], [3]])
}

// Test 7: Complex graph from classic example
do {
    // Graph from CLRS (Fig 22.8)
    var g = Graph(vertexCount: 8, edges: [
        (0,1), (1,2), (2,0), (2,3), (3,4), (4,5), (5,3), (6,5), (6,7), (7,6)
    ])
    var tarjan = TarjanSCC(graph: g)
    let scc = tarjan.run()
    assertSCCs(scc, [[0,1,2], [3,4,5], [6,7]])
}

// All tests passed
print("All Tarjan SCC tests passed.")
