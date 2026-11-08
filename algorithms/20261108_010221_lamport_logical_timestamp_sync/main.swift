import Foundation

// Unit test helpers
@inline(__always)
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    assert(a == b, "Assertion failed: \(a) != \(b). \(message)")
}

@inline(__always)
func assertTrue(_ condition: Bool, _ message: String = "") {
    assert(condition, "Assertion failed: condition is false. \(message)")
}

// Test 1: Internal events increase the counter monotonically
func testInternalEvent() {
    var engine = LamportEngine(processId: 1)
    let ts1 = engine.internalEvent()
    assertEqual(ts1.counter, 1, "First internal event should set counter to 1")
    let ts2 = engine.internalEvent()
    assertEqual(ts2.counter, 2, "Second internal event should set counter to 2")
    let ts3 = engine.internalEvent()
    assertEqual(ts3.counter, 3, "Third internal event should set counter to 3")
}

// Test 2: Send and receive update counters correctly
func testSendReceive() {
    var p1 = LamportEngine(processId: 1)
    var p2 = LamportEngine(processId: 2)

    // p1 sends a message
    let msg = p1.sendMessage()               // p1.counter == 1
    assertEqual(p1.counter, 1, "Sender counter after send should be 1")
    assertEqual(msg.timestamp.counter, 1, "Message timestamp should carry counter 1")

    // p2 receives the message
    let recvTs = p2.receive(message: msg)    // p2.counter == max(0,1)+1 = 2
    assertEqual(p2.counter, 2, "Receiver counter after receive should be 2")
    assertEqual(recvTs.counter, 2, "Returned timestamp should have counter 2")
}

// Test 3: Ordering of timestamps respects Lamport rules
func testTimestampOrdering() {
    let tsA = LamportTimestamp(processId: 1, counter: 5)
    let tsB = LamportTimestamp(processId: 2, counter: 5)
    let tsC = LamportTimestamp(processId: 1, counter: 6)

    // Same counter, lower processId is smaller
    assertTrue(tsA < tsB, "tsA should be less than tsB when counters equal and processId smaller")
    assertTrue(!(tsB < tsA), "tsB should not be less than tsA")

    // Higher counter dominates
    assertTrue(tsC > tsA, "Higher counter should make tsC greater than tsA")
    assertTrue(tsC > tsB, "Higher counter should make tsC greater than tsB")
}

// Test 4: Multiple message exchanges preserve causal order
func testCausalChain() {
    var pA = LamportEngine(processId: 10)
    var pB = LamportEngine(processId: 20)
    var pC = LamportEngine(processId: 30)

    // A internal event
    let a1 = pA.internalEvent()               // counter 1
    // A sends to B
    let msgAB = pA.sendMessage()              // counter 2
    // B receives from A
    let b1 = pB.receive(message: msgAB)       // counter 2
    // B sends to C
    let msgBC = pB.sendMessage()              // counter 3
    // C receives from B
    let c1 = pC.receive(message: msgBC)       // counter 3

    // Verify causal ordering: a1 < msgAB.timestamp < b1 < msgBC.timestamp < c1
    assertTrue(a1 < msgAB.timestamp, "a1 should happen before A's send")
    assertTrue(msgAB.timestamp < b1, "A's send should happen before B's receive")
    assertTrue(b1 < msgBC.timestamp, "B's receive should happen before B's send")
    assertTrue(msgBC.timestamp < c1, "B's send should happen before C's receive")
}

// Test 5: Equality semantics
func testEquality() {
    let t1 = LamportTimestamp(processId: 5, counter: 42)
    let t2 = LamportTimestamp(processId: 5, counter: 42)
    let t3 = LamportTimestamp(processId: 6, counter: 42)
    assertTrue(t1 == t2, "Identical timestamps must be equal")
    assertTrue(t1 != t3, "Different processId makes timestamps unequal")
}

// Run all tests
func runAllTests() {
    testInternalEvent()
    testSendReceive()
    testTimestampOrdering()
    testCausalChain()
    testEquality()
    print("All Lamport engine tests passed.")
}

// Entry point
runAllTests()
