import Foundation

// Simple test harness
func assert(_ condition: @autoclosure () -> Bool, _ message: String = "Assertion failed") {
    if !condition() {
        print("❌ \(message)")
        exit(1)
    } else {
        print("✅ \(message)")
    }
}

// Test 1: Single file
func testSingleFile() {
    let json = """
    {
        "type": "file",
        "name": "hello.txt",
        "content": "Hello, World!"
    }
    """
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
    
    var processor = JsonDirectoryProcessor()
    try! processor.run(json: json, at: tempDir)
    
    let fileURL = tempDir.appendingPathComponent("hello.txt")
    let exists = FileManager.default.fileExists(atPath: fileURL.path)
    assert(exists, "File should exist")
    let content = try! String(contentsOf: fileURL, encoding: .utf8)
    assert(content == "Hello, World!", "File content matches")
    
    try! FileManager.default.removeItem(at: tempDir)
}

// Test 2: Nested directories with files
func testNestedStructure() {
    let json = """
    {
        "type": "directory",
        "name": "root",
        "children": [
            {
                "type": "file",
                "name": "readme.md",
                "content": "# Project"
            },
            {
                "type": "directory",
                "name": "src",
                "children": [
                    {
                        "type": "file",
                        "name": "main.swift",
                        "content": "print(\\"Hi\\")"
                    },
                    {
                        "type": "directory",
                        "name": "utils",
                        "children": [
                            {
                                "type": "file",
                                "name": "helper.swift",
                                "content": "// helper"
                            }
                        ]
                    }
                ]
            }
        ]
    }
    """
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
    
    var processor = JsonDirectoryProcessor()
    try! processor.run(json: json, at: tempDir)
    
    // Verify directories
    let rootURL = tempDir.appendingPathComponent("root", isDirectory: true)
    var isDir: ObjCBool = false
    let rootExists = FileManager.default.fileExists(atPath: rootURL.path, isDirectory: &isDir)
    assert(rootExists && isDir.boolValue, "Root directory exists")
    
    let srcURL = rootURL.appendingPathComponent("src", isDirectory: true)
    let srcExists = FileManager.default.fileExists(atPath: srcURL.path, isDirectory: &isDir)
    assert(srcExists && isDir.boolValue, "src directory exists")
    
    let utilsURL = srcURL.appendingPathComponent("utils", isDirectory: true)
    let utilsExists = FileManager.default.fileExists(atPath: utilsURL.path, isDirectory: &isDir)
    assert(utilsExists && isDir.boolValue, "utils directory exists")
    
    // Verify files
    let readmeURL = rootURL.appendingPathComponent("readme.md")
    assert(FileManager.default.fileExists(atPath: readmeURL.path), "readme.md exists")
    let readmeContent = try! String(contentsOf: readmeURL, encoding: .utf8)
    assert(readmeContent == "# Project", "readme content")
    
    let mainURL = srcURL.appendingPathComponent("main.swift")
    assert(FileManager.default.fileExists(atPath: mainURL.path), "main.swift exists")
    let mainContent = try! String(contentsOf: mainURL, encoding: .utf8)
    assert(mainContent == "print(\"Hi\")", "main.swift content")
    
    let helperURL = utilsURL.appendingPathComponent("helper.swift")
    assert(FileManager.default.fileExists(atPath: helperURL.path), "helper.swift exists")
    let helperContent = try! String(contentsOf: helperURL, encoding: .utf8)
    assert(helperContent == "// helper", "helper.swift content")
    
    try! FileManager.default.removeItem(at: tempDir)
}

// Test 3: Invalid JSON handling
func testInvalidJSON() {
    let json = """
    {
        "type": "unknown",
        "name": "bad"
    }
    """
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
    
    var processor = JsonDirectoryProcessor()
    var caught = false
    do {
        try processor.run(json: json, at: tempDir)
    } catch {
        caught = true
    }
    assert(caught, "Processor should throw on invalid node type")
    
    try! FileManager.default.removeItem(at: tempDir)
}

// Run all tests
func runAllTests() {
    testSingleFile()
    testNestedStructure()
    testInvalidJSON()
    print("All tests passed.")
}

runAllTests()
