import Foundation

struct GarbageCollector {
    var heap: Heap
    var roots: Set<Int> = []
    var grayStack: [Int] = []

    init() {
        self.heap = Heap()
    }

    // Allocation
    mutating func allocateObject() -> Int {
        return heap.allocate()
    }

    // Root management
    mutating func addRoot(_ id: Int) {
        roots.insert(id)
        guard var obj = heap.objects[id] else { return }
        if obj.color == .white {
            obj.color = .gray
            heap.objects[id] = obj
            grayStack.append(id)
        }
    }

    mutating func removeRoot(_ id: Int) {
        roots.remove(id)
    }

    // Reference management with write barrier
    mutating func addReference(from source: Int, to target: Int) {
        heap.addReference(from: source, to: target)
        writeBarrier(source, target)
    }

    private mutating func writeBarrier(_ source: Int, _ target: Int) {
        guard let src = heap.objects[source],
              var tgt = heap.objects[target] else { return }
        if src.color == .black && tgt.color == .white {
            tgt.color = .gray
            heap.objects[target] = tgt
            grayStack.append(target)
        }
    }

    // Incremental marking step
    mutating func incrementalStep() {
        guard !grayStack.isEmpty else { return }
        let id = grayStack.removeLast()
        guard var obj = heap.objects[id] else { return }

        for refId in obj.references {
            guard var refObj = heap.objects[refId] else { continue }
            if refObj.color == .white {
                refObj.color = .gray
                heap.objects[refId] = refObj
                grayStack.append(refId)
            }
        }

        obj.color = .black
        heap.objects[id] = obj
    }

    // Full collection (stop‑the‑world style)
    mutating func collectAll() {
        // Reset colors to white
        for (id, var obj) in heap.objects {
            obj.color = .white
            heap.objects[id] = obj
        }

        // Initialize worklist with roots
        grayStack.removeAll()
        for root in roots {
            guard var obj = heap.objects[root] else { continue }
            obj.color = .gray
            heap.objects[root] = obj
            grayStack.append(root)
        }

        // Process all reachable objects
        while !grayStack.isEmpty {
            incrementalStep()
        }

        // Sweep: remove white (unreachable) objects
        var toRemove: [Int] = []
        for (id, obj) in heap.objects where obj.color == .white {
            toRemove.append(id)
        }
        for id in toRemove {
            heap.objects.removeValue(forKey: id)
        }
    }

    // Helpers for testing
    func objectColor(_ id: Int) -> Color? {
        return heap.objects[id]?.color
    }

    func isObjectAlive(_ id: Int) -> Bool {
        return heap.objects[id] != nil
    }
}
