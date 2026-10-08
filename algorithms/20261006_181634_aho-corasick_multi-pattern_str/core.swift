import Foundation

struct TrieNode {
    var children: [Character: Int] = [:]
    var fail: Int = 0
    var output: [Int] = []
}

struct Match: Equatable {
    let patternIndex: Int
    let start: Int
    let end: Int
}

struct AhoCorasick {
    var nodes: [TrieNode] = [TrieNode()]
    var patterns: [String] = []

    mutating func addPattern(_ pattern: String) {
        let index = patterns.count
        patterns.append(pattern)
        var current = 0
        for char in pattern {
            if let next = nodes[current].children[char] {
                current = next
            } else {
                let newNode = TrieNode()
                nodes.append(newNode)
                let newIndex = nodes.count - 1
                nodes[current].children[char] = newIndex
                current = newIndex
            }
        }
        nodes[current].output.append(index)
    }

    mutating func buildFailLinks() {
        var queue: [Int] = []
        for (_, child) in nodes[0].children {
            nodes[child].fail = 0
            queue.append(child)
        }
        while !queue.isEmpty {
            let current = queue.removeFirst()
            for (char, child) in nodes[current].children {
                var failState = nodes[current].fail
                while failState != 0 && nodes[failState].children[char] == nil {
                    failState = nodes[failState].fail
                }
                if let next = nodes[failState].children[char] {
                    nodes[child].fail = next
                } else {
                    nodes[child].fail = 0
                }
                nodes[child].output += nodes[nodes[child].fail].output
                queue.append(child)
            }
        }
    }

    mutating func search(_ text: String) -> [Match] {
        var results: [Match] = []
        var state = 0
        var index = 0
        for char in text {
            while state != 0 && nodes[state].children[char] == nil {
                state = nodes[state].fail
            }
            if let next = nodes[state].children[char] {
                state = next
            } else {
                state = 0
            }
            for patternIdx in nodes[state].output {
                let patternLength = patterns[patternIdx].count
                let start = index - patternLength + 1
                let end = index
                results.append(Match(patternIndex: patternIdx, start: start, end: end))
            }
            index += 1
        }
        return results
    }
}
