import Foundation
import PackagePlugin

@main
struct EmbedResourcesPlugin: BuildToolPlugin {
	/// Entry point for creating build commands for targets in Swift packages.
	func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
		var commands: [Command] = []

		for module in context.package.sourceModules {
			guard module.kind == .executable else {
				continue
			}

			let moduleDirectory = module.directory
			let resourcesDirectory = moduleDirectory.appending("Resources").string
			let tool = try context.tool(named: "EmbedResources")

			if let command = try createCommand(resourcesDirectory: resourcesDirectory, moduleName: module.moduleName, in: context.pluginWorkDirectory, tool: tool) {
				commands.append(command)
			}
		}

		return commands
	}
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension EmbedResourcesPlugin: XcodeBuildToolPlugin {
	func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
		let resourcesDirectory = context.xcodeProject.directory.appending("Sources/\(target.displayName)/Resources").string
		let moduleName = target.displayName
		let pluginWorkDirectory = context.pluginWorkDirectory
		let tool = try context.tool(named: "EmbedResources")

		if let command = try createCommand(resourcesDirectory: resourcesDirectory, moduleName: moduleName, in: pluginWorkDirectory, tool: tool) {
			return [command]
		} else {
			return []
		}
	}
}
#endif

extension EmbedResourcesPlugin {
	/// Shared function that returns a configured build command if the input files is one that should be processed.
	func createCommand(
		resourcesDirectory: String,
		moduleName: String,
		in pluginWorkDirectory: Path,
		tool: PackagePlugin.PluginContext.Tool
	) throws -> Command? {
		let executable = tool.path
		var isDir: ObjCBool = false

		if FileManager.default.fileExists(atPath: resourcesDirectory, isDirectory: &isDir), isDir.boolValue {
			let resources = try FileManager.default.contentsOfDirectory(atPath: resourcesDirectory)
			let resourcesWithData: [String: String] = resources.reduce(into: [:]) { result, filename in
				let path = Path(resourcesDirectory).appending(filename).string
				result[filename] = path
			}

			Diagnostics.remark("Here we are")

			let configPath = pluginWorkDirectory.appending("\(moduleName)-resources.json")
			let configData = try JSONEncoder().encode(resourcesWithData)
			try configData.write(to: URL(filePath: configPath.string))

			let output = pluginWorkDirectory.appending("__Embedded\(moduleName)Resources.swift")

			return .prebuildCommand(
				displayName: "Embed \(moduleName) Resources",
				executable: executable,
				arguments: [configPath.string, output.string],
				outputFilesDirectory: pluginWorkDirectory
			)
		}

		return nil
	}
}
