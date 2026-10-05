import Foundation

// Helper to create terms more ergonomically
func V(_ name: String) -> Term { .variable(name) }
func A(_ name: String) -> Term { .atom(name) }
func N(_ value: Int) -> Term { .number(value) }
func C(_ name: String, _ args: Term...) -> Term { .compound(name: name, args: args) }

// Build Knowledge Base
let kb = KnowledgeBase()
kb.add(Clause(head: C("parent", A("alice"), A("bob")), body: []))
kb.add(Clause(head: C("parent", A("bob"), A("carol")), body: []))
kb.add(Clause(head: C("male", A("bob")), body: []))
kb.add(Clause(head: C("female", A("alice")), body: []))

// Unit Tests
func testUnify() {
    var env: Substitution = [:]
    let t1 = C("parent", V("X"), V("Y"))
    let t2 = C("parent", A("alice"), A("bob"))
    assert(unify(t1, t2, &env))
    assert(env["X"] == A("alice"))
    assert(env["Y"] == A("bob"))
}
testUnify()

func testSolveSingleGoal() {
    let solver = Solver(kb: kb)
    let goal = C("parent", A("alice"), V("Child"))
    let solutions = solver.solve(goal: goal)
    assert(solutions.count == 1)
    let sol = solutions[0]
    assert(sol["Child"] == A("bob"))
}
testSolveSingleGoal()

func testSolveRecursiveGoal() {
    // Add ancestor rule
    kb.add(Clause(head: C("ancestor", V("X"), V("Y")),
                  body: [C("parent", V("X"), V("Y"))]))
    kb.add(Clause(head: C("ancestor", V("X"), V("Y")),
                  body: [C("parent", V("X"), V("Z")), C("ancestor", V("Z"), V("Y"))]))
    
    let solver = Solver(kb: kb)
    let goal = C("ancestor", A("alice"), V("Desc"))
    let solutions = solver.solve(goal: goal)
    let descSet = Set(solutions.compactMap { $0["Desc"]?.description })
    assert(descSet == Set(["bob", "carol"]))
}
testSolveRecursiveGoal()

func testSynthesis() {
    let goal = C("parent", A("alice"), V("Z"))
    if let clause = synthesize(goal: goal, kb: kb) {
        assert(clause.head == goal)
        assert(clause.body.isEmpty)
    } else {
        assertionFailure("Synthesis failed")
    }
}
testSynthesis()

// Simple Benchmark
func benchmarkSolve(iterations: Int = 1000) {
    let solver = Solver(kb: kb)
    let goal = C("ancestor", A("alice"), V("Desc"))
    let start = Date()
    for _ in 0..<iterations {
        _ = solver.solve(goal: goal)
    }
    let elapsed = Date().timeIntervalSince(start)
    print("Benchmark: \(iterations) solves in \(String(format: "%.3f", elapsed)) seconds")
}
benchmarkSolve(iterations: 200)

// Entry point (for command-line execution)
print("All tests passed.")
