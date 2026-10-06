import Foundation

public final class TrieNode {
    public var children: [Character: TrieNode] = [:]
    public var isEnd: Bool = false
    public var frequency: Int = 0

    public init() {}
}
