import Foundation

/// Represents the primary memory management approach used in a C project.
public enum MemoryManagementStrategy: String, CaseIterable, Hashable {
    case manual          // Direct use of malloc/free
    case garbageCollected // Projects that embed a GC (e.g., Boehm)
    case referenceCounting // Manual reference counting patterns
    case customAllocator // Project defines its own allocator API
    case unknown         // No clear strategy detected
}

/// A C project surveyed for its memory‑management characteristics.
public struct Project: Comparable, Hashable {
    public let name: String
    public let linesOfCode: Int
    public var strategies: Set<MemoryManagementStrategy>

    public init(name: String, linesOfCode: Int, strategies: Set<MemoryManagementStrategy>) {
        self.name = name
        self.linesOfCode = linesOfCode
        self.strategies = strategies
    }

    // MARK: - Comparable
    public static func < (lhs: Project, rhs: Project) -> Bool {
        return lhs.name < rhs.name
    }

    public static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.name == rhs.name &&
               lhs.linesOfCode == rhs.linesOfCode &&
               lhs.strategies == rhs.strategies
    }

    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(linesOfCode)
        hasher.combine(strategies)
    }
}
