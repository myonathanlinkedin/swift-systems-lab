import Foundation

struct Treap {
    var root: Node?

    // MARK: - Public API

    mutating func insert(_ key: Int) {
        let node = Node(key: key, priority: Int.random(in: Int.min...Int.max))
        let (left, right) = Treap.split(root, key: key)
        root = Treap.merge(Treap.merge(left, node), right)
    }

    mutating func delete(_ key: Int) {
        root = Treap.delete(root, key: key)
    }

    func search(_ key: Int) -> Bool {
        var node = root
        while let current = node {
            if key == current.key { return true }
            node = key < current.key ? current.left : current.right
        }
        return false
    }

    func inorder() -> [Int] {
        var result: [Int] = []
        Treap.inorderHelper(root, &result)
        return result
    }

    func size() -> Int {
        return Treap.countNodes(root)
    }

    func isHeapPropertySatisfied() -> Bool {
        return Treap.checkHeap(root)
    }

    // MARK: - Internal Helpers

    static func split(_ root: Node?, key: Int) -> (Node?, Node?) {
        guard let root = root else { return (nil, nil) }
        if key < root.key {
            let (left, right) = split(root.left, key: key)
            root.left = right
            return (left, root)
        } else {
            let (left, right) = split(root.right, key: key)
            root.right = left
            return (root, right)
        }
    }

    static func merge(_ left: Node?, _ right: Node?) -> Node? {
        guard let left = left else { return right }
        guard let right = right else { return left }
        if left.priority < right.priority {
            left.right = merge(left.right, right)
            return left
        } else {
            right.left = merge(left, right.left)
            return right
        }
    }

    static func delete(_ root: Node?, key: Int) -> Node? {
        guard let root = root else { return nil }
        if key < root.key {
            root.left = delete(root.left, key: key)
            return root
        } else if key > root.key {
            root.right = delete(root.right, key: key)
            return root
        } else {
            return merge(root.left, root.right)
        }
    }

    static func inorderHelper(_ node: Node?, _ result: inout [Int]) {
        guard let node = node else { return }
        inorderHelper(node.left, &result)
        result.append(node.key)
        inorderHelper(node.right, &result)
    }

    static func countNodes(_ node: Node?) -> Int {
        guard let node = node else { return 0 }
        return 1 + countNodes(node.left) + countNodes(node.right)
    }

    static func checkHeap(_ node: Node?) -> Bool {
        guard let node = node else { return true }
        if let left = node.left, node.priority > left.priority { return false }
        if let right = node.right, node.priority > right.priority { return false }
        return checkHeap(node.left) && checkHeap(node.right)
    }
}
