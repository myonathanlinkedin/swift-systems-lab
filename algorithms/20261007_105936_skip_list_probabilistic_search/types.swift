import Foundation

// Node used in the SkipList. It holds a key, a value, and forward pointers.
class Node {
    var key: Int
    var value: Int
    var forward: [Node?]

    init(key: Int, value: Int, level: Int) {
        self.key = key
        self.value = value
        self.forward = [Node?](repeating: nil, count: level)
    }
}

// SkipList data structure with probabilistic search and insertion.
struct SkipList {
    var head: Node
    var level: Int
    let maxLevel: Int
    let probability: Double

    init(maxLevel: Int = 16, probability: Double = 0.5) {
        self.maxLevel = maxLevel
        self.probability = probability
        self.head = Node(key: Int.min, value: 0, level: maxLevel)
        self.level = 1
    }

    // Generate a random level for a new node.
    mutating func randomLevel() -> Int {
        var lvl = 1
        while Double.random(in: 0..<1) < probability && lvl < maxLevel {
            lvl += 1
        }
        return lvl
    }

    // Insert or update a key-value pair.
    mutating func insert(key: Int, value: Int) {
        var update = [Node?](repeating: nil, count: maxLevel)
        var current = head

        // Find the place where the new node will be inserted.
        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current.forward[i], next.key < key {
                current = next
            }
            update[i] = current
        }

        // Check if key already exists.
        if let next = current.forward[0], next.key == key {
            next.value = value
            return
        }

        // Create new node with random level.
        let newLevel = randomLevel()
        if newLevel > level {
            for i in level..<newLevel {
                update[i] = head
            }
            level = newLevel
        }

        let newNode = Node(key: key, value: value, level: newLevel)

        // Rewire forward pointers.
        for i in 0..<newLevel {
            newNode.forward[i] = update[i]?.forward[i]
            update[i]?.forward[i] = newNode
        }
    }

    // Search for a key and return its value if found.
    func search(key: Int) -> Int? {
        var current = head
        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current.forward[i], next.key < key {
                current = next
            }
        }
        if let next = current.forward[0], next.key == key {
            return next.value
        }
        return nil
    }

    // Retrieve all keys in ascending order (for testing).
    func allKeys() -> [Int] {
        var keys: [Int] = []
        var current = head.forward[0]
        while let node = current {
            keys.append(node.key)
            current = node.forward[0]
        }
        return keys
    }
}
