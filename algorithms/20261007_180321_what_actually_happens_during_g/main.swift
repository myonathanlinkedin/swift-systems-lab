import Foundation

var gc = GarbageCollector()

// Helper to assert conditions with messages
func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    assert(condition(), message)
}

// Test 1: Simple linear chain reachable from a root
let a = gc.allocateObject()
let b = gc.allocateObject()
let c = gc.allocateObject()
let d = gc.allocateObject()

gc.addRoot(a)
gc.addReference(from: a, to: b)
gc.addReference(from: b, to: c)
gc.addReference(from: c, to: d)

// Run incremental steps until no gray objects remain
while true {
    let before = gc.heap.objects.values.filter { $0.color == .gray }.count
    gc.incrementalStep()
    let after = gc.heap.objects.values.filter { $0.color == .gray }.count
    if after == 0 { break }
    expect(after <= before, "Gray count should not increase")
}

// All objects should be black (reachable)
expect(gc.objectColor(a) == .black, "A should be black")
expect(gc.objectColor(b) == .black, "B should be black")
expect(gc.objectColor(c) == .black, "C should be black")
expect(gc.objectColor(d) == .black, "D should be black")

// Test 2: Removing root makes objects collectible
gc.removeRoot(a)
gc.collectAll()

expect(!gc.isObjectAlive(a), "A should be collected")
expect(!gc.isObjectAlive(b), "B should be collected")
expect(!gc.isObjectAlive(c), "C should be collected")
expect(!gc.isObjectAlive(d), "D should be collected")

// Test 3: Write barrier promotes white object when black references it
let x = gc.allocateObject()
let y = gc.allocateObject()
let z = gc.allocateObject()

gc.addRoot(x)
gc.addReference(from: x, to: y) // x (black after step) -> y (white)
gc.incrementalStep() // mark y black

// At this point x and y are black, z is white
expect(gc.objectColor(x) == .black, "X should be black")
expect(gc.objectColor(y) == .black, "Y should be black")
expect(gc.objectColor(z) == .white, "Z should be white")

// Write barrier: black y references white z
gc.addReference(from: y, to: z)

// z should have been turned gray by the barrier
expect(gc.objectColor(z) == .gray, "Z should be gray after write barrier")

gc.incrementalStep() // finish marking z
expect(gc.objectColor(z) == .black, "Z should be black after incremental step")
expect(gc.isObjectAlive(z), "Z should be alive")

// Test 4: Cyclic structures without roots are collected
let p = gc.allocateObject()
let q = gc.allocateObject()
gc.addRoot(p)
gc.addReference(from: p, to: q)
gc.addReference(from: q, to: p)

// Process the cycle
while true {
    let grayBefore = gc.heap.objects.values.filter { $0.color == .gray }.count
    gc.incrementalStep()
    let grayAfter = gc.heap.objects.values.filter { $0.color == .gray }.count
    if grayAfter == 0 { break }
    expect(grayAfter <= grayBefore, "Gray count should not increase in cycle")
}
expect(gc.isObjectAlive(p), "P should be alive while rooted")
expect(gc.isObjectAlive(q), "Q should be alive while rooted")

// Remove root and collect
gc.removeRoot(p)
gc.collectAll()
expect(!gc.isObjectAlive(p), "P should be collected after root removal")
expect(!gc.isObjectAlive(q), "Q should be collected after root removal")

print("All garbage collection tests passed.")
