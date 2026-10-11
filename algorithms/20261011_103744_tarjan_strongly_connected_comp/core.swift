import Foundation

public struct Graph {
    public let vertexCount: Int
    public var adjacency: [[Int]]

    public init(vertexCount: Int, edges: [(Int, Int)] = []) {
        self.vertexCount = vertexCount
        self.adjacency = Array(repeating: [], count: vertexCount)
        for (src, dst) in edges {
            guard src >= 0 && src < vertexCount && dst >= 0 && dst < vertexCount else { continue }
            adjacency[src].append(dst)
        }
    }

    public mutating func addEdge(from src: Int, to dst: Int) {
        guard src >= 0 && src < vertexCount && dst >= 0 && dst < vertexCount else { return }
        adjacency[src].append(dst)
    }
}

public struct TarjanSCC {
    var graph: Graph
    var index: Int = 0
    var indices: [Int]
    var lowlink: [Int]
    var onStack: [Bool]
    var stack: [Int] = []
    var components: [[Int]] = []

    public init(graph: Graph) {
        self.graph = graph
        self.indices = Array(repeating: -1, count: graph.vertexCount)
        self.lowlink = Array(repeating: 0, count: graph.vertexCount)
        self.onStack = Array(repeating: false, count: graph.vertexCount)
    }

    public mutating func run() -> [[Int]] {
        for v in 0..<graph.vertexCount {
            if indices[v] == -1 {
                strongConnect(v)
            }
        }
        // Deterministic ordering
        for i in 0..<components.count {
            components[i].sort()
        }
        components.sort { (a, b) -> Bool in
            guard let firstA = a.first, let firstB = b.first else { return false }
            return firstA < firstB
        }
        return components
    }

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
            components.append(component)
        }
    }
}
