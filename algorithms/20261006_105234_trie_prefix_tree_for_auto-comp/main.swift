import Foundation

var trie = Trie()

// Insert words with explicit frequencies
trie.insert(word: "apple", frequency: 5)
trie.insert(word: "app", frequency: 3)
trie.insert(word: "application", frequency: 2)
trie.insert(word: "ape", frequency: 4)
trie.insert(word: "banana", frequency: 6)
trie.insert(word: "band", frequency: 2)
trie.insert(word: "bandana", frequency: 1)

// Basic prefix tests
assert(trie.suggestions(prefix: "app", limit: 3) == ["apple", "app", "application"], "Failed: app prefix")
assert(trie.suggestions(prefix: "ba", limit: 2) == ["banana", "band"], "Failed: ba prefix")
assert(trie.suggestions(prefix: "a", limit: 5) == ["apple", "ape", "app", "application"], "Failed: a prefix")
assert(trie.suggestions(prefix: "cat", limit: 3).isEmpty, "Failed: non‑existent prefix")
assert(trie.suggestions(prefix: "", limit: 3) == ["banana", "apple", "ape"], "Failed: empty prefix top‑3")

// Frequency update test
trie.insert(word: "app", frequency: 2) // app frequency becomes 5 (3 + 2)
assert(trie.suggestions(prefix: "app", limit: 3) == ["app", "apple", "application"], "Failed: frequency update tie‑break")

print("All Trie auto‑completion tests passed.")
