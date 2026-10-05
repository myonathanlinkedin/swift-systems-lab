import Foundation

public struct Sample: Comparable {
    public let timestamp: Double
    public let value: Double

    public init(timestamp: Double, value: Double) {
        self.timestamp = timestamp
        self.value = value
    }

    public static func < (lhs: Sample, rhs: Sample) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    public static func == (lhs: Sample, rhs: Sample) -> Bool {
        lhs.timestamp == rhs.timestamp && lhs.value == rhs.value
    }
}

public struct Statistics {
    public let count: Int
    public let mean: Double
    public let variance: Double
    public let min: Double
    public let max: Double

    public init(count: Int, mean: Double, variance: Double, min: Double, max: Double) {
        self.count = count
        self.mean = mean
        self.variance = variance
        self.min = min
        self.max = max
    }
}

public struct RingBuffer<T> {
    private var buffer: [T?]
    private var head: Int = 0          // Next write position
    private var count: Int = 0
    public let capacity: Int

    public init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero")
        self.capacity = capacity
        self.buffer = Array<T?>(repeating: nil, count: capacity)
    }

    public mutating func push(_ element: T) {
        buffer[head] = element
        head = (head + 1) % capacity
        if count < capacity {
            count += 1
        }
    }

    public func get(at index: Int) -> T? {
        // index 0 = most recent element
        guard index >= 0 && index < count else { return nil }
        let idx = (head - 1 - index + capacity) % capacity
        return buffer[idx]
    }

    public var elements: [T] {
        var result = [T]()
        for i in stride(from: count - 1, through: 0, by: -1) {
            if let e = get(at: i) {
                result.append(e)
            }
        }
        return result
    }

    public var isFull: Bool { count == capacity }
    public var currentCount: Int { count }
}
