import Foundation

public final class AhoCorasick {
    let root: ACNode
    
    public init() {
        self.root = ACNode()
        // The root's failure points to itself for simplicity during traversal
        self.root.failure = self.root
    }
    
    // Add a pattern to the trie
    public func addPattern(_ pattern: String) {
        guard !pattern.isEmpty else { return }
        var node = root
        for ch in pattern {
            if node.children[ch] == nil {
                node.children[ch] = ACNode()
            }
            node = node.children[ch]!
        }
        node.outputs.append(pattern)
    }
    
    // Build failure links using BFS
    public func buildFailureLinks() {
        var queue: [ACNode] = []
        
        // Initialize depth‑1 nodes
        for child in root.children.values {
            child.failure = root
            queue.append(child)
        }
        
        // BFS
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (ch, child) in current.children {
                var failNode = current.failure
                while failNode !== root && failNode?.children[ch] == nil {
                    failNode = failNode?.failure
                }
                if let next = failNode?.children[ch] {
                    child.failure = next
                } else {
                    child.failure = root
                }
                // Merge output patterns
                child.outputs.append(contentsOf: child.failure!.outputs)
                queue.append(child)
            }
        }
    }
    
    // Search the text and return (pattern, startIndex) pairs
    public func search(_ text: String) -> [(pattern: String, index: Int)] {
        var results: [(String, Int)] = []
        var node: ACNode = root
        var position = 0
        
        for ch in text {
            // Follow failure links for mismatches
            while node !== root && node.children[ch] == nil {
                node = node.failure!
            }
            if let next = node.children[ch] {
                node = next
            } // else stay at root
            
            // Record any matches ending at the current position
            if !node.outputs.isEmpty {
                for pat in node.outputs {
                    let startIdx = position - pat.count + 1
                    results.append((pat, startIdx))
                }
            }
            position += 1
        }
        return results
    }
}
