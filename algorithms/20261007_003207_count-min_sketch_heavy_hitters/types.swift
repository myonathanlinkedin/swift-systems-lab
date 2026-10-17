import Foundation

public struct CountMinSketch {
    public let width: Int
    public let depth: Int
    public var table: [[UInt64]]
    public var items: Set<String>
    public let hashParams: [(a: UInt64, b: UInt64)]

    public init(width: Int, depth: Int) {
        precondition(width > 0 && depth > 0, "Width and depth must be positive")
        self.width = width
        self.depth = depth
        self.table = Array(repeating: Array(repeating: 0, count: width), count: depth)
        self.items = Set<String>()
        var params: [(UInt64, UInt64)] = []
        var a: UInt64 = 6364136223846793005
        var b: UInt64 = 1442695040888963407
        for _ in 0..<depth {
            a = a &* 2862933555777941757 &+ 3037000493
            b = b &* 3267000013 &+ 12345
            params.append((a, b))
        }
        self.hashParams = params
    }
}
