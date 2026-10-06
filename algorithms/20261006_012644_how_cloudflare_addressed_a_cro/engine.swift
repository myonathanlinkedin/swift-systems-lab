import Foundation

/// Core engine that enforces strict tenant‑container isolation.
public struct IsolationEngine {
    // MARK: Internal State
    private var tenants: Set<Tenant> = []
    private var containers: [String: Container] = [:]   // containerId → Container
    
    // MARK: Tenant Management
    public mutating func addTenant(_ tenant: Tenant) -> Bool {
        let (inserted, _) = tenants.insert(tenant)
        return inserted
    }
    
    public func hasTenant(_ tenantId: String) -> Bool {
        return tenants.contains(where: { $0.id == tenantId })
    }
    
    // MARK: Container Management
    public mutating func createContainer(for tenantId: String, containerId: String = UUID().uuidString) throws -> Container {
        guard hasTenant(tenantId) else {
            throw IsolationError.tenantNotFound(tenantId: tenantId)
        }
        guard containers[containerId] == nil else {
            throw IsolationError.duplicateContainer(containerId: containerId)
        }
        let container = Container(id: containerId, tenantId: tenantId)
        containers[containerId] = container
        return container
    }
    
    public func getContainer(_ containerId: String) throws -> Container {
        guard let container = containers[containerId] else {
            throw IsolationError.containerNotFound(containerId: containerId)
        }
        return container
    }
    
    // MARK: Data Operations
    public mutating func storeData(containerId: String, tenantId: String, key: String, value: String) throws {
        guard var container = containers[containerId] else {
            throw IsolationError.containerNotFound(containerId: containerId)
        }
        guard container.tenantId == tenantId else {
            throw IsolationError.unauthorizedAccess(requestingTenant: tenantId, containerTenant: container.tenantId)
        }
        container.data[key] = value
        containers[containerId] = container   // persist mutation
    }
    
    public func retrieveData(containerId: String, tenantId: String, key: String) throws -> String {
        let container = try getContainer(containerId)
        guard container.tenantId == tenantId else {
            throw IsolationError.unauthorizedAccess(requestingTenant: tenantId, containerTenant: container.tenantId)
        }
        guard let value = container.data[key] else {
            throw IsolationError.keyNotFound(key: key)
        }
        return value
    }
}
