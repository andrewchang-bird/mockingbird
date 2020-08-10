// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "MockingbirdSPMExample",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v8),
    .tvOS(.v9),
  ],
  products: [
    .library(name: "MockingbirdSPMExample", targets: ["MockingbirdSPMExample"]),
  ],
  dependencies: [
    .package(url: "https://github.com/birdrides/mockingbird.git", .upToNextMinor(from: "0.14.0")),
  ],
  targets: [
    .target(
      name: "MockingbirdSPMExample",
      path: "Sources/MockingbirdSPMExample"
    ),
    .testTarget(
      name: "MockingbirdSPMExampleTests",
      dependencies: ["MockingbirdSPMExample", "Mockingbird"],
      path: "Tests/MockingbirdSPMExampleTests"
    ),
  ]
)
