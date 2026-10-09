import Foundation

public struct AhoCorasick {
    // Node of the trie/automaton
    public struct Node {
        public var children: [Character: Int] = [:]   // edges to child node indices
        public var fail: Int = 0                     // failure link
        public var output: [Int] = []                // pattern indices ending at this node
    }
    
    public private(set) var patterns: [String] = []   // stored patterns
    public private(set) var nodes: [Node] = [Node()] // node 0 is the root
    
    // MARK: - Initialization
    
    public init(patterns: [String]) {
        // Filter out empty patterns (they would match everywhere)
        self.patterns = patterns.filter { !$0.isEmpty }
        buildTrie()
        buildFailureLinks()
    }
    
    // MARK: - Trie Construction
    
    private mutating func buildTrie() {
        for (index, pattern) in patterns.enumerated() {
            var current = 0 // start at root
            for ch in pattern {
                if let next = nodes[current].children[ch] {
                    current = next
                } else {
                    let newNode = Node()
                    nodes.append(newNode)
                    let newIndex = nodes.count - 1
                    nodes[current].children[ch] = newIndex
                    current = newIndex
                }
            }
            // pattern ends at current node
            nodes[current].output.append(index)
        }
    }
    
    // MARK: - Failure Links Construction
    
    private mutating func buildFailureLinks() {
        var queue: [Int] = []
        // Initialize depth‑1 nodes: fail = root (0)
        for (_, childIdx) in nodes[0].children {
            nodes[childIdx].fail = 0
            queue.append(childIdx)
        }
        // BFS
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            for (ch, childIdx) in nodes[current].children {
                // Compute failure link for child
                var failNode = nodes[current].fail
                while failNode != 0 && nodes[failNode].children[ch] == nil {
                    failNode = nodes[failNode].fail
                }
                if let fallback = nodes[failNode].children[ch] {
                    nodes[childIdx].fail = fallback
                } else {
                    nodes[childIdx].fail = 0
                }
                // Merge output
                let failOutput = nodes[nodes[childIdx].fail].output
                if !failOutput.isEmpty {
                    nodes[childIdx].output.append(contentsOf: failOutput)
                }
                queue.append(childIdx)
            }
        }
    }
    
    // MARK: - Search
    
    /// Returns an array of matches. Each match is a tuple `(pattern: String, position: Int)`
    /// where `position` is the start index of the match in `text`.
    public func search(in text: String) -> [(pattern: String, position: Int)] {
        var results: [(String, Int)] = []
        var state = 0 // start at root
        var index = 0
        for ch in text {
            // Follow failure links if there is no edge for ch
            while state != 0 && nodes[state].children[ch] == nil {
                state = nodes[state].fail
            }
            if let next = nodes[state].children[ch] {
                state = next
            } else {
                state = 0
            }
            // Emit all patterns that end here
            for patternIdx in nodes[state].output {
                let pat = patterns[patternIdx]
                let startPos = index - pat.count + 1
                results.append((pat, startPos))
            }
            index += 1
        }
        return results
    }
}
