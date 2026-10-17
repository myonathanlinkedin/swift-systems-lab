import Foundation

public final class ACNode {
    public var children: [Character: ACNode] = [:]
    public var fail: ACNode? = nil
    public var output: [String] = []
    
    public init() {}
}

public struct AhoCorasick {
    let root = ACNode()
    
    public init() {}
    
    // Add a pattern to the trie. Empty patterns are ignored.
    public mutating func addPattern(_ pattern: String) {
        guard !pattern.isEmpty else { return }
        var node: ACNode = root
        for ch in pattern {
            if let next = node.children[ch] {
                node = next
            } else {
                let newNode = ACNode()
                node.children[ch] = newNode
                node = newNode
            }
        }
        node.output.append(pattern)
    }
    
    // Build failure links using BFS. Must be called after all patterns are added.
    public mutating func build() {
        var queue: [ACNode] = []
        
        // Initialize depth‑1 nodes.
        for child in root.children.values {
            child.fail = root
            queue.append(child)
        }
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (ch, child) in current.children {
                // Follow failure links to find a matching transition.
                var failNode = current.fail
                while failNode != nil && failNode?.children[ch] == nil {
                    failNode = failNode?.fail
                }
                if let failNode = failNode, let transition = failNode.children[ch] {
                    child.fail = transition
                } else {
                    child.fail = root
                }
                
                // Merge output of failure node.
                if let failOutputs = child.fail?.output {
                    child.output.append(contentsOf: failOutputs)
                }
                
                queue.append(child)
            }
        }
    }
    
    // Search the given text and return all (pattern, startIndex) matches.
    public func search(in text: String) -> [(pattern: String, index: Int)] {
        var results: [(String, Int)] = []
        var node: ACNode = root
        var position = 0
        
        for ch in text {
            // Follow failure links when there is no edge for the current character.
            while node !== root && node.children[ch] == nil {
                if let f = node.fail {
                    node = f
                } else {
                    node = root
                    break
                }
            }
            
            // Take the transition if it exists.
            if let next = node.children[ch] {
                node = next
            } else {
                node = root
            }
            
            // Record all patterns that end at this position.
            if !node.output.isEmpty {
                for pat in node.output {
                    let start = position - pat.count + 1
                    if start >= 0 {
                        results.append((pat, start))
                    }
                }
            }
            position += 1
        }
        return results
    }
}
