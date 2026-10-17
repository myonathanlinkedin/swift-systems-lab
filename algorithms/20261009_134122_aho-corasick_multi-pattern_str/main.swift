import Foundation

// Simple test harness
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    if a != b {
        print("Assertion failed: \(message)")
        print("  left : \(a)")
        print("  right: \(b)")
        exit(1)
    }
}

// Test 1: Basic single pattern
func testSinglePattern() {
    let ac = AhoCorasick(patterns: ["he"])
    let matches = ac.search(in: "she")
    assertEqual(matches.count, 1, "single pattern count")
    assertEqual(matches[0].pattern, "he", "single pattern text")
    assertEqual(matches[0].position, 1, "single pattern position")
}

// Test 2: Multiple patterns with overlap
func testMultiplePatterns() {
    let ac = AhoCorasick(patterns: ["he", "she", "his", "hers"])
    let matches = ac.search(in: "ushers")
    // Expected matches: "she" at 1, "he" at 2, "hers" at 2
    let expected: [(String, Int)] = [("she", 1), ("he", 2), ("hers", 2)]
    assertEqual(matches.count, expected.count, "multiple patterns count")
    for (exp, got) in zip(expected, matches) {
        assertEqual(got.pattern, exp.0, "multiple patterns text")
        assertEqual(got.position, exp.1, "multiple patterns position")
    }
}

// Test 3: No matches
func testNoMatches() {
    let ac = AhoCorasick(patterns: ["abc", "def"])
    let matches = ac.search(in: "ghijkl")
    assertEqual(matches.isEmpty, true, "no matches")
}

// Test 4: Empty text
func testEmptyText() {
    let ac = AhoCorasick(patterns: ["a", "b"])
    let matches = ac.search(in: "")
    assertEqual(matches.isEmpty, true, "empty text")
}

// Test 5: Patterns with shared prefixes
func testSharedPrefixes() {
    let ac = AhoCorasick(patterns: ["a", "ab", "abc"])
    let matches = ac.search(in: "abc")
    // Expected: "a" at 0, "ab" at 0, "abc" at 0, "b" not a pattern, "c" not a pattern
    let expected: [(String, Int)] = [("a", 0), ("ab", 0), ("abc", 0)]
    assertEqual(matches.count, expected.count, "shared prefixes count")
    for (exp, got) in zip(expected, matches) {
        assertEqual(got.pattern, exp.0, "shared prefixes text")
        assertEqual(got.position, exp.1, "shared prefixes position")
    }
}

// Test 6: Empty pattern list (should produce no matches for any text)
func testEmptyPatternList() {
    let ac = AhoCorasick(patterns: [])
    let matches = ac.search(in: "anything")
    assertEqual(matches.isEmpty, true, "empty pattern list")
}

// Run all tests
func runAllTests() {
    testSinglePattern()
    testMultiplePatterns()
    testNoMatches()
    testEmptyText()
    testSharedPrefixes()
    testEmptyPatternList()
    print("All Aho‑Corasick tests passed.")
}

runAllTests()
