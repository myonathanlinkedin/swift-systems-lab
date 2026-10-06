import Foundation

// Instantiate the engine
var engine = IsolationEngine()

// Create tenants
let tenantA = Tenant(id: "tenant-A")
let tenantB = Tenant(id: "tenant-B")
assert(engine.addTenant(tenantA), "Tenant A should be added")
assert(!engine.addTenant(tenantA), "Adding Tenant A again should be idempotent (returns false)")
assert(engine.addTenant(tenantB), "Tenant B should be added")

// Create containers
let containerAId = "container-A"
let containerBId = "container-B"
do {
    let _ = try engine.createContainer(for: tenantA.id, containerId: containerAId)
    let _ = try engine.createContainer(for: tenantB.id, containerId: containerBId)
} catch {
    assertionFailure("Container creation failed: \(error)")
}

// Attempt duplicate container creation (should throw)
do {
    try engine.createContainer(for: tenantA.id, containerId: containerAId)
    assertionFailure("Duplicate container creation must throw")
} catch IsolationError.duplicateContainer(let id) {
    assert(id == containerAId, "Duplicate container ID should match")
} catch {
    assertionFailure("Unexpected error on duplicate container creation: \(error)")
}

// Store data correctly
do {
    try engine.storeData(containerId: containerAId, tenantId: tenantA.id, key: "secret", value: "alpha")
    try engine.storeData(containerId: containerBId, tenantId: tenantB.id, key: "secret", value: "beta")
} catch {
    assertionFailure("Authorized store failed: \(error)")
}

// Retrieve data correctly
do {
    let valA = try engine.retrieveData(containerId: containerAId, tenantId: tenantA.id, key: "secret")
    assert(valA == "alpha", "Tenant A should retrieve its own secret")
    let valB = try engine.retrieveData(containerId: containerBId, tenantId: tenantB.id, key: "secret")
    assert(valB == "beta", "Tenant B should retrieve its own secret")
} catch {
    assertionFailure("Authorized retrieve failed: \(error)")
}

// Unauthorized access attempts
do {
    _ = try engine.retrieveData(containerId: containerAId, tenantId: tenantB.id, key: "secret")
    assertionFailure("Cross‑tenant read must be denied")
} catch IsolationError.unauthorizedAccess(let requesting, let owner) {
    assert(requesting == tenantB.id && owner == tenantA.id, "Unauthorized access details must match")
} catch {
    assertionFailure("Unexpected error on unauthorized read: \(error)")
}

do {
    try engine.storeData(containerId: containerBId, tenantId: tenantA.id, key: "malicious", value: "hacked")
    assertionFailure("Cross‑tenant write must be denied")
} catch IsolationError.unauthorizedAccess(let requesting, let owner) {
    assert(requesting == tenantA.id && owner == tenantB.id, "Unauthorized write details must match")
} catch {
    assertionFailure("Unexpected error on unauthorized write: \(error)")
}

// Edge case: non‑existent container
do {
    _ = try engine.retrieveData(containerId: "nonexistent", tenantId: tenantA.id, key: "any")
    assertionFailure("Access to non‑existent container must throw")
} catch IsolationError.containerNotFound(let id) {
    assert(id == "nonexistent", "Container not found ID should match")
} catch {
    assertionFailure("Unexpected error on missing container: \(error)")
}

// Edge case: non‑existent tenant during container creation
do {
    try engine.createContainer(for: "ghost-tenant", containerId: "ghost-container")
    assertionFailure("Creation with unknown tenant must throw")
} catch IsolationError.tenantNotFound(let id) {
    assert(id == "ghost-tenant", "Tenant not found ID should match")
} catch {
    assertionFailure("Unexpected error on unknown tenant: \(error)")
}

// Edge case: missing key
do {
    _ = try engine.retrieveData(containerId: containerAId, tenantId: tenantA.id, key: "missing")
    assertionFailure("Retrieving missing key must throw")
} catch IsolationError.keyNotFound(let key) {
    assert(key == "missing", "Missing key name should match")
} catch {
    assertionFailure("Unexpected error on missing key: \(error)")
}

// Demo output (only when run in a non‑test environment)
print("All isolation tests passed successfully.")
