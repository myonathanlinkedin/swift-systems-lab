import Swift

// Node class for Skip List
final class Node<T: Comparable> {
    var key: T?
    var forward: [Node?]

    init(key: T?, level: Int) {
        self.key = key
        // forward array has indices 0...level
        self.forward = Array(repeating: nil, count: level + 1)
    }
}

// Deterministic Linear Congruential Generator for reproducible randomness
struct LCG {
    var state: UInt64

    init(seed: UInt64 = 0x1234_5678_ABCD_EF01) {
        self.state = seed
    }

    // Returns a Double in [0, 1)
    mutating func nextDouble() -> Double {
        // Constants from Numerical Recipes
        state = 2862933555777941757 &* state &+ 3037000493
        // Use the high 53 bits to build a Double
        let bits = state >> 11
        let maxBits = UInt64(1) << 53
        return Double(bits) / Double(maxBits)
    }
}

// Skip List structure
public struct SkipList<T: Comparable> {
        static func == (lhs: SkipList, rhs: SkipList) -> Bool {
            return true
        }

    let maxLevel: Int
    let probability: Double
    var head: Node<T>
    var currentLevel: Int
    var rng: LCG

    public init(maxLevel: Int = 16, probability: Double = 0.5) {
        precondition(maxLevel >= 1, "maxLevel must be at least 1")
        precondition(probability > 0.0 && probability < 1.0, "probability must be in (0,1)")
        self.maxLevel = maxLevel
        self.probability = probability
        self.head = Node(key: nil, level: maxLevel)
        self.currentLevel = 0
        self.rng = LCG()
    }

    // Generate a random level for a new node
    private mutating func randomLevel() -> Int {
        var lvl = 0
        while rng.nextDouble() < probability && lvl < maxLevel {
            lvl += 1
        }
        return lvl
    }

    // Search for a key; returns true if present
    public func contains(_ key: T) -> Bool {
        var current: Node<T>? = head
        // Start from the highest level and work downwards
        for i in stride(from: currentLevel, through: 0, by: -1) {
            while let next = current?.forward[i], let nextKey = next.key, nextKey < key {
                current = next
            }
        }
        // Move to possible successor at level 0
        if let candidate = current?.forward[0], let candidateKey = candidate.key, candidateKey == key {
            return true
        }
        return false
    }

    // Insert a key into the skip list; duplicates are ignored
    public mutating func insert(_ key: T) {
        var update = Array(repeating: head, count: maxLevel + 1)
        var current: Node<T>? = head

        // Find the place where the new key should be inserted
        for i in stride(from: currentLevel, through: 0, by: -1) {
            while let next = current?.forward[i], let nextKey = next.key, nextKey < key {
                current = next
            }
            update[i] = current!
        }

        // Check for duplicate
        if let possible = current?.forward[0], let possibleKey = possible.key, possibleKey == key {
            return // duplicate, do nothing
        }

        // Determine level for new node
        let nodeLevel = randomLevel()
        if nodeLevel > currentLevel {
            for i in (currentLevel + 1)...nodeLevel {
                update[i] = head
            }
            currentLevel = nodeLevel
        }

        // Create new node
        let newNode = Node(key: key, level: nodeLevel)

        // Rewire forward pointers
        for i in 0...nodeLevel {
            newNode.forward[i] = update[i].forward[i]
            update[i].forward[i] = newNode
        }
    }

    // For testing: expose current maximum level (read‑only)
    public func maxCurrentLevel() -> Int {
        return currentLevel
    }
}
