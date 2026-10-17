import Foundation

// Simple correctness tests
var sketch = CountMinSketch(width: 100, depth: 5)
sketch.add(item: "apple", count: 3)
sketch.add(item: "banana", count: 1)
sketch.add(item: "apple", count: 2) // total apple = 5

assert(sketch.estimate(item: "apple") >= 5, "Apple count underestimated")
assert(sketch.estimate(item: "banana") >= 1, "Banana count underestimated")
assert(sketch.estimate(item: "cherry") == 0, "Cherry should have zero count")

// Heavy hitters detection test
var heavySketch = CountMinSketch(width: 200, depth: 7)

// Insert heavy items
for _ in 0..<1000 { heavySketch.add(item: "dog") }
for _ in 0..<800 { heavySketch.add(item: "cat") }
for _ in 0..<200 { heavySketch.add(item: "mouse") }

// Insert many low-frequency noise items
for i in 0..<500 {
    heavySketch.add(item: "noise\(i)")
}

// Verify estimates are not underestimates
assert(heavySketch.estimate(item: "dog") >= 1000, "Dog count underestimated")
assert(heavySketch.estimate(item: "cat") >= 800, "Cat count underestimated")
assert(heavySketch.estimate(item: "mouse") >= 200, "Mouse count underestimated")

// Heavy hitters with threshold 500 should include dog and cat, exclude mouse and noise
let hitters = heavySketch.heavyHitters(threshold: 500)
assert(hitters.contains("dog"), "Dog should be a heavy hitter")
assert(hitters.contains("cat"), "Cat should be a heavy hitter")
assert(!hitters.contains("mouse"), "Mouse should not be a heavy hitter")
assert(!hitters.contains(where: { $0.hasPrefix("noise") }), "Noise items should not be heavy hitters")

print("All Count-Min Sketch tests passed.")
