import Foundation

public final class TreapNode<K: Comparable> {
    public var key: K
    public var priority: Int
    public var left: TreapNode?
    public var right: TreapNode?
    
    public init(key: K, priority: Int) {
        self.key = key
        self.priority = priority
        self.left = nil
        self.right = nil
    }
}

public struct Treap<K: Comparable> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    var root: TreapNode<K>?
    
    public init() {
        self.root = nil
    }
    
    // MARK: - Public API
    
    public mutating func insert(_ key: K, priority: Int? = nil) {
        guard !contains(key) else { return }
        let nodePriority = priority ?? Int.random(in: Int.min...Int.max)
        let newNode = TreapNode(key: key, priority: nodePriority)
        let (left, right) = Treap.split(root, key)
        let mergedLeft = Treap.merge(left, newNode)
        root = Treap.merge(mergedLeft, right)
    }
    
    @discardableResult
    public mutating func remove(_ key: K) -> Bool {
        guard contains(key) else { return false }
        root = Treap.remove(root, key)
        return true
    }
    
    public func contains(_ key: K) -> Bool {
        var cur = root
        while let node = cur {
            if key == node.key {
                return true
            } else if key < node.key {
                cur = node.left
            } else {
                cur = node.right
            }
        }
        return false
    }
    
    public func toArray() -> [K] {
        var result: [K] = []
        Treap.inOrder(root, &result)
        return result
    }
    
    // MARK: - Internal Helpers (static for recursion)
    
    private static func split(_ node: TreapNode<K>?, _ key: K) -> (TreapNode<K>?, TreapNode<K>?) {
        guard let current = node else { return (nil, nil) }
        if key <= current.key {
            let (l, r) = split(current.left, key)
            current.left = r
            return (l, current)
        } else {
            let (l, r) = split(current.right, key)
            current.right = l
            return (current, r)
        }
    }
    
    private static func merge(_ left: TreapNode<K>?, _ right: TreapNode<K>?) -> TreapNode<K>? {
        switch (left, right) {
        case (nil, _):
            return right
        case (_, nil):
            return left
        case let (l?, r?):
            if l.priority > r.priority {
                l.right = merge(l.right, r)
                return l
            } else {
                r.left = merge(l, r.left)
                return r
            }
        }
    }
    
    private static func remove(_ node: TreapNode<K>?, _ key: K) -> TreapNode<K>? {
        guard let current = node else { return nil }
        if key < current.key {
            current.left = remove(current.left, key)
            return current
        } else if key > current.key {
            current.right = remove(current.right, key)
            return current
        } else {
            // Node to delete found
            return merge(current.left, current.right)
        }
    }
    
    private static func inOrder(_ node: TreapNode<K>?, _ out: inout [K]) {
        guard let current = node else { return }
        inOrder(current.left, &out)
        out.append(current.key)
        inOrder(current.right, &out)
    }
}
