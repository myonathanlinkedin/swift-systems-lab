public struct Graph {
    var nodes: Set<Int>
    var adjacency: [Int: [Int]]
    
    public init() {
        nodes = Set<Int>()
        adjacency = [:]
    }
    
    public mutating func addNode(_ node: Int) {
        nodes.insert(node)
    }
    
    public mutating func addEdge(from: Int, to: Int) {
        nodes.insert(from)
        nodes.insert(to)
        adjacency[from, default: []].append(to)
    }
}
