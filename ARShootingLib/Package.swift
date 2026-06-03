// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ARShootingLib",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ARShootingLib",
            targets: ["ARShootingLib"]),
    ],
    targets: [
        .target(
            name: "ARShootingLib",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ARShootingLibTests",
            dependencies: ["ARShootingLib"]),
    ]
)
