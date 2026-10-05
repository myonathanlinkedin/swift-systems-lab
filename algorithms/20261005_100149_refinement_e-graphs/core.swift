import Foundation

/// A unique identifier for a node in the E-Graph.
public struct ENodeID: Hashable, Comparable, CustomStringConvertible {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static func < (lhs: ENodeID, rhs: ENodeID) -> Bool { lhs.rawValue < rhs.rawValue }
    public var description: String { "e\(rawValue)" }
}

/// Represents a single node in the E-Graph.
public struct ENode: Hashable {
    public let id: ENodeID
    public let op: String
    public let children: [ENodeID]
    
    public init(id: ENodeID, op: String, children: [ENodeID]) {
        self.id = id
        self.op = op
        self.children = children
    }
    
    public var isLeaf: Bool { children.isEmpty }
}

/// The core data structure for the E-Graph.
public final class EGraph {
    private var nodes: [ENodeID: ENode] = [:]
    private var nextID: Int = 0
    private var equivalenceClasses: [ENodeID: Set<ENodeID>] = [:]
    private var classToNodes: [ENodeID: Set<ENodeID>] = [:]
    
    public init() {}
    
    /// Adds a new node to the E-Graph and returns its ID.
    @discardableResult
    public func addNode(op: String, children: [ENodeID]) -> ENodeID {
        let id = ENodeID(rawValue: nextID)
        nextID += 1
        let node = ENode(id: id, op: op, children: children)
        nodes[id] = node
        
        // Initialize equivalence class
        equivalenceClasses[id] = [id]
        classToNodes[id] = [id]
        
        return id
    }
    
    /// Unifies two nodes, merging their equivalence classes.
    public func unify(_ a: ENodeID, _ b: ENodeID) {
        guard let classA = equivalenceClasses[a], let classB = equivalenceClasses[b] else { return }
        
        // Find the root of each class
        let rootA = classA.first!
        let rootB = classB.first!
        
        guard rootA != rootB else { return }
        
        // Merge classB into classA
        let merged = classA.union(classB)
        
        // Update all nodes in the merged class
        for nodeID in merged {
            equivalenceClasses[nodeID] = merged
        }
        
        // Update classToNodes
        classToNodes[rootA] = merged
        classToNodes[rootB] = nil
        
        // Update references in other nodes
        for (nodeID, node) in nodes {
            if node.children.contains(rootB) {
                let newChildren = node.children.map { $0 == rootB ? rootA : $0 }
                nodes[nodeID] = ENode(id: nodeID, op: node.op, children: newChildren)
            }
        }
    }
    
    /// Returns the canonical representative of the equivalence class containing the given node.
    public func canonical(_ nodeID: ENodeID) -> ENodeID? {
        return equivalenceClasses[nodeID]?.first
    }
    
    /// Returns all nodes in the equivalence class containing the given node.
    public func equivalenceClass(of nodeID: ENodeID) -> Set<ENodeID> {
        return equivalenceClasses[nodeID] ?? []
    }
    
    /// Returns the node with the given ID.
    public func node(_ id: ENodeID) -> ENode? {
        return nodes[id]
    }
    
    /// Returns all nodes in the E-Graph.
    public var allNodes: [ENode] {
        return nodes.values.sorted { $0.id < $1.id }
    }
    
    /// Returns the number of distinct equivalence classes.
    public var classCount: Int {
        return classToNodes.count
    }
}

/// A refinement rule that can be applied to the E-Graph.
public struct RefinementRule {
    public let pattern: (op: String, childCount: Int)
    public let action: (ENode, EGraph) -> [ENodeID]?
    
    public init(op: String, childCount: Int, action: @escaping (ENode, EGraph) -> [ENodeID]?) {
        self.pattern = (op: op, childCount: childCount)
        self.action = action
    }
}

/// The Refinement E-Graph engine that applies refinement rules.
public final class RefinementEngine {
    private let graph: EGraph
    private let rules: [RefinementRule]
    private var worklist: [ENodeID] = []
    private var processed: Set<ENodeID> = []
    
    public init(graph: EGraph, rules: [RefinementRule]) {
        self.graph = graph
        self.rules = rules
    }
    
    /// Adds a node to the worklist for processing.
    public func enqueue(_ nodeID: ENodeID) {
        if !processed.contains(nodeID) {
            worklist.append(nodeID)
        }
    }
    
    /// Processes the worklist, applying refinement rules until fixpoint.
    public func run() -> Bool {
        var changed = false
        while !worklist.isEmpty {
            let nodeID = worklist.removeFirst()
            guard !processed.contains(nodeID) else { continue }
            processed.insert(nodeID)
            
            guard let node = graph.node(nodeID) else { continue }
            
            for rule in rules {
                if node.op == rule.pattern.op && node.children.count == rule.pattern.childCount {
                    if let newNodes = rule.action(node, graph) {
                        for newNode in newNodes {
                            graph.unify(nodeID, newNode)
                            enqueue(newNode)
                        }
                        changed = true
                    }
                }
            }
        }
        return changed
    }
    
    /// Returns the underlying E-Graph.
    public var eGraph: EGraph {
        return graph
    }
}
