import Foundation

public enum ArchiveNode: Decodable {
    case file(name: String, content: String)
    case directory(name: String, children: [ArchiveNode])
    
    fileprivate enum CodingKeys: String, CodingKey {
        case type, name, content, children
    }
    
    fileprivate enum NodeType: String {
        case file, directory
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        guard let nodeType = NodeType(rawValue: typeString) else {
            throw DecodingError.dataCorruptedError(forKey: .type,
                                                   in: container,
                                                   debugDescription: "Invalid node type")
        }
        let name = try container.decode(String.self, forKey: .name)
        switch nodeType {
        case .file:
            let content = try container.decode(String.self, forKey: .content)
            self = .file(name: name, content: content)
        case .directory:
            let children = try container.decode([ArchiveNode].self, forKey: .children)
            self = .directory(name: name, children: children)
        }
    }
    
    // Helper to materialize the node at a given URL
    public func materialize(at url: URL) throws {
        switch self {
        case .file(let name, let content):
            let fileURL = url.appendingPathComponent(name, isDirectory: false)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        case .directory(let name, let children):
            let dirURL = url.appendingPathComponent(name, isDirectory: true)
            try FileManager.default.createDirectory(at: dirURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            for child in children {
                try child.materialize(at: dirURL)
            }
        }
    }
}

// Processor struct to parse JSON and materialize
public struct JsonDirectoryProcessor {
    public init() {}
    
    public func run(json: String, at destination: URL) throws {
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let rootNode = try decoder.decode(ArchiveNode.self, from: data)
        try rootNode.materialize(at: destination)
    }
}
