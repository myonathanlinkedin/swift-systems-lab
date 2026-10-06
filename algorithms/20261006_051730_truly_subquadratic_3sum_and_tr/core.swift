import Foundation

// MARK: - 3SUM Solver

public struct ThreeSumSolver {
    /// Returns all unique triplets [a, b, c] such that a + b + c == 0.
    /// Each triplet is sorted in non‑decreasing order and the result contains no duplicates.
    public func solve(_ nums: [Int]) -> [[Int]] {
        guard nums.count >= 3 else { return [] }
        let sorted = nums.sorted()
        var result: [[Int]] = []
        let n = sorted.count
        
        for i in 0..<(n - 2) {
            if i > 0 && sorted[i] == sorted[i - 1] { continue }
            var left = i + 1
            var right = n - 1
            while left < right {
                let sum = sorted[i] + sorted[left] + sorted[right]
                if sum == 0 {
                    result.append([sorted[i], sorted[left], sorted[right]])
                    // skip duplicates
                    let curL = sorted[left]
                    let curR = sorted[right]
                    while left < right && sorted[left] == curL { left += 1 }
                    while left < right && sorted[right] == curR { right -= 1 }
                } else if sum < 0 {
                    left += 1
                } else {
                    right -= 1
                }
            }
        }
        return result
    }
}

// MARK: - Graph Structures for APSP (Johnson's Algorithm)

public struct Edge {
    public let to: Int
    public let weight: Int
    public init(to: Int, weight: Int) {
        self.to = to
        self.weight = weight
    }
}

public struct Graph {
    public let vertexCount: Int
    private var adjacency: [[Edge]]
    
    public init(vertexCount: Int) {
        self.vertexCount = vertexCount
        self.adjacency = Array(repeating: [], count: vertexCount)
    }
    
    public mutating func addEdge(from: Int, to: Int, weight: Int) {
        precondition(0 <= from && from < vertexCount)
        precondition(0 <= to && to < vertexCount)
        adjacency[from].append(Edge(to: to, weight: weight))
    }
    
    private func edges(from v: Int) -> [Edge] {
        return adjacency[v]
    }
    
    // Johnson's algorithm: O(V * E log V) for sparse graphs
    public func allPairsShortestPaths() -> [[Int?]] {
        // Step 1: add a new source s = V with zero-weight edges to all vertices
        var extendedAdj = adjacency
        extendedAdj.append(Array(repeating: Edge(to: 0, weight: 0), count: vertexCount))
        for v in 0..<vertexCount {
            extendedAdj[vertexCount].append(Edge(to: v, weight: 0))
        }
        // Step 2: Bellman‑Ford from s to compute potentials h(v)
        guard let h = bellmanFord(start: vertexCount, adjacency: extendedAdj) else {
            // Negative cycle detected; APSP undefined
            return Array(repeating: Array(repeating: nil, count: vertexCount), count: vertexCount)
        }
        // Step 3: reweight edges to eliminate negatives
        var reweightedAdj = adjacency
        for u in 0..<vertexCount {
            for i in 0..<reweightedAdj[u].count {
                let e = reweightedAdj[u][i]
                let newWeight = e.weight + h[u] - h[e.to]
                reweightedAdj[u][i] = Edge(to: e.to, weight: newWeight)
            }
        }
        // Step 4: run Dijkstra from each vertex on reweighted graph
        var distances = Array(repeating: Array(repeating: Int?.none, count: vertexCount), count: vertexCount)
        for src in 0..<vertexCount {
            let d = dijkstra(start: src, adjacency: reweightedAdj)
            for v in 0..<vertexCount {
                if let dv = d[v] {
                    // undo reweighting
                    distances[src][v] = dv - h[src] + h[v]
                }
            }
        }
        return distances
    }
    
    // MARK: - Bellman‑Ford
    
    private func bellmanFord(start: Int, adjacency: [[Edge]]) -> [Int]? {
        let V = adjacency.count
        var dist = Array(repeating: Int.max / 2, count: V)
        dist[start] = 0
        for _ in 0..<(V - 1) {
            var updated = false
            for u in 0..<V {
                let du = dist[u]
                if du == Int.max / 2 { continue }
                for e in adjacency[u] {
                    if du + e.weight < dist[e.to] {
                        dist[e.to] = du + e.weight
                        updated = true
                    }
                }
            }
            if !updated { break }
        }
        // Check for negative cycles
        for u in 0..<V {
            let du = dist[u]
            if du == Int.max / 2 { continue }
            for e in adjacency[u] {
                if du + e.weight < dist[e.to] {
                    return nil // negative cycle
                }
            }
        }
        return dist
    }
    
    // MARK: - Dijkstra with binary heap
    
    private func dijkstra(start: Int, adjacency: [[Edge]]) -> [Int?] {
        var dist = Array(repeating: Int?.none, count: vertexCount)
        var heap = MinHeap<NodeDist>()
        heap.push(NodeDist(node: start, dist: 0))
        while let nd = heap.pop() {
            if let existing = dist[nd.node] {
                if nd.dist >= existing { continue }
            }
            dist[nd.node] = nd.dist
            for e in adjacency[nd.node] {
                let newDist = nd.dist + e.weight
                if let cur = dist[e.to] {
                    if newDist < cur {
                        heap.push(NodeDist(node: e.to, dist: newDist))
                    }
                } else {
                    heap.push(NodeDist(node: e.to, dist: newDist))
                }
            }
        }
        return dist
    }
}

// MARK: - MinHeap and NodeDist

public struct NodeDist: Comparable {
    public let node: Int
    public let dist: Int
    
    public static func < (lhs: NodeDist, rhs: NodeDist) -> Bool {
        if lhs.dist == rhs.dist {
            return lhs.node < rhs.node
        }
        return lhs.dist < rhs.dist
    }
    
    public static func == (lhs: NodeDist, rhs: NodeDist) -> Bool {
        return lhs.dist == rhs.dist && lhs.node == rhs.node
    }
}

public struct MinHeap<T: Comparable> {
    private var elements: [T] = []
    
    public var isEmpty: Bool { elements.isEmpty }
    
    public mutating func push(_ value: T) {
        elements.append(value)
        siftUp(from: elements.count - 1)
    }
    
    public mutating func pop() -> T? {
        guard !elements.isEmpty else { return nil }
        if elements.count == 1 {
            return elements.removeLast()
        }
        let root = elements[0]
        elements[0] = elements.removeLast()
        siftDown(from: 0)
        return root
    }
    
    // MARK: - Heap Helpers
    
    private mutating func siftUp(from index: Int) {
        var child = index
        var parent = (child - 1) / 2
        while child > 0 && elements[child] < elements[parent] {
            elements.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }
    
    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var candidate = parent
            if left < elements.count && elements[left] < elements[candidate] {
                candidate = left
            }
            if right < elements.count && elements[right] < elements[candidate] {
                candidate = right
            }
            if candidate == parent { return }
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
}
