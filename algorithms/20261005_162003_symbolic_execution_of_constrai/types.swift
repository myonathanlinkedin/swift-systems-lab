import Foundation

// MARK: - Terms

enum Term: Hashable {
    case variable(String)
    case constant(Int)
    
    var description: String {
        switch self {
        case .variable(let name): return name
        case .constant(let value): return "\(value)"
        }
    }
}

// MARK: - Atoms

struct Atom: Hashable {
    let predicate: String
    let terms: [Term]
    
    var description: String {
        let args = terms.map { $0.description }.joined(separator: ", ")
        return "\(predicate)(\(args))"
    }
}

// MARK: - Constraints

struct Constraint: Hashable {
    enum Op: Hashable {
        case eq   // ==
        case ne   // !=
        case lt   // <
        case le   // <=
        case gt   // >
        case ge   // >=
    }
    
    let left: Term
    let op: Op
    let right: Term
}

// MARK: - Horn Clauses

struct HornClause: Hashable {
    // head == nil represents a query/goal clause (no head)
    let head: Atom?
    let body: [Atom]
    let constraints: [Constraint]
}

// MARK: - Substitution

typealias Substitution = [String: Term]

// MARK: - Utility Extensions

extension Term {
    func substitute(using subst: Substitution) -> Term {
        switch self {
        case .variable(let name):
            if let replacement = subst[name] {
                // Recursive substitution in case of chained variables
                return replacement.substitute(using: subst)
            } else {
                return self
            }
        case .constant:
            return self
        }
    }
}

extension Atom {
    func substitute(using subst: Substitution) -> Atom {
        let newTerms = terms.map { $0.substitute(using: subst) }
        return Atom(predicate: predicate, terms: newTerms)
    }
}
