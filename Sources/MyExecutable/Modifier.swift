struct Modifier: Hashable, Comparable {
    
    let name: String
    let platforms: [PlatformVersion]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Modifier, rhs: Modifier) -> Bool {
        lhs.name == rhs.name
    }
    
    
    static func < (lhs: Modifier, rhs: Modifier) -> Bool {
        lhs.name < rhs.name
    }
    
}

extension Modifier: Codable { }

extension [Modifier] {
    
    func iOS(from lowerVersion: Double? = nil, upTo upperVersion: Double) -> [Modifier] {
        filter {
            $0.platforms.contains {
                guard $0.platform == "iOS" else { return false }
                return $0.version >= (lowerVersion ?? 0) &&  $0.version < upperVersion
            }
        }
    }
    
}
