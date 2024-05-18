//
//  File.swift
//  
//
//  Created by Pat Nakajima on 5/17/24.
//

import Foundation

@main
struct Embedder {
	static func main() throws {
		if ProcessInfo.processInfo.arguments.count != 3 {
			fatalError("bad args: \(ProcessInfo.processInfo.arguments)")
		}

		let configPath = ProcessInfo.processInfo.arguments[1]
		let outputPath = ProcessInfo.processInfo.arguments[2]

		let configData = try Data(contentsOf: URL(filePath: configPath))
		let config = try JSONDecoder().decode([String: String].self, from: configData)

		var embeddedData: [String] = []
		for (filename, location) in config {
			let data = try Data(contentsOf: URL(filePath: location))
			let dataString = "[" + data.map { "\($0)" }.joined(separator: ",") + "]"
			embeddedData.append("\(filename.debugDescription): \(dataString)")
		}
		
		let output = """
		import Foundation

		public struct EmbeddedResources {
			let resources: [String: [UInt8]]

			public func data(for resource: String) -> Data? {
				if let bytes = resources[resource] {
					return Data(bytes)
				}

				return nil
			}

			public func string(for resource: String) -> String? {
				if let data = data(for: resource) {
					return String(data: data, encoding: .utf8)
				}

				return nil
			}

			public func bytes(for resource: String) -> [UInt8]? {
				resources[resource]
			}
		}

		public extension Bundle {
			static let embedded = EmbeddedResources(resources: [\(embeddedData.joined(separator: ",\n"))])
		}
		"""

		let outputURL = URL(filePath: outputPath)
		try? FileManager.default.removeItem(at: outputURL)
		try! output.write(to: outputURL, atomically: true, encoding: .utf8)
	}
}
