final class ACNode {
    var children: [Character: ACNode] = [:]
    var fail: ACNode? = nil
    var output: [String] = []
    
    init() {}
}

// Result of a match: the index (0‑based) of the last character of the match and the list of patterns ending there.
public struct ACMatch {
    public let position: Int
    public let patterns: [String]
    
    public init(position: Int, patterns: [String]) {
        self.position = position
        self.patterns = patterns
    }
}
