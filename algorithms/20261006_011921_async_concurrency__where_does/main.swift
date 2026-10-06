import Foundation

func testSchedulerBasicFunctionality() {
    var scheduler = AsyncScheduler()
    var executionOrder: [String] = []

    scheduler.schedule(name: "Task A", priority: 1, scheduledAt: 0, duration: 1) {
        executionOrder.append("A")
    }
    scheduler.schedule(name: "Task B", priority: 2, scheduledAt: 0, duration: 1) {
        executionOrder.append("B")
    }
    scheduler.schedule(name: "Task C", priority: 1, scheduledAt: 0, duration: 1) {
        executionOrder.append("C")
    }

    let ticks = scheduler.run()

    assert(ticks == 3, "Expected 3 ticks, got \(ticks)")
    assert(executionOrder == ["B", "A", "C"], "Expected [B, A, C], got \(executionOrder)")
    assert(scheduler.results.count == 3, "Expected 3 completed tasks")
    print("✓ testSchedulerBasicFunctionality passed")
}

func testSchedulerPriorityOrdering() {
    var scheduler = AsyncScheduler()
    var executionOrder: [String] = []

    // All scheduled at tick 0, different priorities
    scheduler.schedule(name: "Low", priority: 1, scheduledAt: 0) { executionOrder.append("Low") }
    scheduler.schedule(name: "High", priority: 10, scheduledAt: 0) { executionOrder.append("High") }
    scheduler.schedule(name: "Medium", priority: 5, scheduledAt: 0) { executionOrder.append("Medium") }

    scheduler.run()

    assert(executionOrder == ["High", "Medium", "Low"], "Priority ordering failed: \(executionOrder)")
    print("✓ testSchedulerPriorityOrdering passed")
}

func testSchedulerDelayedTasks() {
    var scheduler = AsyncScheduler()
    var executionOrder: [String] = []

    // Task A at tick 0, Task B at tick 2
    scheduler.schedule(name: "Immediate", priority: 1, scheduledAt: 0) { executionOrder.append("Immediate") }
    scheduler.schedule(name: "Delayed", priority: 10, scheduledAt: 2) { executionOrder.append("Delayed") }

    // Tick 1: Only Immediate is eligible
    scheduler.tick()
    assert(executionOrder == ["Immediate"], "Immediate should execute at tick 1")

    // Tick 2: Delayed becomes eligible
    scheduler.tick()
    assert(executionOrder == ["Immediate", "Delayed"], "Delayed should execute at tick 2")

    print("✓ testSchedulerDelayedTasks passed")
}

func testSchedulerEmptyState() {
    var scheduler = AsyncScheduler()
    let ticks = scheduler.run()
    assert(ticks == 0, "Empty scheduler should run 0 ticks")
    assert(scheduler.results.isEmpty, "No tasks should be completed")
    print("✓ testSchedulerEmptyState passed")
}

func testSchedulerStateTracking() {
    var scheduler = AsyncScheduler()

    scheduler.schedule(name: "T1", priority: 1, scheduledAt: 0) { }
    scheduler.schedule(name: "T2", priority: 2, scheduledAt: 0) { }

    let initialState = scheduler.state
    assert(initialState.pending == 2, "Expected 2 pending tasks")
    assert(initialState.completed == 0, "Expected 0 completed tasks")
    assert(initialState.tick == 0, "Expected tick 0")

    scheduler.tick()
    let midState = scheduler.state
    assert(midState.pending == 1, "Expected 1 pending task after 1 tick")
    assert(midState.completed == 1, "Expected 1 completed task after 1 tick")
    assert(midState.tick == 1, "Expected tick 1")

    scheduler.run()
    let finalState = scheduler.state
    assert(finalState.pending == 0, "Expected 0 pending tasks after run")
    assert(finalState.completed == 2, "Expected 2 completed tasks after run")
    print("✓ testSchedulerStateTracking passed")
}

func testSchedulerTaskEquality() {
    var scheduler = AsyncScheduler()
    scheduler.schedule(name: "Test", priority: 1, scheduledAt: 0) { }

    let results = scheduler.results
    assert(results.isEmpty, "No tasks should be completed yet")

    scheduler.run()
    let completed = scheduler.results
    assert(completed.count == 1, "Expected 1 completed task")
    assert(completed[0].name == "Test", "Task name should be 'Test'")
    print("✓ testSchedulerTaskEquality passed")
}

func testSchedulerComplexScenario() {
    var scheduler = AsyncScheduler()
    var executionLog: [String] = []

    // Simulate a realistic workload
    scheduler.schedule(name: "Init", priority: 10, scheduledAt: 0) { executionLog.append("Init") }
    scheduler.schedule(name: "Load Data", priority: 5, scheduledAt: 1) { executionLog.append("Load Data") }
    scheduler.schedule(name: "Process", priority: 3, scheduledAt: 2) { executionLog.append("Process") }
    scheduler.schedule(name: "Cleanup", priority: 1, scheduledAt: 3) { executionLog.append("Cleanup") }

    let ticks = scheduler.run()

    assert(ticks == 4, "Expected 4 ticks for sequential delayed tasks")
    assert(executionLog == ["Init", "Load Data", "Process", "Cleanup"], "Execution order incorrect: \(executionLog)")
    print("✓ testSchedulerComplexScenario passed")
}

func testSchedulerConcurrentEligibleTasks() {
    var scheduler = AsyncScheduler()
    var executionOrder: [String] = []

    // Multiple tasks eligible at the same tick, ordered by priority
    scheduler.schedule(name: "P1", priority: 1, scheduledAt: 0) { executionOrder.append("P1") }
    scheduler.schedule(name: "P3", priority: 3, scheduledAt: 0) { executionOrder.append("P3") }
    scheduler.schedule(name: "P2", priority: 2, scheduledAt: 0) { executionOrder.append("P2") }

    scheduler.run()

    assert(executionOrder == ["P3", "P2", "P1"], "Concurrent eligible tasks should follow priority: \(executionOrder)")
    print("✓ testSchedulerConcurrentEligibleTasks passed")
}

func runAllTests() {
    print("Running AsyncScheduler test suite...")
    testSchedulerBasicFunctionality()
    testSchedulerPriorityOrdering()
    testSchedulerDelayedTasks()
    testSchedulerEmptyState()
    testSchedulerStateTracking()
    testSchedulerTaskEquality()
    testSchedulerComplexScenario()
    testSchedulerConcurrentEligibleTasks()
    print("All tests passed successfully.")
}

// Entry point
runAllTests()
