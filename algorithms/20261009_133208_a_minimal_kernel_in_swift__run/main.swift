import Foundation

// Unit test utilities
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    assert(a == b, message.isEmpty ? "Assertion failed: \(a) != \(b)" : message)
}

func assertTrue(_ condition: Bool, _ message: String = "") {
    assert(condition, message.isEmpty ? "Assertion failed" : message)
}

// Test 1: Round‑Robin scheduling order
func testRoundRobinOrder() {
    var kernel = Kernel()
    let p1 = kernel.createProcess(instructionCount: 2)
    let p2 = kernel.createProcess(instructionCount: 2)
    let p3 = kernel.createProcess(instructionCount: 2)

    var scheduleLog: [Int] = []

    for _ in 0..<6 {
        if let pid = kernel.tick() {
            scheduleLog.append(pid)
        }
    }

    let expected = [p1, p2, p3, p1, p2, p3]
    assertEqual(scheduleLog, expected, "Round‑Robin order mismatch")
    assertTrue(kernel.activePIDs().isEmpty, "All processes should have terminated")
}

// Test 2: Process termination handling
func testProcessTermination() {
    var kernel = Kernel()
    let pid = kernel.createProcess(instructionCount: 1)

    // First tick should run and terminate the process.
    let scheduled = kernel.tick()
    assertEqual(scheduled, pid, "Expected PID \(pid) to be scheduled")
    assertTrue(kernel.processInfo(pid: pid) == nil, "Process should be terminated")
    assertTrue(kernel.activePIDs().isEmpty, "No active processes should remain")
}

// Test 3: Adding processes after some have terminated
func testDynamicProcessAddition() {
    var kernel = Kernel()
    let pA = kernel.createProcess(instructionCount: 1) // will finish quickly
    let pB = kernel.createProcess(instructionCount: 3)

    // Tick 1: pA runs and terminates, pB becomes ready.
    _ = kernel.tick()
    assertTrue(kernel.processInfo(pid: pA) == nil, "pA should be terminated")
    assertTrue(kernel.activePIDs() == [pB], "Only pB should remain")

    // Add a new process after termination.
    let pC = kernel.createProcess(instructionCount: 2)

    // Run remaining ticks and capture order.
    var order: [Int] = []
    for _ in 0..<5 {
        if let pid = kernel.tick() {
            order.append(pid)
        }
    }

    // Expected order: pB, pC, pB, pC, pB (pB has 3 instructions total)
    let expected = [pB, pC, pB, pC, pB]
    assertEqual(order, expected, "Dynamic addition order mismatch")
    assertTrue(kernel.activePIDs().isEmpty, "All processes should have terminated")
}

// Test 4: No processes scenario
func testNoProcessScenario() {
    var kernel = Kernel()
    let result = kernel.tick()
    assertTrue(result == nil, "Tick with no processes should return nil")
}

// Execute tests
func runAllTests() {
    testRoundRobinOrder()
    testProcessTermination()
    testDynamicProcessAddition()
    testNoProcessScenario()
    print("All tests passed.")
}

runAllTests()
