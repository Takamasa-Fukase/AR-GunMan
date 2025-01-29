// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ARShooting",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ARShooting",
            targets: ["ARShooting"]),
    ],
    targets: [
        .target(
            name: "ARShooting",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ARShootingTests",
            dependencies: ["ARShooting"]),
    ]
)
