import Foundation

// Helper to assert equality of integer arrays irrespective of order.
func assertUnorderedEqual(_ lhs: [(Int, Int)], _ rhs: [(Int, Int)], _ message: String = "") {
    let setL = Set(lhs.map { "\($0.0)-\($0.1)" })
    let setR = Set(rhs.map { "\($0.0)-\($0.1)" })
    assert(setL == setR, "Assertion failed: \(message) Expected \(rhs), got \(lhs)")
}

// Test 1: Simple graph with known max flow = 15.
do {
    var g = Graph()
    g.addEdge(from: 0, to: 1, capacity: 10)
    g.addEdge(from: 0, to: 2, capacity: 5)
    g.addEdge(from: 1, to: 2, capacity: 15)
    g.addEdge(from: 1, to: 3, capacity: 10)
    g.addEdge(from: 2, to: 3, capacity: 10)
    
    var engine = MaxFlowEngine(graph: g, source: 0, sink: 3)
    let (maxFlow, cut) = engine.run()
    assert(maxFlow == 15, "Test 1: Expected max flow 15, got \(maxFlow)")
    // Expected min cut edges: (0,1) and (0,2) with total capacity 15.
    assertUnorderedEqual(cut, [(0,1), (0,2)], "Test 1: Min cut edges mismatch")
}

// Test 2: Disconnected sink (no path). Max flow = 0, cut empty.
do {
    var g = Graph()
    g.addEdge(from: 0, to: 1, capacity: 7)
    g.addEdge(from: 1, to: 2, capacity: 3)
    // Sink 4 is isolated.
    var engine = MaxFlowEngine(graph: g, source: 0, sink: 4)
    let (maxFlow, cut) = engine.run()
    assert(maxFlow == 0, "Test 2: Expected max flow 0, got \(maxFlow)")
    assert(cut.isEmpty, "Test 2: Expected empty min cut")
}

// Test 3: Parallel edges between same vertices.
do {
    var g = Graph()
    g.addEdge(from: 0, to: 1, capacity: 4)
    g.addEdge(from: 0, to: 1, capacity: 6) // parallel
    g.addEdge(from: 1, to: 2, capacity: 5)
    g.addEdge(from: 1, to: 2, capacity: 3) // parallel
    var engine = MaxFlowEngine(graph: g, source: 0, sink: 2)
    let (maxFlow, cut) = engine.run()
    // Total capacity from 0->1 is 10, from 1->2 is 8, so max flow = 8.
    assert(maxFlow == 8, "Test 3: Expected max flow 8, got \(maxFlow)")
    // Min cut should be the set of edges from 1 to 2 (total capacity 8).
    assertUnorderedEqual(cut, [(1,2)], "Test 3: Min cut edges mismatch")
}

// Test 4: Source equals sink. By definition, max flow = 0, cut empty.
do {
    var g = Graph()
    g.addEdge(from: 0, to: 1, capacity: 5)
    var engine = MaxFlowEngine(graph: g, source: 0, sink: 0)
    let (maxFlow, cut) = engine.run()
    assert(maxFlow == 0, "Test 4: Expected max flow 0 when source == sink")
    assert(cut.isEmpty, "Test 4: Expected empty min cut when source == sink")
}

// Test 5: Larger synthetic graph mimicking a subway line shutdown scenario.
// We'll construct a graph with 6 stations (0..5) and 23,445 riders represented as capacities.
// The "shutdown" corresponds to cutting the edge (2,3) which carries the bottleneck.
do {
    var g = Graph()
    // Build a chain 0->1->2->3->4->5 with large capacities.
    g.addEdge(from: 0, to: 1, capacity: 10000)
    g.addEdge(from: 1, to: 2, capacity: 12000)
    g.addEdge(from: 2, to: 3, capacity: 23445) // critical edge
    g.addEdge(from: 3, to: 4, capacity: 15000)
    g.addEdge(from: 4, to: 5, capacity: 20000)
    // Add an alternative bypass 2->4 with lower capacity.
    g.addEdge(from: 2, to: 4, capacity: 5000)
    
    var engine = MaxFlowEngine(graph: g, source: 0, sink: 5)
    let (maxFlow, cut) = engine.run()
    // The bottleneck is edge (2,3) with capacity 23,445, so max flow cannot exceed that.
    assert(maxFlow == 23445, "Test 5: Expected max flow 23,445, got \(maxFlow)")
    // Min cut should contain the critical edge (2,3).
    assertUnorderedEqual(cut, [(2,3)], "Test 5: Expected min cut to be edge (2,3)")
}

// All assertions passed.
print("All unit tests passed.")
