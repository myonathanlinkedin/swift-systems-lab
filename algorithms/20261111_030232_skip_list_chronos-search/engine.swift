import Foundation

public final class SkipList<Key: Comparable, Value> {
    let maxLevel: Int
    let probability: Double
    var level: Int
    var header: SkipNode<Key, Value>
    let rng: DeterministicRandom

    public init(maxLevel: Int = 16, probability: Double = 0.5, seed: UInt64 = 0xCAFEBABE) {
        precondition(maxLevel > 0, "maxLevel must be positive")
        precondition(probability > 0 && probability < 1, "probability must be in (0,1)")
        self.maxLevel = maxLevel
        self.probability = probability
        self.level = 0
        // Header uses a dummy key/value; they are never accessed.
        self.header = SkipNode(key: unsafeBitCast(0 as Int, to: Key.self),
                               value: unsafeBitCast(0 as Int, to: Value.self),
                               level: maxLevel)
        self.rng = DeterministicRandom(seed: seed)
    }

    // Generate a random level for a new node
    func randomLevel() -> Int {
        var lvl = 1
        while rng.nextDouble() < probability && lvl < maxLevel {
            lvl += 1
        }
        return lvl
    }

    // Search for a key; returns associated value or nil
    public func search(_ key: Key) -> Value? {
        var current: SkipNode<Key, Value>? = header
        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current?.forward[i],
                  next.key < key {
                current = next
            }
        }
        // Move to possible target node
        if let candidate = current?.forward[0],
           candidate.key == key {
            return candidate.value
        }
        return nil
    }

    // Insert a key/value pair; updates value if key already exists
    public func insert(_ key: Key, _ value: Value) {
        var update = Array<SkipNode<Key, Value>?>(repeating: nil, count: maxLevel)
        var current: SkipNode<Key, Value>? = header

        // Find positions that need to be updated
        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current?.forward[i],
                  next.key < key {
                current = next
            }
            update[i] = current
        }

        // Check if key already exists
        if let candidate = current?.forward[0],
           candidate.key == key {
            candidate.value = value
            return
        }

        // Create new node with random level
        let nodeLevel = randomLevel()
        if nodeLevel > level {
            for i in level..<nodeLevel {
                update[i] = header
            }
            level = nodeLevel
        }

        let newNode = SkipNode(key: key, value: value, level: nodeLevel)

        // Splice new node into list
        for i in 0..<nodeLevel {
            let prev = update[i]!
            newNode.forward[i] = prev.forward[i]
            prev.forward[i] = newNode
        }
    }

    // Delete a key; returns true if deletion succeeded
    @discardableResult
    public func delete(_ key: Key) -> Bool {
        var update = Array<SkipNode<Key, Value>?>(repeating: nil, count: maxLevel)
        var current: SkipNode<Key, Value>? = header

        // Locate nodes that precede the target at each level
        for i in stride(from: level - 1, through: 0, by: -1) {
            while let next = current?.forward[i],
                  next.key < key {
                current = next
            }
            update[i] = current
        }

        // Target node
        guard let target = current?.forward[0],
              target.key == key else {
            return false
        }

        // Remove references
        for i in 0..<level {
            if update[i]?.forward[i] === target {
                update[i]?.forward[i] = target.forward[i]
            }
        }

        // Adjust current level if highest levels are empty
        while level > 1 && header.forward[level - 1] == nil {
            level -= 1
        }
        return true
    }

    // For testing: returns all keys in order
    public func allKeys() -> [Key] {
        var result: [Key] = []
        var node = header.forward[0]
        while let n = node {
            result.append(n.key)
            node = n.forward[0]
        }
        return result
    }
}
