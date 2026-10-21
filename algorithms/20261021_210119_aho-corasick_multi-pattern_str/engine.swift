import Foundation

public final class AhoCorasick {
    let patterns: [String]
    let patternLengths: [Int]
    let root: ACNode
    
    public init(patterns: [String]) {
        // Discard empty patterns – they would match everywhere and break the algorithm.
        self.patterns = patterns.filter { !$0.isEmpty }
        self.patternLengths = self.patterns.map { $0.count }
        self.root = ACNode()
        buildTrie()
        buildFailureLinks()
    }
    
    func buildTrie() {
        for (index, pattern) in patterns.enumerated() {
            var node = root
            for ch in pattern {
                if node.children[ch] == nil {
                    node.children[ch] = ACNode()
                }
                node = node.children[ch]!
            }
            node.output.append(index)
        }
    }
    
    func buildFailureLinks() {
        var queue: [ACNode] = []
        
        // Initialize depth‑1 nodes.
        for child in root.children.values {
            child.fail = root
            queue.append(child)
        }
        
        // BFS over the trie.
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (ch, child) in current.children {
                var fallback = current.fail
                while fallback !== root && fallback?.children[ch] == nil {
                    fallback = fallback?.fail
                }
                if let next = fallback?.children[ch] {
                    child.fail = next
                } else {
                    child.fail = root
                }
                // Merge output links.
                if let failOutputs = child.fail?.output {
                    child.output.append(contentsOf: failOutputs)
                }
                queue.append(child)
            }
        }
    }
    
    /// Searches `text` for all pattern occurrences.
    /// - Returns: An array of `ACMatch` where each match records the pattern index and the start position (0‑based).
    public func search(in text: String) -> [ACMatch] {
        var results: [ACMatch] = []
        var node = root
        var index = 0   // Position in `text`
        
        for ch in text {
            // Follow failure links if the transition does not exist.
            while node !== root && node.children[ch] == nil {
                node = node.fail!
            }
            if let next = node.children[ch] {
                node = next
            } else {
                node = root
            }
            
            // Emit all matches ending at the current character.
            if !node.output.isEmpty {
                for patIdx in node.output {
                    let startPos = index - patternLengths[patIdx] + 1
                    results.append(ACMatch(patternIndex: patIdx, startPosition: startPos))
                }
            }
            index += 1
        }
        return results
    }
}
