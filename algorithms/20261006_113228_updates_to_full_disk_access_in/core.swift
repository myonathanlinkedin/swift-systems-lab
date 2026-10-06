import Foundation

/// Represents the Full Disk Access status for an application.
public enum FullDiskAccessStatus: Equatable {
    case notDetermined
    case denied
    case granted(Date) // Date when access was granted
}

/// Manages Full Disk Access permissions for multiple applications.
public struct FullDiskAccessManager {
    // Mapping from application identifier to its access status.
    public var statusByApp: [String: FullDiskAccessStatus] = [:]
    
    /// Returns the current status for the given app identifier.
    /// If the app has never been seen, the status is `.notDetermined`.
    public func status(of appID: String) -> FullDiskAccessStatus {
        return statusByApp[appID] ?? .notDetermined
    }
    
    /// Requests access for the given app.
    /// - Returns: The status after the request. If the app was previously denied,
    ///   the request remains denied. If not determined, it stays not determined
    ///   until an explicit grant or revoke occurs.
    public mutating func requestAccess(appID: String) -> FullDiskAccessStatus {
        // In a real system this would trigger a UI prompt.
        // Here we simply return the current status without changing it.
        return status(of: appID)
    }
    
    /// Grants Full Disk Access to the given app.
    /// - Parameter appID: The unique identifier of the application.
    public mutating func grantAccess(appID: String) {
        let now = Date()
        statusByApp[appID] = .granted(now)
    }
    
    /// Revokes Full Disk Access from the given app.
    /// - Parameter appID: The unique identifier of the application.
    public mutating func revokeAccess(appID: String) {
        statusByApp[appID] = .denied
    }
    
    /// Returns a list of all app identifiers that currently have granted access.
    public func listGranted() -> [String] {
        return statusByApp.compactMap { (key, value) in
            if case .granted = value {
                return key
            }
            return nil
        }
    }
    
    /// Clears all stored permissions (useful for testing).
    public mutating func reset() {
        statusByApp.removeAll()
    }
}
