import Foundation

/// A Union‑Find / Disjoint Set Union (DSU) data structure implementing
/// path compression and union by rank.  It provides near‑constant‑time
/// amortized operations for `find`, `union` and `connected`.
public struct DisjointSetUnion {
    /// Parent links; a root node is its own parent.
    var parent: [Int]
    /// Approximate tree depth used for union by rank.
    var rank: [Int]
    /// Number of distinct sets currently represented.
    public private(set) var setCount: Int

    /// Creates a DSU managing `size` isolated elements indexed `0..<size`.
    /// - Parameter size: The number of elements. Must be non‑negative.
    public init(size: Int) {
        precondition(size >= 0, "size must be non‑negative")
        self.parent = Array(0..<size)
        self.rank = Array(repeating: 0, count: size)
        self.setCount = size
    }

    /// Returns the representative (root) of the set containing `x`.
    /// Performs path compression so future queries are faster.
    /// - Parameter x: Index of the element.
    /// - Returns: Root index of the set.
    public mutating func find(_ x: Int) -> Int {
        precondition(x >= 0 && x < parent.count, "index out of bounds")
        if parent[x] != x {
            parent[x] = find(parent[x])   // Path compression
        }
        return parent[x]
    }

    /// Merges the sets containing `x` and `y`.  If they are already in the
    /// same set the structure is unchanged.
    /// - Parameters:
    ///   - x: First element index.
    ///   - y: Second element index.
    public mutating func union(_ x: Int, _ y: Int) {
        let rootX = find(x)
        let rootY = find(y)
        guard rootX != rootY else { return }

        // Union by rank: attach the shallower tree under the deeper one.
        if rank[rootX] < rank[rootY] {
            parent[rootX] = rootY
        } else if rank[rootX] > rank[rootY] {
            parent[rootY] = rootX
        } else {
            parent[rootY] = rootX
            rank[rootX] += 1
        }
        setCount -= 1
    }

    /// Determines whether `x` and `y` belong to the same set.
    /// - Parameters:
    ///   - x: First element index.
    ///   - y: Second element index.
    /// - Returns: `true` if both elements share a representative.
    public mutating func connected(_ x: Int, _ y: Int) -> Bool {
        return find(x) == find(y)
    }

    /// Returns the total number of elements managed by the DSU.
    public var size: Int {
        return parent.count
    }
}
