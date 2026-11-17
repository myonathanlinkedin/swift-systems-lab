import Foundation

// Helper to compare two dictionaries of Double values with tolerance.
func assertDictionariesEqual(_ lhs: [MemoryManagementStrategy: Double],
                             _ rhs: [MemoryManagementStrategy: Double],
                             tolerance: Double = 1e-6,
                             file: StaticString = #file,
                             line: UInt = #line) {
    assert(lhs.keys == rhs.keys, "Dictionary keys differ", file: file, line: line)
    for key in lhs.keys {
        let left = lhs[key] ?? 0.0
        let right = rhs[key] ?? 0.0
        assert(abs(left - right) <= tolerance,
               "Values for \(key) differ: \(left) vs \(right)",
               file: file,
               line: line)
    }
}

// Unit tests
func runTests() {
    // Test 1: Empty engine
    var emptyEngine = SurveyEngine()
    assert(emptyEngine.totalProjects == 0, "Empty engine should have zero projects")
    let emptyAbs = emptyEngine.absoluteFrequency()
    for strategy in MemoryManagementStrategy.allCases {
        assert(emptyAbs[strategy] == 0, "Empty engine frequency for \(strategy) must be 0")
    }
    let emptyRel = emptyEngine.relativeFrequency()
    for strategy in MemoryManagementStrategy.allCases {
        assert(emptyRel[strategy] == 0.0, "Empty engine relative frequency for \(strategy) must be 0.0")
    }
    assert(emptyEngine.mostCommonStrategy() == nil, "Empty engine should have no most common strategy")

    // Test 2: Single project with multiple strategies
    var engine = SurveyEngine()
    let projA = Project(name: "Alpha", linesOfCode: 120_000,
                        strategies: [.manual, .customAllocator])
    engine.add(projA)
    assert(engine.totalProjects == 1, "Engine should contain one project")
    let absFreq1 = engine.absoluteFrequency()
    assert(absFreq1[.manual] == 1, "Manual count should be 1")
    assert(absFreq1[.customAllocator] == 1, "CustomAllocator count should be 1")
    assert(absFreq1[.garbageCollected] == 0, "GC count should be 0")
    let relFreq1 = engine.relativeFrequency()
    assert(relFreq1[.manual] == 100.0, "Manual percentage should be 100%")
    assert(relFreq1[.customAllocator] == 100.0, "CustomAllocator percentage should be 100%")
    assert(relFreq1[.garbageCollected] == 0.0, "GC percentage should be 0%")
    assert(engine.mostCommonStrategy() == .manual || engine.mostCommonStrategy() == .customAllocator,
           "Most common strategy should be either Manual or CustomAllocator")
    let projectsUsingManual = engine.projects(using: .manual)
    assert(projectsUsingManual.count == 1 && projectsUsingManual[0] == projA,
           "Projects using Manual should return Alpha")

    // Test 3: Multiple projects with overlapping strategies
    let projB = Project(name: "Beta", linesOfCode: 250_000,
                        strategies: [.manual, .referenceCounting])
    let projC = Project(name: "Gamma", linesOfCode: 80_000,
                        strategies: [.garbageCollected])
    let projD = Project(name: "Delta", linesOfCode: 45_000,
                        strategies: [.unknown])
    engine.add(projB)
    engine.add(projC)
    engine.add(projD)

    assert(engine.totalProjects == 4, "Engine should contain four projects")

    let absFreq2 = engine.absoluteFrequency()
    assert(absFreq2[.manual] == 2, "Manual count should be 2")
    assert(absFreq2[.referenceCounting] == 1, "ReferenceCounting count should be 1")
    assert(absFreq2[.garbageCollected] == 1, "GarbageCollected count should be 1")
    assert(absFreq2[.customAllocator] == 1, "CustomAllocator count should be 1")
    assert(absFreq2[.unknown] == 1, "Unknown count should be 1")

    let relFreq2 = engine.relativeFrequency()
    // Expected percentages (rounded to 2 decimal places for readability)
    let expectedRel: [MemoryManagementStrategy: Double] = [
        .manual: 50.0,
        .referenceCounting: 25.0,
        .garbageCollected: 25.0,
        .customAllocator: 25.0,
        .unknown: 25.0
    ]
    assertDictionariesEqual(relFreq2, expectedRel, tolerance: 1e-6)

    // Most common strategy should be .manual (2 occurrences)
    assert(engine.mostCommonStrategy() == .manual, "Most common strategy must be Manual")

    // Projects using .manual should be Alpha and Beta, sorted by name.
    let manualProjects = engine.projects(using: .manual)
    assert(manualProjects.count == 2, "Two projects should use Manual")
    assert(manualProjects[0] == projA && manualProjects[1] == projB,
           "Manual projects should be Alpha then Beta")

    // Edge case: strategy with zero occurrences should still appear in dictionaries.
    let zeroStrategy = MemoryManagementStrategy.garbageCollected
    var engineZero = SurveyEngine()
    let projE = Project(name: "Epsilon", linesOfCode: 10_000,
                        strategies: [.manual])
    engineZero.add(projE)
    let absZero = engineZero.absoluteFrequency()
    assert(absZero[zeroStrategy] == 0, "Zero-occurrence strategy must have count 0")
    let relZero = engineZero.relativeFrequency()
    assert(relZero[zeroStrategy] == 0.0, "Zero-occurrence strategy must have 0%")
}

// Execute tests
runTests()
print("All tests passed.")
