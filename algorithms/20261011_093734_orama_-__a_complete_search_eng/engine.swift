import Foundation

/// In‑memory inverted index implementing a simple TF‑IDF based search engine.
public struct InvertedIndex: SearchEngine {
    // Mapping from document identifier to its raw text.
    public var documents: [Int: String] = [:]

    // Inverted index: term → (docId → term frequency)
    public var index: [String: [Int: Int]] = [:]

    // Counter for generating unique document identifiers.
    var nextDocId: Int = 0

    public init() {}

    // MARK: - SearchEngine conformance

    public mutating func addDocument(_ text: String) -> Int {
        let docId = nextDocId
        nextDocId += 1
        documents[docId] = text

        let terms = Self.tokenize(text)
        var termCounts: [String: Int] = [:]
        for term in terms {
            termCounts[term, default: 0] += 1
        }

        for (term, count) in termCounts {
            var postings = index[term] ?? [:]
            postings[docId] = count
            index[term] = postings
        }

        return docId
    }

    public func search(_ query: String) -> [SearchResult] {
        let queryTerms = Self.tokenize(query)
        guard !queryTerms.isEmpty else { return [] }

        // Document → accumulated TF‑IDF score.
        var scores: [Int: Double] = [:]
        let totalDocs = Double(documents.count)

        for term in queryTerms {
            guard let postings = index[term] else { continue }
            let docFreq = Double(postings.count)
            // Guard against division by zero; skip term if it never appears.
            guard docFreq > 0 else { continue }
            let idf = log(totalDocs / docFreq)

            for (docId, tf) in postings {
                let tfWeight = Double(tf)
                let contribution = tfWeight * idf
                scores[docId, default: 0.0] += contribution
            }
        }

        // Transform to SearchResult array and sort descending by score.
        var results: [SearchResult] = []
        for (docId, score) in scores {
            results.append(SearchResult(docId: docId, score: score))
        }

        // Higher scores first.
        results.sort(by: >)
        return results
    }

    // MARK: - Helper utilities

    /// Simple tokenizer: lower‑cases the input and splits on non‑alphanumeric characters.
    private static func tokenize(_ text: String) -> [String] {
        let lowercased = text.lowercased()
        let separators = CharacterSet.alphanumerics.inverted
        let rawTokens = lowercased.components(separatedBy: separators)
        // Filter out empty strings resulting from consecutive separators.
        let tokens = rawTokens.filter { !$0.isEmpty }
        return tokens
    }
}
