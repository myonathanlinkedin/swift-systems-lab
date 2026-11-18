import Foundation

public struct VectorStoreError: Error, CustomStringConvertible {
    public let description: String
    public init(_ description: String) {
        self.description = description
    }
}

public struct Record {
    public let id: String
    public let vector: [Double]
    public init(id: String, vector: [Double]) {
        self.id = id
        self.vector = vector
    }
}

public struct Neighbor: Comparable {
    public let id: String
    public let distance: Double

    public static func < (lhs: Neighbor, rhs: Neighbor) -> Bool {
        return lhs.distance < rhs.distance
    }

    public static func == (lhs: Neighbor, rhs: Neighbor) -> Bool {
        return lhs.id == rhs.id && lhs.distance == rhs.distance
    }
}

public struct VectorStore {
    var records: [Record] = []
    var dimension: Int? = nil

    public init() {}

    public mutating func add(id: String, vector: [Double]) throws {
        if let dim = dimension {
            guard vector.count == dim else {
                throw VectorStoreError("Vector dimension mismatch: expected \(dim), got \(vector.count)")
            }
        } else {
            dimension = vector.count
        }
        records.append(Record(id: id, vector: vector))
    }

    private static func euclideanDistance(_ a: [Double], _ b: [Double]) -> Double {
        var sum: Double = 0.0
        for i in 0..<a.count {
            let diff = a[i] - b[i]
            sum += diff * diff
        }
        return sqrt(sum)
    }

    public func query(vector: [Double], k: Int) throws -> [Neighbor] {
        guard let dim = dimension else {
            return []
        }
        guard vector.count == dim else {
            throw VectorStoreError("Query vector dimension mismatch: expected \(dim), got \(vector.count)")
        }
        guard k > 0 else {
            return []
        }

        var heap = [Neighbor]()
        heap.reserveCapacity(min(k, records.count))

        for rec in records {
            let dist = VectorStore.euclideanDistance(vector, rec.vector)
            let neighbor = Neighbor(id: rec.id, distance: dist)

            if heap.count < k {
                heap.append(neighbor)
                if heap.count == k {
                    heap.sort()
                }
            } else if dist < heap.last!.distance {
                heap[heap.count - 1] = neighbor
                heap.sort()
            }
        }
        return heap
    }

    public func count() -> Int {
        return records.count
    }
}
