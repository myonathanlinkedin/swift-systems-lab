import Foundation

public final class ACNode {
    public var children: [Character: ACNode] = [:]
    public var failure: ACNode?
    public var outputs: [String] = []
    
    public init() {}
}
