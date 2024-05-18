// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "EmbedResources",
	platforms: [.macOS(.v14)],
	products: [
		.plugin(
			name: "EmbedResourcesPlugin",
			targets: ["EmbedResourcesPlugin"]
		),
		.executable(
			name: "EmbedResources",
			targets: ["EmbedResources"]
		)
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.executableTarget(name: "EmbedResources"),
		.plugin(
			name: "EmbedResourcesPlugin",
			capability: .buildTool(),
			dependencies: ["EmbedResourcesTool"]
		),
		.binaryTarget(name: "EmbedResourcesTool", path: "Binaries/EmbedResourcesTool.artifactbundle")
	]
)
