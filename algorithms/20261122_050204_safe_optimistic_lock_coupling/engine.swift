import Foundation

/// A sorted singly linked list that employs Safe Optimistic Lock Coupling
/// for its mutating operations.  The implementation is deterministic and
/// suitable for unit‑testing without real concurrency.
struct OptimisticLockCouplingList {
    /// Sentinel head node with key `Int.min`.  It never gets removed.
    var head: OLCNode

    init() {
        // Tail sentinel with key `Int.max` simplifies boundary checks.
        let tail = OLCNode(key: Int.max, next: nil)
        self.head = OLCNode(key: Int.min, next: tail)
    }

    // MARK: - Public API

    /// Returns true iff the list contains `key`.
    func contains(_ key: Int) -> Bool {
        var (pred, curr) = find(key)
        // After a successful find, `curr` is either nil or the first node
        // whose key is >= `key`.  No lock is held, so we can simply compare.
        if let c = curr, c.key == key {
            return true
        }
        return false
    }

    /// Inserts `key` into the list if it is not already present.
    /// Returns true on successful insertion, false if the key already exists.
    @discardableResult
    mutating func insert(_ key: Int) -> Bool {
        while true {
            // 1. Optimistic traversal.
            let (pred, curr) = find(key)

            // 2. If key already present, abort.
            if let c = curr, c.key == key {
                return false
            }

            // 3. Acquire lock on predecessor.
            var predLockVersion = pred.lock.version
            pred.lock.lock()
            // Record version after lock acquisition for validation.
            predLockVersion = pred.lock.version

            // 4. Validate that the list has not changed between traversal and lock.
            //    The predecessor must still point to `curr` and must not be
            //    marked as deleted (i.e., its next is unchanged).
            if pred.next !== curr || pred.lock.locked == false && pred.lock.version != predLockVersion {
                // Validation failed – release lock and retry.
                pred.lock.unlock()
                continue
            }

            // 5. Insert new node.
            let newNode = OLCNode(key: key, next: curr)
            pred.next = newNode

            // 6. Release lock.
            pred.lock.unlock()
            return true
        }
    }

    /// Removes `key` from the list if present.
    /// Returns true on successful removal, false if the key does not exist.
    @discardableResult
    mutating func remove(_ key: Int) -> Bool {
        while true {
            // 1. Optimistic traversal.
            let (pred, curr) = find(key)

            // 2. If key not present, abort.
            guard let target = curr, target.key == key else {
                return false
            }

            // 3. Acquire locks on predecessor and target in key order
            //    (pred.key < target.key) to avoid deadlock.
            var predVersion = pred.lock.version
            var targetVersion = target.lock.version

            pred.lock.lock()
            predVersion = pred.lock.version

            // Validate after acquiring predecessor lock.
            if pred.next !== target || pred.lock.locked == false && pred.lock.version != predVersion {
                pred.lock.unlock()
                continue
            }

            target.lock.lock()
            targetVersion = target.lock.version

            // Validate that target has not been removed/changed.
            if pred.next !== target || target.lock.locked == false && target.lock.version != targetVersion {
                // Undo locks and retry.
                target.lock.unlock()
                pred.lock.unlock()
                continue
            }

            // 4. Splice out the target node.
            pred.next = target.next

            // 5. Release both locks.
            target.lock.unlock()
            pred.lock.unlock()
            return true
        }
    }

    // MARK: - Internal Helpers

    /// Performs an optimistic traversal to locate the predecessor (`pred`)
    /// and current (`curr`) nodes for a given `key`.  No locks are held on exit.
    ///
    /// The algorithm repeats the traversal until it observes a consistent
    /// snapshot (i.e., versions of visited nodes do not change while reading).
    func find(_ key: Int) -> (pred: OLCNode, curr: OLCNode?) {
        while true {
            var pred = head
            var predVersion = pred.lock.version

            var curr = pred.next
            // Traverse while the current key is less than the search key.
            while let c = curr, c.key < key {
                pred = c
                predVersion = pred.lock.version
                curr = c.next
            }

            // Capture versions after traversal.
            let predVersionAfter = pred.lock.version
            let currVersionAfter = curr?.lock.version ?? 0

            // If any version changed during traversal, restart.
            if predVersion != predVersionAfter {
                continue
            }
            if let c = curr, currVersionAfter != c.lock.version {
                continue
            }

            // Ensure that the predecessor is not locked.
            if pred.lock.locked {
                continue
            }

            // Consistent snapshot obtained.
            return (pred, curr)
        }
    }

    // MARK: - Debug Helpers (used only in tests)

    /// Returns the list contents as an array of keys (excluding sentinels).
    func toArray() -> [Int] {
        var result: [Int] = []
        var node = head.next
        while let n = node, n.key != Int.max {
            result.append(n.key)
            node = n.next
        }
        return result
    }
}
