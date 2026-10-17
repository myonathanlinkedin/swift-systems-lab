import Foundation

func runTests() {
    // Helper to create a grid with optional obstacle list
    func makeGrid(width: Int, height: Int, obstacles: [Point] = []) -> Grid {
        var g = Grid(width: width, height: height)
        for o in obstacles {
            g.setCost(at: o, cost: Grid.infiniteCost)
        }
        return g
    }
    
    // Test 1: Simple clear grid
    do {
        var grid = makeGrid(width: 5, height: 5)
        let astar = AStar(grid: grid)
        let start = Point(x: 0, y: 0)
        let goal = Point(x: 4, y: 4)
        let path = astar.findPath(from: start, to: goal)
        assert(path != nil, "Path should exist")
        assert(path!.first == start && path!.last == goal, "Path endpoints incorrect")
        // Minimum Manhattan steps = 8 moves + start = 9 points
        assert(path!.count == 9, "Unexpected path length")
    }
    
    // Test 2: Static obstacles forcing detour
    do {
        var grid = makeGrid(width: 5, height: 5, obstacles: [
            Point(x: 2, y: 0), Point(x: 2, y: 1), Point(x: 2, y: 2), Point(x: 2, y: 3)
        ])
        let astar = AStar(grid: grid)
        let start = Point(x: 0, y: 0)
        let goal = Point(x: 4, y: 4)
        let path = astar.findPath(from: start, to: goal)
        assert(path != nil, "Detour path should exist")
        // Path must go around column x=2, length should be 11 (right side)
        assert(path!.count == 11, "Detour path length mismatch")
        // Ensure no obstacle point is in path
        for p in path! {
            assert(p.x != 2 || p.y > 3, "Path includes blocked cell")
        }
    }
    
    // Test 3: Dynamic obstacle cost change
    do {
        var grid = makeGrid(width: 5, height: 5)
        // Initially cheap path straight line
        let start = Point(x: 0, y: 0)
        let goal = Point(x: 4, y: 0)
        var astar = AStar(grid: grid)
        var path1 = astar.findPath(from: start, to: goal)
        assert(path1 != nil && path1!.count == 5, "Initial straight path expected")
        // Increase cost of middle cell dynamically
        grid.setCost(at: Point(x: 2, y: 0), cost: 100.0)
        astar = AStar(grid: grid)
        let path2 = astar.findPath(from: start, to: goal)
        assert(path2 != nil, "Alternative path should exist after cost increase")
        // New path should avoid (2,0)
        for p in path2! {
            assert(p != Point(x: 2, y: 0), "Path still uses high‑cost cell")
        }
        // Length should be longer than 5
        assert(path2!.count > 5, "Alternative path should be longer")
    }
    
    // Test 4: Unreachable goal
    do {
        var grid = makeGrid(width: 3, height: 3, obstacles: [
            Point(x: 1, y: 0), Point(x: 1, y: 1), Point(x: 1, y: 2)
        ])
        let astar = AStar(grid: grid)
        let start = Point(x: 0, y: 1)
        let goal = Point(x: 2, y: 1)
        let path = astar.findPath(from: start, to: goal)
        assert(path == nil, "Path should be nil when goal is blocked off")
    }
    
    print("All A* tests passed.")
}

runTests()
