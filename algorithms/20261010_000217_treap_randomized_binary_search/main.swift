import Foundation

// Simple deterministic priority generator for testing
struct DeterministicPriorityGenerator {
    private var index: Int = 0
    private let priorities: [Int]
    
    init(_ priorities: [Int]) {
        self.priorities = priorities
    }
    
    mutating func next() -> Int {
        let p = priorities[index % priorities.count]
        index += 1
        return p
    }
}

// Unit Tests
func testInsertionAndOrder() {
    var treap = Treap<Int>()
    let keys = [5, 3, 8, 1, 4]
    var gen = DeterministicPriorityGenerator([40, 30, 50, 20, 35])
    for k in keys {
        treap.insert(k, priority: gen.next())
    }
    let sorted = treap.toArray()
    assert(sorted == keys.sorted(), "In-order traversal must be sorted")
    for k in keys {
        assert(treap.contains(k), "Treap must contain inserted key \(k)")
    }
}

func testDuplicateInsertion() {
    var treap = Treap<Int>()
    treap.insert(10, priority: 100)
    treap.insert(10, priority: 200) // duplicate, should be ignored
    let arr = treap.toArray()
    assert(arr == [10], "Duplicate keys must not be inserted")
}

func testDeletionLeaf() {
    var treap = Treap<Int>()
    let keys = [2, 1, 3]
    var gen = DeterministicPriorityGenerator([30, 20, 40])
    for k in keys {
        treap.insert(k, priority: gen.next())
    }
    let removed = treap.remove(1)
    assert(removed, "Leaf node removal should return true")
    assert(!treap.contains(1), "Removed key should not be present")
    assert(treap.toArray() == [2, 3], "Remaining keys must be correct")
}

func testDeletionOneChild() {
    var treap = Treap<Int>()
    let keys = [5, 2, 8, 1] // 2 will have left child 1 only
    var gen = DeterministicPriorityGenerator([50, 30, 60, 20])
    for k in keys {
        treap.insert(k, priority: gen.next())
    }
    let removed = treap.remove(2)
    assert(removed, "Node with one child removal should succeed")
    assert(!treap.contains(2), "Removed key absent")
    assert(treap.toArray() == [1,5,8], "Structure after removal is correct")
}

func testDeletionTwoChildren() {
    var treap = Treap<Int>()
    let keys = [10, 5, 15, 2, 7, 12, 20]
    var gen = DeterministicPriorityGenerator([70, 50, 80, 30, 55, 65, 90])
    for k in keys {
        treap.insert(k, priority: gen.next())
    }
    let removed = treap.remove(10)
    assert(removed, "Root with two children removal should succeed")
    assert(!treap.contains(10), "Root key removed")
    assert(treap.toArray() == [2,5,7,12,15,20], "In-order after root removal")
}

func testNonexistentDeletion() {
    var treap = Treap<Int>()
    treap.insert(42, priority: 100)
    let result = treap.remove(99)
    assert(!result, "Removing non‑existent key must return false")
}

// Run all tests
func runAllTests() {
    testInsertionAndOrder()
    testDuplicateInsertion()
    testDeletionLeaf()
    testDeletionOneChild()
    testDeletionTwoChildren()
    testNonexistentDeletion()
    print("All Treap tests passed.")
}

runAllTests()
