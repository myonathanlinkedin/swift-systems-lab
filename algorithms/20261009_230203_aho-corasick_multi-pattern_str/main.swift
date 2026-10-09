import Foundation

// Helper to compare two match arrays irrespective of order.
func matchesEqual(_ a: [(String, Int, Int)], _ b: [(String, Int, Int)]) -> Bool {
    guard a.count == b.count else { return false }
    let sortedA = a.sorted { ($0.0, $0.1, $0.2) < ($1.0, $1.1, $1.2) }
    let sortedB = b.sorted { ($0.0, $0.1, $0.2) < ($1.0, $1.1, $1.2) }
    for (x, y) in zip(sortedA, sortedB) {
        if x != y { return false }
    }
    return true
}

// Test 1: Classic example from literature.
do {
    let patterns = ["he", "she", "his", "hers"]
    let text = "ushers"
    let automaton = AhoCorasick(patterns)
    let matches = automaton.search(text)
    let expected: [(String, Int, Int)] = [
        ("she", 1, 4),   // indices 1..3 inclusive, end exclusive 4
        ("he", 2, 4),
        ("hers", 2, 6)
    ]
    assert(matchesEqual(matches, expected), "Test 1 failed")
}

// Test 2: Overlapping patterns of varying lengths.
do {
    let patterns = ["a", "aa", "aaa"]
    let text = "aaaa"
    let automaton = AhoCorasick(patterns)
    let matches = automaton.search(text)
    // Expected matches: each position yields all patterns that end there.
    // Position 0: "a"
    // Position 1: "a" (1), "aa" (0-1)
    // Position 2: "a" (2), "aa" (1-2), "aaa" (0-2)
    // Position 3: "a" (3), "aa" (2-3), "aaa" (1-3)
    let expected: [(String, Int, Int)] = [
        ("a", 0, 1),
        ("a", 1, 2), ("aa", 0, 2),
        ("a", 2, 3), ("aa", 1, 3), ("aaa", 0, 3),
        ("a", 3, 4), ("aa", 2, 4), ("aaa", 1, 4)
    ]
    assert(matchesEqual(matches, expected), "Test 2 failed")
}

// Test 3: No matches scenario.
do {
    let patterns = ["xyz", "123"]
    let text = "abcdef"
    let automaton = AhoCorasick(patterns)
    let matches = automaton.search(text)
    assert(matches.isEmpty, "Test 3 failed")
}

// Test 4: Empty pattern list should never crash and produce no matches.
do {
    let patterns: [String] = []
    let text = "anything"
    let automaton = AhoCorasick(patterns)
    let matches = automaton.search(text)
    assert(matches.isEmpty, "Test 4 failed")
}

// Test 5: Patterns containing Unicode characters.
do {
    let patterns = ["😀", "😃😀", "😀😄"]
    let text = "😃😀😄😀"
    let automaton = AhoCorasick(patterns)
    let matches = automaton.search(text)
    let expected: [(String, Int, Int)] = [
        ("😀", 1, 2),
        ("😃😀", 0, 2),
        ("😀😄", 2, 4),
        ("😀", 3, 4)
    ]
    assert(matchesEqual(matches, expected), "Test 5 failed")
}

// All tests passed.
print("All Aho‑Corasick unit tests passed.")
