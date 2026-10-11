import Foundation

/// Represents a document stored in the search engine.
public struct Document {
    public let id: Int
    public let text: String

    public init(id: Int, text: String) {
        self.id = id
        self.text = text
    }
}

/// Posting information for a term within a specific document.
public struct Posting {
    public let docId: Int
    public var termFrequency: Int

    public init(docId: Int, termFrequency: Int) {
        self.docId = docId
        self.termFrequency = termFrequency
    }
}

/// Search result returned by the engine, sortable by relevance score.
public struct SearchResult: Comparable {
    public let docId: Int
    public let score: Double

    public init(docId: Int, score: Double) {
        self.docId = docId
        self.score = score
    }

    // Comparable conformance – higher score is considered greater.
    public static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.score < rhs.score
    }

    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.docId == rhs.docId && lhs.score == rhs.score
    }
}

/// Protocol defining the minimal search engine capabilities.
public protocol SearchEngine {
    /// Adds a document to the collection and returns its assigned identifier.
    mutating func addDocument(_ text: String) -> Int

    /// Executes a query and returns a list of ranked results.
    func search(_ query: String) -> [SearchResult]
}
