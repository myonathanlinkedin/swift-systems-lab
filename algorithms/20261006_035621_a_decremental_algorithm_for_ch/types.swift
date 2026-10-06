import Foundation

// MARK: - Edge Definition
public struct Edge: Equatable {
    public let id: Int
    public let source: Int
    public let target: Int
    public let weight: Double
    
    public init(id: Int, source: Int, target: Int, weight: Double) {
        self.id = id
        self.source = source
        self.target = target
        self.weight = weight
    }
    
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.id == rhs.id &&
               lhs.source == rhs.source &&
               lhs.target == rhs.target &&
               lhs.weight == rhs.weight
    }
}

// MARK: - Heap Node for Dijkstra
public struct HeapNode: Comparable {
    public let distance: Double
    public let vertex: Int
    
    public init(distance: Double, vertex: Int) {
        self.distance = distance
        self.vertex = vertex
    }
    
    public static func < (lhs: HeapNode, rhs: HeapNode) -> Bool {
        return lhs.distance < rhs.distance
    }
    
    public static func == (lhs: HeapNode, rhs: HeapNode) -> Bool {
        return lhs.distance == rhs.distance && lhs.vertex == rhs.vertex
    }
}

// MARK: - Simple Min-Heap
public struct MinHeap {
    private var elements: [HeapNode] = []
    
    public var isEmpty: Bool {
        return elements.isEmpty
    }
    
    public mutating func push(_ node: HeapNode) {
        elements.append(node)
        siftUp(from: elements.count - 1)
    }
    
    public mutating func pop() -> HeapNode? {
        guard !elements.isEmpty else { return nil }
        if elements.count == 1 {
            return elements.removeLast()
        } else {
            let root = elements[0]
            elements[0] = elements.removeLast()
            siftDown(from: 0)
            return root
        }
    }
    
    private mutating func siftUp(from index: Int) {
        var child = index
        var parent = (child - 1) / 2
        while child > 0 && elements[child] < elements[parent] {
            elements.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }
    
    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var candidate = parent
            if left < elements.count && elements[left] < elements[candidate] {
                candidate = left
            }
            if right < elements.count && elements[right] < elements[candidate] {
                candidate = right
            }
            if candidate == parent { return }
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
}

// MARK: - Graph Structure
public struct Graph {
    public let vertexCount: Int
    public private(set) var edges: [Edge] = []
    private var adjacency: [[(to: Int, weight: Double, edgeId: Int)]] = []
    
    public init(vertexCount: Int) {
        self.vertexCount = vertexCount
        self.adjacency = Array(repeating: [], count: vertexCount)
    }
    
    public mutating func addEdge(source: Int, target: Int, weight: Double) {
        let edgeId = edges.count
        let edge = Edge(id: edgeId, source: source, target: target, weight: weight)
        edges.append(edge)
        adjacency[source].append((to: target, weight: weight, edgeId: edgeId))
    }
    
    public func neighbors(of vertex: Int) -> [(to: Int, weight: Double, edgeId: Int)] {
        return adjacency[vertex]
    }
    
    // Returns a new Graph without the edge of given id
    public func removingEdge(_ edgeId: Int) -> Graph {
        var newGraph = Graph(vertexCount: vertexCount)
        for edge in edges where edge.id != edgeId {
            newGraph.addEdge(source: edge.source, target: edge.target, weight: edge.weight)
        }
        return newGraph
    }
    
    // Dijkstra's algorithm for a single source
    public func shortestPath(from source: Int, to target: Int) -> Double? {
        var distances = Array(repeating: Double.infinity, count: vertexCount)
        distances[source] = 0.0
        var heap = MinHeap()
        heap.push(HeapNode(distance: 0.0, vertex: source))
        
        while let node = heap.pop() {
            let u = node.vertex
            let distU = node.distance
            if distU > distances[u] { continue }
            if u == target { return distU }
            for edge in neighbors(of: u) {
                let v = edge.to
                let alt = distU + edge.weight
                if alt < distances[v] {
                    distances[v] = alt
                    heap.push(HeapNode(distance: alt, vertex: v))
                }
            }
        }
        return distances[target] == Double.infinity ? nil : distances[target]
    }
}
