import Foundation

/// Core engine that aggregates a collection of `Project` instances and
/// provides statistical insight about memory‑management strategies.
public struct SurveyEngine {
    public var projects: [Project] = []

    public init() {}

    /// Adds a new project to the survey.
    /// - Parameter project: The `Project` to be recorded.
    public mutating func add(_ project: Project) {
        projects.append(project)
    }

    /// Returns the total number of surveyed projects.
    public var totalProjects: Int {
        return projects.count
    }

    /// Computes the absolute frequency of each `MemoryManagementStrategy`.
    /// - Returns: A dictionary mapping each strategy to the number of projects that mention it.
    public func absoluteFrequency() -> [MemoryManagementStrategy: Int] {
        var freq: [MemoryManagementStrategy: Int] = [:]
        for strategy in MemoryManagementStrategy.allCases {
            freq[strategy] = 0
        }
        for project in projects {
            for strategy in project.strategies {
                freq[strategy, default: 0] += 1
            }
        }
        return freq
    }

    /// Computes the relative frequency (percentage) of each strategy.
    /// - Returns: A dictionary mapping each strategy to its percentage of the total project count.
    public func relativeFrequency() -> [MemoryManagementStrategy: Double] {
        let total = Double(totalProjects)
        guard total > 0 else {
            // Avoid division by zero; return zero percentages.
            var empty: [MemoryManagementStrategy: Double] = [:]
            for strategy in MemoryManagementStrategy.allCases {
                empty[strategy] = 0.0
            }
            return empty
        }

        let absFreq = absoluteFrequency()
        var relFreq: [MemoryManagementStrategy: Double] = [:]
        for (strategy, count) in absFreq {
            relFreq[strategy] = (Double(count) / total) * 100.0
        }
        return relFreq
    }

    /// Determines the most common memory‑management strategy.
    /// - Returns: The strategy with the highest absolute count, or `nil` if no projects are recorded.
    public func mostCommonStrategy() -> MemoryManagementStrategy? {
        let freq = absoluteFrequency()
        // Find the strategy with the maximum count.
        var bestStrategy: MemoryManagementStrategy? = nil
        var bestCount = -1
        for (strategy, count) in freq {
            if count > bestCount {
                bestCount = count
                bestStrategy = strategy
            }
        }
        return bestStrategy
    }

    /// Retrieves all projects that use a specific strategy.
    /// - Parameter strategy: The strategy to filter by.
    /// - Returns: An array of matching `Project` instances, sorted by name.
    public func projects(using strategy: MemoryManagementStrategy) -> [Project] {
        let filtered = projects.filter { $0.strategies.contains(strategy) }
        return filtered.sorted()
    }
}
