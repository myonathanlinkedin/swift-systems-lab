import Foundation

/// Represents a directed edge in a flow network.
public struct Edge {
    public let from: Int
    public let to: Int
    public let capacity: Int
    public var flow: Int
    
    public init(from: Int, to: Int, capacity: Int, flow: Int = 0) {
        self.from = from
        self.to = to
        self.capacity = capacity
        self.flow = flow
    }
    
    /// Residual capacity of the edge in the forward direction.
    public var residualCapacity: Int {
        return capacity - flow
    }
    
    /// Residual capacity of the reverse edge (used implicitly in the algorithm).
    public var reverseResidualCapacity: Int {
        return flow
    }
}

/// Simple directed graph suitable for max‑flow / min‑cut computations.
public struct Graph {
    /// All edges stored in a flat array. For each original edge we also store a reverse edge.
    public var edges: [Edge] = []
    
    /// Adjacency list mapping a vertex to indices in `edges`.
    public var adjacency: [Int: [Int]] = [:]
    
    /// Set of all vertex identifiers.
    public var vertices: Set<Int> = []
    
    public init() {}
    
    /// Adds a directed edge with the given capacity. Also creates a reverse edge with 0 capacity.
    public mutating func addEdge(from: Int, to: Int, capacity: Int) {
        precondition(capacity >= 0, "Capacity must be non‑negative")
        let forwardIndex = edges.count
        let reverseIndex = forwardIndex + 1
        
        let forward = Edge(from: from, to: to, capacity: capacity, flow: 0)
        let reverse = Edge(from: to, to: from, capacity: 0, flow: 0)
        
        edges.append(forward)
        edges.append(reverse)
        
        adjacency[from, default: []].append(forwardIndex)
        adjacency[to, default: []].append(reverseIndex)
        
        vertices.insert(from)
        vertices.insert(to)
    }
    
    /// Returns the index of the reverse edge for a given forward edge index.
    public func reverseIndex(of index: Int) -> Int {
        return index ^ 1 // flips the least‑significant bit (0↔1, 2↔3, …)
    }
}
