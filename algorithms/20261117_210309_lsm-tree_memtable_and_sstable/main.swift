import Foundation

// Simple test harness.
func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "") {
    if a != b {
        fatalError("Assertion failed: \(a) != \(b). \(message)")
    }
}

func testMemTableBasic() {
    var mem = MemTable()
    mem.upsert(key: "c", value: "3")
    mem.upsert(key: "a", value: "1")
    mem.upsert(key: "b", value: "2")
    // Should be sorted a,b,c.
    assertEqual(mem.entries.map { $0.key }, ["a", "b", "c"])
    // Replace existing.
    mem.upsert(key: "b", value: "22")
    assertEqual(mem.get(key: "b"), "22")
    // Not present.
    assertEqual(mem.get(key: "z"), nil as String?)
}

func testSSTableLookup() {
    let pairs = [KVPair(key: "a", value: "1"),
                 KVPair(key: "b", value: "2"),
                 KVPair(key: "c", value: "3")]
    let sst = SSTable(entries: pairs)
    assertEqual(sst.get(key: "b"), "2")
    assertEqual(sst.get(key: "x"), nil as String?)
}

func testEngineFlushAndRead() {
    var engine = LSMEngine(memTableCapacity: 2, maxSSTableCount: 10)
    engine.put(key: "k1", value: "v1")
    engine.put(key: "k2", value: "v2") // Triggers flush (capacity 2 -> >2 after next)
    engine.put(key: "k3", value: "v3") // New memtable entry
    // k1 and k2 should be in first SSTable, k3 in memtable.
    assertEqual(engine.get(key: "k1"), "v1")
    assertEqual(engine.get(key: "k3"), "v3")
    // Force another flush.
    engine.put(key: "k4", value: "v4")
    // Now two SSTables exist.
    assertEqual(engine.sstables.count, 2)
    // Verify values across tables.
    assertEqual(engine.get(key: "k2"), "v2")
    assertEqual(engine.get(key: "k4"), "v4")
}

func testEngineCompactionDedup() {
    var engine = LSMEngine(memTableCapacity: 2, maxSSTableCount: 3)
    // Insert keys that will cause multiple flushes.
    engine.put(key: "a", value: "1") // mem
    engine.put(key: "b", value: "2") // flush -> SSTable0
    engine.put(key: "a", value: "10") // mem (newer a)
    engine.put(key: "c", value: "3") // flush -> SSTable1
    engine.put(key: "b", value: "20") // mem (newer b)
    engine.put(key: "d", value: "4") // flush -> SSTable2 (now count = 3)
    // Next insert triggers compaction because count > maxSSTableCount.
    engine.put(key: "e", value: "5") // mem
    engine.put(key: "f", value: "6") // flush -> triggers compaction
    // After compaction there should be exactly one SSTable.
    assertEqual(engine.sstables.count, 1)
    // Verify that newest values win.
    assertEqual(engine.get(key: "a"), "10")
    assertEqual(engine.get(key: "b"), "20")
    assertEqual(engine.get(key: "c"), "3")
    assertEqual(engine.get(key: "d"), "4")
    assertEqual(engine.get(key: "e"), "5")
    assertEqual(engine.get(key: "f"), "6")
}

func runAllTests() {
    testMemTableBasic()
    testSSTableLookup()
    testEngineFlushAndRead()
    testEngineCompactionDedup()
    print("All LSM‑Tree tests passed.")
}

// Entry point.
runAllTests()
