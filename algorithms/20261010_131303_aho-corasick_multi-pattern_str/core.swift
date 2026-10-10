import Foundation

public struct AhoCorasick {
    // Publicly accessible patterns for result interpretation
    public let patterns: [String]
    
    // Internal node representation
    struct Node {
        var children: [Character: Int] = [:]   // Edge label -> child node index
        var fail: Int = 0                      // Failure link
        var output: [Int] = []                 // Indices of patterns ending at this node
    }
    
    // Trie stored as a flat array for cache friendliness
    var nodes: [Node] = [Node()] // root node at index 0
    
    // MARK: - Initializer
    
    public init(patterns: [String]) {
        self.patterns = patterns
        buildTrie()
        buildFailureLinks()
    }
    
    // MARK: - Trie Construction
    
    private mutating func buildTrie() {
        for (index, pattern) in patterns.enumerated() {
            guard !pattern.isEmpty else { continue } // ignore empty patterns
            var current = 0 // start at root
            for ch in pattern {
                if let child = nodes[current].children[ch] {
                    current = child
                } else {
                    let newNode = Node()
                    nodes.append(newNode)
                    let newIndex = nodes.count - 1
                    nodes[current].children[ch] = newIndex
                    current = newIndex
                }
            }
            nodes[current].output.append(index)
        }
    }
    
    // MARK: - Failure Link Construction (BFS)
    
    private mutating func buildFailureLinks() {
        var queue: [Int] = []
        // Initialize depth‑1 nodes
        for (ch, childIdx) in nodes[0].children {
            nodes[childIdx].fail = 0
            queue.append(childIdx)
        }
        // BFS
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            for (ch, childIdx) in nodes[current].children {
                var failState = nodes[current].fail
                while failState != 0 && nodes[failState].children[ch] == nil {
                    failState = nodes[failState].fail
                }
                if let next = nodes[failState].children[ch] {
                    nodes[childIdx].fail = next
                } else {
                    nodes[childIdx].fail = 0
                }
                // Merge output of failure state into child
                nodes[childIdx].output.append(contentsOf: nodes[nodes[childIdx].fail].output)
                queue.append(childIdx)
            }
        }
    }
    
    // MARK: - Search
    
    /// Returns an array of matches. Each match is a tuple `(patternIndex, startPosition)`.
    /// `startPosition` is the index in `text` where the pattern begins (0‑based).
    public func search(in text: String) -> [(patternIndex: Int, start: Int)] {
        var results: [(Int, Int)] = []
        var state = 0
        var position = 0 // current index in text
        
        for ch in text {
            // Follow failure links for missing transitions
            while state != 0 && nodes[state].children[ch] == nil {
                state = nodes[state].fail
            }
            // Take the transition if it exists
            if let next = nodes[state].children[ch] {
                state = next
            } else {
                state = 0
            }
            // Emit all patterns that end at this state
            for patternIdx in nodes[state].output {
                let patternLength = patterns[patternIdx].count
                let startPos = position - patternLength + 1
                results.append((patternIdx, startPos))
            }
            position += 1
        }
        return results
    }
}
