import Foundation

/// A lightweight lock used for optimistic lock coupling.
/// It tracks a version number and a locked flag.
struct OLCVersionedLock {
    /// Incremented on each lock/unlock operation.
    var version: UInt64 = 0
    /// Indicates whether the node is currently locked.
    var locked: Bool = false

    /// Acquire the lock.
    /// Returns the new version after locking.
    mutating func lock() -> UInt64 {
        // In a real concurrent setting this would be an atomic compare‑and‑swap.
        // Here we simply set the flag and bump the version.
        locked = true
        version &+= 1
        return version
    }

    /// Release the lock.
    /// Returns the new version after unlocking.
    mutating func unlock() -> UInt64 {
        locked = false
        version &+= 1
        return version
    }
}

/// Node of a sorted singly linked list used by the OLC algorithm.
final class OLCNode {
    /// The key stored in the node.
    var key: Int
    /// Reference to the next node (nil for the tail sentinel).
    var next: OLCNode?
    /// The per‑node versioned lock.
    var lock = OLCVersionedLock()

    init(key: Int, next: OLCNode? = nil) {
        self.key = key
        self.next = next
    }
}
