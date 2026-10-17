import Foundation

/// Internal storage class for copy‑on‑write semantics.
/// Holds a mutable array of elements and tracks its logical count.
final class CowBuffer<Element> {
    /// Underlying storage; may have extra capacity beyond `count`.
    var storage: [Element]
    /// Number of valid elements in `storage`.
    var count: Int

    init(capacity: Int = 0) {
        self.storage = Array(repeating: unsafeBitCast(0 as Int, to: Element.self), count: capacity)
        self.count = 0
    }

    init(elements: [Element]) {
        self.storage = elements
        self.count = elements.count
    }

    /// Returns the current logical capacity (size of allocated storage).
    var capacity: Int { storage.count }

    /// Provides a deep copy of the buffer.
    func clone() -> CowBuffer<Element> {
        let copy = CowBuffer<Element>(capacity: storage.count)
        copy.storage = storage
        copy.count = count
        return copy
    }
}

/// Public vector type exposing copy‑on‑write behavior.
/// Generic over any element type.
public struct CowVector<Element> {
    // The shared buffer; may be referenced by multiple vectors.
    var buffer: CowBuffer<Element>

    /// Creates an empty vector.
    public init() {
        self.buffer = CowBuffer<Element>()
    }

    /// Creates a vector pre‑filled with the supplied elements.
    public init(_ elements: [Element]) {
        self.buffer = CowBuffer<Element>(elements: elements)
    }

    /// Number of elements currently stored.
    public var count: Int { buffer.count }

    /// Current allocated capacity.
    public var capacity: Int { buffer.capacity }

    /// Provides read‑only access to the element at `index`.
    public subscript(index: Int) -> Element {
        get {
            precondition(index >= 0 && index < buffer.count, "Index out of bounds")
            return buffer.storage[index]
        }
        set {
            precondition(index >= 0 && index < buffer.count, "Index out of bounds")
            ensureUnique()
            buffer.storage[index] = newValue
        }
    }
}
