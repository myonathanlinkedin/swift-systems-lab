import Foundation

// Simple assertion helper.
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    if a != b {
        fatalError("Assertion failed: \(message) – \(a) is not equal to \(b)")
    }
}

// Test 1 – single pattern.
func testSinglePattern() {
    let ac = AhoCorasick(patterns: ["he"])
    let matches = ac.search(in: "hehe")
    assertEqual(matches.count, 2)
    assertEqual(matches[0].pattern, "he")
    assertEqual(matches[0].index, 0)
    assertEqual(matches[1].pattern, "he")
    assertEqual(matches[1].index, 2)
}

// Test 2 – multiple overlapping patterns.
func testOverlappingPatterns() {
    let ac = AhoCorasick(patterns: ["a", "ab", "bab", "bc", "bca", "c", "caa"])
    let matches = ac.search(in: "abccab")
    // Expected matches (pattern, start):
    // a@0, ab@0, b@1?, bc@1, c@2, c@3, a@4, ab@4
    let expected: [(String, Int)] = [
        ("a",0), ("ab",0), ("b",1), ("bc",1), ("c",2), ("c",3), ("a",4), ("ab",4)
    ]
    assertEqual(matches.count, expected.count)
    for (i, exp) in expected.enumerated() {
        assertEqual(matches[i].pattern, exp.0)
        assertEqual(matches[i].index, exp.1)
    }
}

// Test 3 – shared prefixes.
func testSharedPrefixes() {
    let ac = AhoCorasick(patterns: ["he", "her", "hers", "his"])
    let matches = ac.search(in: "ahishers")
    let expected: [(String, Int)] = [
        ("his",2), ("he",4), ("her",4), ("hers",4)
    ]
    assertEqual(matches.count, expected.count)
    for (i, exp) in expected.enumerated() {
        assertEqual(matches[i].pattern, exp.0)
        assertEqual(matches[i].index, exp.1)
    }
}

// Test 4 – no matches.
func testNoMatches() {
    let ac = AhoCorasick(patterns: ["xyz", "abc"])
    let matches = ac.search(in: "defgh")
    assertEqual(matches.count, 0)
}

// Test 5 – empty pattern list.
func testEmptyPatterns() {
    let ac = AhoCorasick(patterns: [])
    let matches = ac.search(in: "anything")
    assertEqual(matches.count, 0)
}

// Test 6 – empty text.
func testEmptyText() {
    let ac = AhoCorasick(patterns: ["a", "b"])
    let matches = ac.search(in: "")
    assertEqual(matches.count, 0)
}

// Run all tests.
func runTests() {
    testSinglePattern()
    testOverlappingPatterns()
    testSharedPrefixes()
    testNoMatches()
    testEmptyPatterns()
    testEmptyText()
    print("All Aho‑Corasick tests passed.")
}

// Entry point.
runTests()
