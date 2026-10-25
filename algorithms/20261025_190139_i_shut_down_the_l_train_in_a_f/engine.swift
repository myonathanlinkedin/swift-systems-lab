import Foundation

/// Core algorithm implementing Edmonds‑Karp (BFS‑based Ford‑Fulkerson) to compute max flow and min cut.
public struct MaxFlowEngine {
    public var graph: Graph
    public let source: Int
    public let sink: Int
    
    public init(graph: Graph, source: Int, sink: Int) {
        precondition(graph.vertices.contains(source), "Source vertex must exist in the graph")
        precondition(graph.vertices.contains(sink), "Sink vertex must exist in the graph")
        self.graph = graph
        self.source = source
        self.sink = sink
    }
    
    /// Runs the algorithm and returns the maximum flow value together with the list of min‑cut edges.
    public mutating func run() -> (maxFlow: Int, minCutEdges: [(Int, Int)]) {
        var maxFlow = 0
        
        // Repeatedly find augmenting paths via BFS.
        while let (path, bottleneck) = bfsAugmentingPath() {
            // Augment flow along the path.
            for edgeIdx in path {
                // Forward edge update.
                graph.edges[edgeIdx].flow += bottleneck
                // Reverse edge update.
                let revIdx = graph.reverseIndex(of: edgeIdx)
                graph.edges[revIdx].flow -= bottleneck
            }
            maxFlow += bottleneck
        }
        
        // After max flow, compute reachable vertices in the residual graph.
        let reachable = residualReachableVertices()
        
        // Min‑cut edges are original forward edges crossing from reachable to non‑reachable.
        var cutEdges: [(Int, Int)] = []
        for (idx, edge) in graph.edges.enumerated() where idx % 2 == 0 { // only original forward edges
            if reachable.contains(edge.from) && !reachable.contains(edge.to) && edge.capacity > 0 {
                cutEdges.append((edge.from, edge.to))
            }
        }
        
        return (maxFlow, cutEdges)
    }
    
    /// Breadth‑first search for an augmenting path. Returns the list of edge indices (forward or reverse) and the bottleneck capacity.
    private mutating func bfsAugmentingPath() -> (path: [Int], bottleneck: Int)? {
        var parentEdge: [Int: Int] = [:] // child vertex -> edge index used to reach it
        var visited: Set<Int> = [source]
        var queue: [Int] = [source]
        var head = 0
        
        while head < queue.count {
            let u = queue[head]
            head += 1
            
            guard let edgeIndices = graph.adjacency[u] else { continue }
            for edgeIdx in edgeIndices {
                let edge = graph.edges[edgeIdx]
                let residual = edgeIdx % 2 == 0 ? edge.residualCapacity : edge.reverseResidualCapacity
                if residual > 0 && !visited.contains(edge.to) {
                    visited.insert(edge.to)
                    parentEdge[edge.to] = edgeIdx
                    if edge.to == sink {
                        // Reconstruct path.
                        var path: [Int] = []
                        var v = sink
                        var minCap = Int.max
                        while v != source {
                            guard let eIdx = parentEdge[v] else { break }
                            let e = graph.edges[eIdx]
                            let cap = eIdx % 2 == 0 ? e.residualCapacity : e.reverseResidualCapacity
                            minCap = min(minCap, cap)
                            path.append(eIdx)
                            v = e.from
                        }
                        return (path.reversed(), minCap)
                    }
                    queue.append(edge.to)
                }
            }
        }
        return nil // no augmenting path
    }
    
    /// Returns the set of vertices reachable from the source in the residual network.
    func residualReachableVertices() -> Set<Int> {
        var reachable: Set<Int> = [source]
        var queue: [Int] = [source]
        var head = 0
        
        while head < queue.count {
            let u = queue[head]
            head += 1
            guard let edgeIndices = graph.adjacency[u] else { continue }
            for edgeIdx in edgeIndices {
                let edge = graph.edges[edgeIdx]
                let residual = edgeIdx % 2 == 0 ? edge.residualCapacity : edge.reverseResidualCapacity
                if residual > 0 && !reachable.contains(edge.to) {
                    reachable.insert(edge.to)
                    queue.append(edge.to)
                }
            }
        }
        return reachable
    }
}
