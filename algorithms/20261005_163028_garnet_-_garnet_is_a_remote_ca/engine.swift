import Foundation

/// Thread‑safe, strongly consistent in‑memory cache with LRU eviction and versioning.
public final class GarnetCache<Value>: CacheStore {
    public typealias Value = Value

    // MARK: - Internal Node for LRU tracking
    private final class Node {
        let key: CacheKey
        var prev: Node?
        var next: Node?

        init(key: CacheKey) {
            self.key = key
        }
    }

    // MARK: - Storage
    private var storage: [CacheKey: CacheEntry<Value>] = [:]
    private var nodes: [CacheKey: Node] = [:]

    // LRU list pointers
    private var head: Node?
    private var tail: Node?

    private let capacity: Int
    private let queue: DispatchQueue

    // MARK: - Initialization
    public init(capacity: Int) {
        precondition(capacity >= 0, "Capacity must be non‑negative")
        self.capacity = capacity
        self.queue = DispatchQueue(label: "com.garnet.cache.\(UUID())", attributes: .concurrent)
    }

    // MARK: - Public API
    public func get(_ key: CacheKey) -> CacheEntry<Value>? {
        var result: CacheEntry<Value>?
        queue.sync {
            guard let entry = storage[key] else { return }
            result = entry
            // Move accessed node to front (most recently used)
            if let node = nodes[key] {
                moveToHead(node)
            }
        }
        return result
    }

    public func set(_ key: CacheKey, value: Value) {
        queue.async(flags: .barrier) {
            if var existing = self.storage[key] {
                // Update existing entry
                existing.value = value
                existing.version += 1
                existing.timestamp = Date()
                self.storage[key] = existing
                if let node = self.nodes[key] {
                    self.moveToHead(node)
                }
            } else {
                // Insert new entry
                if self.capacity > 0 && self.storage.count >= self.capacity {
                    self.evictLeastRecentlyUsed()
                }
                let entry = CacheEntry(value: value, version: 0, timestamp: Date())
                self.storage[key] = entry
                let node = Node(key: key)
                self.nodes[key] = node
                self.insertAtHead(node)
            }
        }
    }

    public func remove(_ key: CacheKey) {
        queue.async(flags: .barrier) {
            guard let _ = self.storage.removeValue(forKey: key) else { return }
            if let node = self.nodes.removeValue(forKey: key) {
                self.unlink(node)
            }
        }
    }

    public func clear() {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
            self.nodes.removeAll()
            self.head = nil
            self.tail = nil
        }
    }

    // MARK: - LRU Helpers
    private func insertAtHead(_ node: Node) {
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
        if tail == nil {
            tail = node
        }
    }

    private func moveToHead(_ node: Node) {
        guard head !== node else { return }
        unlink(node)
        insertAtHead(node)
    }

    private func unlink(_ node: Node) {
        if let prev = node.prev {
            prev.next = node.next
        } else {
            head = node.next
        }
        if let next = node.next {
            next.prev = node.prev
        } else {
            tail = node.prev
        }
        node.prev = nil
        node.next = nil
    }

    private func evictLeastRecentlyUsed() {
        guard let lru = tail else { return }
        remove(lru.key)
    }
}
