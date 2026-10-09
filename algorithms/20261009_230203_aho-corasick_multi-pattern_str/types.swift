import Foundation

public final class ACNode {
    public var children: [Character: ACNode] = [:]
    public weak var fail: ACNode?
    public var output: [Int] = []          // indices of patterns ending at this node
    
    public init() {}
}

// The automaton struct encapsulates the trie, failure links and pattern data.
public struct AhoCorasick {
    // Stored patterns; empty strings are ignored during construction.
    public var patterns: [String] = []
    public var patternLengths: [Int] = []
    public var root: ACNode = ACNode()
    
    // Build the automaton from a list of patterns.
    public init(_ patterns: [String]) {
        // Filter out empty patterns – they are not meaningful for searching.
        let filtered = patterns.enumerated().compactMap { (idx, pat) -> (Int, String)? in
            return pat.isEmpty ? nil : (idx, pat)
        }
        // Preserve original order for output consistency.
        self.patterns = filtered.map { $0.1 }
        self.patternLengths = self.patterns.map { $0.count }
        self.buildTrie(with: self.patterns)
        self.buildFailureLinks()
    }
    
    // MARK: - Trie Construction
    
    private mutating func buildTrie(with patterns: [String]) {
        for (index, pattern) in patterns.enumerated() {
            var node = root
            for ch in pattern {
                if let child = node.children[ch] {
                    node = child
                } else {
                    let newNode = ACNode()
                    node.children[ch] = newNode
                    node = newNode
                }
            }
            node.output.append(index)   // pattern ends at this node
        }
    }
    
    // MARK: - Failure Links Construction (BFS)
    
    private mutating func buildFailureLinks() {
        var queue: [ACNode] = []
        // Initialize depth‑1 nodes: fail points to root.
        for child in root.children.values {
            child.fail = root
            queue.append(child)
        }
        // BFS
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            for (ch, child) in current.children {
                // Follow failure links from current's fail until we find a matching transition or reach root.
                var fallback = current.fail
                while fallback != nil && fallback?.children[ch] == nil {
                    fallback = fallback?.fail
                }
                if let fallbackNode = fallback, let next = fallbackNode.children[ch] {
                    child.fail = next
                } else {
                    child.fail = root
                }
                // Merge output lists.
                if let failNode = child.fail {
                    child.output.append(contentsOf: failNode.output)
                }
                queue.append(child)
            }
        }
    }
    
    // MARK: - Search
    
    // Returns a list of matches: (matched pattern, start index, end index exclusive)
    public func search(_ text: String) -> [(pattern: String, start: Int, end: Int)] {
        var results: [(String, Int, Int)] = []
        let chars = Array(text)               // O(N) conversion, enables integer indexing.
        var node: ACNode = root
        
        for (i, ch) in chars.enumerated() {
            // Follow transitions; if missing, follow failure links.
            while node !== root && node.children[ch] == nil {
                if let failNode = node.fail {
                    node = failNode
                } else {
                    node = root
                    break
                }
            }
            if let next = node.children[ch] {
                node = next
            } else {
                node = root
            }
            // Emit all patterns that end at this position.
            for patternIdx in node.output {
                let patLen = patternLengths[patternIdx]
                let startIdx = i - patLen + 1
                if startIdx >= 0 {
                    let matchedPattern = patterns[patternIdx]
                    results.append((matchedPattern, startIdx, i + 1))
                }
            }
        }
        return results
    }
}
