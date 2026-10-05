import Foundation

/// Represents a tenant in a multi-tenant environment.
public struct Tenant: Identifiable, Comparable, Hashable {
    public let id: UUID
    public let name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    // MARK: - Comparable Conformance
    public static func < (lhs: Tenant, rhs: Tenant) -> Bool {
        lhs.id.uuidString < rhs.id.uuidString
    }

    public static func == (lhs: Tenant, rhs: Tenant) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents an isolated container belonging to a tenant.
public struct Container: Identifiable, Comparable, Hashable {
    public let id: UUID
    public let tenantID: UUID

    public init(id: UUID = UUID(), tenantID: UUID) {
        self.id = id
        self.tenantID = tenantID
    }

    // MARK: - Comparable Conformance
    public static func < (lhs: Container, rhs: Container) -> Bool {
        lhs.id.uuidString < rhs.id.uuidString
    }

    public static func == (lhs: Container, rhs: Container) -> Bool {
        lhs.id == rhs.id && lhs.tenantID == rhs.tenantID
    }
}

/// Represents a piece of data owned by a tenant.
public struct DataItem: Identifiable, Hashable {
    public let id: UUID
    public let ownerTenantID: UUID
    public let payload: String

    public init(id: UUID = UUID(), ownerTenantID: UUID, payload: String) {
        self.id = id
        self.ownerTenantID = ownerTenantID
        self.payload = payload
    }
}

/// Errors that can arise during isolation enforcement.
public enum IsolationError: Error, CustomStringConvertible {
    case tenantNotFound(UUID)
    case containerNotFound(UUID)
    case dataNotFound(UUID)
    case unauthorizedAccess(containerID: UUID, dataID: UUID)

    public var description: String {
        switch self {
        case .tenantNotFound(let id):
            return "Tenant not found: \(id)"
        case .containerNotFound(let id):
            return "Container not found: \(id)"
        case .dataNotFound(let id):
            return "Data item not found: \(id)"
        case .unauthorizedAccess(let containerID, let dataID):
            return "Unauthorized access: Container \(containerID) attempted to read Data \(dataID)"
        }
    }
}
