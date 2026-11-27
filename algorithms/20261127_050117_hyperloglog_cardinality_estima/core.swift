import Foundation

public struct HyperLogLog {
    public let precision: Int          // number of bits for index (p)
    public let registerCount: Int      // m = 2^p
    var registers: [UInt8]     // registers storing max rank per bucket
    
    // MARK: - Initialization
    public init(precision: Int) {
        precondition(precision >= 4 && precision <= 16, "Precision must be in [4,16]")
        self.precision = precision
        self.registerCount = 1 << precision
        self.registers = Array(repeating: 0, count: registerCount)
    }
    
    // MARK: - Public API
    public mutating func add<T: Hashable>(_ item: T) {
        var hasher = Hasher()
        hasher.combine(item)
        let rawHash = UInt64(bitPattern: Int64(hasher.finalize()))
        // Extract index (first p bits)
        let idx = Int(rawHash >> (64 - precision))
        // Remaining bits for rank calculation
        let w = rawHash << precision
        let maxRank = 64 - precision + 1
        let rank = min(Int(w.leadingZeroBitCount) + 1, maxRank)
        if UInt8(rank) > registers[idx] {
            registers[idx] = UInt8(rank)
        }
    }
    
    public func estimate() -> Double {
        let m = Double(registerCount)
        var sum: Double = 0.0
        var zeroCount = 0
        for reg in registers {
            sum += pow(2.0, -Double(reg))
            if reg == 0 { zeroCount += 1 }
        }
        let alpha: Double = {
            switch registerCount {
            case 16: return 0.673
            case 32: return 0.697
            case 64: return 0.709
            default: return 0.7213 / (1.0 + 1.079 / m)
            }
        }()
        var estimate = alpha * m * m / sum
        
        // Small range correction (linear counting)
        if estimate <= 5.0/2.0 * m && zeroCount > 0 {
            estimate = m * log(m / Double(zeroCount))
        }
        // Large range correction
        let two64 = pow(2.0, 64.0)
        if estimate > (1.0/30.0) * two64 {
            estimate = -two64 * log(1.0 - estimate / two64)
        }
        return estimate
    }
    
    public mutating func merge(_ other: HyperLogLog) {
        precondition(other.precision == self.precision, "Precisions must match to merge")
        for i in 0..<registerCount {
            if other.registers[i] > self.registers[i] {
                self.registers[i] = other.registers[i]
            }
        }
    }
}
