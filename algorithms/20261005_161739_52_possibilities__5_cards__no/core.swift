import Foundation

public enum Suit: Int, CaseIterable, Comparable {
    case clubs = 0, diamonds, hearts, spades

    public static func < (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public enum Rank: Int, CaseIterable, Comparable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen, king, ace

    public static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public var symbol: String {
        switch self {
        case .two:   return "2"
        case .three: return "3"
        case .four:  return "4"
        case .five:  return "5"
        case .six:   return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine:  return "9"
        case .ten:   return "10"
        case .jack:  return "J"
        case .queen: return "Q"
        case .king:  return "K"
        case .ace:   return "A"
        }
    }
}

public struct Card: Comparable, Hashable {
    public let rank: Rank
    public let suit: Suit

    public init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }

    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }

    public static func < (lhs: Card, rhs: Card) -> Bool {
        if lhs.suit != rhs.suit {
            return lhs.suit < rhs.suit
        }
        return lhs.rank < rhs.rank
    }

    public var description: String {
        return "\(rank.symbol)\(suitSymbol)"
    }

    private var suitSymbol: String {
        switch suit {
        case .clubs:    return "♣︎"
        case .diamonds: return "♦︎"
        case .hearts:   return "♥︎"
        case .spades:   return "♠︎"
        }
    }
}

public struct Deck {
    public static let allCards: [Card] = {
        var cards = [Card]()
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        return cards
    }()
}

public struct CombinationGenerator<Element>: Sequence, IteratorProtocol where Element: Comparable {
    private let elements: [Element]
    private let k: Int
    private var indices: [Int]?
    private var firstCall = true

    public init(_ elements: [Element], choose k: Int) {
        precondition(k > 0 && k <= elements.count, "Invalid combination size")
        self.elements = elements.sorted()
        self.k = k
        self.indices = nil
    }

    public mutating func next() -> [Element]? {
        if firstCall {
            firstCall = false
            indices = Array(0..<k)
            return currentCombination()
        }

        guard var idx = indices else { return nil }

        var i = k - 1
        while i >= 0 {
            if idx[i] != i + elements.count - k {
                break
            }
            i -= 1
        }
        if i < 0 { return nil }

        idx[i] += 1
        for j in (i+1)..<k {
            idx[j] = idx[j-1] + 1
        }
        indices = idx
        return currentCombination()
    }

    private func currentCombination() -> [Element]? {
        guard let idx = indices else { return nil }
        return idx.map { elements[$0] }
    }

    public func makeIterator() -> CombinationGenerator<Element> {
        var copy = self
        copy.firstCall = true
        copy.indices = nil
        return copy
    }
}

public func nChooseK(_ n: Int, _ k: Int) -> Int {
    precondition(k >= 0 && n >= k, "Invalid parameters")
    if k == 0 || k == n { return 1 }
    var result = 1
    let k = min(k, n - k)
    for i in 1...k {
        result = result * (n - k + i) / i
    }
    return result
}
