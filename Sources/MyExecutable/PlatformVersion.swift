import SwiftSyntax

struct PlatformVersion {
    let platform: String
    let version: Double
}

extension PlatformVersion: CustomStringConvertible {
    var description: String {
        return "\(platform) \(version)"
    }
}

extension PlatformVersion: Codable { }

extension PlatformVersion {
    
    init?(_ node: PlatformVersionSyntax) {
        guard let _version = node.version?.trimmedDescription, let version = Double(_version) else { return nil }
        self.init(platform: node.platform.trimmedDescription, version: version)
    }
    
}
