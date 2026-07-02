// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        ),
    ],
    dependencies: [
        .package(path: "DeviceInterface"),
        .package(path: "Domain"),
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: [
                "DeviceInterface",
                "Domain",
            ],
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
    ],
)
