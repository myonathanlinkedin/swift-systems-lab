import Foundation

// Instantiate the engine.
var engine = InvertedIndex()

// Add sample documents.
let docId0 = engine.addDocument("Swift is a powerful and intuitive programming language for iOS, macOS, watchOS, and tvOS.")
let docId1 = engine.addDocument("Python is popular for data science, machine learning, and web development.")
let docId2 = engine.addDocument("Rust offers memory safety without a garbage collector, making it ideal for systems programming.")
let docId3 = engine.addDocument("Swift and Rust both emphasize safety, but Swift targets Apple platforms while Rust is system‑level.")
let docId4 = engine.addDocument("JavaScript runs in browsers and powers many web applications.")

// ---- Unit Tests ----

// Test 1: Simple single‑term query.
let results1 = engine.search("swift")
assert(results1.count == 2, "Expected 2 results for term 'swift'")
assert(results1[0].docId == docId0 || results1[0].docId == docId3, "Top result should be a Swift document")
assert(results1[1].docId == docId0 || results1[1].docId == docId3, "Second result should be the other Swift document")
assert(results1[0].docId != results1[1].docId, "Results must be distinct documents")

// Test 2: Multi‑term AND‑like query (documents containing any term, ranked by relevance).
let results2 = engine.search("swift safety")
assert(results2.count == 3, "Expected 3 documents containing 'swift' or 'safety'")
let expectedIds2: Set<Int> = [docId0, docId3, docId2] // docId2 contains 'safety' via description.
assert(Set(results2.map { $0.docId }) == expectedIds2, "Result set mismatch for query 'swift safety'")

// Test 3: Query with a term that does not exist.
let results3 = engine.search("kubernetes")
assert(results3.isEmpty, "Expected empty result set for unknown term")

// Test 4: Empty query string.
let results4 = engine.search("")
assert(results4.isEmpty, "Expected empty result set for empty query")

// Test 5: Verify TF‑IDF ranking – the document containing both terms should rank higher.
let results5 = engine.search("swift rust")
assert(results5.count == 3, "Expected 3 results for 'swift rust'")
assert(results5[0].docId == docId3, "Document containing both 'swift' and 'rust' should be top-ranked")

// Test 6: Ensure document identifiers are stable and unique.
let allDocIds = [docId0, docId1, docId2, docId3, docId4]
let uniqueIds = Set(allDocIds)
assert(uniqueIds.count == allDocIds.count, "Document IDs must be unique")

print("All unit tests passed.")
