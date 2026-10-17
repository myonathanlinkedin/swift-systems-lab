import Foundation

public struct Graph {
    public let vertexCount: Int
    public var adjacency: [[Int]]
    
    public init(vertexCount: Int, edges: [(Int, Int)]) {
        self.vertexCount = vertexCount
        self.adjacency = Array(repeating: [], count: vertexCount)
        for (src, dst) in edges {
            precondition(src >= 0 && src < vertexCount, "Source vertex out of bounds")
            precondition(dst >= 0 && dst < vertexCount, "Destination vertex out of bounds")
            self.adjacency[src].append(dst)
        }
    }
}
