import Foundation

public struct SplitScheduler {
    public var tasks: [Task]
    public var nodes: [ComputeNode]
    public var links: [Link]
    
    // processing factors (ms per compute unit)
    let edgeProcessingFactor: Double = 5.0
    let cloudProcessingFactor: Double = 0.5
    
    public init(tasks: [Task], nodes: [ComputeNode], links: [Link]) {
        self.tasks = tasks
        self.nodes = nodes
        self.links = links
    }
    
    // Helper to find a link from an edge node to a cloud node, if any.
    func link(from edgeId: Int, to cloudId: Int) -> Link? {
        return links.first { $0.fromNode == edgeId && $0.toNode == cloudId }
    }
    
    // Compute network transfer time (ms) for given data size over a link.
    func networkTransferTimeMs(dataSizeMB: Double, over link: Link) -> Double {
        // Convert MB to megabits (1 byte = 8 bits)
        let dataMegabits = dataSizeMB * 8.0
        let transmissionMs = (dataMegabits / link.bandwidthMbps) * 1000.0
        return transmissionMs + link.latencyMs
    }
    
    // Estimate total latency (ms) for placing a task on a specific node.
    func estimatedLatency(task: Task, on node: ComputeNode) -> Double {
        switch node.type {
        case .edge:
            // Edge processing only, no network cost.
            return Double(task.computeRequirement) * edgeProcessingFactor
        case .cloud:
            // Find a link from any edge to this cloud node.
            // For simplicity, assume a single edge node exists.
            guard let edgeNode = nodes.first(where: { $0.type == .edge }) else {
                // No edge node; treat as pure processing cost.
                return Double(task.computeRequirement) * cloudProcessingFactor
            }
            if let l = link(from: edgeNode.id, to: node.id) {
                let networkMs = networkTransferTimeMs(dataSizeMB: task.dataSizeMB, over: l)
                let processingMs = Double(task.computeRequirement) * cloudProcessingFactor
                return networkMs + processingMs
            } else {
                // No link; fallback to processing only.
                return Double(task.computeRequirement) * cloudProcessingFactor
            }
        }
    }
    
    // Greedy scheduler: pick node with minimal estimated latency for each task.
    public mutating func run() -> [PlacementResult] {
        var results: [PlacementResult] = []
        for task in tasks {
            var bestNode: ComputeNode? = nil
            var bestLatency: Double = Double.greatestFiniteMagnitude
            for node in nodes {
                let latency = estimatedLatency(task: task, on: node)
                if latency < bestLatency {
                    bestLatency = latency
                    bestNode = node
                }
            }
            if let chosen = bestNode {
                let result = PlacementResult(taskId: task.id, nodeId: chosen.id, estimatedLatencyMs: bestLatency)
                results.append(result)
            }
        }
        return results
    }
}
