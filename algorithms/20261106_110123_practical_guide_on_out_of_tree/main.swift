import Foundation

// ---------- Unit Tests ----------
var tree = ChronosTree<String>()

// Insert three disjoint intervals
tree.insert(interval: TimeInterval(start: 10, end: 20), value: "A")
tree.insert(interval: TimeInterval(start: 30, end: 40), value: "B")
tree.insert(interval: TimeInterval(start: 50, end: 60), value: "C")

// 1. Queries inside intervals
assert(tree.query(15) == "A", "Query inside interval A failed")
assert(tree.query(35) == "B", "Query inside interval B failed")
assert(tree.query(55) == "C", "Query inside interval C failed")

// 2. Queries before the first interval (nearest is the first)
assert(tree.query(5) == "A", "Out‑of‑tree before first interval failed")

// 3. Queries after the last interval (nearest is the last)
assert(tree.query(70) == "C", "Out‑of‑tree after last interval failed")

// 4. Queries between intervals – tie‑break prefers the left neighbor when distances are equal
assert(tree.query(25) == "A", "Nearest left interval for point 25 failed")
assert(tree.query(45) == "B", "Nearest left interval for point 45 failed")

// 5. Empty tree query returns nil
var emptyTree = ChronosTree<Int>()
assert(emptyTree.query(0) == nil, "Empty tree should return nil")

// 6. Edge case: point exactly on the boundary
assert(tree.query(20) == "A", "Boundary query at end of interval A failed")
assert(tree.query(30) == "B", "Boundary query at start of interval B failed")

// 7. Verify that intervals remain sorted after multiple insertions
let expectedStarts = [10, 30, 50]
for (idx, entry) in tree.intervals.enumerated() {
    assert(entry.interval.start == expectedStarts[idx], "Intervals not sorted correctly at index \(idx)")
}

// All assertions passed
print("All ChronosTree unit tests passed.")
