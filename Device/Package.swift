// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Device",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Device",
            targets: ["Device"]
        ),
    ],
    dependencies: [
        .package(path: "ARShootingLib"),
        .package(path: "Domain"),
    ],
    targets: [
        .target(
            name: "Device",
            dependencies: [
                "ARShootingLib",
                "Domain",
            ]
        ),
        .testTarget(
            name: "DeviceTests",
            dependencies: ["Device"]
        ),
    ],
)
