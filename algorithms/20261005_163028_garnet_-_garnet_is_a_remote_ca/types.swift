import Foundation

/// Represents a cache key. Uses a string identifier internally.
public struct CacheKey: Hashable, Comparable {
    public let identifier: String

    public init(_ identifier: String) {
        self.identifier = identifier
    }

    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    // MARK: - Equatable
    public static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    // MARK: - Comparable
    public static func < (lhs: CacheKey, rhs: CacheKey) -> Bool {
        return lhs.identifier < rhs.identifier
    }
}

/// Holds a cached value together with metadata.
public struct CacheEntry<Value> {
    public var value: Value
    public var version: Int
    public var timestamp: Date

    public init(value: Value, version: Int = 0, timestamp: Date = Date()) {
        self.value = value
        self.version = version
        self.timestamp = timestamp
    }
}

/// Errors that can be thrown by the cache store.
public enum CacheError: Error {
    case capacityExceeded
    case keyNotFound
    case invalidOperation(String)
}

/// Abstract cache store protocol.
public protocol CacheStore {
    associatedtype Value

    /// Retrieves the value for the given key, or nil if absent.
    func get(_ key: CacheKey) -> CacheEntry<Value>?

    /// Inserts or updates the value for the given key.
    func set(_ key: CacheKey, value: Value)

    /// Removes the entry for the given key.
    func remove(_ key: CacheKey)

    /// Clears all entries.
    func clear()
}
