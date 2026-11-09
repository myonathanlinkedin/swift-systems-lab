import Foundation

public final class TreeNode<T> {
    public var value: T
    public var children: [TreeNode<T>] = []
    public weak var parent: TreeNode<T>?

    public init(value: T) {
        self.value = value
    }

    public func addChild(_ child: TreeNode<T>) {
        children.append(child)
        child.parent = self
    }

    public func removeChild(_ child: TreeNode<T>) {
        if let index = children.firstIndex(where: { $0 === child }) {
            children.remove(at: index)
            child.parent = nil
        }
    }

    public func subtreeSize() -> Int {
        var count = 1
        for child in children {
            count += child.subtreeSize()
        }
        return count
    }

    public func subtreeHeight() -> Int {
        if children.isEmpty { return 0 }
        var maxChildHeight = 0
        for child in children {
            let h = child.subtreeHeight()
            if h > maxChildHeight { maxChildHeight = h }
        }
        return maxChildHeight + 1
    }

    public func depth() -> Int {
        var d = 0
        var current = parent
        while let p = current {
            d += 1
            current = p.parent
        }
        return d
    }

    public func dfsValues() -> [T] {
        var result: [T] = [self.value]
        for child in children {
            result.append(contentsOf: child.dfsValues())
        }
        return result
    }

    public func bfsValues() -> [T] {
        var result: [T] = []
        var queue: [TreeNode<T>] = [self]
        var index = 0
        while index < queue.count {
            let node = queue[index]
            result.append(node.value)
            queue.append(contentsOf: node.children)
            index += 1
        }
        return result
    }

    public func averageBranchingFactor() -> Double {
        var internalNodeCount = 0
        var totalChildren = 0

        func traverse(_ node: TreeNode<T>) {
            if !node.children.isEmpty {
                internalNodeCount += 1
                totalChildren += node.children.count
                for child in node.children {
                    traverse(child)
                }
            }
        }

        traverse(self)

        if internalNodeCount == 0 { return 0.0 }
        return Double(totalChildren) / Double(internalNodeCount)
    }
}

public struct Tree<T> {
    public var root: TreeNode<T>?

    public init() {
        self.root = nil
    }

    public init(rootValue: T) {
        self.root = TreeNode(value: rootValue)
    }

    public func size() -> Int {
        guard let r = root else { return 0 }
        return r.subtreeSize()
    }

    public func height() -> Int {
        guard let r = root else { return -1 } // convention: empty tree height = -1
        return r.subtreeHeight()
    }

    public func bfs() -> [T] {
        guard let r = root else { return [] }
        return r.bfsValues()
    }

    public func dfs() -> [T] {
        guard let r = root else { return [] }
        return r.dfsValues()
    }

    public func averageBranchingFactor() -> Double {
        guard let r = root else { return 0.0 }
        return r.averageBranchingFactor()
    }
}
