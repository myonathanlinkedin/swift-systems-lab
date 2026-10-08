import Foundation

extension CowVector {
    /// Ensures the buffer is uniquely referenced before a mutation.
    /// If the buffer is shared, it is cloned to preserve copy‑on‑write semantics.
    mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&buffer) {
            buffer = buffer.clone()
        }
    }

    /// Appends a new element to the end of the vector.
    /// Amortized O(1) time; capacity grows geometrically.
    public mutating func append(_ element: Element) {
        ensureUnique()
        if buffer.count == buffer.capacity {
            // Grow capacity: double or start at 1.
            let newCapacity = max(1, buffer.capacity * 2)
            reserveCapacity(newCapacity)
        }
        buffer.storage[buffer.count] = element
        buffer.count += 1
    }

    /// Reserves storage for at least `minimumCapacity` elements.
    /// If current capacity is already sufficient, does nothing.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        precondition(minimumCapacity >= 0, "Capacity must be non‑negative")
        ensureUnique()
        if buffer.capacity < minimumCapacity {
            var newStorage = Array(repeating: unsafeBitCast(0 as Int, to: Element.self), count: minimumCapacity)
            // Copy existing elements.
            for i in 0..<buffer.count {
                newStorage[i] = buffer.storage[i]
            }
            buffer.storage = newStorage
        }
    }

    /// Removes and returns the last element.
    /// Precondition: vector is non‑empty.
    @discardableResult
    public mutating func popLast() -> Element {
        precondition(buffer.count > 0, "Pop from empty vector")
        ensureUnique()
        buffer.count -= 1
        return buffer.storage[buffer.count]
    }

    /// Returns a shallow copy that shares the underlying buffer.
    public func clone() -> CowVector<Element> {
        return self
    }
}

// Equality when elements are Equatable.
extension CowVector: Equatable where Element: Equatable {
    public static func == (lhs: CowVector<Element>, rhs: CowVector<Element>) -> Bool {
        if lhs.count != rhs.count { return false }
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] { return false }
        }
        return true
    }
}
