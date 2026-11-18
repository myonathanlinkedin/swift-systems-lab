import Foundation

func testAddAndCount() {
    var store = VectorStore()
    try! store.add(id: "a", vector: [1.0, 2.0])
    try! store.add(id: "b", vector: [3.0, 4.0])
    assert(store.count() == 2, "Count should be 2 after adding two records")
}

func testExactMatchQuery() {
    var store = VectorStore()
    try! store.add(id: "doc1", vector: [0.0, 0.0, 0.0])
    try! store.add(id: "doc2", vector: [1.0, 1.0, 1.0])
    let results = try! store.query(vector: [0.0, 0.0, 0.0], k: 1)
    assert(results.count == 1, "Should return exactly one neighbor")
    assert(results[0].id == "doc1", "Nearest neighbor should be doc1")
    assert(results[0].distance == 0.0, "Distance for exact match must be zero")
}

func testKNearestOrdering() {
    var store = VectorStore()
    try! store.add(id: "p1", vector: [0.0, 0.0])
    try! store.add(id: "p2", vector: [1.0, 0.0])
    try! store.add(id: "p3", vector: [0.0, 1.0])
    try! store.add(id: "p4", vector: [1.0, 1.0])
    let query = [0.5, 0.5]
    let results = try! store.query(vector: query, k: 3)
    assert(results.count == 3, "Should return three neighbors")
    // Expected distances: sqrt(0.5) ≈ 0.7071 for all four points; ordering by id after sort stability
    let expectedIds = ["p1", "p2", "p3"]
    for i in 0..<3 {
        assert(results[i].id == expectedIds[i], "Neighbor order mismatch at index \(i)")
    }
}

func testDimensionMismatchOnAdd() {
    var store = VectorStore()
    try! store.add(id: "first", vector: [1.0, 2.0, 3.0])
    var caught = false
    do {
        try store.add(id: "bad", vector: [1.0, 2.0])
    } catch {
        caught = true
    }
    assert(caught, "Adding vector with mismatched dimension must throw")
}

func testDimensionMismatchOnQuery() {
    var store = VectorStore()
    try! store.add(id: "only", vector: [1.0, 2.0])
    var caught = false
    do {
        _ = try store.query(vector: [1.0, 2.0, 3.0], k: 1)
    } catch {
        caught = true
    }
    assert(caught, "Query with mismatched dimension must throw")
}

func testKGreaterThanCount() {
    var store = VectorStore()
    try! store.add(id: "a", vector: [0.0])
    try! store.add(id: "b", vector: [1.0])
    let results = try! store.query(vector: [0.5], k: 5)
    assert(results.count == 2, "When k > count, should return all records")
}

func runAllTests() {
    testAddAndCount()
    testExactMatchQuery()
    testKNearestOrdering()
    testDimensionMismatchOnAdd()
    testDimensionMismatchOnQuery()
    testKGreaterThanCount()
    print("All tests passed.")
}

runAllTests()
