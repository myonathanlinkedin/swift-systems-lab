import Foundation

// MARK: - SearchableNode Protocol
/// A node that can be used in beam search.
/// Must provide an identifier, a score, and its children.
protocol SearchableNode: Comparable, Hashable {
    var id: Int { get }
    var score: Double { get }
    var children: [Self] { get }
}

// Provide default Comparable implementation based on score (higher is better).
extension SearchableNode {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.score < rhs.score
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.score == rhs.score
    }
}

// MARK: - Node Struct
/// Concrete implementation of SearchableNode.
struct Node: SearchableNode {
    let id: Int
    let score: Double
    let children: [Node]
    
    init(id: Int, score: Double, children: [Node] = []) {
        self.id = id
        self.score = score
        self.children = children
    }
}

// MARK: - Priority Queue
/// A binary max-heap priority queue for Comparable elements.
struct PriorityQueue<T: Comparable> {
    private var heap: [T] = []
    
    var isEmpty: Bool { heap.isEmpty }
    var count: Int { heap.count }
    
    mutating func push(_ element: T) {
        heap.append(element)
        siftUp(heap.count - 1)
    }
    
    mutating func pop() -> T? {
        guard !heap.isEmpty else { return nil }
        if heap.count == 1 { return heap.removeLast() }
        let top = heap[0]
        heap[0] = heap.removeLast()
        siftDown(0)
        return top
    }
    
    private mutating func siftUp(_ index: Int) {
        var child = index
        var parent = (child - 1) / 2
        while child > 0 && heap[child] > heap[parent] {
            heap.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }
    
    private mutating func siftDown(_ index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var candidate = parent
            if left < heap.count && heap[left] > heap[candidate] {
                candidate = left
            }
            if right < heap.count && heap[right] > heap[candidate] {
                candidate = right
            }
            if candidate == parent { break }
            heap.swapAt(parent, candidate)
            parent = candidate
        }
    }
}

// MARK: - Beam Search
/// Performs beam search on a graph of SearchableNode.
struct BeamSearch<NodeType: SearchableNode> {
    let beamWidth: Int
    let maxDepth: Int
    let startNode: NodeType
    
    init(startNode: NodeType, beamWidth: Int = 3, maxDepth: Int = 5) {
        self.startNode = startNode
        self.beamWidth = beamWidth
        self.maxDepth = maxDepth
    }
    
    /// Executes the beam search and returns the top nodes at the final depth.
    mutating func run() -> [NodeType] {
        var frontier: [NodeType] = [startNode]
        for _ in 0..<maxDepth {
            var candidates = PriorityQueue<NodeType>()
            for node in frontier {
                for child in node.children {
                    candidates.push(child)
                }
            }
            if candidates.isEmpty { break }
            frontier = []
            for _ in 0..<beamWidth {
                if let top = candidates.pop() {
                    frontier.append(top)
                } else {
                    break
                }
            }
        }
        return frontier
    }
}
