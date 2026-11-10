import Foundation

public struct Suggestion: Comparable, Equatable {
    public let word: String
    public let weight: Int

    public static func < (lhs: Suggestion, rhs: Suggestion) -> Bool {
        // Higher weight is considered "better" and should appear earlier.
        if lhs.weight != rhs.weight {
            return lhs.weight > rhs.weight
        }
        // Tie‑break by lexical order (ascending).
        return lhs.word < rhs.word
    }

    public static func == (lhs: Suggestion, rhs: Suggestion) -> Bool {
        return lhs.word == rhs.word && lhs.weight == rhs.weight
    }
}

public final class TrieNode {
    public var children: [Character: TrieNode] = [:]
    public var top: [Suggestion] = []

    public init() {}

    public func updateTop(with suggestion: Suggestion) {
        // If the word already exists, keep the higher weight.
        if let idx = top.firstIndex(where: { $0.word == suggestion.word }) {
            if suggestion.weight > top[idx].weight {
                top[idx] = suggestion
                top.sort()
            }
            return
        }

        // Insert if we have space.
        if top.count < 10 {
            top.append(suggestion)
            top.sort()
            return
        }

        // Replace the worst entry if the new suggestion is better.
        if let worst = top.last, suggestion < worst {
            top[top.count - 1] = suggestion
            top.sort()
        }
    }
}

public struct Trie {
    public var root = TrieNode()

    public init() {}

    public mutating func insert(word: String, weight: Int) {
        let suggestion = Suggestion(word: word, weight: weight)

        // Update root node.
        root.updateTop(with: suggestion)

        var node = root
        for ch in word {
            if node.children[ch] == nil {
                node.children[ch] = TrieNode()
            }
            node = node.children[ch]!
            node.updateTop(with: suggestion)
        }
    }

    public func suggestions(for prefix: String) -> [String] {
        var node: TrieNode? = root
        for ch in prefix {
            node = node?.children[ch]
            if node == nil {
                return []
            }
        }
        return node?.top.map { $0.word } ?? []
    }
}
