import Foundation

public enum Instruction {
    case nop
    case inc(Int)          // increment memory at address
    case dec(Int)          // decrement memory at address
    case jmp(Int)          // jump to instruction index
    case halt
}

public struct Process: Comparable {
    public let pid: Int
    public var priority: Int
    public var pc: Int = 0
    public var code: [Instruction]
    public var terminated: Bool = false

    public init(pid: Int, priority: Int, code: [Instruction]) {
        self.pid = pid
        self.priority = priority
        self.code = code
    }

    public static func < (lhs: Process, rhs: Process) -> Bool {
        // Higher priority value means higher precedence
        return lhs.priority < rhs.priority
    }

    public static func == (lhs: Process, rhs: Process) -> Bool {
        return lhs.pid == rhs.pid &&
               lhs.priority == rhs.priority &&
               lhs.pc == rhs.pc &&
               lhs.terminated == rhs.terminated &&
               lhs.code.elementsEqual(rhs.code, by: { $0 == $1 })
    }
}

extension Instruction: Equatable {
    public static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        switch (lhs, rhs) {
        case (.nop, .nop): return true
        case let (.inc(a), .inc(b)) where a == b: return true
        case let (.dec(a), .dec(b)) where a == b: return true
        case let (.jmp(a), .jmp(b)) where a == b: return true
        case (.halt, .halt): return true
        default: return false
        }
    }
}

public struct Memory {
    public var cells: [Int]

    public init(size: Int) {
        self.cells = Array(repeating: 0, count: size)
    }

    public subscript(address: Int) -> Int {
        get {
            precondition(address >= 0 && address < cells.count, "Memory access out of bounds")
            return cells[address]
        }
        set {
            precondition(address >= 0 && address < cells.count, "Memory access out of bounds")
            cells[address] = newValue
        }
    }
}

public struct Scheduler {
    public var readyQueue: [Process] = []

    public mutating func add(_ process: Process) {
        readyQueue.append(process)
        readyQueue.sort(by: >) // highest priority first
    }

    public mutating func next() -> Process? {
        guard !readyQueue.isEmpty else { return nil }
        return readyQueue.removeFirst()
    }

    public mutating func requeue(_ process: Process) {
        guard !process.terminated else { return }
        readyQueue.append(process)
        readyQueue.sort(by: >)
    }
}

public struct Kernel {
    public var memory: Memory
    public var scheduler: Scheduler = Scheduler()
    var current: Process?

    public init(memorySize: Int) {
        self.memory = Memory(size: memorySize)
    }

    public mutating func loadProcess(pid: Int, priority: Int, code: [Instruction]) {
        var proc = Process(pid: pid, priority: priority, code: code)
        scheduler.add(proc)
    }

    public mutating func step() -> Bool {
        // Load next process if none active
        if current == nil {
            current = scheduler.next()
        }
        guard var proc = current else { return false } // no work left

        guard proc.pc < proc.code.count else {
            proc.terminated = true
            current = nil
            return true
        }

        let instr = proc.code[proc.pc]
        var advance = true

        switch instr {
        case .nop:
            break
        case .inc(let addr):
            memory[addr] = memory[addr] + 1
        case .dec(let addr):
            memory[addr] = memory[addr] - 1
        case .jmp(let target):
            proc.pc = target
            advance = false
        case .halt:
            proc.terminated = true
            advance = false
        }

        if advance {
            proc.pc += 1
        }

        // Update current process state
        if proc.terminated {
            current = nil
        } else {
            current = proc
        }

        // If we just finished a time slice, requeue (simple round‑robin)
        if let active = current, !active.terminated {
            scheduler.requeue(active)
            current = nil
        }

        return true
    }

    public mutating func runUntilIdle() {
        while step() { }
    }
}
