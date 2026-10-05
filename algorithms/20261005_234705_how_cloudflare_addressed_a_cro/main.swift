import Foundation

// Instantiate the isolation engine.
let engine = IsolationEngine()

// Register two distinct tenants.
let tenantA = engine.registerTenant(name: "AlphaCorp")
let tenantB = engine.registerTenant(name: "BetaInc")

// Verify tenant registration.
assert(engine.totalTenants() == 2, "Expected two tenants to be registered.")

// Create containers for each tenant.
let containerA1 = try engine.createContainer(for: tenantA.id)
let containerA2 = try engine.createContainer(for: tenantA.id)
let containerB1 = try engine.createContainer(for: tenantB.id)

// Verify container creation.
assert(engine.totalContainers() == 3, "Expected three containers across tenants.")

// Store data in containers belonging to Tenant A.
let dataA1 = try engine.storeData(in: containerA1.id, payload: "SecretAlpha1")
let dataA2 = try engine.storeData(in: containerA2.id, payload: "SecretAlpha2")

// Store data in container belonging to Tenant B.
let dataB1 = try engine.storeData(in: containerB1.id, payload: "ConfidentialBeta")

// Verify data storage count.
assert(engine.totalDataItems() == 3, "Expected three data items stored.")

// Successful retrievals within the same tenant.
do {
    let retrieved = try engine.retrieveData(containerID: containerA1.id, dataID: dataA1.id)
    assert(retrieved == "SecretAlpha1", "Data payload mismatch for Tenant A.")
} catch {
    assertionFailure("Unexpected error during authorized retrieval: \(error)")
}

// Unauthorized access attempt: Tenant B's container trying to read Tenant A's data.
do {
    _ = try engine.retrieveData(containerID: containerB1.id, dataID: dataA2.id)
    assertionFailure("Unauthorized access should have thrown an error.")
} catch IsolationError.unauthorizedAccess(let containerID, let dataID) {
    // Expected path.
    print("Caught expected unauthorized access: Container \(containerID) -> Data \(dataID)")
} catch {
    assertionFailure("Unexpected error type for unauthorized access: \(error)")
}

// Edge case: Attempt to retrieve non‑existent data.
do {
    _ = try engine.retrieveData(containerID: containerA1.id, dataID: UUID())
    assertionFailure("Retrieving non‑existent data should have thrown an error.")
} catch IsolationError.dataNotFound {
    // Expected path.
} catch {
    assertionFailure("Unexpected error type for missing data: \(error)")
}

// Edge case: Attempt to create a container for an unknown tenant.
do {
    _ = try engine.createContainer(for: UUID())
    assertionFailure("Creating a container for unknown tenant should have thrown an error.")
} catch IsolationError.tenantNotFound {
    // Expected path.
} catch {
    assertionFailure("Unexpected error type for unknown tenant: \(error)")
}

// Demonstration output (non‑essential for unit tests, but shows successful flow).
print("All isolation checks passed. System behaves as expected.")
