import Foundation

var skip = SkipList<Int>()

// Basic insertion and search
skip.insert(10)
skip.insert(5)
skip.insert(20)
assert(skip.search(10))
assert(skip.search(5))
assert(skip.search(20))
assert(!skip.search(15))

// Verify ordering
let ordered = skip.elementsInOrder()
assert(ordered == [5, 10, 20])

// Insert duplicates and ensure they are present
skip.insert(10)
skip.insert(5)
let orderedDup = skip.elementsInOrder()
assert(orderedDup.filter { $0 == 5 }.count == 2)
assert(orderedDup.filter { $0 == 10 }.count == 2)

// Large random insertion test
var largeSkip = SkipList<Int>()
let count = 1000
var reference = Set<Int>()
for _ in 0..<count {
    let val = Int.random(in: 0..<5000)
    largeSkip.insert(val)
    reference.insert(val)
}
for v in reference {
    assert(largeSkip.search(v))
}
assert(!largeSkip.search(-1))

// Verify max level never exceeds configured limit
var levelCheckSkip = SkipList<Int>(maxLevel: 8)
for i in 0..<200 {
    levelCheckSkip.insert(i)
}
assert(levelCheckSkip.elementsInOrder() == Array(0..<200))

print("All SkipList tests passed.")
