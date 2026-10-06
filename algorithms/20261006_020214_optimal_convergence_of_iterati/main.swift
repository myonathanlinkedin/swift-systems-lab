import Foundation

// Helper to create a fact
func fact(_ predicate: String, _ args: String...) -> Fact {
    return Fact(predicate: predicate, arguments: args)
}

// Helper to create a rule
func rule(_ head: Fact, _ body: Fact...) -> Rule {
    return Rule(head: head, body: body)
}

// Test 1: Simple facts and rules
func testSimpleFacts() {
    var engine = DatalogEngine()
    engine.addFact(fact("parent", "a", "b"))
    engine.addFact(fact("parent", "b", "c"))
    engine.addRule(rule(fact("ancestor", "X", "Y"), fact("parent", "X", "Y")))
    engine.addRule(rule(fact("ancestor", "X", "Y"), fact("parent", "X", "Z"), fact("ancestor", "Z", "Y")))
    let result = engine.run()
    let expected: Set<Fact> = [
        fact("parent", "a", "b"),
        fact("parent", "b", "c"),
        fact("ancestor", "a", "b"),
        fact("ancestor", "b", "c"),
        fact("ancestor", "a", "c")
    ]
    assert(result == expected, "Test Simple Facts Failed")
}

// Test 2: Recursive rule without base facts
func testRecursiveRule() {
    var engine = DatalogEngine()
    engine.addRule(rule(fact("reach", "X", "Y"), fact("reach", "X", "Z"), fact("reach", "Z", "Y")))
    engine.addFact(fact("reach", "a", "b"))
    let result = engine.run()
    let expected: Set<Fact> = [
        fact("reach", "a", "b")
    ]
    assert(result == expected, "Test Recursive Rule Failed")
}

// Test 3: No rules
func testNoRules() {
    var engine = DatalogEngine()
    engine.addFact(fact("p", "x"))
    let result = engine.run()
    let expected: Set<Fact> = [
        fact("p", "x")
    ]
    assert(result == expected, "Test No Rules Failed")
}

// Test 4: Duplicate facts
func testDuplicateFacts() {
    var engine = DatalogEngine()
    let f = fact("q", "1")
    engine.addFact(f)
    engine.addFact(f)
    engine.addRule(rule(fact("r", "1"), f))
    let result = engine.run()
    let expected: Set<Fact> = [
        fact("q", "1"),
        fact("r", "1")
    ]
    assert(result == expected, "Test Duplicate Facts Failed")
}

// Test 5: Performance benchmark
func testPerformance() {
    var engine = DatalogEngine()
    let count = 1000
    // Add facts
    for i in 0..<count {
        engine.addFact(fact("node", "\(i)"))
    }
    // Add rules: node(i) -> node(i+1)
    for i in 0..<(count - 1) {
        let head = fact("node", "\(i+1)")
        let body = fact("node", "\(i)")
        engine.addRule(rule(head, body))
    }
    let start = Date()
    let result = engine.run()
    var _instance_duration = Date()
        let duration = _instance_duration.timeIntervalSince(start)
    assert(result.count == count, "Test Performance Failed: Expected \(count) facts, got \(result.count)")
    print("Performance test completed in \(duration) seconds.")
}

// Run all tests
func runTests() {
    testSimpleFacts()
    testRecursiveRule()
    testNoRules()
    testDuplicateFacts()
    testPerformance()
    print("All tests passed.")
}

runTests()
