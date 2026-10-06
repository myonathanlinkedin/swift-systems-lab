import Foundation

// MARK: - Test Utilities
/// Simple assertion helper that throws a fatal error on failure.
func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    if lhs != rhs {
        fatalError("Assertion failed: \(lhs) != \(rhs). \(message)")
    }
}

// MARK: - Unit Tests
func testBeamSearchSimpleGraph() {
    // Construct a small graph:
    //      0(10)
    //     /     \
    //  1(8)     2(9)
    //   |        |
    //  3(7)     4(6)
    let node3 = Node(id: 3, score: 7)
    let node4 = Node(id: 4, score: 6)
    let node1 = Node(id: 1, score: 8, children: [node3])
    let node2 = Node(id: 2, score: 9, children: [node4])
    let root = Node(id: 0, score: 10, children: [node1, node2])
    
    var search = BeamSearch(startNode: root, beamWidth: 2, maxDepth: 2)
    let result = search.run()
    
    // Expected top nodes at depth 2: node1 (8) and node2 (9)
    assertEqual(result.count, 2, "Result count mismatch")
    let ids = result.map { $0.id }
    assertEqual(Set(ids), Set([1, 2]), "Result IDs mismatch")
}

func testBeamSearchEmptyChildren() {
    let leaf = Node(id: 5, score: 5)
    var search = BeamSearch(startNode: leaf, beamWidth: 3, maxDepth: 3)
    let result = search.run()
    assertEqual(result.count, 1, "Result count should be 1 for leaf")
    assertEqual(result[0].id, 5, "Leaf node ID mismatch")
}

func testBeamSearchLargeDepth() {
    // Create a linear chain of 10 nodes.
    var current = Node(id: 9, score: 9)
    for i in stride(from: 8, through: 0, by: -1) {
        current = Node(id: i, score: Double(i), children: [current])
    }
    var search = BeamSearch(startNode: current, beamWidth: 1, maxDepth: 10)
    let result = search.run()
    assertEqual(result.count, 1, "Result count should be 1")
    assertEqual(result[0].id, 9, "Final node ID should be 9")
}

// MARK: - Benchmark
func benchmarkBeamSearch() {
    // Generate a balanced binary tree of depth 10 (~1023 nodes)
    func buildTree(depth: Int, startId: Int) -> Node {
        if depth == 0 { return Node(id: startId, score: Double(startId)) }
        let left = buildTree(depth: depth - 1, startId: startId * 2)
        let right = buildTree(depth: depth - 1, startId: startId * 2 + 1)
        return Node(id: startId, score: Double(startId), children: [left, right])
    }
    let root = buildTree(depth: 10, startId: 1)
    var search = BeamSearch(startNode: root, beamWidth: 5, maxDepth: 10)
    
    let start = Date()
    _ = search.run()
    var _instance_duration = Date()
        let duration = _instance_duration.timeIntervalSince(start)
    print("Benchmark: Beam search on 1023-node tree took \(duration) seconds.")
}

// MARK: - Main Entry Point
func main() {
    testBeamSearchSimpleGraph()
    testBeamSearchEmptyChildren()
    testBeamSearchLargeDepth()
    benchmarkBeamSearch()
    print("All tests passed.")
}

main()
