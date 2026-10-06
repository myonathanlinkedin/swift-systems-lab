import Foundation

public struct Trie {
    public var root = TrieNode()

    public init() {}

    public mutating func insert(word: String, frequency: Int = 1) {
        var node = root
        for ch in word {
            if node.children[ch] == nil {
                node.children[ch] = TrieNode()
            }
            node = node.children[ch]!
        }
        node.isEnd = true
        node.frequency += frequency
    }

    public func suggestions(prefix: String, limit: Int = 5) -> [String] {
        var node: TrieNode? = root
        for ch in prefix {
            node = node?.children[ch]
            if node == nil {
                return []
            }
        }

        var results: [(word: String, freq: Int)] = []
        var stack: [(node: TrieNode, word: String)] = []

        if let startNode = node {
            stack.append((startNode, prefix))
        }

        while !stack.isEmpty {
            let (currentNode, currentWord) = stack.removeLast()
            if currentNode.isEnd {
                results.append((currentWord, currentNode.frequency))
            }
            for (ch, child) in currentNode.children {
                stack.append((child, currentWord + String(ch)))
            }
        }

        results.sort {
            if $0.freq != $1.freq {
                return $0.freq > $1.freq   // higher frequency first
            } else {
                return $0.word < $1.word   // alphabetical tie‑breaker
            }
        }

        let limited = results.prefix(limit).map { $0.word }
        return Array(limited)
    }
}
