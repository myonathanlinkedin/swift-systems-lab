import Foundation

struct Graph {
    var adjacency: [[Int]]
    init(nodeCount: Int) {
        adjacency = Array(repeating: [], count: nodeCount)
    }
    mutating func addEdge(from: Int, to: Int) {
        adjacency[from].append(to)
    }
    var nodeCount: Int { adjacency.count }
}

struct TarjanSCC {
    var graph: Graph
    var index: Int = 0
    var indices: [Int]
    var lowlink: [Int]
    var onStack: [Bool]
    var stack: [Int] = []
    var result: [[Int]] = []

    init(graph: Graph) {
        self.graph = graph
        let n = graph.nodeCount
        indices = Array(repeating: -1, count: n)
        lowlink = Array(repeating: -1, count: n)
        onStack = Array(repeating: false, count: n)
    }

    mutating func run() -> [[Int]] {
        for v in 0..<graph.nodeCount {
            if indices[v] == -1 {
                strongConnect(v: v)
            }
        }
        return result
    }

    mutating func strongConnect(v: Int) {
        indices[v] = index
        lowlink[v] = index
        index += 1
        stack.append(v)
        onStack[v] = true

        for w in graph.adjacency[v] {
            if indices[w] == -1 {
                strongConnect(v: w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            } else if onStack[w] {
                lowlink[v] = min(lowlink[v], indices[w])
            }
        }

        if lowlink[v] == indices[v] {
            var scc: [Int] = []
            var w: Int
            repeat {
                w = stack.removeLast()
                onStack[w] = false
                scc.append(w)
            } while w != v
            result.append(scc)
        }
    }
}
