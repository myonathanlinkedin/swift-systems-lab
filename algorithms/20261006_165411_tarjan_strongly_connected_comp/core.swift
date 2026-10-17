import Foundation

struct TarjanSCC {
    let graph: [[Int]]
    var index: Int = 0
    var indices: [Int]
    var lowlink: [Int]
    var onStack: [Bool]
    var stack: [Int] = []
    var sccs: [[Int]] = []

    init(graph: [[Int]]) {
        self.graph = graph
        let n = graph.count
        self.indices = Array(repeating: -1, count: n)
        self.lowlink = Array(repeating: -1, count: n)
        self.onStack = Array(repeating: false, count: n)
    }

    mutating func run() -> [[Int]] {
        for v in 0..<graph.count {
            if indices[v] == -1 {
                strongConnect(v)
            }
        }
        return sccs
    }

    mutating func strongConnect(_ v: Int) {
        indices[v] = index
        lowlink[v] = index
        index += 1
        stack.append(v)
        onStack[v] = true

        for w in graph[v] {
            if indices[w] == -1 {
                strongConnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            } else if onStack[w] {
                lowlink[v] = min(lowlink[v], indices[w])
            }
        }

        if lowlink[v] == indices[v] {
            var component: [Int] = []
            var w: Int = -1
            repeat {
                w = stack.removeLast()
                onStack[w] = false
                component.append(w)
            } while w != v
            sccs.append(component)
        }
    }
}
