import Foundation

// Helper to compare expected matches with actual results.
func assertMatches(_ actual: [ACMatch], _ expected: [(Int, Int)], file: StaticString = #file, line: UInt = #line) {
    for (patIdx, pos) in expected {
        let found = actual.contains { $0.patternIndex == patIdx && $0.startPosition == pos }
        assert(found, "Expected match (pattern \(patIdx), position \(pos)) not found", file: file, line: line)
    }
    assert(actual.count == expected.count, "Expected \(expected.count) matches, found \(actual.count)", file: file, line: line)
}

// Test 1: Classic example from literature.
do {
    let patterns = ["he", "she", "his", "hers"]
    let text = "ushers"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    // Expected: "she" at 1, "he" at 2, "hers" at 2
    let expected: [(Int, Int)] = [
        (1, 1), // "she"
        (0, 2), // "he"
        (3, 2)  // "hers"
    ]
    assertMatches(matches, expected)
}

// Test 2: Overlapping patterns.
do {
    let patterns = ["a", "ab", "bab", "bc", "bca", "c", "caa"]
    let text = "abccab"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    // Manually enumerated expected matches:
    // index:0 'a' -> pattern 0 at 0
    // index:0-1 "ab" -> pattern 1 at 0
    // index:1 'b' -> none
    // index:2 'c' -> pattern 5 at 2
    // index:2-3 "cc" -> none
    // index:3 'c' -> pattern 5 at 3
    // index:4 'a' -> pattern 0 at 4
    // index:4-5 "ab" -> pattern 1 at 4
    // index:5 'b' -> none
    let expected: [(Int, Int)] = [
        (0,0), (1,0), (5,2), (5,3), (0,4), (1,4)
    ]
    assertMatches(matches, expected)
}

// Test 3: Empty pattern list.
do {
    let patterns: [String] = []
    let text = "anytext"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    assert(matches.isEmpty, "Expected no matches for empty pattern set")
}

// Test 4: Duplicate patterns.
do {
    let patterns = ["test", "test"]
    let text = "testtest"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    // Each occurrence should be reported twice (once per pattern index).
    let expected: [(Int, Int)] = [
        (0,0), (1,0), (0,4), (1,4)
    ]
    assertMatches(matches, expected)
}

// Test 5: No matches.
do {
    let patterns = ["xyz", "abc"]
    let text = "defghijkl"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    assert(matches.isEmpty, "Expected no matches when patterns are absent")
}

// If execution reaches this point, all assertions have succeeded.
print("All Aho‑Corasick unit tests passed.")
