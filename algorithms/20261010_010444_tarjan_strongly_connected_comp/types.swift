import Foundation

/// Represents a directed graph using an adjacency list.
/// Vertices are identified by integer indices ranging from 0 to `vertexCount - 1`.
public struct Graph {
    /// Number of vertices in the graph.
    public var vertexCount: Int
    
    /// Adjacency list where `adjacency[v]` contains all vertices reachable from `v`.
    public var adjacency: [[Int]]
    
    /// Creates a graph with a given number of vertices and optional edges.
    /// - Parameters:
    ///   - vertexCount: Total number of vertices (must be non‑negative).
    ///   - edges: Collection of directed edges represented as `(source, destination)`.
    public init(vertexCount: Int, edges: [(Int, Int)] = []) {
        precondition(vertexCount >= 0, "vertexCount must be non‑negative")
        self.vertexCount = vertexCount
        self.adjacency = Array(repeating: [], count: vertexCount)
        for (src, dst) in edges {
            addEdge(from: src, to: dst)
        }
    }
    
    /// Adds a directed edge from `src` to `dst`.
    /// - Parameters:
    ///   - src: Source vertex index.
    ///   - dst: Destination vertex index.
    public mutating func addEdge(from src: Int, to dst: Int) {
        precondition(src >= 0 && src < vertexCount, "source out of bounds")
        precondition(dst >= 0 && dst < vertexCount, "destination out of bounds")
        adjacency[src].append(dst)
    }
}
