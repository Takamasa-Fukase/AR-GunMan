// swift-tools-version: 5.10

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
    dependencies: [
        .package(path: "Core"),
        .package(path: "Data"),
        .package(path: "Domain"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMinor(from: .init(11, 7, 0))
        )
    ],
    targets: [
        .target(
            name: "Infrastructure",
            dependencies: [
                "Core",
                "Data",
                "Domain",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: ["Infrastructure"]
        ),
    ]
)
