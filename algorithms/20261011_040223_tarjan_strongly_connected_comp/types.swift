import Foundation

/// Represents a directed graph using an adjacency list.
/// Vertices are identified by integer indices ranging from 0 to `vertexCount - 1`.
public struct Graph {
    public let vertexCount: Int
    /// adjacency list where `edges[v]` contains all vertices reachable from `v`.
    public var edges: [[Int]]

    /// Initializes a graph with a given number of vertices and optional edge list.
    /// - Parameters:
    ///   - vertexCount: Number of vertices in the graph.
    ///   - edges: Optional adjacency list; if omitted, an empty list for each vertex is created.
    public init(vertexCount: Int, edges: [[Int]]? = nil) {
        precondition(vertexCount >= 0, "vertexCount must be non‑negative")
        self.vertexCount = vertexCount
        if let provided = edges {
            precondition(provided.count == vertexCount, "edges count must match vertexCount")
            self.edges = provided
        } else {
            self.edges = Array(repeating: [], count: vertexCount)
        }
    }

    /// Adds a directed edge from `source` to `destination`.
    /// - Parameters:
    ///   - source: Index of the source vertex.
    ///   - destination: Index of the destination vertex.
    public mutating func addEdge(from source: Int, to destination: Int) {
        precondition(source >= 0 && source < vertexCount, "source out of bounds")
        precondition(destination >= 0 && destination < vertexCount, "destination out of bounds")
        edges[source].append(destination)
    }
}
