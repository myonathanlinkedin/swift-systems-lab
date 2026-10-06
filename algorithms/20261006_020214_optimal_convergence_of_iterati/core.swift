struct Fact: Hashable {
    let predicate: String
    let arguments: [String]
}

struct Rule: Hashable {
    let head: Fact
    let body: [Fact]
}

struct DatalogEngine {
    private(set) var facts: Set<Fact>
    private var rules: [Rule]
    private var predicateToRules: [String: Set<Int>]

    init() {
        self.facts = Set<Fact>()
        self.rules = [Rule]()
        self.predicateToRules = [String: Set<Int>]()
    }

    mutating func addFact(_ fact: Fact) {
        facts.insert(fact)
    }

    mutating func addRule(_ rule: Rule) {
        let index = rules.count
        rules.append(rule)
        for bodyFact in rule.body {
            predicateToRules[bodyFact.predicate, default: Set<Int>()].insert(index)
        }
    }

    mutating func run() -> Set<Fact> {
        var worklist: [Int] = []
        // Initially, all rules are candidates
        for i in 0..<rules.count {
            worklist.append(i)
        }

        while !worklist.isEmpty {
            let ruleIndex = worklist.removeLast()
            let rule = rules[ruleIndex]
            // Check if all body facts are present
            let satisfied = rule.body.allSatisfy { facts.contains($0) }
            if satisfied {
                // Attempt to insert head fact
                if facts.insert(rule.head).inserted {
                    // New fact added; enqueue dependent rules
                    if let dependents = predicateToRules[rule.head.predicate] {
                        for depIndex in dependents {
                            worklist.append(depIndex)
                        }
                    }
                }
            }
        }
        return facts
    }
}
