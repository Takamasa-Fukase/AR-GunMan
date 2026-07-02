// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DeviceInterface",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DeviceInterface",
            targets: ["DeviceInterface"]
        ),
    ],
    dependencies: [
        .package(path: "Domain"),
    ],
    targets: [
        .target(
            name: "DeviceInterface",
            dependencies: [
                "Domain",
            ],
        ),
        .testTarget(
            name: "DeviceInterfaceTests",
            dependencies: ["DeviceInterface"]
        ),
    ],
)
