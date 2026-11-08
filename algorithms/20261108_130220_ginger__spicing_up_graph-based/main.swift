import Foundation

// Helper to compute exact nearest neighbors via brute force
func bruteForceSearch(graph: Graph, query: Vector, k: Int) -> [Int] {
    var distances: [(id: Int, dist: Double)] = []
    for id in 0..<graph.nodeCount() {
        if let vec = graph.vector(of: id) {
            distances.append((id: id, dist: query.distance(to: vec)))
        }
    }
    let sorted = distances.sorted { $0.dist < $1.dist }
    return sorted.prefix(k).map { $0.id }
}

// Test 1: Empty graph
do {
    let g = Graph()
    let q = Vector([0.0, 0.0])
    let res = g.search(query: q, k: 1)
    assert(res.isEmpty, "Empty graph should return empty result")
}

// Test 2: Single node
do {
    let g = Graph()
    let id = g.addNode(vector: Vector([1.0, 2.0]))
    g.connect(id, id) // self-loop (optional)
    let q = Vector([1.1, 2.1])
    let res = g.search(query: q, k: 1)
    assert(res == [id], "Single node graph should return the only node")
}

// Test 3: Small deterministic graph
do {
    let g = Graph()
    let points: [[Double]] = [
        [0.0, 0.0],
        [1.0, 0.0],
        [0.0, 1.0],
        [1.0, 1.0],
        [0.5, 0.5]
    ]
    var ids: [Int] = []
    for p in points {
        ids.append(g.addNode(vector: Vector(p)))
    }
    // Fully connect each node to all others (dense graph for correctness)
    for i in ids {
        for j in ids where i != j {
            g.connect(i, j)
        }
    }
    let query = Vector([0.6, 0.6])
    let k = 3
    let approx = g.search(query: query, k: k)
    let exact = bruteForceSearch(graph: g, query: query, k: k)
    assert(approx == exact, "Approximate search should match exact on fully connected small graph")
}

// Test 4: k larger than node count
do {
    let g = Graph()
    let ids = (0..<5).map { _ in g.addNode(vector: Vector([Double.random(in: -10...10), Double.random(in: -10...10)])) }
    // Connect each node to its two nearest (simple heuristic)
    for i in ids {
        var distances: [(id: Int, dist: Double)] = []
        guard let vi = g.vector(of: i) else { continue }
        for j in ids where i != j {
            if let vj = g.vector(of: j) {
                distances.append((id: j, dist: vi.distance(to: vj)))
            }
        }
        let nearest = distances.sorted { $0.dist < $1.dist }.prefix(2)
        for n in nearest {
            g.connect(i, n.id)
        }
    }
    let query = Vector([0.0, 0.0])
    let result = g.search(query: query, k: 10)
    assert(result.count == 5, "Result count should be capped at number of nodes")
}

// Test 5: Random moderate graph consistency check
do {
    let nodeCount = 50
    let dim = 3
    let g = Graph()
    var ids: [Int] = []
    for _ in 0..<nodeCount {
        let vec = Vector((0..<dim).map { _ in Double.random(in: -100...100) })
        ids.append(g.addNode(vector: vec))
    }
    // Connect each node to its 5 nearest neighbors
    for i in ids {
        var distances: [(id: Int, dist: Double)] = []
        guard let vi = g.vector(of: i) else { continue }
        for j in ids where i != j {
            if let vj = g.vector(of: j) {
                distances.append((id: j, dist: vi.distance(to: vj)))
            }
        }
        let nearest = distances.sorted { $0.dist < $1.dist }.prefix(5)
        for n in nearest {
            g.connect(i, n.id)
        }
    }
    let query = Vector((0..<dim).map { _ in Double.random(in: -100...100) })
    let k = 5
    let approx = g.search(query: query, k: k)
    let exact = bruteForceSearch(graph: g, query: query, k: k)
    // Approximate may differ; ensure it returns k distinct ids and all are valid
    assert(approx.count == k, "Approximate result should contain k ids")
    for id in approx {
        assert(g.vector(of: id) != nil, "Returned id must exist in graph")
    }
    // Additionally, verify that the farthest distance in approx is not greater than twice the farthest exact distance (sanity)
    let approxDists = approx.map { g.vector(of: $0)!.distance(to: query) }
    let exactDists = exact.map { g.vector(of: $0)!.distance(to: query) }
    if let maxApprox = approxDists.max(), let maxExact = exactDists.max() {
        assert(maxApprox <= 2.0 * maxExact + 1e-6, "Approximate distances should be within reasonable bound")
    }
}

// All tests passed
print("All tests passed.")
