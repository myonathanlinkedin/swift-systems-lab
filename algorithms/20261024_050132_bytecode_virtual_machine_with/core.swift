import Foundation

/// Represents the set of bytecode instructions supported by the virtual machine.
/// Each case may carry associated data required for execution.
public enum Opcode {
    case pushInt(Int)      // Push an integer literal onto the stack.
    case add               // Pop two values, push their sum.
    case sub               // Pop two values, push lhs - rhs.
    case mul               // Pop two values, push their product.
    case div               // Pop two values, push lhs / rhs (integer division, traps on divide‑by‑zero).
    case dup               // Duplicate the top stack element.
    case swap              // Swap the two topmost stack elements.
    case pop               // Discard the top stack element.
    case halt              // Stop execution.
}

/// Errors that can be raised during VM execution.
public enum VMError: Error, CustomStringConvertible {
    case stackUnderflow(expected: Int, actual: Int)
    case divisionByZero
    case unknownOpcode

    public var description: String {
        switch self {
        case .stackUnderflow(let expected, let actual):
            return "Stack underflow: expected at least \(expected) values, found \(actual)."
        case .divisionByZero:
            return "Division by zero."
        case .unknownOpcode:
            return "Encountered unknown opcode."
        }
    }
}

/// A simple stack‑based bytecode virtual machine.
/// The VM is deliberately deterministic and side‑effect free apart from returning results.
public struct BytecodeVM {
    // MARK: - Public immutable interface
    public let program: [Opcode]          // Bytecode to execute.
    public private(set) var instructionPointer: Int = 0   // Index of next instruction.
    public private(set) var stack: [Int] = []             // Operand stack.

    // MARK: - Initialization
    public init(program: [Opcode]) {
        self.program = program
    }

    // MARK: - Execution
    /// Executes the loaded program until a `halt` instruction or an error occurs.
    /// - Returns: The final stack state after execution.
    /// - Throws: `VMError` if an illegal operation is performed.
    public mutating func run() throws -> [Int] {
        while try step() {}
        return stack
    }

    // MARK: - Single‑step execution
    /// Executes a single instruction.
    /// - Returns: `true` if execution should continue, `false` if a `halt` was processed.
    /// - Throws: `VMError` on illegal operations.
    private mutating func step() throws -> Bool {
        guard instructionPointer < program.count else {
            // Implicit halt if we run off the end of the program.
            return false
        }

        let opcode = program[instructionPointer]
        instructionPointer += 1   // Advance before execution to simplify jumps (none in this VM).

        switch opcode {
        case .pushInt(let value):
            stack.append(value)
            return true

        case .add:
            try binaryOp { $0 + $1 }
            return true

        case .sub:
            try binaryOp { $0 - $1 }
            return true

        case .mul:
            try binaryOp { $0 * $1 }
            return true

        case .div:
            try binaryOp { lhs, rhs in
                guard rhs != 0 else { throw VMError.divisionByZero }
                return lhs / rhs
            }
            return true

        case .dup:
            guard let top = stack.last else {
                throw VMError.stackUnderflow(expected: 1, actual: stack.count)
            }
            stack.append(top)
            return true

        case .swap:
            guard stack.count >= 2 else {
                throw VMError.stackUnderflow(expected: 2, actual: stack.count)
            }
            let top = stack.removeLast()
            let second = stack.removeLast()
            stack.append(top)
            stack.append(second)
            return true

        case .pop:
            guard !stack.isEmpty else {
                throw VMError.stackUnderflow(expected: 1, actual: 0)
            }
            _ = stack.removeLast()
            return true

        case .halt:
            return false
        }

        // Should never reach here because all cases are covered.
        // The compiler knows this, but we keep the guard for future extensions.
        // swiftlint:disable:next fatal_error_message
        fatalError("Unreachable code in BytecodeVM.step()")
    }

    // MARK: - Helper for binary arithmetic operations
    /// Pops two operands, applies `op`, and pushes the result.
    /// The right‑hand operand is the *top* of the stack.
    private mutating func binaryOp(_ op: (Int, Int) throws -> Int) throws {
        guard stack.count >= 2 else {
            throw VMError.stackUnderflow(expected: 2, actual: stack.count)
        }
        let rhs = stack.removeLast()
        let lhs = stack.removeLast()
        let result = try op(lhs, rhs)
        stack.append(result)
    }
}
