// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Devices",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Devices",
            targets: ["Devices"]
        ),
    ],
    dependencies: [
        .package(path: "Domain"),
    ],
    targets: [
        .target(
            name: "Devices",
            dependencies: [
                "Domain",
            ],
        ),
        .testTarget(
            name: "DevicesTests",
            dependencies: ["Devices"]
        ),
    ],
)
