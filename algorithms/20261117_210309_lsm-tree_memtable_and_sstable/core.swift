import Foundation

// Simple key‑value pair that is comparable by key.
public struct KVPair: Comparable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    // Comparable – order by key only.
    public static func < (lhs: KVPair, rhs: KVPair) -> Bool {
        return lhs.key < rhs.key
    }

    public static func == (lhs: KVPair, rhs: KVPair) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

// In‑memory sorted table (MemTable).
public struct MemTable {
    // Sorted array of KVPair, no duplicates (newer value replaces older).
    public var entries: [KVPair] = []

    // Binary search returning index if found, otherwise insertion point (negative).
    func binarySearch(key: String) -> Int {
        var low = 0
        var high = entries.count - 1
        while low <= high {
            let mid = (low + high) >> 1
            let midKey = entries[mid].key
            if midKey == key {
                return mid
            } else if midKey < key {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        // Not found – return insertion point as negative value.
        return -(low + 1)
    }

    // Insert or replace a key‑value pair.
    public mutating func upsert(key: String, value: String) {
        let idx = binarySearch(key: key)
        if idx >= 0 {
            // Replace existing.
            entries[idx] = KVPair(key: key, value: value)
        } else {
            // Insert at insertion point.
            let insertPos = -(idx + 1)
            entries.insert(KVPair(key: key, value: value), at: insertPos)
        }
    }

    // Retrieve a value for a key, or nil if absent.
    public func get(key: String) -> String? {
        let idx = binarySearch(key: key)
        if idx >= 0 {
            return entries[idx].value
        }
        return nil
    }

    // Flush creates an immutable SSTable and clears the memtable.
    public mutating func flush() -> SSTable {
        let sstable = SSTable(entries: entries)
        entries.removeAll(keepingCapacity: true)
        return sstable
    }

    // Current number of entries.
    public var count: Int {
        return entries.count
    }
}

// Immutable on‑disk sorted table (SSTable).
public struct SSTable {
    public let entries: [KVPair]   // Sorted, no duplicates.

    public init(entries: [KVPair]) {
        // Assume caller provides sorted, deduped entries.
        self.entries = entries
    }

    // Binary search similar to MemTable.
    func binarySearch(key: String) -> Int {
        var low = 0
        var high = entries.count - 1
        while low <= high {
            let mid = (low + high) >> 1
            let midKey = entries[mid].key
            if midKey == key {
                return mid
            } else if midKey < key {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return -(low + 1)
    }

    public func get(key: String) -> String? {
        let idx = binarySearch(key: key)
        if idx >= 0 {
            return entries[idx].value
        }
        return nil
    }
}

// LSM‑Tree engine handling writes, reads, flushes, and compaction.
public struct LSMEngine {
    // Configuration.
    public let memTableCapacity: Int          // Max entries before flush.
    public let maxSSTableCount: Int           // Trigger compaction when exceeded.

    // State.
    public var memTable = MemTable()
    public var sstables: [SSTable] = []        // Newest first.

    public init(memTableCapacity: Int = 4, maxSSTableCount: Int = 4) {
        precondition(memTableCapacity > 0, "memTableCapacity must be positive")
        precondition(maxSSTableCount > 0, "maxSSTableCount must be positive")
        self.memTableCapacity = memTableCapacity
        self.maxSSTableCount = maxSSTableCount
    }

    // Write a key‑value pair.
    public mutating func put(key: String, value: String) {
        memTable.upsert(key: key, value: value)
        if memTable.count > memTableCapacity {
            flushMemTable()
        }
    }

    // Read a key‑value pair, searching memtable then SSTables.
    public func get(key: String) -> String? {
        if let v = memTable.get(key: key) {
            return v
        }
        for sstable in sstables {
            if let v = sstable.get(key: key) {
                return v
            }
        }
        return nil
    }

    // Flush current memtable to a new SSTable.
    private mutating func flushMemTable() {
        let newSSTable = memTable.flush()
        sstables.insert(newSSTable, at: 0) // Newest at front.
        if sstables.count > maxSSTableCount {
            compactAll()
        }
    }

    // Compact all existing SSTables into a single one.
    private mutating func compactAll() {
        guard !sstables.isEmpty else { return }
        // Merge from newest to oldest, keeping the newest value for duplicate keys.
        var merged: [KVPair] = []
        var iterators: [[KVPair]].Iterator = sstables.map { $0.entries }.makeIterator()
        var buffers: [[KVPair]] = sstables.map { $0.entries }
        var indices = Array(repeating: 0, count: buffers.count)

        // Helper to fetch current key from a buffer or nil if exhausted.
        func currentKey(at i: Int) -> String? {
            let idx = indices[i]
            return idx < buffers[i].count ? buffers[i][idx].key : nil
        }

        while true {
            // Find the smallest key among the heads of all buffers.
            var smallestKey: String? = nil
            var smallestIdx: Int? = nil
            for i in 0..<buffers.count {
                if let key = currentKey(at: i) {
                    if smallestKey == nil || key < smallestKey! {
                        smallestKey = key
                        smallestIdx = i
                    }
                }
            }
            guard let chosenIdx = smallestIdx, let key = smallestKey else {
                break // All buffers exhausted.
            }

            // The chosen buffer holds the smallest key; because buffers are ordered newest→oldest,
            // the first occurrence we encounter is the newest value for that key.
            let kv = buffers[chosenIdx][indices[chosenIdx]]
            merged.append(kv)

            // Advance all buffers that have this key (to discard older duplicates).
            for i in 0..<buffers.count {
                while let curKey = currentKey(at: i), curKey == key {
                    indices[i] += 1
                }
            }
        }

        // Replace all SSTables with the single merged one.
        let compacted = SSTable(entries: merged)
        sstables = [compacted]
    }
}
