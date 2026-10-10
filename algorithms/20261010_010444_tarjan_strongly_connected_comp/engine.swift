import Foundation

/// Implements Tarjan's algorithm for finding strongly connected components (SCCs) in a directed graph.
/// The algorithm runs in O(V + E) time and O(V) space.
public struct TarjanSCC {
    /// Input graph.
    public var graph: Graph
    
    // Internal mutable state used during the depth‑first search.
    var indexCounter: Int = 0
    var indices: [Int]          // Discovery index of each vertex; -1 means unvisited.
    var lowlink: [Int]          // Lowest index reachable from the vertex.
    var onStack: [Bool]         // Tracks whether a vertex is currently on the stack.
    var stack: [Int]            // Stack of vertices in the current DFS path.
    var components: [[Int]]     // Accumulated SCCs.
    
    /// Creates a new TarjanSCC instance for the supplied graph.
    /// - Parameter graph: Directed graph to analyse.
    public init(graph: Graph) {
        self.graph = graph
        self.indices = Array(repeating: -1, count: graph.vertexCount)
        self.lowlink = Array(repeating: -1, count: graph.vertexCount)
        self.onStack = Array(repeating: false, count: graph.vertexCount)
        self.stack = []
        self.components = []
    }
    
    /// Executes Tarjan's algorithm and returns all strongly connected components.
    /// Each component is an array of vertex indices; the order of components and vertices
    /// inside each component follows the order of discovery (deterministic for a given graph).
    /// - Returns: A two‑dimensional array where each inner array is an SCC.
    public mutating func run() -> [[Int]] {
        // Start a DFS from every unvisited vertex.
        for v in 0..<graph.vertexCount {
            if indices[v] == -1 {
                strongConnect(v)
            }
        }
        return components
    }
    
    /// Recursive helper that performs the core of Tarjan's algorithm.
    /// - Parameter v: Vertex to process.
    private mutating func strongConnect(_ v: Int) {
        // Set the discovery index and lowlink value.
        indices[v] = indexCounter
        lowlink[v] = indexCounter
        indexCounter += 1
        
        // Push v onto the stack.
        stack.append(v)
        onStack[v] = true
        
        // Consider successors of v.
        for w in graph.adjacency[v] {
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
                guard let w = stack.popLast() else {
                    fatalError("Stack underflow while forming SCC")
                }
                onStack[w] = false
                component.append(w)
                if w == v { break }
            }
            // Store the component (reverse to maintain original discovery order).
            components.append(component.reversed())
        }
    }
}
