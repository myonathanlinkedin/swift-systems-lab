import Foundation

public struct Point: Hashable, Equatable {
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public struct Grid {
    public let width: Int
    public let height: Int
    var costs: [[Double]]
    public static let infiniteCost = Double.greatestFiniteMagnitude
    
    public init(width: Int, height: Int, defaultCost: Double = 1.0) {
        self.width = width
        self.height = height
        self.costs = Array(repeating: Array(repeating: defaultCost, count: width), count: height)
    }
    
    public func isInside(_ p: Point) -> Bool {
        return p.x >= 0 && p.x < width && p.y >= 0 && p.y < height
    }
    
    public func cost(at p: Point) -> Double {
        guard isInside(p) else { return Grid.infiniteCost }
        return costs[p.y][p.x]
    }
    
    public mutating func setCost(at p: Point, cost: Double) {
        guard isInside(p) else { return }
        costs[p.y][p.x] = cost
    }
    
    public func isWalkable(at p: Point) -> Bool {
        return cost(at: p) < Grid.infiniteCost
    }
}

// Wrapper for priority queue elements
fileprivate struct PQElement: Comparable {
    let point: Point
    let priority: Double
    
    static func < (lhs: PQElement, rhs: PQElement) -> Bool {
        return lhs.priority < rhs.priority
    }
    
    static func == (lhs: PQElement, rhs: PQElement) -> Bool {
        return lhs.point == rhs.point && lhs.priority == rhs.priority
    }
}

// Simple binary min-heap
fileprivate struct MinHeap {
    var elements: [PQElement] = []
    
    var isEmpty: Bool { elements.isEmpty }
    
    mutating func push(_ element: PQElement) {
        elements.append(element)
        siftUp(from: elements.count - 1)
    }
    
    mutating func pop() -> PQElement? {
        guard !elements.isEmpty else { return nil }
        if elements.count == 1 {
            return elements.removeLast()
        }
        let root = elements[0]
        elements[0] = elements.removeLast()
        siftDown(from: 0)
        return root
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

public struct AStar {
    let grid: Grid
    let heuristicScale: Double
    
    public init(grid: Grid, heuristicScale: Double = 1.0) {
        self.grid = grid
        self.heuristicScale = heuristicScale
    }
    
    // Manhattan distance
    func heuristic(_ a: Point, _ b: Point) -> Double {
        let dx = abs(a.x - b.x)
        let dy = abs(a.y - b.y)
        return Double(dx + dy) * heuristicScale
    }
    
    let neighborOffsets = [
        (dx: 0, dy: -1),
        (dx: 1, dy: 0),
        (dx: 0, dy: 1),
        (dx: -1, dy: 0)
    ]
    
    public func findPath(from start: Point, to goal: Point) -> [Point]? {
        guard grid.isInside(start), grid.isInside(goal) else { return nil }
        guard grid.isWalkable(at: start), grid.isWalkable(at: goal) else { return nil }
        if start == goal { return [start] }
        
        var openSet = MinHeap()
        openSet.push(PQElement(point: start, priority: heuristic(start, goal)))
        
        var cameFrom: [Point: Point] = [:]
        var gScore: [Point: Double] = [start: 0.0]
        
        while let currentElem = openSet.pop() {
            let current = currentElem.point
            if current == goal {
                return reconstructPath(cameFrom: cameFrom, current: current)
            }
            
            for offset in neighborOffsets {
                let neighbor = Point(x: current.x + offset.dx, y: current.y + offset.dy)
                guard grid.isInside(neighbor), grid.isWalkable(at: neighbor) else { continue }
                
                let tentativeG = (gScore[current] ?? Double.greatestFiniteMagnitude) + grid.cost(at: neighbor)
                if tentativeG < (gScore[neighbor] ?? Double.greatestFiniteMagnitude) {
                    cameFrom[neighbor] = current
                    gScore[neighbor] = tentativeG
                    let f = tentativeG + heuristic(neighbor, goal)
                    openSet.push(PQElement(point: neighbor, priority: f))
                }
            }
        }
        return nil // No path found
    }
    
    func reconstructPath(cameFrom: [Point: Point], current: Point) -> [Point] {
        var path: [Point] = [current]
        var cur = current
        while let prev = cameFrom[cur] {
            path.append(prev)
            cur = prev
        }
        return path.reversed()
    }
}
