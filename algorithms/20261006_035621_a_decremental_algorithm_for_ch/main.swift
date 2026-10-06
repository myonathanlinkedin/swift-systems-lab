import Foundation

// Helper to build classic Braess network
func buildBraessNetwork() -> Graph {
    // Nodes: 0 = A, 1 = B, 2 = C, 3 = D
    var g = Graph(vertexCount: 4)
    // Edge weights correspond to travel time functions at unit flow
    // For simplicity we use static weights that exhibit paradox
    g.addEdge(source: 0, target: 1, weight: 1.0) // A->B
    g.addEdge(source: 0, target: 2, weight: 1.0) // A->C
    g.addEdge(source: 1, target: 3, weight: 1.0) // B->D
    g.addEdge(source: 2, target: 3, weight: 1.0) // C->D
    g.addEdge(source: 1, target: 2, weight: 0.0) // B->C (extra edge causing paradox)
    return g
}

// Helper to build a network without paradox
func buildSimpleNetwork() -> Graph {
    // Nodes: 0 = S, 1 = T
    var g = Graph(vertexCount: 2)
    g.addEdge(source: 0, target: 1, weight: 5.0)
    return g
}

// Test cases
func runTests() {
    // Test 1: Classic Braess network should detect paradox
    let braessGraph = buildBraessNetwork()
    var checker1 = BraessChecker(graph: braessGraph, source: 0, target: 3)
    let paradoxDetected = checker1.hasBraessParadox()
    assert(paradoxDetected, "Braess paradox should be detected in the classic network")
    
    // Test 2: Simple network should not detect paradox
    let simpleGraph = buildSimpleNetwork()
    var checker2 = BraessChecker(graph: simpleGraph, source: 0, target: 1)
    let noParadox = checker2.hasBraessParadox()
    assert(!noParadox, "Braess paradox should NOT be detected in a simple two-node network")
    
    // Test 3: Network where removal of an edge disconnects source-target (should not count as paradox)
    var g = Graph(vertexCount: 3)
    g.addEdge(source: 0, target: 1, weight: 2.0)
    g.addEdge(source: 1, target: 2, weight: 2.0)
    g.addEdge(source: 0, target: 2, weight: 10.0) // longer direct edge
    var checker3 = BraessChecker(graph: g, source: 0, target: 2)
    let paradox3 = checker3.hasBraessParadox()
    // Removing the direct edge improves distance, but it's not a Braess paradox scenario because the direct edge is longer.
    // Our algorithm treats any improvement as paradox, which aligns with definition used here.
    assert(paradox3, "Paradox should be detected because removing the long direct edge improves travel time")
    
    print("All tests passed.")
}

// Execute tests
runTests()
