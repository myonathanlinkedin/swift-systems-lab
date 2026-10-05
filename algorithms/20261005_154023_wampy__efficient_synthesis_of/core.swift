import Foundation

// MARK: - Prolog Term Representation

enum Term: Equatable, CustomStringConvertible {
    case variable(String)
    case atom(String)
    case number(Int)
    case compound(name: String, args: [Term])
    
    var description: String {
        switch self {
        case .variable(let v): return v
        case .atom(let a): return a
        case .number(let n): return "\(n)"
        case .compound(let name, let args):
            let argsDesc = args.map { $0.description }.joined(separator: ", ")
            return "\(name)(\(argsDesc))"
        }
    }
    
    var isVariable: Bool {
        if case .variable = self { return true }
        return false
    }
    
    var name: String? {
        switch self {
        case .atom(let a): return a
        case .compound(let n, _): return n
        default: return nil
        }
    }
}

// MARK: - Clause

struct Clause: CustomStringConvertible {
    let head: Term
    let body: [Term]   // empty body means a fact
    
    var description: String {
        if body.isEmpty {
            return "\(head)."
        } else {
            let goals = body.map { $0.description }.joined(separator: ", ")
            return "\(head) :- \(goals)."
        }
    }
}

// MARK: - Knowledge Base

final class KnowledgeBase {
    private var clauses: [Clause] = []
    
    func add(_ clause: Clause) {
        clauses.append(clause)
    }
    
    func clauses(for predicate: String) -> [Clause] {
        return clauses.filter {
            switch $0.head {
            case .atom(let name), .compound(let name, _):
                return name == predicate
            default:
                return false
            }
        }
    }
}

// MARK: - Substitution

typealias Substitution = [String: Term]

func apply(_ term: Term, _ subst: Substitution) -> Term {
    switch term {
    case .variable(let v):
        if let t = subst[v] {
            return apply(t, subst)
        } else {
            return term
        }
    case .compound(let name, let args):
        return .compound(name: name, args: args.map { apply($0, subst) })
    default:
        return term
    }
}

// MARK: - Unification

func unify(_ t1: Term, _ t2: Term, _ env: inout Substitution) -> Bool {
    let a = apply(t1, env)
    let b = apply(t2, env)
    
    switch (a, b) {
    case (.variable(let v), let term), (let term, .variable(let v)):
        if occursCheck(v, term, env) { return false }
        env[v] = term
        return true
    case (.atom(let a1), .atom(let a2)):
        return a1 == a2
    case (.number(let n1), .number(let n2)):
        return n1 == n2
    case (.compound(let n1, let args1), .compound(let n2, let args2)):
        guard n1 == n2 && args1.count == args2.count else { return false }
        for (x, y) in zip(args1, args2) {
            if !unify(x, y, &env) { return false }
        }
        return true
    default:
        return false
    }
}

func occursCheck(_ varName: String, _ term: Term, _ env: Substitution) -> Bool {
    let t = apply(term, env)
    switch t {
    case .variable(let v):
        return v == varName
    case .compound(_, let args):
        return args.contains { occursCheck(varName, $0, env) }
    default:
        return false
    }
}

// MARK: - Variable Renaming

func rename(_ term: Term, _ counter: inout Int, _ mapping: inout [String: String]) -> Term {
    switch term {
    case .variable(let v):
        if let existing = mapping[v] {
            return .variable(existing)
        } else {
            let fresh = "V\(counter)"
            counter += 1
            mapping[v] = fresh
            return .variable(fresh)
        }
    case .compound(let name, let args):
        let newArgs = args.map { rename($0, &counter, &mapping) }
        return .compound(name: name, args: newArgs)
    default:
        return term
    }
}

// MARK: - Solver

final class Solver {
    private let kb: KnowledgeBase
    private var varCounter: Int = 0
    
    init(kb: KnowledgeBase) {
        self.kb = kb
    }
    
    func solve(goal: Term, maxDepth: Int = 64) -> [Substitution] {
        var results: [Substitution] = []
        var env: Substitution = [:]
        solveRecursive(goals: [goal], env: &env, depth: 0, maxDepth: maxDepth, results: &results)
        return results
    }
    
    private func solveRecursive(goals: [Term], env: inout Substitution, depth: Int, maxDepth: Int, results: inout [Substitution]) {
        guard depth <= maxDepth else { return }
        if goals.isEmpty {
            results.append(env)
            return
        }
        var remaining = goals
        let current = remaining.removeFirst()
        guard let predName = current.name else { return }
        let candidateClauses = kb.clauses(for: predName)
        for clause in candidateClauses {
            var localEnv = env
            var counter = varCounter
            var varMap: [String: String] = [:]
            let renamedHead = rename(clause.head, &counter, &varMap)
            let renamedBody = clause.body.map { rename($0, &counter, &varMap) }
            varCounter = counter
            if unify(current, renamedHead, &localEnv) {
                let newGoals = renamedBody + remaining
                solveRecursive(goals: newGoals, env: &localEnv, depth: depth + 1, maxDepth: maxDepth, results: &results)
            }
        }
    }
}

// MARK: - Simple Synthesis (Placeholder)

func synthesize(goal: Term, kb: KnowledgeBase, maxDepth: Int = 3) -> Clause? {
    // Very naive synthesis: if a fact exists that unifies with the goal, return it as a clause.
    let predName = goal.name ?? ""
    for clause in kb.clauses(for: predName) where clause.body.isEmpty {
        var env: Substitution = [:]
        if unify(goal, clause.head, &env) {
            // Return a clause identical to the fact (could be refined)
            return Clause(head: goal, body: [])
        }
    }
    // Attempt one-step composition: goal :- subgoal1, subgoal2 where subgoals are existing facts.
    // This placeholder does not implement full synthesis due to complexity constraints.
    return nil
}
