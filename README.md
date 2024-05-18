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
