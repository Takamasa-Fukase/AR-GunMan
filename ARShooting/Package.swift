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
    dependencies: [
        .package(path: "Core"),
    ],
    targets: [
        .target(
            name: "ARShooting",
            dependencies: [
                "Core",
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ARShootingTests",
            dependencies: ["ARShooting"]),
    ]
)
