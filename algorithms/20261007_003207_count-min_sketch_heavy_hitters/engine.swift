import Foundation

extension CountMinSketch {
    public mutating func add(item: String, count: UInt64 = 1) {
        items.insert(item)
        for d in 0..<depth {
            let idx = Int(hash(item: item, depth: d) % UInt64(width))
            table[d][idx] &+= count
        }
    }

    public func estimate(item: String) -> UInt64 {
        var minCount = UInt64.max
        for d in 0..<depth {
            let idx = Int(hash(item: item, depth: d) % UInt64(width))
            let c = table[d][idx]
            if c < minCount {
                minCount = c
            }
        }
        return minCount
    }

    public func heavyHitters(threshold: UInt64) -> [String] {
        var result: [String] = []
        for item in items {
            if estimate(item: item) >= threshold {
                result.append(item)
            }
        }
        return result
    }

    func hash(item: String, depth: Int) -> UInt64 {
        var h: UInt64 = 0
        for byte in item.utf8 {
            h = h &* 31 &+ UInt64(byte)
        }
        let params = hashParams[depth]
        let prime: UInt64 = 1099511628211
        let mixed = (h &* params.a &+ params.b) % prime
        return mixed
    }
}
