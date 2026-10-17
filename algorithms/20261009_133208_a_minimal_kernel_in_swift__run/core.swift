import Foundation

public enum ProcessState {
    case ready
    case running
    case terminated
}

public struct Process {
    public let pid: Int
    public var remainingInstructions: Int
    public var state: ProcessState

    public init(pid: Int, instructionCount: Int) {
        self.pid = pid
        self.remainingInstructions = instructionCount
        self.state = .ready
    }
}

public protocol Scheduler {
    mutating func add(_ pid: Int)
    mutating func remove(_ pid: Int)
    mutating func next() -> Int?
}

public struct RoundRobinScheduler: Scheduler {
    var queue: [Int] = []

    public init() {}

    public mutating func add(_ pid: Int) {
        // Avoid duplicate entries
        if !queue.contains(pid) {
            queue.append(pid)
        }
    }

    public mutating func remove(_ pid: Int) {
        queue.removeAll { $0 == pid }
    }

    public mutating func next() -> Int? {
        guard !queue.isEmpty else { return nil }
        // Dequeue the first pid and enqueue it back (rotation)
        let pid = queue.removeFirst()
        queue.append(pid)
        return pid
    }
}

public struct Kernel {
    var scheduler: RoundRobinScheduler = RoundRobinScheduler()
    var processes: [Int: Process] = [:]
    var nextPID: Int = 1

    public init() {}

    // Create a new process with a given instruction budget.
    // Returns the assigned PID.
    public mutating func createProcess(instructionCount: Int) -> Int {
        precondition(instructionCount > 0, "Instruction count must be positive")
        let pid = nextPID
        nextPID += 1
        var proc = Process(pid: pid, instructionCount: instructionCount)
        proc.state = .ready
        processes[pid] = proc
        scheduler.add(pid)
        return pid
    }

    // Simulate a single timer tick.
    // Returns the PID that was scheduled this tick, or nil if no process is runnable.
    @discardableResult
    public mutating func tick() -> Int? {
        guard let pid = scheduler.next() else {
            // No ready processes.
            return nil
        }

        // Fetch mutable copy.
        guard var proc = processes[pid] else {
            // Process might have been terminated in a previous tick.
            scheduler.remove(pid)
            return nil
        }

        // Simulate execution of one instruction.
        proc.state = .running
        proc.remainingInstructions -= 1

        if proc.remainingInstructions <= 0 {
            // Process has finished execution.
            proc.state = .terminated
            processes.removeValue(forKey: pid)
            scheduler.remove(pid)
        } else {
            // Still has work to do; mark as ready for next round.
            proc.state = .ready
            processes[pid] = proc
        }

        return pid
    }

    // Query the current set of active PIDs.
    public func activePIDs() -> [Int] {
        return Array(processes.keys).sorted()
    }

    // Retrieve a snapshot of a process (if it exists).
    public func processInfo(pid: Int) -> Process? {
        return processes[pid]
    }
}
