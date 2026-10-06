import Foundation

// Unit test suite for FullDiskAccessManager
func runTests() {
    var manager = FullDiskAccessManager()
    
    // Test initial state
    assert(manager.status(of: "com.example.app") == .notDetermined, "Initial status should be notDetermined")
    
    // Test request does not change state
    let requestResult = manager.requestAccess(appID: "com.example.app")
    assert(requestResult == .notDetermined, "Request should return current status")
    assert(manager.status(of: "com.example.app") == .notDetermined, "Status should remain notDetermined after request")
    
    // Grant access and verify
    manager.grantAccess(appID: "com.example.app")
    let grantedStatus = manager.status(of: "com.example.app")
    if case .granted(let date) = grantedStatus {
        // Ensure the grant date is recent (within the last second)
        let now = Date()
        assert(now.timeIntervalSince(date) < 1.0, "Grant date should be recent")
    } else {
        assertionFailure("Status should be granted after grantAccess")
    }
    
    // List granted apps
    let grantedList = manager.listGranted()
    assert(grantedList.contains("com.example.app"), "Granted list should contain the app")
    
    // Revoke access and verify
    manager.revokeAccess(appID: "com.example.app")
    assert(manager.status(of: "com.example.app") == .denied, "Status should be denied after revocation")
    assert(manager.listGranted().isEmpty, "No apps should be granted after revocation")
    
    // Multiple apps scenario
    manager.grantAccess(appID: "com.apple.mail")
    manager.grantAccess(appID: "com.apple.photos")
    manager.revokeAccess(appID: "com.apple.mail")
    
    let finalGranted = manager.listGranted()
    assert(finalGranted == ["com.apple.photos"], "Only Photos should remain granted")
    
    // Reset and ensure clean state
    manager.reset()
    assert(manager.status(of: "com.apple.photos") == .notDetermined, "After reset, status should be notDetermined")
    assert(manager.listGranted().isEmpty, "After reset, granted list should be empty")
    
    print("All FullDiskAccessManager tests passed.")
}

// Execute tests
runTests()
