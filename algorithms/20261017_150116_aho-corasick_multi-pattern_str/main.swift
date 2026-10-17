import Foundation

// Simple assertion helper
func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    if lhs != rhs {
        print("Assertion failed: \(message)")
        print("  lhs: \(lhs)")
        print("  rhs: \(rhs)")
        exit(1)
    }
}

// Unit tests
func testBasic() {
    let patterns = ["he", "she", "his", "hers"]
    let automaton = AhoCorasickAutomaton(patterns: patterns)
    let text = "ushers"
    let matches = automaton.search(in: text)
    let expected: [Match] = [
        Match(pattern: "she", start: 1, end: 3),
        Match(pattern: "he",  start: 2, end: 3),
        Match(pattern: "hers",start: 2, end: 5)
    ].sorted()
    assertEqual(matches, expected, "Basic test failed")
}

func testOverlapping() {
    let patterns = ["a", "ab", "bab", "bc", "bca", "c", "caa"]
    let automaton = AhoCorasickAutomaton(patterns: patterns)
    let text = "abccab"
    let matches = automaton.search(in: text)
    let expected: [Match] = [
        Match(pattern: "a",   start: 0, end: 0),
        Match(pattern: "ab",  start: 0, end: 1),
        Match(pattern: "b",   start: 1, end: 1), // not a pattern, ignore
        Match(pattern: "c",   start: 2, end: 2),
        Match(pattern: "c",   start: 3, end: 3),
        Match(pattern: "a",   start: 4, end: 4),
        Match(pattern: "ab",  start: 4, end: 5)
    ].filter { patterns.contains($0.pattern) }.sorted()
    assertEqual(matches, expected, "Overlapping test failed")
}

func testNoMatch() {
    let patterns = ["xyz", "123"]
    let automaton = AhoCorasickAutomaton(patterns: patterns)
    let text = "abcdef"
    let matches = automaton.search(in: text)
    assertEqual(matches.isEmpty, true, "No‑match test failed")
}

func testUnicode() {
    let patterns = ["😀", "😃", "😀😃"]
    let automaton = AhoCorasickAutomaton(patterns: patterns)
    let text = "ab😀😃cd😀"
    let matches = automaton.search(in: text)
    let expected: [Match] = [
        Match(pattern: "😀",   start: 2, end: 2),
        Match(pattern: "😀😃", start: 2, end: 3),
        Match(pattern: "😃",   start: 3, end: 3),
        Match(pattern: "😀",   start: 6, end: 6)
    ].sorted()
    assertEqual(matches, expected, "Unicode test failed")
}

func testEmptyPatternList() {
    let automaton = AhoCorasickAutomaton(patterns: [])
    let matches = automaton.search(in: "anything")
    assertEqual(matches.isEmpty, true, "Empty pattern list test failed")
}

func testEmptyText() {
    let automaton = AhoCorasickAutomaton(patterns: ["a", "b"])
    let matches = automaton.search(in: "")
    assertEqual(matches.isEmpty, true, "Empty text test failed")
}

// Run all tests
func runAllTests() {
    testBasic()
    testOverlapping()
    testNoMatch()
    testUnicode()
    testEmptyPatternList()
    testEmptyText()
    print("All Aho‑Corasick tests passed.")
}

runAllTests()
