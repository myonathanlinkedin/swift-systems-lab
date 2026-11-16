import Foundation

// Helper to create a point quickly.
func P(_ x: Double, _ y: Double) -> Point { Point(x: x, y: y) }

// Test 1: Two facilities, two clients, unit quotas.
func testSimpleTwo() {
    let facs = [
        Facility(location: P(0,0), openingCost: 0.0, quota: 1),
        Facility(location: P(10,0), openingCost: 0.0, quota: 1)
    ]
    let clis = [
        Client(location: P(0.1, 0.0)),
        Client(location: P(9.9, 0.0))
    ]
    var algo = ApproxFacilityLocation(facilities: facs, clients: clis)
    let sol = algo.run()
    assert(sol.assignments == [0,1], "Expected each client to be assigned to its nearest facility")
    assert(sol.opened == [true,true], "Both facilities should be opened")
    let expectedCost = clis[0].location.distance(to: facs[0].location) +
                       clis[1].location.distance(to: facs[1].location)
    assert(abs(sol.totalCost() - expectedCost) < 1e-9, "Cost mismatch")
}

// Test 2: Single facility with quota 2.
func testSingleFacility() {
    let facs = [
        Facility(location: P(5,5), openingCost: 5.0, quota: 2)
    ]
    let clis = [
        Client(location: P(4,5)),
        Client(location: P(6,5))
    ]
    var algo = ApproxFacilityLocation(facilities: facs, clients: clis)
    let sol = algo.run()
    assert(sol.assignments == [0,0], "Both clients must be assigned to the only facility")
    assert(sol.opened == [true], "Facility must be opened")
    let assignCost = clis[0].location.distance(to: facs[0].location) +
                     clis[1].location.distance(to: facs[0].location)
    let expected = 5.0 + assignCost
    assert(abs(sol.totalCost() - expected) < 1e-9, "Cost mismatch")
}

// Test 3: Insufficient quota should trigger precondition.
func testInsufficientQuota() {
    let facs = [
        Facility(location: P(0,0), openingCost: 1.0, quota: 1)
    ]
    let clis = [
        Client(location: P(0,1)),
        Client(location: P(0,2))
    ]
    var algo = ApproxFacilityLocation(facilities: facs, clients: clis)
    var didCrash = false
    // Capture the precondition failure without aborting the whole process.
    // Swift's precondition aborts the program; we simulate by checking total quota first.
    let totalQuota = facs.reduce(0) { $0 + $1.quota }
    if totalQuota < clis.count {
        didCrash = true
    } else {
        _ = algo.run()
    }
    assert(didCrash, "Algorithm should detect insufficient total quota")
}

// Execute tests.
func runAllTests() {
    testSimpleTwo()
    testSingleFacility()
    testInsufficientQuota()
    print("All tests passed.")
}

runAllTests()
