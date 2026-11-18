import Foundation

public struct HyperLogLog {
    public let p: Int               // precision (number of bits for index)
    public let m: Int               // number of registers = 2^p
    public var registers: [UInt8]   // registers storing max rank
    
    public init(p: Int) {
        precondition(p >= 4 && p <= 16, "Precision p must be in [4,16]")
        self.p = p
        self.m = 1 << p
        self.registers = [UInt8](repeating: 0, count: m)
    }
    
    // MARK: - Public API
    
    public mutating func add<T: Hashable>(_ element: T) {
        let hash = HyperLogLog.fnv1a64(of: element)
        let index = Int(hash >> (64 - p))               // top p bits
        let w = hash << p                               // remaining bits
        // rank = position of first 1-bit plus 1 (count leading zeros)
        let leadingZeros = w.leadingZeroBitCount
        let rank = UInt8(min(64 - p + 1, leadingZeros + 1))
        if rank > registers[index] {
            registers[index] = rank
        }
    }
    
    public func count() -> Double {
        // If no elements have been added, all registers are zero.
        if registers.allSatisfy({ $0 == 0 }) {
            return 0.0
        }
        
        var sum: Double = 0.0
        for reg in registers {
            sum += pow(2.0, -Double(reg))
        }
        let alpha = HyperLogLog.alpha(m: m)
        var estimate = alpha * Double(m * m) / sum
        
        // Small range correction (linear counting)
        if estimate <= (5.0 / 2.0) * Double(m) {
            let zeros = registers.filter { $0 == 0 }.count
            if zeros != 0 {
                estimate = Double(m) * log(Double(m) / Double(zeros))
            }
        }
        // Large range correction
        else if estimate > (1.0 / 30.0) * pow(2.0, 64) {
            estimate = -pow(2.0, 64) * log(1.0 - (estimate / pow(2.0, 64)))
        }
        return estimate
    }
    
    // MARK: - Helpers
    
    // FNV-1a 64-bit hash (deterministic, independent of Swift's built‑in hashValue)
    private static func fnv1a64<T: Hashable>(of value: T) -> UInt64 {
        let fnvPrime: UInt64 = 0x00000100000001B3
        let offsetBasis: UInt64 = 0xcbf29ce484222325
        var hash = offsetBasis
        let data = "\(value)".utf8
        for byte in data {
            hash ^= UInt64(byte)
            hash = hash &* fnvPrime
        }
        return hash
    }
    
    // Alpha constant depending on number of registers
    private static func alpha(m: Int) -> Double {
        switch m {
        case 16: return 0.673
        case 32: return 0.697
        case 64: return 0.709
        default:
            return 0.7213 / (1.0 + 1.079 / Double(m))
        }
    }
}
