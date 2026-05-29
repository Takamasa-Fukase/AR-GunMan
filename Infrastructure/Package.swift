// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Infrastructure",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Infrastructure",
            targets: ["Infrastructure"]
        ),
    ],
    targets: [
        .target(
            name: "Infrastructure"
        ),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: ["Infrastructure"]
        ),
    ]
)
