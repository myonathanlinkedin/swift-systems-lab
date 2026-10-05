import Foundation

// MARK: - Unification

func unify(_ t1: Term, _ t2: Term, _ subst: Substitution) -> Substitution? {
    let s1 = t1.substitute(using: subst)
    let s2 = t2.substitute(using: subst)
    
    switch (s1, s2) {
    case let (.constant(c1), .constant(c2)):
        return c1 == c2 ? subst : nil
    case let (.variable(v), term), let (term, .variable(v)):
        // Occurs check omitted for simplicity (no cyclic terms in this domain)
        var newSubst = subst
        newSubst[v] = term
        return newSubst
    case let (.variable(v1), .variable(v2)):
        if v1 == v2 { return subst }
        var newSubst = subst
        newSubst[v1] = .variable(v2)
        return newSubst
    }
}

// Unify two atoms term-by-term
func unifyAtoms(_ a1: Atom, _ a2: Atom, _ subst: Substitution) -> Substitution? {
    guard a1.predicate == a2.predicate,
          a1.terms.count == a2.terms.count else { return nil }
    
    var currentSubst = subst
    for (t1, t2) in zip(a1.terms, a2.terms) {
        guard let s = unify(t1, t2, currentSubst) else { return nil }
        currentSubst = s
    }
    return currentSubst
}

// MARK: - Constraint Evaluation

func evaluate(_ op: Constraint.Op, _ lhs: Int, _ rhs: Int) -> Bool {
    switch op {
    case .eq: return lhs == rhs
    case .ne: return lhs != rhs
    case .lt: return lhs < rhs
    case .le: return lhs <= rhs
    case .gt: return lhs > rhs
    case .ge: return lhs >= rhs
    }
}

// Returns true if the constraint is definitely satisfied under the substitution,
// false if definitely violated, and nil if indeterminate (contains unbound variables).
func checkConstraint(_ c: Constraint, with subst: Substitution) -> Bool? {
    let left = c.left.substitute(using: subst)
    let right = c.right.substitute(using: subst)
    
    switch (left, right) {
    case let (.constant(lc), .constant(rc)):
        return evaluate(c.op, lc, rc)
    default:
        // Indeterminate – we conservatively treat as satisfiable for this simple engine
        return nil
    }
}

// Returns true if all constraints are compatible with the substitution.
func constraintsSatisfied(_ constraints: [Constraint], with subst: Substitution) -> Bool {
    for c in constraints {
        if let result = checkConstraint(c, with: subst) {
            if !result { return false }
        }
    }
    return true
}

// MARK: - Symbolic Execution Engine

/// Attempts to prove `goal` using the supplied Horn clauses.
/// Returns true if a derivation exists within `depthLimit`.
func symbolicExecute(goal: Atom, clauses: [HornClause], depthLimit: Int = 12) -> Bool {
    // Depth‑first search with backtracking
    func dfs(_ current: Atom, _ depth: Int, _ visited: Set<Atom>) -> Bool {
        if depth > depthLimit { return false }
        if visited.contains(current) { return false } // prevent simple loops
        
        var newVisited = visited
        newVisited.insert(current)
        
        for clause in clauses {
            guard let head = clause.head else { continue }
            // Try to unify the clause head with the current atom
            if let subst = unifyAtoms(head, current, [:]) {
                // Verify clause constraints under this substitution
                if !constraintsSatisfied(clause.constraints, with: subst) {
                    continue
                }
                
                // If the body is empty, we have reached a fact
                if clause.body.isEmpty {
                    return true
                }
                
                // Recursively prove each atom in the body
                var allProved = true
                for bodyAtom in clause.body {
                    let instantiated = bodyAtom.substitute(using: subst)
                    if !dfs(instantiated, depth + 1, newVisited) {
                        allProved = false
                        break
                    }
                }
                if allProved { return true }
            }
        }
        return false
    }
    
    return dfs(goal, 0, Set())
}
