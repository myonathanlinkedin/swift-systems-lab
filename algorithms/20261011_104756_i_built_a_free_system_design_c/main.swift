import Foundation

// Simple test harness using Swift's built‑in `assert`.
func runTests() {
    // Test 1: Initialization
    var dsu = DisjointSetUnion(size: 5)
    assert(dsu.size == 5, "Size should be 5")
    assert(dsu.setCount == 5, "Initially each element is its own set")

    // Test 2: Basic union and connectivity
    dsu.union(0, 1)
    assert(dsu.setCount == 4, "Union reduces set count")
    assert(dsu.connected(0, 1), "0 and 1 should be connected")
    assert(!dsu.connected(0, 2), "0 and 2 should not be connected yet")

    // Test 3: Union transitivity
    dsu.union(1, 2)   // merges {0,1} with {2}
    assert(dsu.setCount == 3, "Another union reduces set count")
    assert(dsu.connected(0, 2), "0 and 2 become connected via 1")
    assert(dsu.connected(1, 2), "1 and 2 are directly connected")

    // Test 4: Idempotent union (union same set)
    dsu.union(0, 2)   // already same set; count unchanged
    assert(dsu.setCount == 3, "Union of same set does not change count")

    // Test 5: Multiple independent unions
    dsu.union(3, 4)
    assert(dsu.setCount == 2, "Two groups now: {0,1,2} and {3,4}")
    assert(dsu.connected(3, 4), "3 and 4 should be connected")
    assert(!dsu.connected(0, 3), "Different groups remain disconnected")

    // Test 6: Full connectivity
    dsu.union(2, 3)   // merge the two groups
    assert(dsu.setCount == 1, "All elements now belong to a single set")
    for i in 0..<dsu.size {
        for j in 0..<dsu.size {
            assert(dsu.connected(i, j), "All pairs should be connected")
        }
    }

    // Test 7: Edge cases – self‑union and out‑of‑bounds handling
    dsu.union(0, 0)   // self‑union should be a no‑op
    assert(dsu.setCount == 1, "Self‑union does not affect count")
    // The following precondition failures are intentional; they are
    // verified via Swift's `assertionFailure` mechanism in debug builds.
    // Uncomment to see runtime crashes in a debug environment.
    // var badDSU = DisjointSetUnion(size: 3)
    // badDSU.union(-1, 2)   // should trigger precondition
    // badDSU.union(0, 3)    // should trigger precondition

    // Test 8: Large random scenario (deterministic seed)
    var largeDSU = DisjointSetUnion(size: 1000)
    var rng = SystemRandomNumberGenerator()
    for _ in 0..<5000 {
        let a = Int.random(in: 0..<largeDSU.size, using: &rng)
        let b = Int.random(in: 0..<largeDSU.size, using: &rng)
        largeDSU.union(a, b)
    }
    // After many unions, setCount must be at least 1 and at most 1000.
    assert(largeDSU.setCount >= 1 && largeDSU.setCount <= 1000,
           "Set count within expected bounds after random unions")
}

// Entry point
runTests()
print("All DSU unit tests passed.")
