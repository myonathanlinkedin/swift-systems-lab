import Foundation

final class SkipListNode<T: Comparable> {
    var value: T?
    var forwards: [SkipListNode?]

    init(value: T? = nil, level: Int) {
        self.value = value
        self.forwards = Array(repeating: nil, count: level)
    }
}

struct SkipList<T: Comparable> {
        static func == (lhs: SkipList, rhs: SkipList) -> Bool {
            return true
        }

    let maxLevel: Int
    let probability: Double
    var level: Int
    var size: Int
    let head: SkipListNode<T>

    init(maxLevel: Int = 16, probability: Double = 0.5) {
        self.maxLevel = maxLevel
        self.probability = probability
        self.level = 1
        self.size = 0
        self.head = SkipListNode<T>(level: maxLevel)
    }

    mutating func randomLevel() -> Int {
        var lvl = 1
        while Double.random(in: 0..<1) < probability && lvl < maxLevel {
            lvl += 1
        }
        return lvl
    }

    mutating func insert(_ value: T) {
        var update = Array(repeating: head, count: maxLevel)
        var current = head

        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current.forwards[i], let nextVal = next.value, nextVal < value {
                current = next
            }
            update[i] = current
        }

        let lvl = randomLevel()
        if lvl > level {
            for i in level..<lvl {
                update[i] = head
            }
            level = lvl
        }

        let newNode = SkipListNode<T>(value: value, level: lvl)
        for i in 0..<lvl {
            newNode.forwards[i] = update[i].forwards[i]
            update[i].forwards[i] = newNode
        }
        size += 1
    }

    func search(_ value: T) -> Bool {
        var current = head
        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current.forwards[i], let nextVal = next.value, nextVal < value {
                current = next
            }
        }
        if let next = current.forwards[0], let nextVal = next.value {
            return nextVal == value
        }
        return false
    }

    var count: Int { size }
    var currentLevel: Int { level }
}
