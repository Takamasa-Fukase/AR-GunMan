// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "Domain")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain"
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]),
    ]
)
