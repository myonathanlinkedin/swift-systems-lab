func runTests() {
    // Test 1: Empty graph
    var g1 = Graph()
    let sorter1 = TopologicalSorter(graph: g1)
    assert(sorter1.run() == [])
    assert(sorter1.hasCycle() == false)
    
    // Test 2: Single node
    var g2 = Graph()
    g2.addNode(1)
    let sorter2 = TopologicalSorter(graph: g2)
    assert(sorter2.run() == [1])
    assert(sorter2.hasCycle() == false)
    
    // Test 3: Simple DAG
    var g3 = Graph()
    g3.addEdge(from: 1, to: 2)
    g3.addEdge(from: 2, to: 3)
    let sorter3 = TopologicalSorter(graph: g3)
    let order3 = sorter3.run()!
    assert(order3 == [1, 2, 3])
    assert(sorter3.hasCycle() == false)
    
    // Test 4: Disconnected graph
    var g4 = Graph()
    g4.addEdge(from: 1, to: 2)
    g4.addEdge(from: 3, to: 4)
    let sorter4 = TopologicalSorter(graph: g4)
    let order4 = sorter4.run()!
    assert(order4.count == 4)
    assert(order4.firstIndex(of: 1)! < order4.firstIndex(of: 2)!)
    assert(order4.firstIndex(of: 3)! < order4.firstIndex(of: 4)!)
    assert(sorter4.hasCycle() == false)
    
    // Test 5: Cycle
    var g5 = Graph()
    g5.addEdge(from: 1, to: 2)
    g5.addEdge(from: 2, to: 3)
    g5.addEdge(from: 3, to: 1)
    let sorter5 = TopologicalSorter(graph: g5)
    assert(sorter5.run() == nil)
    assert(sorter5.hasCycle() == true)
    
    // Test 6: Self-loop
    var g6 = Graph()
    g6.addEdge(from: 1, to: 1)
    let sorter6 = TopologicalSorter(graph: g6)
    assert(sorter6.run() == nil)
    assert(sorter6.hasCycle() == true)
    
    // Test 7: Larger graph
    var g7 = Graph()
    g7.addEdge(from: 5, to: 2)
    g7.addEdge(from: 5, to: 0)
    g7.addEdge(from: 4, to: 0)
    g7.addEdge(from: 4, to: 1)
    g7.addEdge(from: 2, to: 3)
    g7.addEdge(from: 3, to: 1)
    let sorter7 = TopologicalSorter(graph: g7)
    let order7 = sorter7.run()!
    assert(order7.count == 6)
    assert(order7.firstIndex(of: 5)! < order7.firstIndex(of: 2)!)
    assert(order7.firstIndex(of: 5)! < order7.firstIndex(of: 0)!)
    assert(order7.firstIndex(of: 4)! < order7.firstIndex(of: 0)!)
    assert(order7.firstIndex(of: 4)! < order7.firstIndex(of: 1)!)
    assert(order7.firstIndex(of: 2)! < order7.firstIndex(of: 3)!)
    assert(order7.firstIndex(of: 3)! < order7.firstIndex(of: 1)!)
    assert(sorter7.hasCycle() == false)
    
    // Test 8: Isolated node
    var g8 = Graph()
    g8.addEdge(from: 1, to: 2)
    g8.addNode(3)
    let sorter8 = TopologicalSorter(graph: g8)
    let order8 = sorter8.run()!
    assert(order8.count == 3)
    assert(order8.firstIndex(of: 1)! < order8.firstIndex(of: 2)!)
    assert(order8.contains(3))
    assert(sorter8.hasCycle() == false)
    
    // Test 9: Duplicate edges
    var g9 = Graph()
    g9.addEdge(from: 1, to: 2)
    g9.addEdge(from: 1, to: 2)
    let sorter9 = TopologicalSorter(graph: g9)
    let order9 = sorter9.run()!
    assert(order9 == [1, 2] || order9 == [1, 2])
    assert(sorter9.hasCycle() == false)
}

runTests()
print("All tests passed.")
