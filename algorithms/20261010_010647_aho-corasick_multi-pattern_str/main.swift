import Foundation

// Helper to compare two arrays of (String, Int) irrespective of order.
func assertMatchesEqual(_ actual: [(String, Int)], _ expected: [(String, Int)], file: StaticString = #file, line: UInt = #line) {
    let sortedActual = actual.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
    let sortedExpected = expected.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
    assert(sortedActual.elementsEqual(sortedExpected) { $0.0 == $1.0 && $0.1 == $1.1 }, "Mismatch.\nActual: \(sortedActual)\nExpected: \(sortedExpected)", file: file, line: line)
}

// Test 1: Basic example from classic literature.
func testBasic() {
    var ac = AhoCorasick()
    ac.addPattern("he")
    ac.addPattern("she")
    ac.addPattern("his")
    ac.addPattern("hers")
    ac.build()
    
    let text = "ushers"
    let matches = ac.search(in: text)
    let expected: [(String, Int)] = [("she", 1), ("he", 2), ("hers", 2)]
    assertMatchesEqual(matches, expected)
}

// Test 2: Overlapping patterns (Wikipedia example).
func testOverlapping() {
    var ac = AhoCorasick()
    let patterns = ["a", "ab", "bab", "bc", "bca", "c", "caa"]
    for p in patterns {
        ac.addPattern(p)
    }
    ac.build()
    
    let text = "abccab"
    let matches = ac.search(in: text)
    let expected: [(String, Int)] = [
        ("a", 0), ("ab", 0),
        ("b", 1), ("bc", 1), ("c", 2), ("c", 3),
        ("a", 4), ("ab", 4)
    ]
    // Note: The automaton does not emit single‑character patterns unless they were added.
    // Here we added "a", "ab", "bab", "bc", "bca", "c", "caa".
    // The expected matches are therefore:
    let expectedFiltered: [(String, Int)] = [
        ("a", 0), ("ab", 0),
        ("bc", 1), ("c", 2), ("c", 3),
        ("a", 4), ("ab", 4)
    ]
    assertMatchesEqual(matches, expectedFiltered)
}

// Test 3: No patterns added.
func testNoPatterns() {
    var ac = AhoCorasick()
    ac.build()
    let matches = ac.search(in: "anytext")
    assert(matches.isEmpty, "Expected no matches when no patterns are added")
}

// Test 4: Empty text.
func testEmptyText() {
    var ac = AhoCorasick()
    ac.addPattern("test")
    ac.build()
    let matches = ac.search(in: "")
    assert(matches.isEmpty, "Expected no matches on empty text")
}

// Test 5: Patterns with shared prefixes.
func testSharedPrefixes() {
    var ac = AhoCorasick()
    ac.addPattern("he")
    ac.addPattern("her")
    ac.addPattern("hers")
    ac.build()
    
    let text = "ahers"
    let matches = ac.search(in: text)
    let expected: [(String, Int)] = [("he", 1), ("her", 1), ("hers", 1)]
    assertMatchesEqual(matches, expected)
}

// Execute all tests.
func runAllTests() {
    testBasic()
    testOverlapping()
    testNoPatterns()
    testEmptyText()
    testSharedPrefixes()
    print("All Aho‑Corasick tests passed.")
}

runAllTests()
