import Foundation

public struct Vector {
    public var components: [Double]

    public init(_ components: [Double]) {
        self.components = components
    }

    public func distance(to other: Vector) -> Double {
        precondition(components.count == other.components.count, "Dimension mismatch")
        var sum: Double = 0.0
        for i in 0..<components.count {
            let diff = components[i] - other.components[i]
            sum += diff * diff
        }
        return sqrt(sum)
    }
}

public struct Node {
    public let id: Int
    public let vector: Vector
    public var neighbors: [Int]

    public init(id: Int, vector: Vector) {
        self.id = id
        self.vector = vector
        self.neighbors = []
    }
}

public struct Candidate: Comparable {
    public let distance: Double
    public let nodeId: Int

    public static func < (lhs: Candidate, rhs: Candidate) -> Bool {
        return lhs.distance < rhs.distance
    }

    public static func == (lhs: Candidate, rhs: Candidate) -> Bool {
        return lhs.distance == rhs.distance && lhs.nodeId == rhs.nodeId
    }
}

public struct MinHeap<T: Comparable> {
    var elements: [T] = []

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public mutating func push(_ value: T) {
        elements.append(value)
        siftUp(from: elements.count - 1)
    }

    public mutating func pop() -> T? {
        guard !elements.isEmpty else { return nil }
        if elements.count == 1 {
            return elements.removeLast()
        }
        let value = elements[0]
        elements[0] = elements.removeLast()
        siftDown(from: 0)
        return value
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
            var smallest = parent
            if left < elements.count && elements[left] < elements[smallest] {
                smallest = left
            }
            if right < elements.count && elements[right] < elements[smallest] {
                smallest = right
            }
            if smallest == parent { break }
            elements.swapAt(parent, smallest)
            parent = smallest
        }
    }
}

public final class Graph {
    var nodes: [Int: Node] = [:]
    var nextId: Int = 0

    public init() {}

    @discardableResult
    public func addNode(vector: Vector) -> Int {
        let id = nextId
        nextId += 1
        nodes[id] = Node(id: id, vector: vector)
        return id
    }

    public func connect(_ fromId: Int, _ toId: Int) {
        guard var fromNode = nodes[fromId] else { return }
        guard nodes[toId] != nil else { return }
        if !fromNode.neighbors.contains(toId) {
            fromNode.neighbors.append(toId)
            nodes[fromId] = fromNode
        }
    }

    public func neighbors(of id: Int) -> [Int] {
        return nodes[id]?.neighbors ?? []
    }

    public func vector(of id: Int) -> Vector? {
        return nodes[id]?.vector
    }

    public func nodeCount() -> Int {
        return nodes.count
    }

    public func search(query: Vector, k: Int, visitedLimit: Int = 200) -> [Int] {
        guard !nodes.isEmpty else { return [] }
        // Choose an arbitrary start node (the smallest id)
        let startId = nodes.keys.min()!
        var heap = MinHeap<Candidate>()
        var visited = Set<Int>()
        var result: [(id: Int, distance: Double)] = []

        if let startVector = nodes[startId]?.vector {
            let dist = query.distance(to: startVector)
            heap.push(Candidate(distance: dist, nodeId: startId))
        }

        while !heap.isEmpty && visited.count < visitedLimit && result.count < k {
            guard let current = heap.pop() else { break }
            if visited.contains(current.nodeId) { continue }
            visited.insert(current.nodeId)

            if let nodeVector = nodes[current.nodeId]?.vector {
                result.append((id: current.nodeId, distance: current.distance))
                // Expand neighbors
                for neighborId in nodes[current.nodeId]?.neighbors ?? [] {
                    if visited.contains(neighborId) { continue }
                    if let neighborVector = nodes[neighborId]?.vector {
                        let ndist = query.distance(to: neighborVector)
                        heap.push(Candidate(distance: ndist, nodeId: neighborId))
                    }
                }
            }
        }

        // Sort final results by distance (ascending) and return ids
        let sorted = result.sorted { $0.distance < $1.distance }
        return sorted.prefix(k).map { $0.id }
    }
}
