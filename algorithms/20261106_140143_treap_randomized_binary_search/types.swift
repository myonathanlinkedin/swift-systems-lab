import Foundation

class Node {
    var key: Int
    var priority: Int
    var left: Node?
    var right: Node?

    init(key: Int, priority: Int) {
        self.key = key
        self.priority = priority
        self.left = nil
        self.right = nil
    }
}
