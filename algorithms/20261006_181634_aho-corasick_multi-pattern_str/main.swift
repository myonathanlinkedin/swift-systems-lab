import Foundation

func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    if lhs != rhs {
        fatalError("Assertion failed: \(lhs) != \(rhs). \(message)")
    }
}

func testBasic() {
    var ac = AhoCorasick()
    ac.addPattern("he")
    ac.addPattern("she")
    ac.addPattern("his")
    ac.addPattern("hers")
    ac.buildFailLinks()
    let matches = ac.search("ushers")
    let expected: [Match] = [
        Match(patternIndex: 1, start: 1, end: 3), // she
        Match(patternIndex: 0, start: 2, end: 3), // he
        Match(patternIndex: 3, start: 2, end: 5)  // hers
    ]
    assertEqual(matches.count, expected.count, "Basic test match count")
    for (m, e) in zip(matches, expected) {
        assertEqual(m, e, "Basic test match mismatch")
    }
}

func testMultipleMatches() {
    var ac = AhoCorasick()
    ac.addPattern("a")
    ac.addPattern("aa")
    ac.addPattern("aaa")
    ac.buildFailLinks()
    let matches = ac.search("aaaaa")
    // Count expected matches
    // positions 0-4
    // at index 0: "a"
    // at index 1: "a","aa"
    // at index 2: "a","aa","aaa"
    // at index 3: "a","aa","aaa"
    // at index 4: "a","aa","aaa"
    let expectedCount = 1 + 2 + 3 + 3 + 3
    assertEqual(matches.count, expectedCount, "Multiple matches count")
}

func testNoMatch() {
    var ac = AhoCorasick()
    ac.addPattern("abc")
    ac.buildFailLinks()
    let matches = ac.search("defgh")
    assertEqual(matches.count, 0, "No match test")
}

func testEmptyText() {
    var ac = AhoCorasick()
    ac.addPattern("a")
    ac.buildFailLinks()
    let matches = ac.search("")
    assertEqual(matches.count, 0, "Empty text test")
}

func runAllTests() {
    testBasic()
    testMultipleMatches()
    testNoMatch()
    testEmptyText()
    print("All tests passed.")
}

runAllTests()
