import Foundation

/// Implements Tarjan's algorithm for finding strongly connected components (SCCs) in a directed graph.
/// The algorithm runs in O(V + E) time and O(V) auxiliary space.
public struct TarjanSCC {
    let graph: Graph

    // Mutable state used during the depth‑first search.
    var indexCounter: Int = 0
    var indices: [Int]          // discovery index of each vertex; -1 means unvisited
    var lowlink: [Int]          // smallest index reachable from the vertex
    var onStack: [Bool]         // whether a vertex is currently on the stack
    var stack: [Int]            // stack of vertices in the current DFS path
    var components: [[Int]] = [] // collected SCCs

    /// Creates a TarjanSCC instance for a given graph.
    /// - Parameter graph: The directed graph to analyse.
    public init(graph: Graph) {
        self.graph = graph
        self.indices = Array(repeating: -1, count: graph.vertexCount)
        self.lowlink = Array(repeating: 0, count: graph.vertexCount)
        self.onStack = Array(repeating: false, count: graph.vertexCount)
        self.stack = []
    }

    /// Executes Tarjan's algorithm and returns all strongly connected components.
    /// Each component is represented as an array of vertex indices.
    /// The order of components and the order of vertices inside a component are deterministic
    /// (components are sorted lexicographically after internal sorting).
    public mutating func run() -> [[Int]] {
        // Perform DFS from every unvisited vertex.
        for v in 0..<graph.vertexCount {
            if indices[v] == -1 {
                strongConnect(v)
            }
        }

        // Normalise output: sort vertices inside each component and then sort the list of components.
        let normalized = components.map { $0.sorted() }
        return normalized.sorted(by: { $0.lexicographicallyPrecedes($1) })
    }

    // MARK: - Private helpers

    /// The recursive core of Tarjan's algorithm.
    private mutating func strongConnect(_ v: Int) {
        // Set the discovery index and lowlink value.
        indices[v] = indexCounter
        lowlink[v] = indexCounter
        indexCounter += 1

        // Push v onto the stack.
        stack.append(v)
        onStack[v] = true

        // Consider successors of v.
        for w in graph.edges[v] {
            if indices[w] == -1 {
                // Successor w has not yet been visited; recurse on it.
                strongConnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            } else if onStack[w] {
                // Successor w is in the current SCC.
                lowlink[v] = min(lowlink[v], indices[w])
            }
        }

        // If v is a root node, pop the stack to generate an SCC.
        if lowlink[v] == indices[v] {
            var component: [Int] = []
            while true {
                let w = stack.removeLast()
                onStack[w] = false
                component.append(w)
                if w == v { break }
            }
            components.append(component)
        }
    }
}
