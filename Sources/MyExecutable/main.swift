import Foundation
import SwiftSyntax
import SwiftParser

class ExtensionsCollector: SyntaxVisitor {
    
    var extensions = [ExtensionDeclSyntax]()
    
    init(source: String) throws {
        super.init(viewMode: .sourceAccurate)
        walk(Parser.parse(source: source))
    }
        
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        extensions.append(node)
        return .skipChildren
    }
    
}

class PlatformVersionsCollector: SyntaxVisitor {
    
    var versions: [PlatformVersionSyntax] = []
    
    override func visit(_ node: PlatformVersionSyntax) -> SyntaxVisitorContinueKind {
        versions.append(node)
        return .skipChildren
    }
    
}

extension SyntaxProtocol {
    
    var platforms: [PlatformVersionSyntax]? {
        let collector = PlatformVersionsCollector(viewMode: .all)
        collector.walk(self)
        if collector.versions.isEmpty {
            return nil
        } else {
            return collector.versions
        }
    }
    
}

func modifiers(framework: String, from file: URL) -> [Modifier] {
        
    do {
        
        let data = try Data(contentsOf: file)
        
        let source = String(data: data, encoding: .utf8)!
        
        let collector = try ExtensionsCollector(source: source)
        
        let swiftuiViewExtensions = collector.extensions.filter({ $0.extendedType.trimmedDescription == "SwiftUI.View" })
              
        let swiftuiViewModifiers = swiftuiViewExtensions.flatMap { _extension in
             
            let modifiers: [Modifier] = _extension.memberBlock.members.compactMap { member in
                guard let function = member.as(MemberBlockItemSyntax.self)?.decl.as(FunctionDeclSyntax.self) else { return nil }
                if function.modifiers.contains(where: { $0.trimmedDescription == "static" }) {
                    return nil
                } else {
                    
                    let _platforms = function.platforms ?? _extension.platforms ?? []
                    
                    let parameters = function.signature.parameterClause.parameters.map({ $0.firstName.text })
                    
                    return Modifier(
                        name: function.name.text + "(" + parameters.joined(separator: ":") + ")",
                        platforms: _platforms.compactMap { PlatformVersion($0) }
                    )
                }
            }
            
            return modifiers
            
        }
                
        return swiftuiViewModifiers
        
    } catch {
        return []
    }
    
}

let basePath = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/"

let swiftuiRelatedFrameworks = try! FileManager.default.contentsOfDirectory(atPath: basePath).filter({ $0.contains("SwiftUI") })

var modifiers = [Modifier]()

for framework in swiftuiRelatedFrameworks.sorted() {
    
    let contents = FileManager.default.enumerator(atPath: basePath + framework)
    
    let interface = contents?.first {
        guard let file = $0 as? String else { return false }
        if file.contains("arm64-apple-ios") {
            return true
        } else {
            return false
        }
    }
    
    if let interface = interface as? String {
        
        let file = URL(fileURLWithPath: basePath + framework + "/" + interface)
        
        let frameworkModifiers = modifiers(framework: framework, from: file)
        
//        print("\(framework):", frameworkModifiers.count)
        
        modifiers.append(contentsOf: frameworkModifiers)
        
    }
    
}

modifiers.sort()

//modifiers.forEach {
//    print($0.name)
//    print($0.platforms.map(\.trimmedDescription).joined(separator: ", "))
//    print("\n")
//}
//

//modifiers.forEach {
//    print(#""\#($0.name)","#)
//}

//print("TOTAL:", modifiers.count)

//modifiers.iOS(upTo: 14).forEach {
//    print($0.name, $0.platforms)
//}

print("iOS 13+:", modifiers.iOS(upTo: 14).count)
print("iOS 14+:", modifiers.iOS(from: 14, upTo: 15).count)
print("iOS 15+:", modifiers.iOS(from: 15, upTo: 16).count)
print("iOS 16+:", modifiers.iOS(from: 16, upTo: 17).count)
print("iOS 17+:", modifiers.iOS(from: 17, upTo: 18).count)



