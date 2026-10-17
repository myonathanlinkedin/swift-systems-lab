import Foundation

// Helper to create a vector with a range of integers.
func makeIntVector(_ n: Int) -> CowVector<Int> {
    var v = CowVector<Int>()
    for i in 0..<n {
        v.append(i)
    }
    return v
}

// Unit Tests
func runTests() {
    // Test 1: Basic append and count.
    var v1 = CowVector<Int>()
    assert(v1.count == 0)
    v1.append(10)
    assert(v1.count == 1)
    assert(v1[0] == 10)

    // Test 2: Reserve capacity does not shrink.
    let initialCap = v1.capacity
    v1.reserveCapacity(initialCap + 5)
    assert(v1.capacity >= initialCap + 5)
    assert(v1[0] == 10)

    // Test 3: Copy‑on‑write isolation.
    var original = makeIntVector(5)          // [0,1,2,3,4]
    let copy = original                       // shallow copy
    // Mutate original
    original.append(99)
    assert(original.count == 6)
    assert(original[5] == 99)
    // Ensure copy unchanged
    assert(copy.count == 5)
    for i in 0..<5 { assert(copy[i] == i) }

    // Mutate copy and verify original stays intact.
    var mutableCopy = copy
    mutableCopy[0] = -1
    assert(mutableCopy[0] == -1)
    assert(original[0] == 0) // original unaffected

    // Test 4: Pop operation.
    var popVec = makeIntVector(3) // [0,1,2]
    let popped = popVec.popLast()
    assert(popped == 2)
    assert(popVec.count == 2)
    assert(popVec[0] == 0 && popVec[1] == 1)

    // Test 5: Equality checks.
    let a = makeIntVector(4) // [0,1,2,3]
    var b = makeIntVector(4)
    assert(a == b)
    b.append(5)
    assert(a != b)

    // Test 6: Capacity growth pattern.
    var growVec = CowVector<Int>()
    var previousCap = growVec.capacity
    for i in 0..<100 {
        growVec.append(i)
        if growVec.capacity != previousCap {
            // Capacity should at least double when it changes.
            assert(growVec.capacity >= max(1, previousCap * 2))
            previousCap = growVec.capacity
        }
    }
    assert(growVec.count == 100)

    // Test 7: Reserve larger than needed does not affect count.
    var reserveVec = CowVector<Int>()
    reserveVec.append(1)
    reserveVec.reserveCapacity(50)
    assert(reserveVec.count == 1)
    assert(reserveVec.capacity >= 50)

    // Test 8: Subscript bounds checking (should trigger precondition in debug builds).
    var boundsVec = makeIntVector(3)
    // The following line is intentionally commented out because it would abort execution.
    // let _ = boundsVec[3]

    print("All tests passed.")
}

// Execute tests.
runTests()
