import Foundation

public final class ACNode {
    public var children: [Character: ACNode] = [:]
    public var failure: ACNode? = nil
    public var output: [Int] = []          // indices of patterns ending at this node
    
    public init() {}
}

public struct Match: Equatable, Comparable {
    public let pattern: String
    public let start: Int   // inclusive
    public let end: Int     // inclusive
    
    public init(pattern: String, start: Int, end: Int) {
        self.pattern = pattern
        self.start = start
        self.end = end
    }
    
    // Equatable – field‑by‑field
    public static func == (lhs: Match, rhs: Match) -> Bool {
        return lhs.pattern == rhs.pattern &&
               lhs.start == rhs.start &&
               lhs.end == rhs.end
    }
    
    // Comparable – order by start, then by end, then by pattern
    public static func < (lhs: Match, rhs: Match) -> Bool {
        if lhs.start != rhs.start { return lhs.start < rhs.start }
        if lhs.end != rhs.end { return lhs.end < rhs.end }
        return lhs.pattern < rhs.pattern
    }
}

public struct AhoCorasickAutomaton {
    public let patterns: [String]
    public let root: ACNode
    
    public init(patterns: [String]) {
        self.patterns = patterns
        self.root = ACNode()
        self.buildTrie()
        self.buildFailureLinks()
    }
    
    // MARK: - Trie construction
    private mutating func buildTrie() {
        for (idx, pat) in patterns.enumerated() {
            var node = root
            for ch in pat {
                if node.children[ch] == nil {
                    node.children[ch] = ACNode()
                }
                node = node.children[ch]!
            }
            node.output.append(idx)
        }
    }
    
    // MARK: - Failure links (BFS)
    private mutating func buildFailureLinks() {
        var queue: [ACNode] = []
        // First level: failure = root
        for child in root.children.values {
            child.failure = root
            queue.append(child)
        }
        // BFS
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (ch, child) in current.children {
                // Find failure for child
                var failNode = current.failure
                while failNode != nil && failNode?.children[ch] == nil {
                    failNode = failNode?.failure
                }
                if let f = failNode?.children[ch] {
                    child.failure = f
                } else {
                    child.failure = root
                }
                // Merge output
                if let f = child.failure {
                    child.output.append(contentsOf: f.output)
                }
                queue.append(child)
            }
        }
    }
    
    // MARK: - Search
    public func search(in text: String) -> [Match] {
        var results: [Match] = []
        var node: ACNode = root
        var position = 0   // integer index in text (character count)
        
        for ch in text {
            // Follow failure links for missing transition
            while node.children[ch] == nil && node !== root {
                if let fail = node.failure {
                    node = fail
                } else {
                    node = root
                    break
                }
            }
            // Take the transition if it exists
            if let next = node.children[ch] {
                node = next
            } else {
                node = root
            }
            // Emit matches
            if !node.output.isEmpty {
                for patIdx in node.output {
                    let pat = patterns[patIdx]
                    let patLen = pat.count
                    let startPos = position - patLen + 1
                    if startPos >= 0 {
                        results.append(Match(pattern: pat, start: startPos, end: position))
                    }
                }
            }
            position += 1
        }
        // Return matches sorted for deterministic test comparison
        return results.sorted()
    }
}
