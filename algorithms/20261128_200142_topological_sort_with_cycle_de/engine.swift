public struct TopologicalSorter {
    let graph: Graph
    
    public init(graph: Graph) {
        self.graph = graph
    }
    
    public func run() -> [Int]? {
        var indegree: [Int: Int] = [:]
        for node in graph.nodes {
            indegree[node] = 0
        }
        for (from, neighbors) in graph.adjacency {
            for neighbor in neighbors {
                indegree[neighbor]! += 1
            }
        }
        var queue: [Int] = []
        for (node, deg) in indegree {
            if deg == 0 {
                queue.append(node)
            }
        }
        var index = 0
        var order: [Int] = []
        while index < queue.count {
            let node = queue[index]
            index += 1
            order.append(node)
            if let neighbors = graph.adjacency[node] {
                for neighbor in neighbors {
                    indegree[neighbor]! -= 1
                    if indegree[neighbor]! == 0 {
                        queue.append(neighbor)
                    }
                }
            }
        }
        if order.count == graph.nodes.count {
            return order
        } else {
            return nil
        }
    }
    
    public func hasCycle() -> Bool {
        return run() == nil
    }
}
