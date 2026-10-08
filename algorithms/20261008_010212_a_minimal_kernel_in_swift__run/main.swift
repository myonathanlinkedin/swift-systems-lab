import Foundation

func testProcessEquality() {
    let p1 = Process(pid: 1, priority: 5, code: [.nop, .halt])
    var p2 = Process(pid: 1, priority: 5, code: [.nop, .halt])
    assert(p1 == p2, "Identical processes should be equal")
    p2.priority = 3
    assert(p1 != p2, "Different priority should break equality")
}

func testSchedulerOrdering() {
    var sched = Scheduler()
    let low = Process(pid: 2, priority: 1, code: [.halt])
    let high = Process(pid: 3, priority: 10, code: [.halt])
    sched.add(low)
    sched.add(high)
    let first = sched.next()
    assert(first?.pid == high.pid, "Higher priority process should be dequeued first")
}

func testMemoryOperations() {
    var mem = Memory(size: 4)
    mem[0] = 10
    mem[1] = -5
    assert(mem[0] == 10 && mem[1] == -5, "Memory set/get failed")
    mem[0] += 2
    assert(mem[0] == 12, "Memory increment failed")
}

func testKernelExecution() {
    var kernel = Kernel(memorySize: 8)

    // Process A: increments cell 0 three times then halts
    let codeA: [Instruction] = [
        .inc(0), .inc(0), .inc(0), .halt
    ]

    // Process B: decrements cell 0 once, jumps back to start, then halts after 2 iterations
    let codeB: [Instruction] = [
        .dec(0), .jmp(0), .halt
    ]

    kernel.loadProcess(pid: 1, priority: 5, code: codeA)
    kernel.loadProcess(pid: 2, priority: 3, code: codeB)

    kernel.runUntilIdle()

    // Expected: Process A adds 3, Process B subtracts 2 (runs twice before being pre‑empted)
    assert(kernel.memory[0] == 1, "Final memory cell 0 should be 1")
    // Verify both processes terminated
    // Since we cannot directly inspect internal queues, we rely on runUntilIdle completing without error
}

func testJumpInstruction() {
    var kernel = Kernel(memorySize: 2)
    let code: [Instruction] = [
        .inc(0),          // pc=0 -> mem[0]=1
        .jmp(0),          // pc=1 -> jump back to 0
        .halt             // unreachable
    ]
    kernel.loadProcess(pid: 99, priority: 1, code: code)

    // Run a limited number of steps to avoid infinite loop
    var steps = 0
    while steps < 5 {
        _ = kernel.step()
        steps += 1
    }
    // After 5 steps, mem[0] should be 3 (incremented on steps 0,2,4)
    assert(kernel.memory[0] == 3, "Jump loop should have incremented memory three times")
}

func runAllTests() {
    testProcessEquality()
    testSchedulerOrdering()
    testMemoryOperations()
    testKernelExecution()
    testJumpInstruction()
    print("All tests passed.")
}

runAllTests()
