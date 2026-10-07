import Foundation

enum Color {
    case white
    case gray
    case black
}

struct GCObject {
    let id: Int
    var references: [Int] = []
    var color: Color = .white
}

struct Heap {
    var objects: [Int: GCObject] = [:]
    var nextId: Int = 0

    mutating func allocate() -> Int {
        let id = nextId
        nextId += 1
        objects[id] = GCObject(id: id)
        return id
    }

    mutating func addReference(from source: Int, to target: Int) {
        guard var src = objects[source] else { return }
        if !src.references.contains(target) {
            src.references.append(target)
            objects[source] = src
        }
    }

    func getObject(_ id: Int) -> GCObject? {
        return objects[id]
    }
}
