import Foundation

// Helper to compare unordered collections of matches
func unorderedEqual(_ lhs: [(String, Int)], _ rhs: [(String, Int)]) -> Bool {
    let lhsSorted = lhs.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
    let rhsSorted = rhs.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
    return lhsSorted.elementsEqual(rhsSorted) { $0.0 == $1.0 && $0.1 == $1.1 }
}

// Test 1: Basic example from literature
var automaton1 = AhoCorasick()
let patterns1 = ["he", "she", "his", "hers"]
for p in patterns1 {
    automaton1.addPattern(p)
}
automaton1.buildFailureLinks()
let text1 = "ushers"
let matches1 = automaton1.search(text1)
let expected1: [(String, Int)] = [("she", 1), ("he", 2), ("hers", 2)]
assert(unorderedEqual(matches1, expected1), "Test 1 failed: \(matches1)")

// Test 2: Overlapping patterns
var automaton2 = AhoCorasick()
let patterns2 = ["a", "ab", "bab", "bc", "bca", "c", "caa"]
for p in patterns2 {
    automaton2.addPattern(p)
}
automaton2.buildFailureLinks()
let text2 = "abccab"
let matches2 = automaton2.search(text2)
let expected2: [(String, Int)] = [
    ("a", 0), ("ab", 0),
    ("b", 1), // not a pattern, ignore
    ("c", 2), ("c", 3),
    ("a", 4), ("ab", 4)
]
let filteredExpected2 = expected2.filter { patterns2.contains($0.0) }
assert(unorderedEqual(matches2, filteredExpected2), "Test 2 failed: \(matches2)")

// Test 3: Empty text
var automaton3 = AhoCorasick()
automaton3.addPattern("test")
automaton3.buildFailureLinks()
let matches3 = automaton3.search("")
assert(matches3.isEmpty, "Test 3 failed: expected empty result")

// Test 4: No patterns added
var automaton4 = AhoCorasick()
automaton4.buildFailureLinks()
let matches4 = automaton4.search("anytext")
assert(matches4.isEmpty, "Test 4 failed: expected empty result when no patterns")

print("All Aho‑Corasick tests passed.")
