import Foundation

/// Core engine that enforces strict tenant isolation for containers.
public final class IsolationEngine {
    // MARK: - Internal Storage
    private var tenants: [UUID: Tenant] = [:]
    private var containers: [UUID: Container] = [:]
    private var dataStore: [UUID: DataItem] = [:]

    // MARK: - Tenant Management
    @discardableResult
    public func registerTenant(name: String) -> Tenant {
        let tenant = Tenant(name: name)
        tenants[tenant.id] = tenant
        return tenant
    }

    public func tenant(for id: UUID) throws -> Tenant {
        guard let tenant = tenants[id] else {
            throw IsolationError.tenantNotFound(id)
        }
        return tenant
    }

    // MARK: - Container Management
    @discardableResult
    public func createContainer(for tenantID: UUID) throws -> Container {
        // Ensure tenant exists before creating a container.
        _ = try tenant(for: tenantID)
        let container = Container(tenantID: tenantID)
        containers[container.id] = container
        return container
    }

    public func container(for id: UUID) throws -> Container {
        guard let container = containers[id] else {
            throw IsolationError.containerNotFound(id)
        }
        return container
    }

    // MARK: - Data Management
    @discardableResult
    public func storeData(in containerID: UUID, payload: String) throws -> DataItem {
        let container = try container(for: containerID)
        let data = DataItem(ownerTenantID: container.tenantID, payload: payload)
        dataStore[data.id] = data
        return data
    }

    /// Retrieves the payload of a data item if the requesting container belongs to the same tenant.
    public func retrieveData(containerID: UUID, dataID: UUID) throws -> String {
        let container = try container(for: containerID)
        guard let data = dataStore[dataID] else {
            throw IsolationError.dataNotFound(dataID)
        }
        guard data.ownerTenantID == container.tenantID else {
            throw IsolationError.unauthorizedAccess(containerID: containerID, dataID: dataID)
        }
        return data.payload
    }

    // MARK: - Diagnostic Helpers (used in tests)
    public func totalTenants() -> Int { tenants.count }
    public func totalContainers() -> Int { containers.count }
    public func totalDataItems() -> Int { dataStore.count }
}
