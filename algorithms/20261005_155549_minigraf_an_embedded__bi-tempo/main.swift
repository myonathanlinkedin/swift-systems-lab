import Foundation

// Helper to create deterministic timestamps
func ts(_ secondsFromNow: Double) -> Timestamp {
    return Timestamp(Date().addingTimeInterval(secondsFromNow).timeIntervalSince1970 * 1000)
}

// Unit Tests
func runTests() {
    let g = Graph()
    
    // Base timestamps
    let t0 = Timestamp.now
    let t1 = t0 + 1_000          // +1 sec
    let t2 = t0 + 10_000         // +10 sec
    let t3 = t0 + 60_000         // +1 min
    
    // Add nodes
    g.addNode(id: 1, data: "Alice", validFrom: t0)
    g.addNode(id: 2, data: "Bob",   validFrom: t0)
    g.addNode(id: 3, data: "Carol", validFrom: t1, validTo: t2) // temporal window
    
    // Verify immediate visibility
    assert(g.node(id: 1, atValidTime: t0, atTxTime: t0) == "Alice")
    assert(g.node(id: 2, atValidTime: t0, atTxTime: t0) == "Bob")
    assert(g.node(id: 3, atValidTime: t0, atTxTime: t0) == nil)
    assert(g.node(id: 3, atValidTime: t1, atTxTime: t1) == "Carol")
    assert(g.node(id: 3, atValidTime: t3, atTxTime: t3) == nil)
    
    // Add edges
    g.addEdge(id: 100, from: 1, to: 2, validFrom: t0)
    g.addEdge(id: 101, from: 2, to: 3, validFrom: t1, validTo: t2)
    
    // Edge queries
    assert(g.edge(id: 100, atValidTime: t0, atTxTime: t0)?.from == 1)
    assert(g.edge(id: 101, atValidTime: t1, atTxTime: t1)?.to == 3)
    assert(g.edge(id: 101, atValidTime: t3, atTxTime: t3) == nil)
    
    // Neighbor checks
    let n1t0 = g.neighbors(of: 1, atValidTime: t0, atTxTime: t0)
    assert(n1t0 == [2])
    let n2t1 = g.neighbors(of: 2, atValidTime: t1, atTxTime: t1).sorted()
    assert(n2t1 == [1,3])
    
    // Temporal removal
    g.removeNode(id: 2, txEnd: t2) // Bob removed at t2
    assert(g.node(id: 2, atValidTime: t1, atTxTime: t1) == "Bob")
    assert(g.node(id: 2, atValidTime: t1, atTxTime: t3) == nil)
    
    // Edge should also become invisible after transaction end
    g.removeEdge(id: 100, txEnd: t2)
    assert(g.edge(id: 100, atValidTime: t0, atTxTime: t1) != nil)
    assert(g.edge(id: 100, atValidTime: t0, atTxTime: t3) == nil)
    
    // Benchmark simple loop (not a rigorous benchmark, just sanity)
    var sum = 0
    for i in 0..<10_000 {
        g.addNode(id: 1000 + i, data: "N\(i)", validFrom: t0)
        if let name = g.node(id: 1000 + i, atValidTime: t0, atTxTime: t0) {
            sum += name.count
        }
    }
    assert(sum > 0)
    
    print("All tests passed.")
}

// Entry point
runTests()
