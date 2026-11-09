import Foundation

// Helper to compare two arrays of Equatable elements
func assertEqualArrays<T: Equatable>(_ a: [T], _ b: [T], _ message: String = "") {
    assert(a == b, "Array equality failed. \(message) Expected \(b), got \(a)")
}

// Helper to compare Double with tolerance
func assertApproximatelyEqual(_ a: Double, _ b: Double, tolerance: Double = 1e-9, _ message: String = "") {
    assert(abs(a - b) <= tolerance, "Double approximation failed. \(message) Expected \(b), got \(a)")
}

// Test 1: Empty tree
var emptyTree = Tree<Int>()
assert(emptyTree.size() == 0, "Empty tree size should be 0")
assert(emptyTree.height() == -1, "Empty tree height should be -1")
assert(emptyTree.bfs().isEmpty, "Empty tree BFS should be empty")
assert(emptyTree.dfs().isEmpty, "Empty tree DFS should be empty")
assertApproximatelyEqual(emptyTree.averageBranchingFactor(), 0.0, "Empty tree branching factor")

// Test 2: Single node tree
var singleTree = Tree<String>(rootValue: "root")
assert(singleTree.size() == 1, "Single node tree size")
assert(singleTree.height() == 0, "Single node tree height")
assertEqualArrays(singleTree.bfs(), ["root"], "Single node BFS")
assertEqualArrays(singleTree.dfs(), ["root"], "Single node DFS")
assertApproximatelyEqual(singleTree.averageBranchingFactor(), 0.0, "Single node branching factor")

// Test 3: Complex tree
var complexTree = Tree<Int>(rootValue: 1)
guard let root = complexTree.root else {
    fatalError("Root should exist")
}

// Level 1
let node2 = TreeNode(value: 2)
let node3 = TreeNode(value: 3)
let node4 = TreeNode(value: 4)
root.addChild(node2)
root.addChild(node3)
root.addChild(node4)

// Level 2
let node5 = TreeNode(value: 5)
let node6 = TreeNode(value: 6)
node2.addChild(node5)
node2.addChild(node6)

let node7 = TreeNode(value: 7)
node3.addChild(node7)

// Level 3
let node8 = TreeNode(value: 8)
let node9 = TreeNode(value: 9)
node5.addChild(node8)
node5.addChild(node9)

// Expected properties
assert(complexTree.size() == 9, "Complex tree size")
assert(complexTree.height() == 3, "Complex tree height (edges)")

// BFS order: 1,2,3,4,5,6,7,8,9
assertEqualArrays(complexTree.bfs(), [1,2,3,4,5,6,7,8,9], "Complex tree BFS")

// DFS pre-order: 1,2,5,8,9,6,3,7,4
assertEqualArrays(complexTree.dfs(), [1,2,5,8,9,6,3,7,4], "Complex tree DFS")

// Average branching factor:
// Internal nodes: 1 (root, 3 children), 2 (2 children), 5 (2 children), 3 (1 child)
// Total internal nodes = 4, total children = 3+2+2+1 = 8
// Expected = 8 / 4 = 2.0
assertApproximatelyEqual(complexTree.averageBranchingFactor(), 2.0, "Complex tree branching factor")

// Test removal
node2.removeChild(node6)
assert(complexTree.size() == 8, "Size after removal")
assert(complexTree.height() == 3, "Height unchanged after removal")
assertEqualArrays(complexTree.bfs(), [1,2,3,4,5,7,8,9], "BFS after removal")
assertApproximatelyEqual(complexTree.averageBranchingFactor(), 1.75, "Branching factor after removal") // internal nodes: 1(3),2(1),5(2),3(1) => total children 7 / 4 = 1.75

print("All tests passed.")
