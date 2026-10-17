import Foundation

/// A simple directed graph using adjacency lists.
public struct Graph {
    public let vertexCount: Int
    public var adjacency: [[Int]]

    /// Initializes a graph with a given number of vertices and optional edges.
    /// - Parameters:
    ///   - vertexCount: Number of vertices, indexed from 0 to vertexCount‑1.
    ///   - edges: Array of directed edges represented as `(source, destination)`.
    public init(vertexCount: Int, edges: [(Int, Int)] = []) {
        precondition(vertexCount >= 0, "Vertex count must be non‑negative")
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
        precondition(src >= 0 && src < vertexCount, "Source out of bounds")
        precondition(dst >= 0 && dst < vertexCount, "Destination out of bounds")
        adjacency[src].append(dst)
    }
}

/// Tarjan's algorithm for finding strongly connected components (SCCs) in a directed graph.
/// The algorithm runs in O(V + E) time and O(V) space.
public struct TarjanSCC {
    public var graph: Graph

    var index: Int = 0
    var indices: [Int]
    var lowlink: [Int]
    var onStack: [Bool]
    var stack: [Int] = []
    var sccs: [[Int]] = []

    /// Creates a new TarjanSCC instance for the supplied graph.
    /// - Parameter graph: The directed graph to analyse.
    public init(graph: Graph) {
        self.graph = graph
        self.indices = Array(repeating: -1, count: graph.vertexCount)
        self.lowlink = Array(repeating: -1, count: graph.vertexCount)
        self.onStack = Array(repeating: false, count: graph.vertexCount)
    }

    /// Executes the algorithm and returns all SCCs.
    /// Each component is an array of vertex indices; the order of components is
    /// deterministic but not guaranteed to be topologically sorted.
    /// - Returns: A list of strongly connected components.
    public mutating func run() -> [[Int]] {
        for v in 0..<graph.vertexCount {
            if indices[v] == -1 {
                strongConnect(v)
            }
        }
        return sccs
    }

    /// Recursive depth‑first search that discovers SCCs.
    /// - Parameter v: The current vertex.
    private mutating func strongConnect(_ v: Int) {
        indices[v] = index
        lowlink[v] = index
        index += 1
        stack.append(v)
        onStack[v] = true

        for w in graph.adjacency[v] {
            if indices[w] == -1 {
                strongConnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            } else if onStack[w] {
                lowlink[v] = min(lowlink[v], indices[w])
            }
        }

        if lowlink[v] == indices[v] {
            var component: [Int] = []
            while true {
                let w = stack.removeLast()
                onStack[w] = false
                component.append(w)
                if w == v { break }
            }
            sccs.append(component)
        }
    }
}
