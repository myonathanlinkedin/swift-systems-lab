import Foundation

// Sample CHC set demonstrating simple equality constraints

let clause1 = HornClause(
    head: Atom(predicate: "p", terms: [.variable("X")]),
    body: [Atom(predicate: "q", terms: [.variable("X")])],
    constraints: [Constraint(left: .variable("X"), op: .eq, right: .constant(1))]
)

let clause2 = HornClause(
    head: Atom(predicate: "q", terms: [.constant(1)]),
    body: [],
    constraints: []
)

// Unsatisfiable clause (contradictory constraints)
let clause3 = HornClause(
    head: Atom(predicate: "r", terms: [.variable("Y")]),
    body: [],
    constraints: [
        Constraint(left: .variable("Y"), op: .eq, right: .constant(0)),
        Constraint(left: .variable("Y"), op: .eq, right: .constant(1))
    ]
)

let clauses = [clause1, clause2, clause3]

// --- Positive test: goal should be provable ---
let goal1 = Atom(predicate: "p", terms: [.constant(1)])
assert(symbolicExecute(goal: goal1, clauses: clauses) == true, "Goal p(1) must be reachable")

// --- Negative test: different constant, should fail ---
let goal2 = Atom(predicate: "p", terms: [.constant(2)])
assert(symbolicExecute(goal: goal2, clauses: clauses) == false, "Goal p(2) must be unreachable")

// --- Unsatisfiable clause test ---
let goal3 = Atom(predicate: "r", terms: [.constant(0)])
assert(symbolicExecute(goal: goal3, clauses: clauses) == false, "Goal r(0) must be unreachable due to contradictory constraints")

print("All symbolic execution assertions passed.")
