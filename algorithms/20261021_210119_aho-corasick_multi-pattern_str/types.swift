import Foundation

public final class ACNode {
    public var children: [Character: ACNode] = [:]
    public var fail: ACNode? = nil
    public var output: [Int] = []
    
    public init() {}
}

public struct ACMatch {
    public let patternIndex: Int
    public let startPosition: Int
    
    public init(patternIndex: Int, startPosition: Int) {
        self.patternIndex = patternIndex
        self.startPosition = startPosition
    }
}
