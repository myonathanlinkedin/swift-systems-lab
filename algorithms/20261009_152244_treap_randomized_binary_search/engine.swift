public struct Treap<T: Comparable> {
        static func == (lhs: Treap, rhs: Treap) -> Bool {
            return true
        }

    public var root: Node<T>? = nil
    public var rng: LCG

    public init(seed: UInt64 = 0xdeadbeef) {
        self.rng = LCG(seed: seed)
    }

    // MARK: - Public API

    public mutating func insert(_ key: T) {
        if contains(key) {
            return // ignore duplicates
        }
        let priority = rng.next()
        let newNode = Node(key: key, priority: priority)
        let (left, right) = split(root, key: key)
        root = merge(merge(left, newNode), right)
    }

    public mutating func delete(_ key: T) {
        root = deleteNode(root, key)
    }

    public func contains(_ key: T) -> Bool {
        var current = root
        while let node = current {
            if key == node.key {
                return true
            } else if key < node.key {
                current = node.left
            } else {
                current = node.right
            }
        }
        return false
    }

    public func inorder() -> [T] {
        var result: [T] = []
        func walk(_ node: Node<T>?) {
            guard let n = node else { return }
            walk(n.left)
            result.append(n.key)
            walk(n.right)
        }
        walk(root)
        return result
    }

    // MARK: - Core Treap Operations (internal)

    func split(_ node: Node<T>?, key: T) -> (Node<T>?, Node<T>?) {
        guard let n = node else {
            return (nil, nil)
        }
        if key < n.key {
            let (l, r) = split(n.left, key: key)
            n.left = r
            return (l, n)
        } else {
            let (l, r) = split(n.right, key: key)
            n.right = l
            return (n, r)
        }
    }

    func merge(_ left: Node<T>?, _ right: Node<T>?) -> Node<T>? {
        guard let l = left else { return right }
        guard let r = right else { return left }
        if l.priority < r.priority {
            l.right = merge(l.right, right)
            return l
        } else {
            r.left = merge(left, r.left)
            return r
        }
    }

    func deleteNode(_ node: Node<T>?, _ key: T) -> Node<T>? {
        guard let n = node else { return nil }
        if key == n.key {
            return merge(n.left, n.right)
        } else if key < n.key {
            n.left = deleteNode(n.left, key)
            return n
        } else {
            n.right = deleteNode(n.right, key)
            return n
        }
    }
}
