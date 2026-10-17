import Foundation

// Helper to compare unordered collections of matches
func unorderedEqual(_ a: [(Int, Int)], _ b: [(Int, Int)]) -> Bool {
    guard a.count == b.count else { return false }
    var dict: [String: Int] = [:]
    for (p, s) in a {
        let key = "\(p)#\(s)"
        dict[key, default: 0] += 1
    }
    for (p, s) in b {
        let key = "\(p)#\(s)"
        guard let count = dict[key], count > 0 else { return false }
        dict[key] = count - 1
    }
    return true
}

// Test 1: Classic example
do {
    let patterns = ["he", "she", "his", "hers"]
    let text = "ushers"
    var automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    // Expected: ("she", start 1), ("he", start 2), ("hers", start 2)
    let expected: [(Int, Int)] = [
        (1, 1), // "she"
        (0, 2), // "he"
        (3, 2)  // "hers"
    ]
    assert(unorderedEqual(matches, expected), "Test 1 failed")
}

// Test 2: Overlapping patterns
do {
    let patterns = ["a", "aa", "aaa"]
    let text = "aaaa"
    var automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    // Enumerate expected matches manually
    var expected: [(Int, Int)] = []
    // positions: 0,1,2,3
    for i in 0..<text.count {
        // "a"
        expected.append((0, i))
        // "aa"
        if i >= 1 { expected.append((1, i - 1)) }
        // "aaa"
        if i >= 2 { expected.append((2, i - 2)) }
    }
    assert(unorderedEqual(matches, expected), "Test 2 failed")
}

// Test 3: Unicode characters
do {
    let patterns = ["😀", "😁"]
    let text = "😀😁😀"
    var automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    let expected: [(Int, Int)] = [
        (0, 0), // first 😀
        (1, 1), // 😁
        (0, 2)  // second 😀
    ]
    assert(unorderedEqual(matches, expected), "Test 3 failed")
}

// Test 4: Empty pattern list
do {
    let patterns: [String] = []
    let text = "any text"
    var automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    assert(matches.isEmpty, "Test 4 failed")
}

// Test 5: Pattern not present
do {
    let patterns = ["xyz"]
    let text = "abc"
    var automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    assert(matches.isEmpty, "Test 5 failed")
}

// Simple benchmark (non‑rigorous, for sanity)
do {
    let patterns = (1...1000).map { "p\($0)" }
    let text = String(repeating: "a", count: 100_000) + "p500"
    var automaton = AhoCorasick(patterns: patterns)
    let start = Date()
    _ = automaton.search(in: text)
    var _instance_elapsed = Date()
        let elapsed = _instance_elapsed.timeIntervalSince(start)
    print(String(format: "Benchmark elapsed: %.3f seconds", elapsed))
}

// Entry point confirmation
print("All tests passed.")
