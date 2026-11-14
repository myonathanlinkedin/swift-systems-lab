func testSimpleCase() {
    let patterns = ["he", "she", "his", "hers"]
    let text = "ushers"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    
    // Expected: (3, ["he","she"]), (5, ["hers"])
    assert(matches.count == 2, "Expected 2 matches, got \(matches.count)")
    assert(matches[0].position == 3, "First match should end at index 3")
    assert(Set(matches[0].patterns) == Set(["he", "she"]), "First match patterns mismatch")
    assert(matches[1].position == 5, "Second match should end at index 5")
    assert(matches[1].patterns == ["hers"], "Second match patterns mismatch")
}

func testOverlappingPatterns() {
    let patterns = ["a", "aa", "aaa"]
    let text = "aaaa"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    
    // Expected matches per ending index:
    // 0: ["a"]
    // 1: ["a","aa"]
    // 2: ["a","aa","aaa"]
    // 3: ["a","aa","aaa"]
    let expected: [Int: Set<String>] = [
        0: ["a"],
        1: ["a","aa"],
        2: ["a","aa","aaa"],
        3: ["a","aa","aaa"]
    ]
    assert(matches.count == expected.count, "Expected \(expected.count) matches, got \(matches.count)")
    for match in matches {
        guard let expSet = expected[match.position] else {
            assertionFailure("Unexpected match at position \(match.position)")
            continue
        }
        assert(Set(match.patterns) == expSet, "Mismatch at position \(match.position)")
    }
}

func testEmptyPatterns() {
    let automaton = AhoCorasick(patterns: [])
    let matches = automaton.search(in: "anytext")
    assert(matches.isEmpty, "Expected no matches with empty pattern set")
}

func testEmptyText() {
    let automaton = AhoCorasick(patterns: ["a", "b"])
    let matches = automaton.search(in: "")
    assert(matches.isEmpty, "Expected no matches with empty text")
}

func testUnicodePatterns() {
    let patterns = ["😀", "😁"]
    let text = "😀😁😀"
    let automaton = AhoCorasick(patterns: patterns)
    let matches = automaton.search(in: text)
    
    // Expected: index 0 -> ["😀"], index 1 -> ["😁"], index 2 -> ["😀"]
    let expected: [Int: [String]] = [
        0: ["😀"],
        1: ["😁"],
        2: ["😀"]
    ]
    assert(matches.count == expected.count, "Expected \(expected.count) matches, got \(matches.count)")
    for match in matches {
        guard let exp = expected[match.position] else {
            assertionFailure("Unexpected match at position \(match.position)")
            continue
        }
        assert(match.patterns == exp, "Unicode match mismatch at position \(match.position)")
    }
}

// Execute all tests
testSimpleCase()
testOverlappingPatterns()
testEmptyPatterns()
testEmptyText()
testUnicodePatterns()

print("All Aho‑Corasick tests passed.")
