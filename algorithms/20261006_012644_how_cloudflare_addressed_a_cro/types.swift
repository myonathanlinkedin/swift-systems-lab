import Foundation

/// Represents a tenant in a multi-tenant environment.
public struct Tenant: Comparable, Hashable {
    public let id: String
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }
    
    // MARK: Comparable
    public static func < (lhs: Tenant, rhs: Tenant) -> Bool {
        return lhs.id < rhs.id
    }
    
    public static func == (lhs: Tenant, rhs: Tenant) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Represents an isolated container belonging to a tenant.
public struct Container: Identifiable, Comparable {
    public let id: String
    public let tenantId: String
    public var data: [String: String] = [:]
    
    public init(id: String = UUID().uuidString, tenantId: String) {
        self.id = id
        self.tenantId = tenantId
    }
    
    // MARK: Comparable
    public static func < (lhs: Container, rhs: Container) -> Bool {
        return lhs.id < rhs.id
    }
    
    public static func == (lhs: Container, rhs: Container) -> Bool {
        return lhs.id == rhs.id && lhs.tenantId == rhs.tenantId
    }
}

/// Errors that can arise during isolation enforcement.
public enum IsolationError: Error, Equatable {
    case tenantNotFound(tenantId: String)
    case containerNotFound(containerId: String)
    case duplicateContainer(containerId: String)
    case unauthorizedAccess(requestingTenant: String, containerTenant: String)
    case keyNotFound(key: String)
}
