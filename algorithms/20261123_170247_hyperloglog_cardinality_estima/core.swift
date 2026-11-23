import Foundation

struct HyperLogLog {
    let p: Int
    let m: Int
    let alpha: Double
    var registers: [UInt8]

    init(p: Int = 14) {
        precondition(p >= 4 && p <= 16, "p must be between 4 and 16")
        self.p = p
        self.m = 1 << p
        self.alpha = 0.7213 / (1.0 + 1.079 / Double(m))
        self.registers = Array(repeating: 0, count: m)
    }

    mutating func add<T: Hashable>(_ item: T) {
        let hash = HyperLogLog.fnv1a64(item)
        let index = Int(hash >> (64 - UInt(p))) & (m - 1)
        let rank = (hash << UInt(p)).leadingZeroBitCount + 1
        if rank > registers[index] {
            registers[index] = UInt8(rank)
        }
    }

    mutating func merge(with other: HyperLogLog) {
        precondition(m == other.m, "HyperLogLog instances must have the same number of registers")
        for i in 0..<m {
            if other.registers[i] > registers[i] {
                registers[i] = other.registers[i]
            }
        }
    }

    func estimate() -> Double {
        var sum: Double = 0.0
        var zeroCount = 0
        for reg in registers {
            sum += pow(2.0, -Double(reg))
            if reg == 0 { zeroCount += 1 }
        }
        var estimate = alpha * Double(m) * Double(m) / sum
        if estimate <= 5.0 / 2.0 * Double(m) && zeroCount != 0 {
            estimate = Double(m) * log(Double(m) / Double(zeroCount))
        }
        return estimate
    }

    // MARK: - Private Helpers

    private static func fnv1a64<T: Hashable>(_ value: T) -> UInt64 {
        let data = String(describing: value).utf8
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return hash
    }
}
