// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ARShootingEngine",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ARShootingEngine",
            targets: ["ARShootingEngine"]
        ),
    ],
    targets: [
        .target(
            name: "ARShootingEngine"
        ),
        .testTarget(
            name: "ARShootingEngineTests",
            dependencies: ["ARShootingEngine"]
        ),
    ],
)
