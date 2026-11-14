final class AhoCorasick {
    let root = ACNode()
    
    init(patterns: [String]) {
        buildTrie(with: patterns)
        buildFailureLinks()
    }
    
    // MARK: - Trie construction
    func buildTrie(with patterns: [String]) {
        for pattern in patterns {
            var node = root
            for ch in pattern {
                if node.children[ch] == nil {
                    node.children[ch] = ACNode()
                }
                node = node.children[ch]!
            }
            node.output.append(pattern)
        }
    }
    
    // MARK: - Failure links
    func buildFailureLinks() {
        var queue: [ACNode] = []
        
        // First level: fail points to root
        for child in root.children.values {
            child.fail = root
            queue.append(child)
        }
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (ch, child) in current.children {
                var failNode = current.fail
                while failNode !== root && (failNode?.children[ch] == nil) {
                    failNode = failNode?.fail
                }
                if let next = failNode?.children[ch] {
                    child.fail = next
                } else {
                    child.fail = root
                }
                // Merge output of failure node
                if let failOutput = child.fail?.output {
                    child.output.append(contentsOf: failOutput)
                }
                queue.append(child)
            }
        }
    }
    
    // MARK: - Search
    /// Returns an array of matches. Each match contains the index of the last character of the match
    /// (0‑based) and all patterns that end at that position.
    func search(in text: String) -> [ACMatch] {
        var results: [ACMatch] = []
        var node = root
        var index = 0
        
        for ch in text {
            while node !== root && node.children[ch] == nil {
                node = node.fail!
            }
            if let next = node.children[ch] {
                node = next
            } else {
                node = root
            }
            if !node.output.isEmpty {
                results.append(ACMatch(position: index, patterns: node.output))
            }
            index += 1
        }
        return results
    }
}
