import Foundation

/// A deterministic, in-memory scheduler that simulates asynchronous task execution.
/// It maintains a priority queue of pending tasks and processes them in a controlled,
/// non-blocking manner, allowing for precise testing of concurrency semantics.
public struct AsyncScheduler {
    private var pendingTasks: [ScheduledTask] = []
    private var completedTasks: [ScheduledTask] = []
    private var isRunning = false
    private var currentTick: Int = 0

    /// Represents a single unit of asynchronous work.
    public struct ScheduledTask: Identifiable, Equatable {
        public let id: UUID
        public let name: String
        public let priority: Int
        public let scheduledAt: Int
        public let duration: Int
        public let closure: () -> Void

        public init(name: String, priority: Int = 0, scheduledAt: Int = 0, duration: Int = 1, closure: @escaping () -> Void) {
            self.id = UUID()
            self.name = name
            self.priority = priority
            self.scheduledAt = scheduledAt
            self.duration = duration
            self.closure = closure
        }

        public static func == (lhs: ScheduledTask, rhs: ScheduledTask) -> Bool {
            return lhs.id == rhs.id
        }
    }

    /// Schedules a new task for execution.
    /// - Parameters:
    ///   - name: A human-readable identifier for the task.
    ///   - priority: Higher values indicate higher priority.
    ///   - scheduledAt: The tick at which the task becomes eligible for execution.
    ///   - duration: The number of ticks the task will occupy the scheduler.
    ///   - closure: The work to be performed.
    public mutating func schedule(name: String, priority: Int = 0, scheduledAt: Int = 0, duration: Int = 1, closure: @escaping () -> Void) {
        let task = ScheduledTask(name: name, priority: priority, scheduledAt: scheduledAt, duration: duration, closure: closure)
        pendingTasks.append(task)
        // Maintain sorted order by priority (descending) and scheduledAt (ascending)
        pendingTasks.sort { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }
            return lhs.scheduledAt < rhs.scheduledAt
        }
    }

    /// Advances the scheduler by one tick, executing any eligible tasks.
    /// - Returns: The number of tasks executed in this tick.
    @discardableResult
    public mutating func tick() -> Int {
        currentTick += 1
        var executedCount = 0

        // Find the highest priority task that is eligible (scheduledAt <= currentTick)
        if let index = pendingTasks.firstIndex(where: { $0.scheduledAt <= currentTick }) {
            let task = pendingTasks.remove(at: index)
            task.closure()
            completedTasks.append(task)
            executedCount += 1
        }

        return executedCount
    }

    /// Runs the scheduler until all tasks are completed.
    /// - Returns: The total number of ticks executed.
    @discardableResult
    public mutating func run() -> Int {
        isRunning = true
        var totalTicks = 0
        while !pendingTasks.isEmpty {
            tick()
            totalTicks += 1
        }
        isRunning = false
        return totalTicks
    }

    /// Returns the list of completed tasks in execution order.
    public var results: [ScheduledTask] {
        return completedTasks
    }

    /// Returns the current state of the scheduler.
    public var state: (pending: Int, completed: Int, tick: Int) {
        return (pendingTasks.count, completedTasks.count, currentTick)
    }
}
