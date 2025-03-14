// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]),
    ],
    dependencies: [
        .package(path: "Core"),
    ],
    targets: [
        .target(
            name: "Domain"),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                "Core",
            ]
        ),
    ]
)
