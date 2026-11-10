import Foundation

// Unit tests for the Trie implementation.
func testBasicInsertionAndQuery() {
    var trie = Trie()
    let data: [(String, Int)] = [
        ("apple", 5), ("app", 10), ("application", 3),
        ("ape", 8), ("apex", 7), ("banana", 6),
        ("band", 4), ("bandana", 2), ("bandit", 9),
        ("banner", 1), ("appetite", 4), ("apply", 5)
    ]

    for (word, weight) in data {
        trie.insert(word: word, weight: weight)
    }

    let apSuggestions = trie.suggestions(for: "ap")
    let expectedAP = ["app", "ape", "apex", "apple", "apply", "appetite", "application"]
    assert(apSuggestions == expectedAP, "AP suggestions mismatch. Got \(apSuggestions)")

    let banSuggestions = trie.suggestions(for: "ban")
    let expectedBan = ["bandit", "banana", "band", "bandana", "banner"]
    assert(banSuggestions == expectedBan, "BAN suggestions mismatch. Got \(banSuggestions)")

    let emptySuggestions = trie.suggestions(for: "")
    // Top 10 overall (by weight, then lexical)
    let expectedRoot = ["app", "bandit", "ape", "apex", "banana", "apple", "apply", "appetite", "application", "band"]
    assert(emptySuggestions == expectedRoot, "Root suggestions mismatch. Got \(emptySuggestions)")

    let missing = trie.suggestions(for: "z")
    assert(missing.isEmpty, "Expected empty result for unknown prefix")
}

func testTopLimitEnforcement() {
    var trie = Trie()
    // Insert 12 words with descending weights.
    for i in 1...12 {
        let word = "word\(i)"
        trie.insert(word: word, weight: 13 - i) // weights 12..1
    }

    let rootSug = trie.suggestions(for: "")
    // Should contain the 10 highest weighted words: word1..word10
    let expected = (1...10).map { "word\($0)" }
    assert(rootSug == expected, "Top‑10 limit not enforced. Got \(rootSug)")
}

func testWeightUpdate() {
    var trie = Trie()
    trie.insert(word: "alpha", weight: 3)
    trie.insert(word: "alpha", weight: 8) // higher weight should replace

    let suggestions = trie.suggestions(for: "a")
    assert(suggestions.first == "alpha", "Weight update failed. Got \(suggestions)")
    // Ensure the stored weight is the higher one.
    if let node = trie.root.children["a"]?.children["l"]?.children["p"]?.children["h"]?.children["a"] {
        if let top = node.top.first {
            assert(top.weight == 8, "Stored weight not updated. Got \(top.weight)")
        } else {
            assertionFailure("Top suggestion missing after update")
        }
    } else {
        assertionFailure("Node path missing after update")
    }
}

// Execute tests.
testBasicInsertionAndQuery()
testTopLimitEnforcement()
testWeightUpdate()

print("All tests passed.")
