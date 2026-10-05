import Foundation

// Unit Tests
func testCardOrdering() {
    let c1 = Card(rank: .two, suit: .clubs)
    let c2 = Card(rank: .three, suit: .clubs)
    let c3 = Card(rank: .two, suit: .diamonds)
    assert(c1 < c2, "Rank ordering failed")
    assert(c1 < c3, "Suit ordering failed")
    assert(c2 > c3, "Combined ordering failed")
}

func testCombinationCount() {
    let total = nChooseK(52, 5)
    assert(total == 2_598_960, "Combination count mismatch")
}

func testFirstAndLastCombination() {
    let deck = Deck.allCards
    var gen = CombinationGenerator(deck, choose: 5)
    guard let first = gen.next() else { fatalError("No first combo") }
    let expectedFirst = Array(deck[0..<5])
    assert(first == expectedFirst, "First combination incorrect")

    var last: [Card]? = nil
    while let combo = gen.next() {
        last = combo
    }
    guard let lastCombo = last else { fatalError("No last combo") }
    let expectedLast = Array(deck[(deck.count-5)...])
    assert(lastCombo == expectedLast, "Last combination incorrect")
}

func testGeneratorCompleteness() {
    let deck = Deck.allCards
    var count = 0
    for _ in CombinationGenerator(deck, choose: 5) {
        count += 1
    }
    assert(count == nChooseK(52, 5), "Generator did not produce all combos")
}

// Simple benchmark (enumerate without storing)
func benchmarkEnumeration() {
    let deck = Deck.allCards
    var count = 0
    let start = Date()
    for _ in CombinationGenerator(deck, choose: 5) {
        count += 1
    }
    let elapsed = Date().timeIntervalSince(start)
    print("Enumerated \(count) combos in \(String(format: "%.3f", elapsed)) seconds")
}

// Execute tests
testCardOrdering()
testCombinationCount()
testFirstAndLastCombination()
testGeneratorCompleteness()
benchmarkEnumeration()
print("All tests passed.")
