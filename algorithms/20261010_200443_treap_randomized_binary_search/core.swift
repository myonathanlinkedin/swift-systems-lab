import Foundation

public final class TreapNode<Key: Comparable, Value> {
    public var key: Key
    public var value: Value
    public var priority: UInt64
    public var left: TreapNode?
    public var right: TreapNode?
    
    public init(key: Key, value: Value, priority: UInt64) {
        self.key = key
        self.value = value
        self.priority = priority
        self.left = nil
        self.right = nil
    }
}

public struct Treap<Key: Comparable, Value> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    public var root: TreapNode<Key, Value>?
    var rngSeed: UInt64 = 0x9e3779b97f4a7c15 // arbitrary non‑zero seed
    
    public init() {}
    
    // MARK: - Random priority generator (LCG)
    private mutating func nextPriority() -> UInt64 {
        // Constants from Numerical Recipes
        let a: UInt64 = 6364136223846793005
        let c: UInt64 = 1
        rngSeed = a &* rngSeed &+ c
        return rngSeed
    }
    
    // MARK: - Public API
    
    public mutating func insert(key: Key, value: Value) {
        let priority = nextPriority()
        let newNode = TreapNode(key: key, value: value, priority: priority)
        root = insert(node: root, newNode: newNode)
    }
    
    public mutating func delete(key: Key) {
        root = delete(node: root, key: key)
    }
    
    public func find(key: Key) -> Value? {
        var cur = root
        while let node = cur {
            if key == node.key {
                return node.value
            } else if key < node.key {
                cur = node.left
            } else {
                cur = node.right
            }
        }
        return nil
    }
    
    public func inorderKeys() -> [Key] {
        var result: [Key] = []
        inorder(node: root, acc: &result)
        return result
    }
    
    public func checkHeapProperty() -> Bool {
        return heapValid(node: root)
    }
    
    // MARK: - Internal helpers
    
    func heapValid(node: TreapNode<Key, Value>?) -> Bool {
        guard let n = node else { return true }
        if let l = n.left {
            if l.priority < n.priority { return false }
            if !heapValid(node: l) { return false }
        }
        if let r = n.right {
            if r.priority < n.priority { return false }
            if !heapValid(node: r) { return false }
        }
        return true
    }
    
    func inorder(node: TreapNode<Key, Value>?, acc: inout [Key]) {
        guard let n = node else { return }
        inorder(node: n.left, acc: &acc)
        acc.append(n.key)
        inorder(node: n.right, acc: &acc)
    }
    
    // Insert using split/merge
    private mutating func insert(node: TreapNode<Key, Value>?, newNode: TreapNode<Key, Value>) -> TreapNode<Key, Value>? {
        guard let cur = node else { return newNode }
        if newNode.priority > cur.priority {
            let (l, r) = split(root: cur, key: newNode.key)
            newNode.left = l
            newNode.right = r
            return newNode
        } else if newNode.key < cur.key {
            cur.left = insert(node: cur.left, newNode: newNode)
            return cur
        } else if newNode.key > cur.key {
            cur.right = insert(node: cur.right, newNode: newNode)
            return cur
        } else {
            // Replace existing value
            cur.value = newNode.value
            return cur
        }
    }
    
    // Delete recursively
    private mutating func delete(node: TreapNode<Key, Value>?, key: Key) -> TreapNode<Key, Value>? {
        guard let cur = node else { return nil }
        if key < cur.key {
            cur.left = delete(node: cur.left, key: key)
            return cur
        } else if key > cur.key {
            cur.right = delete(node: cur.right, key: key)
            return cur
        } else {
            // Node to delete
            return merge(left: cur.left, right: cur.right)
        }
    }
    
    // Split returns ( < key , >= key )
    func split(root: TreapNode<Key, Value>?, key: Key) -> (TreapNode<Key, Value>?, TreapNode<Key, Value>?) {
        guard let cur = root else { return (nil, nil) }
        if key <= cur.key {
            let (l, r) = split(root: cur.left, key: key)
            cur.left = r
            return (l, cur)
        } else {
            let (l, r) = split(root: cur.right, key: key)
            cur.right = l
            return (cur, r)
        }
    }
    
    // Merge two treaps where all keys in left < keys in right
    func merge(left: TreapNode<Key, Value>?, right: TreapNode<Key, Value>?) -> TreapNode<Key, Value>? {
        guard let l = left else { return right }
        guard let r = right else { return left }
        if l.priority > r.priority {
            l.right = merge(left: l.right, right: r)
            return l
        } else {
            r.left = merge(left: l, right: r.left)
            return r
        }
    }
}
