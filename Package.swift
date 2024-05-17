// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmbedResources.swift",
    products: [
        // Products can be used to vend plugins, making them visible to other packages.
        .plugin(
            name: "EmbedResources.swift",
            targets: ["EmbedResources.swift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .plugin(
            name: "EmbedResources.swift",
            capability: .buildTool()
        ),
    ]
)
