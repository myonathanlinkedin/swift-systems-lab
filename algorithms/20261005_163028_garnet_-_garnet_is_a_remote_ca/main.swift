import Foundation

// Simple assertion helper
func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, _ message: String = "") {
    assert(lhs == rhs, "Assertion failed: \(message) Expected \(rhs), got \(lhs)")
}

// MARK: - Unit Tests
let cache = GarnetCache<String>(capacity: 3)

// Test insertion and retrieval
let keyA = CacheKey("A")
let keyB = CacheKey("B")
let keyC = CacheKey("C")
let keyD = CacheKey("D")

cache.set(keyA, value: "Alpha")
cache.set(keyB, value: "Beta")
cache.set(keyC, value: "Gamma")

// Verify values
if let entryA = cache.get(keyA) {
    assertEqual(entryA.value, "Alpha", "Value for A")
    assertEqual(entryA.version, 0, "Version for A")
}
if let entryB = cache.get(keyB) {
    assertEqual(entryB.value, "Beta", "Value for B")
}
if let entryC = cache.get(keyC) {
    assertEqual(entryC.value, "Gamma", "Value for C")
}

// Update existing key and check version bump
cache.set(keyB, value: "Beta-Updated")
if let entryB2 = cache.get(keyB) {
    assertEqual(entryB2.value, "Beta-Updated", "Updated value for B")
    assertEqual(entryB2.version, 1, "Version increment for B")
}

// Insert fourth key to trigger eviction (capacity = 3)
// LRU order before insertion: A (most recent from earlier get), B (most recent set), C (least recent)
cache.set(keyD, value: "Delta")

// Key C should be evicted
assert(cache.get(keyC) == nil, "Key C should have been evicted")

// Keys A, B, D should be present
assert(cache.get(keyA) != nil, "Key A should be present")
assert(cache.get(keyB) != nil, "Key B should be present")
assert(cache.get(keyD) != nil, "Key D should be present")

// Test removal
cache.remove(keyA)
assert(cache.get(keyA) == nil, "Key A should be removed")

// Test clear
cache.clear()
assert(cache.get(keyB) == nil && cache.get(keyD) == nil, "Cache should be empty after clear")

// MARK: - Concurrency Stress Test
let concurrentCache = GarnetCache<Int>(capacity: 5)
let concurrentQueue = DispatchQueue(label: "com.garnet.test.concurrent", attributes: .concurrent)
let group = DispatchGroup()

for i in 0..<1000 {
    group.enter()
    concurrentQueue.async {
        let key = CacheKey("K\(i % 7)") // limited distinct keys to force contention
        concurrentCache.set(key, value: i)
        _ = concurrentCache.get(key)
        group.leave()
    }
}
group.wait()

// Verify that cache never exceeds capacity
var count = 0
for i in 0..<7 {
    let key = CacheKey("K\(i)")
    if concurrentCache.get(key) != nil {
        count += 1
    }
}
assert(count <= 5, "Cache size should not exceed capacity after concurrent ops")

print("All GarnetCache tests passed.")
