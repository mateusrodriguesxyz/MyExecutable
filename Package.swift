// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyExecutable",
    platforms: [
        .macOS(.v12),
        .iOS(.v16),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "MyExecutable",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ],
            resources: [
                .process("Resources/")
            ]
        ),
    ]
)
