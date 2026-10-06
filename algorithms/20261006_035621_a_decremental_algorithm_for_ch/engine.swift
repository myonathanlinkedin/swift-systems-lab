import Foundation

public struct BraessChecker {
    private let originalGraph: Graph
    private let source: Int
    private let target: Int
    
    public init(graph: Graph, source: Int, target: Int) {
        self.originalGraph = graph
        self.source = source
        self.target = target
    }
    
    // Returns true if removing any single edge strictly decreases the shortest path distance
    public func hasBraessParadox() -> Bool {
        guard let originalDist = originalGraph.shortestPath(from: source, to: target) else {
            // No path exists originally; paradox not defined
            return false
        }
        for edge in originalGraph.edges {
            let reducedGraph = originalGraph.removingEdge(edge.id)
            if let newDist = reducedGraph.shortestPath(from: source, to: target) {
                if newDist < originalDist - 1e-9 {
                    // Found an edge whose removal improves travel time
                    return true
                }
            }
        }
        return false
    }
}
