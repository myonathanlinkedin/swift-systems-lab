import Foundation

// Helper to create components quickly
func C(_ name: String) -> Component { Component(name: name) }

// Unit Tests
func runTests() {
    // Test 1: Empty graph
    var g1 = SystemGraph()
    assert(g1.hasCycle() == false, "Empty graph should have no cycle")
    assert(g1.topologicalOrder() == [], "Empty graph topological order should be empty")
    assert(g1.propagateFailure(from: C("X")).isEmpty, "Propagation on unknown node should be empty")
    
    // Test 2: Single node, no edges
    var g2 = SystemGraph()
    let a = C("A")
    g2.addComponent(a)
    assert(g2.hasCycle() == false, "Single node graph should have no cycle")
    if let order = g2.topologicalOrder() {
        assert(order == [a], "Topological order should contain the single node")
    } else {
        assertionFailure("Topological order returned nil unexpectedly")
    }
    let failSet2 = g2.propagateFailure(from: a)
    assert(failSet2 == Set([a]), "Failure of isolated node should affect only itself")
    
    // Test 3: Simple DAG A -> B -> C
    var g3 = SystemGraph()
    let b = C("B")
    let c = C("C")
    g3.addDependency(from: a, to: b)
    g3.addDependency(from: b, to: c)
    assert(g3.hasCycle() == false, "A->B->C is acyclic")
    if let order = g3.topologicalOrder() {
        // Valid topological orders: A,B,C or A,C,B depending on implementation, but A must be first.
        assert(order.first == a, "A must appear before its dependents")
        assert(order.contains(b) && order.contains(c), "All nodes must appear")
    } else {
        assertionFailure("Topological order failed on acyclic graph")
    }
    let failSet3 = g3.propagateFailure(from: a)
    assert(failSet3 == Set([a, b, c]), "Failure from A should reach B and C")
    let failSetB = g3.propagateFailure(from: b)
    assert(failSetB == Set([b, c]), "Failure from B should reach C only")
    
    // Test 4: Cycle detection A -> B -> C -> A
    var g4 = SystemGraph()
    g4.addDependency(from: a, to: b)
    g4.addDependency(from: b, to: c)
    g4.addDependency(from: c, to: a)
    assert(g4.hasCycle() == true, "Graph with a cycle should be detected")
    assert(g4.topologicalOrder() == nil, "Topological order must be nil when cycle exists")
    
    // Test 5: Disconnected components with independent cycles
    var g5 = SystemGraph()
    let d = C("D")
    let e = C("E")
    // Component set 1: A->B (acyclic)
    g5.addDependency(from: a, to: b)
    // Component set 2: D->E->D (cycle)
    g5.addDependency(from: d, to: e)
    g5.addDependency(from: e, to: d)
    assert(g5.hasCycle() == true, "Graph with any cycle should report true")
    assert(g5.topologicalOrder() == nil, "Topological order nil when any cycle exists")
    
    // Test 6: Failure propagation on disconnected graph
    var g6 = SystemGraph()
    g6.addDependency(from: a, to: b) // A->B
    g6.addComponent(d)               // D isolated
    let failFromD = g6.propagateFailure(from: d)
    assert(failFromD == Set([d]), "Isolated node failure affects only itself")
    
    // Test 7: Complex DAG with branching
    var g7 = SystemGraph()
    let f = C("F")
    let g = C("G")
    g7.addDependency(from: a, to: b) // A->B
    g7.addDependency(from: a, to: c) // A->C
    g7.addDependency(from: b, to: f) // B->F
    g7.addDependency(from: c, to: f) // C->F
    g7.addDependency(from: f, to: g) // F->G
    assert(g7.hasCycle() == false, "Complex DAG should be acyclic")
    if let order = g7.topologicalOrder() {
        // Verify that dependencies appear after their sources
        func index(of comp: Component) -> Int? { order.firstIndex(of: comp) }
        assert(index(of: a)! < index(of: b)!)
        assert(index(of: a)! < index(of: c)!)
        assert(index(of: b)! < index(of: f)!)
        assert(index(of: c)! < index(of: f)!)
        assert(index(of: f)! < index(of: g)!)
    } else {
        assertionFailure("Topological order failed on complex DAG")
    }
    let failFromA = g7.propagateFailure(from: a)
    assert(failFromA == Set([a, b, c, f, g]), "Failure from A reaches all downstream nodes")
    let failFromC = g7.propagateFailure(from: c)
    assert(failFromC == Set([c, f, g]), "Failure from C reaches F and G")
    
    print("All tests passed.")
}

// Entry point
runTests()
