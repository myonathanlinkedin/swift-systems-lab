import Foundation

// Sample topology
let edgeNode = ComputeNode(id: 1, type: .edge)
let cloudNode = ComputeNode(id: 2, type: .cloud)

// High‑bandwidth link between edge and cloud
let link = Link(id: 1, fromNode: edgeNode.id, toNode: cloudNode.id, bandwidthMbps: 1000.0, latencyMs: 20.0)

// Tasks with varying compute and data sizes
let taskA = Task(id: 101, computeRequirement: 10, dataSizeMB: 5.0)    // light task
let taskB = Task(id: 102, computeRequirement: 200, dataSizeMB: 50.0) // heavy task
let taskC = Task(id: 103, computeRequirement: 5, dataSizeMB: 0.5)    // tiny task

// Scheduler instance
var scheduler = SplitScheduler(
    tasks: [taskA, taskB, taskC],
    nodes: [edgeNode, cloudNode],
    links: [link]
)

// Execute scheduling
let placementResults = scheduler.run()

// Assertions
assert(placementResults.count == 3, "Expected three placement results")

// Helper to fetch result by task id
func result(for taskId: Int) -> PlacementResult? {
    return placementResults.first { $0.id == taskId }
}

// Task A should prefer edge (low compute, small data)
if let resA = result(for: taskA.id) {
    assert(resA.nodeId == edgeNode.id, "Task A expected on edge node")
}

// Task B has high compute; cloud processing advantage outweighs network cost
if let resB = result(for: taskB.id) {
    assert(resB.nodeId == cloudNode.id, "Task B expected on cloud node")
}

// Task C is trivial; edge should still be chosen due to zero network overhead
if let resC = result(for: taskC.id) {
    assert(resC.nodeId == edgeNode.id, "Task C expected on edge node")
}

// Edge case: empty task list yields empty result
var emptyScheduler = SplitScheduler(tasks: [], nodes: [edgeNode, cloudNode], links: [link])
let emptyResults = emptyScheduler.run()
assert(emptyResults.isEmpty, "Empty task list should produce empty results")

print("All assertions passed. Scheduler behavior verified.")
