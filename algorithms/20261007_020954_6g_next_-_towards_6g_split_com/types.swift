import Foundation

public enum NodeType {
    case edge
    case cloud
}

public struct ComputeNode: Identifiable {
    public let id: Int
    public let type: NodeType
    public init(id: Int, type: NodeType) {
        self.id = id
        self.type = type
    }
}

public struct Task: Identifiable, Comparable {
    public let id: Int
    public let computeRequirement: Int      // abstract compute units
    public let dataSizeMB: Double           // size of data to transfer (MB)
    
    public init(id: Int, computeRequirement: Int, dataSizeMB: Double) {
        self.id = id
        self.computeRequirement = computeRequirement
        self.dataSizeMB = dataSizeMB
    }
    
    public static func < (lhs: Task, rhs: Task) -> Bool {
        return lhs.computeRequirement < rhs.computeRequirement
    }
    
    public static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id &&
               lhs.computeRequirement == rhs.computeRequirement &&
               lhs.dataSizeMB == rhs.dataSizeMB
    }
}

public struct Link: Identifiable {
    public let id: Int
    public let fromNode: Int
    public let toNode: Int
    public let bandwidthMbps: Double   // megabits per second
    public let latencyMs: Double       // propagation latency in milliseconds
    
    public init(id: Int, fromNode: Int, toNode: Int, bandwidthMbps: Double, latencyMs: Double) {
        self.id = id
        self.fromNode = fromNode
        self.toNode = toNode
        self.bandwidthMbps = bandwidthMbps
        self.latencyMs = latencyMs
    }
}

public struct PlacementResult: Identifiable {
    public let id: Int          // same as task id for convenience
    public let nodeId: Int
    public let estimatedLatencyMs: Double
    
    public init(taskId: Int, nodeId: Int, estimatedLatencyMs: Double) {
        self.id = taskId
        self.nodeId = nodeId
        self.estimatedLatencyMs = estimatedLatencyMs
    }
}
