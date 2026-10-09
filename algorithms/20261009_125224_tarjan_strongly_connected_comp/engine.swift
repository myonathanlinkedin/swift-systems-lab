import Foundation

public struct TarjanSCC {
    public var graph: Graph
    
    // mutable state for the algorithm
    public var index: Int = 0
    public var indices: [Int]
    public var lowlink: [Int]
    public var onStack: [Bool]
    public var stack: [Int] = []
    public var components: [[Int]] = []
    
    public init(graph: Graph) {
        self.graph = graph
        self.indices = Array(repeating: -1, count: graph.vertexCount)
        self.lowlink = Array(repeating: -1, count: graph.vertexCount)
        self.onStack = Array(repeating: false, count: graph.vertexCount)
    }
    
    // Public entry point
    public mutating func run() -> [[Int]] {
        for v in 0..<graph.vertexCount {
            if indices[v] == -1 {
                strongConnect(v)
            }
        }
        // Normalize each component (sorted vertices) and overall order (by first vertex)
        let normalized = components.map { $0.sorted() }
        return normalized.sorted { $0.first! < $1.first! }
    }
    
    // Core recursive function
    private mutating func strongConnect(_ v: Int) {
        // Set the depth index for v
        indices[v] = index
        lowlink[v] = index
        index += 1
        stack.append(v)
        onStack[v] = true
        
        // Consider successors of v
        for w in graph.adjacency[v] {
            if indices[w] == -1 {
                // Successor w has not yet been visited; recurse on it
                strongConnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            } else if onStack[w] {
                // Successor w is in stack and hence in the current SCC
                lowlink[v] = min(lowlink[v], indices[w])
            }
        }
        
        // If v is a root node, pop the stack and generate an SCC
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
