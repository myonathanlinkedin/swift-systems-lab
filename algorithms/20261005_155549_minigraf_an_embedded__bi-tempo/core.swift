import Foundation

// MARK: - Temporal Types

typealias Timestamp = UInt64   // milliseconds since epoch

extension Timestamp {
    static var now: Timestamp {
        return Timestamp(Date().timeIntervalSince1970 * 1000)
    }
}

struct TimeRange {
    let start: Timestamp
    let end: Timestamp?   // nil means infinite
    
    func contains(_ t: Timestamp) -> Bool {
        if t < start { return false }
        if let e = end { return t <= e }
        return true
    }
}

// MARK: - Bi‑Temporal Wrapper

struct BiTemporal<Value> {
    let value: Value
    let validTime: TimeRange
    let transactionTime: TimeRange
}

// MARK: - Graph Primitives

struct Edge {
    let id: Int
    let from: Int
    let to: Int
}

// MARK: - Graph Core

final class Graph {
    // Node ID → list of bi‑temporal versions
    private var nodes: [Int: [BiTemporal<String>]] = [:]
    // Edge ID → list of bi‑temporal versions
    private var edges: [Int: [BiTemporal<Edge>]] = [:]
    
    // MARK: Node Operations
    
    func addNode(id: Int,
                 data: String,
                 validFrom: Timestamp,
                 validTo: Timestamp? = nil,
                 txFrom: Timestamp = .now,
                 txTo: Timestamp? = nil) {
        let vt = TimeRange(start: validFrom, end: validTo)
        let tt = TimeRange(start: txFrom, end: txTo)
        let version = BiTemporal(value: data, validTime: vt, transactionTime: tt)
        nodes[id, default: []].append(version)
    }
    
    func removeNode(id: Int,
                    txEnd: Timestamp = .now) {
        // Close the latest transaction interval
        guard var versions = nodes[id], !versions.isEmpty else { return }
        var latest = versions.removeLast()
        let closedTT = TimeRange(start: latest.transactionTime.start, end: txEnd)
        latest = BiTemporal(value: latest.value,
                            validTime: latest.validTime,
                            transactionTime: closedTT)
        versions.append(latest)
        nodes[id] = versions
    }
    
    func node(id: Int,
              atValidTime vt: Timestamp,
              atTxTime tt: Timestamp) -> String? {
        guard let versions = nodes[id] else { return nil }
        for v in versions.reversed() {
            if v.validTime.contains(vt) && v.transactionTime.contains(tt) {
                return v.value
            }
        }
        return nil
    }
    
    // MARK: Edge Operations
    
    func addEdge(id: Int,
                 from: Int,
                 to: Int,
                 validFrom: Timestamp,
                 validTo: Timestamp? = nil,
                 txFrom: Timestamp = .now,
                 txTo: Timestamp? = nil) {
        let edge = Edge(id: id, from: from, to: to)
        let vt = TimeRange(start: validFrom, end: validTo)
        let tt = TimeRange(start: txFrom, end: txTo)
        let version = BiTemporal(value: edge, validTime: vt, transactionTime: tt)
        edges[id, default: []].append(version)
    }
    
    func removeEdge(id: Int,
                    txEnd: Timestamp = .now) {
        guard var versions = edges[id], !versions.isEmpty else { return }
        var latest = versions.removeLast()
        let closedTT = TimeRange(start: latest.transactionTime.start, end: txEnd)
        latest = BiTemporal(value: latest.value,
                            validTime: latest.validTime,
                            transactionTime: closedTT)
        versions.append(latest)
        edges[id] = versions
    }
    
    func edge(id: Int,
              atValidTime vt: Timestamp,
              atTxTime tt: Timestamp) -> Edge? {
        guard let versions = edges[id] else { return nil }
        for v in versions.reversed() {
            if v.validTime.contains(vt) && v.transactionTime.contains(tt) {
                return v.value
            }
        }
        return nil
    }
    
    // MARK: Traversal
    
    func neighbors(of nodeId: Int,
                   atValidTime vt: Timestamp,
                   atTxTime tt: Timestamp) -> [Int] {
        var result: [Int] = []
        for (_, versions) in edges {
            for v in versions.reversed() {
                if v.validTime.contains(vt) && v.transactionTime.contains(tt) {
                    if v.value.from == nodeId {
                        result.append(v.value.to)
                    } else if v.value.to == nodeId {
                        result.append(v.value.from)
                    }
                }
            }
        }
        return result
    }
}
