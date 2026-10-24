import Foundation

// Helper to run a program and compare the resulting stack with an expected value.
func assertVM(program: [Opcode], expectedStack: [Int], file: StaticString = #file, line: UInt = #line) {
    var vm = BytecodeVM(program: program)
    do {
        let finalStack = try vm.run()
        assert(finalStack == expectedStack, "VM stack mismatch. Expected \(expectedStack), got \(finalStack)", file: file, line: line)
    } catch {
        assertionFailure("VM threw unexpected error: \(error)", file: file, line: line)
    }
}

// MARK: - Unit Tests

// Test 1: Simple push and halt.
assertVM(
    program: [.pushInt(42), .halt],
    expectedStack: [42]
)

// Test 2: Basic arithmetic ( (3 + 4) * 5 )
assertVM(
    program: [
        .pushInt(3),
        .pushInt(4),
        .add,          // stack: [7]
        .pushInt(5),
        .mul,          // stack: [35]
        .halt
    ],
    expectedStack: [35]
)

// Test 3: Subtraction and division with duplicate and swap.
assertVM(
    program: [
        .pushInt(10),
        .pushInt(2),
        .dup,          // stack: [10,2,2]
        .swap,         // stack: [10,2,2] (no visible change, but tests swap)
        .sub,          // 2 - 2 = 0, stack: [10,0]
        .pushInt(5),
        .add,          // 0 + 5 = 5, stack: [10,5]
        .div,          // 10 / 5 = 2, stack: [2]
        .halt
    ],
    expectedStack: [2]
)

// Test 4: Pop discards top value.
assertVM(
    program: [
        .pushInt(1),
        .pushInt(2),
        .pushInt(3),
        .pop,          // removes 3
        .halt
    ],
    expectedStack: [1, 2]
)

// Test 5: Stack underflow detection (should trigger assertion failure).
func testUnderflow() {
    var vm = BytecodeVM(program: [.add, .halt])
    do {
        _ = try vm.run()
        assertionFailure("Expected stack underflow error not thrown")
    } catch VMError.stackUnderflow(let expected, let actual) {
        assert(expected == 2 && actual == 0, "Unexpected underflow details")
    } catch {
        assertionFailure("Unexpected error type: \(error)")
    }
}
testUnderflow()

// Test 6: Division by zero detection.
func testDivByZero() {
    var vm = BytecodeVM(program: [.pushInt(10), .pushInt(0), .div, .halt])
    do {
        _ = try vm.run()
        assertionFailure("Expected division by zero error not thrown")
    } catch VMError.divisionByZero {
        // Expected path.
    } catch {
        assertionFailure("Unexpected error type: \(error)")
    }
}
testDivByZero()

// MARK: - Benchmark (very lightweight)
func benchmark() {
    // Compute factorial of 10 using repeated multiplication.
    var program: [Opcode] = [.pushInt(1)] // accumulator
    for i in 2...10 {
        program.append(.pushInt(i))
        program.append(.mul)
    }
    program.append(.halt)

    var vm = BytecodeVM(program: program)
    let start = Date()
    do {
        let result = try vm.run()
        var _instance_elapsed = Date()
        let elapsed = _instance_elapsed.timeIntervalSince(start)
        assert(result == [3628800], "Factorial computation failed")
        print("Benchmark: factorial(10) = \(result[0]) computed in \(elapsed * 1_000_000) µs")
    } catch {
        assertionFailure("Benchmark VM error: \(error)")
    }
}
benchmark()

// Entry point – nothing else to do; all tests run on import.
