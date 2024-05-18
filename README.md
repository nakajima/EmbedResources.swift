# EmbedResources.swift

Embed stuff from Resources/ in Swift package binaries so you don't need to distribute a separate bundle.

I'm not sure if this is a good idea or not. You probably don't want to include stuff that's too big.

## Usage

```swift
// Add to your Package.swift:
dependencies: [
  .package(url: "https://github.com/nakajima/EmbedResources.swift", branch: "main")
],
// ...
plugins: [
  .plugin(name: "EmbedResourcesPlugin", package: "EmbedResources.swift")
]
```

Then to use your embedded resources:

```swift
// Get a resource as a string
Bundle.embedded.string(for: "Some-String.txt")

// Get a resource as Data
Bundle.embedded.data(for: "some-image.gif")
```

## How it works

It's a build plugin that copies from your modules' Resources/ directories into a generated Swift file.

So let’s say you have a module named "CoolModule" with a Resources/ directory that has a file "Hello.txt"
that has the contents "Hello world". The plugin will generate the following file for you:

```swift
// __EmbeddedCoolModuleResources.swift
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
  static let embedded = EmbeddedResources(resources: ["Hi.txt": [104,101,108,108,111,32,119,111,114,108,100]])
}
```
