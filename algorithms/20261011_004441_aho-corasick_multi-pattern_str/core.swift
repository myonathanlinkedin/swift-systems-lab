import Foundation

// Node of the Aho‑Corasick trie. Reference type to allow recursive links.
final class ACNode {
    var children: [Character: ACNode] = [:]
    var fail: ACNode? = nil
    var output: [Int] = []          // indices of patterns ending at this node
}

// Aho‑Corasick automaton for a fixed set of patterns.
public final class AhoCorasick {
    let patterns: [String]   // original patterns, kept for result reporting
    let root = ACNode()
    
    // Build the automaton immediately.
    public init(patterns: [String]) {
        self.patterns = patterns
        buildTrie()
        buildFailureLinks()
    }
    
    // Insert all patterns into the trie.
    func buildTrie() {
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
    
    // Compute failure links using BFS.
    func buildFailureLinks() {
        var queue: [ACNode] = []
        // Depth‑1 nodes fail to root.
        for child in root.children.values {
            child.fail = root
            queue.append(child)
        }
        // BFS over the trie.
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (ch, child) in current.children {
                var f = current.fail
                while f != nil && f!.children[ch] == nil {
                    f = f!.fail
                }
                child.fail = f?.children[ch] ?? root
                // Merge output of failure node.
                child.output += child.fail?.output ?? []
                queue.append(child)
            }
        }
    }
    
    // Search `text` and return all matches as (pattern, startIndex).
    public func search(in text: String) -> [(pattern: String, index: Int)] {
        var results: [(String, Int)] = []
        var node = root
        var pos = 0
        
        for ch in text {
            // Follow fail links on mismatch.
            while node !== root && node.children[ch] == nil {
                node = node.fail!
            }
            // Advance if possible.
            if let nxt = node.children[ch] {
                node = nxt
            }
            // Emit all patterns that end here.
            if !node.output.isEmpty {
                for patIdx in node.output {
                    let pat = patterns[patIdx]
                    let start = pos - pat.count + 1
                    if start >= 0 {
                        results.append((pat, start))
                    }
                }
            }
            pos += 1
        }
        return results
    }
}
