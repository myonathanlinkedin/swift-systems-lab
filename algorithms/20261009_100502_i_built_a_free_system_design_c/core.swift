import Foundation

// MARK: - Component

public struct Component: Hashable, Comparable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    // Comparable conformance
    public static func < (lhs: Component, rhs: Component) -> Bool {
        return lhs.name < rhs.name
    }
    
    public static func == (lhs: Component, rhs: Component) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: - SystemGraph

public struct SystemGraph {
    // adjacency list: component -> set of dependents (components that rely on it)
    public var adjacency: [Component: Set<Component>] = [:]
    
    public init() {}
    
    // Add a component if it does not exist
    public mutating func addComponent(_ component: Component) {
        if adjacency[component] == nil {
            adjacency[component] = Set<Component>()
        }
    }
    
    // Add a directed edge from `source` to `target`
    // Meaning: if `source` fails, `target` is affected.
    public mutating func addDependency(from source: Component, to target: Component) {
        addComponent(source)
        addComponent(target)
        adjacency[source, default: Set<Component>()].insert(target)
    }
    
    // MARK: Cycle Detection (DFS coloring)
    public func hasCycle() -> Bool {
        enum Color { case white, gray, black }
        var color: [Component: Color] = [:]
        for node in adjacency.keys {
            color[node] = .white
        }
        
        func dfs(_ v: Component) -> Bool {
            color[v] = .gray
            for neighbor in adjacency[v] ?? [] {
                let neighborColor = color[neighbor] ?? .white
                if neighborColor == .gray {
                    return true // back edge -> cycle
                }
                if neighborColor == .white && dfs(neighbor) {
                    return true
                }
            }
            color[v] = .black
            return false
        }
        
        for node in adjacency.keys {
            if color[node] == .white && dfs(node) {
                return true
            }
        }
        return false
    }
    
    // MARK: Topological Sort (Kahn's algorithm)
    // Returns nil if a cycle exists.
    public func topologicalOrder() -> [Component]? {
        // Compute indegrees
        var indegree: [Component: Int] = [:]
        for node in adjacency.keys {
            indegree[node] = 0
        }
        for (_, neighbors) in adjacency {
            for n in neighbors {
                indegree[n, default: 0] += 1
            }
        }
        
        // Queue of nodes with indegree 0
        var queue: [Component] = indegree.filter { $0.value == 0 }.map { $0.key }
        var order: [Component] = []
        
        var indegreeMutable = indegree
        var idx = 0
        while idx < queue.count {
            let v = queue[idx]
            idx += 1
            order.append(v)
            for neighbor in adjacency[v] ?? [] {
                indegreeMutable[neighbor, default: 0] -= 1
                if indegreeMutable[neighbor] == 0 {
                    queue.append(neighbor)
                }
            }
        }
        
        return order.count == adjacency.count ? order : nil
    }
    
    // MARK: Failure Propagation
    // Returns the set of components that become unavailable when `origin` fails.
    public func propagateFailure(from origin: Component) -> Set<Component> {
        guard adjacency.keys.contains(origin) else { return [] }
        var visited: Set<Component> = []
        var stack: [Component] = [origin]
        while let v = stack.popLast() {
            if visited.contains(v) { continue }
            visited.insert(v)
            for neighbor in adjacency[v] ?? [] {
                stack.append(neighbor)
            }
        }
        return visited
    }
}
