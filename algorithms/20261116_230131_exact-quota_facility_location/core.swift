import Foundation

public struct Point {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public func distance(to other: Point) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

public struct Facility {
    public var location: Point
    public var openingCost: Double
    public var quota: Int
    // mutable state used during algorithm execution
    public var remaining: Int
    
    public init(location: Point, openingCost: Double, quota: Int) {
        precondition(quota > 0, "Quota must be positive")
        self.location = location
        self.openingCost = openingCost
        self.quota = quota
        self.remaining = quota
    }
}

public struct Client {
    public var location: Point
    
    public init(location: Point) {
        self.location = location
    }
}

public struct Solution {
    // assignments[clientIndex] = facilityIndex
    public var assignments: [Int]
    // opened[i] == true iff facility i is used
    public var opened: [Bool]
    // reference data for cost computation
    public var facilities: [Facility]
    public var clients: [Client]
    
    public init(assignments: [Int], opened: [Bool], facilities: [Facility], clients: [Client]) {
        self.assignments = assignments
        self.opened = opened
        self.facilities = facilities
        self.clients = clients
    }
    
    public func totalCost() -> Double {
        var cost = 0.0
        for (fIdx, openedFlag) in opened.enumerated() where openedFlag {
            cost += facilities[fIdx].openingCost
        }
        for (cIdx, fIdx) in assignments.enumerated() {
            let d = clients[cIdx].location.distance(to: facilities[fIdx].location)
            cost += d
        }
        return cost
    }
}

public struct ApproxFacilityLocation {
    var facilities: [Facility]
    var clients: [Client]
    
    public init(facilities: [Facility], clients: [Client]) {
        self.facilities = facilities
        self.clients = clients
    }
    
    // Greedy 3‑approximation: assign each client to the nearest facility with remaining quota.
    public mutating func run() -> Solution {
        // Defensive copy to allow mutable remaining quotas.
        var mutableFacilities = facilities.map { fac -> Facility in
            var copy = fac
            copy.remaining = fac.quota
            return copy
        }
        let m = mutableFacilities.count
        let n = clients.count
        var assignments = Array(repeating: -1, count: n)
        var opened = Array(repeating: false, count: m)
        
        // Build all (client, facility, distance) triples.
        var triples: [(c: Int, f: Int, d: Double)] = []
        triples.reserveCapacity(m * n)
        for cIdx in 0..<n {
            let cLoc = clients[cIdx].location
            for fIdx in 0..<m {
                let dist = cLoc.distance(to: mutableFacilities[fIdx].location)
                triples.append((c: cIdx, f: fIdx, d: dist))
            }
        }
        // Sort by increasing distance.
        triples.sort { $0.d < $1.d }
        
        // Greedy assignment.
        for triple in triples {
            if assignments[triple.c] != -1 { continue } // already assigned
            if mutableFacilities[triple.f].remaining == 0 { continue } // no capacity
            assignments[triple.c] = triple.f
            mutableFacilities[triple.f].remaining -= 1
            opened[triple.f] = true
        }
        
        // Verify feasibility.
        for a in assignments {
            precondition(a != -1, "Insufficient total quota to serve all clients")
        }
        
        return Solution(assignments: assignments, opened: opened, facilities: facilities, clients: clients)
    }
}
