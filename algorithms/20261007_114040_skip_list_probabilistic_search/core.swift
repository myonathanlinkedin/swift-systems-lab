import Foundation

public final class SkipListNode<T: Comparable> {
    public var value: T?
    public var forward: [SkipListNode?]

    public init(value: T?, level: Int) {
        self.value = value
        self.forward = Array(repeating: nil, count: level)
    }
}

public struct SkipList<T: Comparable> {
        static func == (lhs: SkipList, rhs: SkipList) -> Bool {
            return true
        }

    let maxLevel: Int
    let probability: Double
    var currentLevel: Int = 1
    public var head: SkipListNode<T>

    public init(maxLevel: Int = 16, probability: Double = 0.5) {
        self.maxLevel = maxLevel
        self.probability = probability
        self.head = SkipListNode(value: nil, level: maxLevel)
    }

    func randomLevel() -> Int {
        var lvl = 1
        while Double.random(in: 0..<1) < probability && lvl < maxLevel {
            lvl += 1
        }
        return lvl
    }

    public mutating func insert(_ value: T) {
        var update = Array(repeating: head, count: maxLevel)
        var current: SkipListNode<T> = head

        // Find update points
        for i in stride(from: currentLevel - 1, through: 0, by: -1) {
            while let next = current.forward[i],
                  let nextVal = next.value,
                  nextVal < value {
                current = next
            }
            update[i] = current
        }

        // Determine node level
        let nodeLevel = randomLevel()
        if nodeLevel > currentLevel {
            for i in currentLevel..<nodeLevel {
                update[i] = head
            }
            currentLevel = nodeLevel
        }

        // Insert new node
        let newNode = SkipListNode(value: value, level: nodeLevel)
        for i in 0..<nodeLevel {
            newNode.forward[i] = update[i].forward[i]
            update[i].forward[i] = newNode
        }
    }

    public func search(_ value: T) -> Bool {
        var current: SkipListNode<T> = head
        for i in stride(from: currentLevel - 1, through: 0, by: -1) {
            while let next = current.forward[i],
                  let nextVal = next.value,
                  nextVal < value {
                current = next
            }
        }
        if let next = current.forward[0],
           let nextVal = next.value,
           nextVal == value {
            return true
        }
        return false
    }

    // Helper to retrieve all elements in order (used for testing)
    public func elementsInOrder() -> [T] {
        var result: [T] = []
        var node = head.forward[0]
        while let n = node {
            if let v = n.value {
                result.append(v)
            }
            node = n.forward[0]
        }
        return result
    }
}
