import Foundation

public final class ProfilerEngine {
    private var buffer: RingBuffer<Sample>

    public init(capacity: Int) {
        self.buffer = RingBuffer<Sample>(capacity: capacity)
    }

    public func addSample(value: Double, at timestamp: Double = Date().timeIntervalSince1970) {
        let sample = Sample(timestamp: timestamp, value: value)
        buffer.push(sample)
    }

    public func reset() {
        buffer = RingBuffer<Sample>(capacity: buffer.capacity)
    }

    public var sampleCount: Int { buffer.currentCount }

    public func getSamples() -> [Sample] {
        // Return samples sorted by timestamp ascending
        return buffer.elements.sorted()
    }

    public func computeStatistics() -> Statistics? {
        let samples = getSamples()
        guard !samples.isEmpty else { return nil }
        let values = samples.map { $0.value }
        let n = Double(values.count)
        let sum = values.reduce(0.0, +)
        let mean = sum / n
        let variance = values.reduce(0.0) { $0 + ($1 - mean) * ($1 - mean) } / n
        let minVal = values.min()!
        let maxVal = values.max()!
        return Statistics(count: values.count, mean: mean, variance: variance, min: minVal, max: maxVal)
    }

    public func percentile(_ p: Double) -> Double? {
        precondition(p >= 0.0 && p <= 100.0, "Percentile must be between 0 and 100")
        let samples = getSamples()
        guard !samples.isEmpty else { return nil }
        let sorted = samples.map { $0.value }.sorted()
        let rank = (p / 100.0) * Double(sorted.count - 1)
        let lower = Int(floor(rank))
        let upper = Int(ceil(rank))
        if lower == upper {
            return sorted[lower]
        } else {
            let weight = rank - Double(lower)
            return sorted[lower] * (1.0 - weight) + sorted[upper] * weight
        }
    }
}
