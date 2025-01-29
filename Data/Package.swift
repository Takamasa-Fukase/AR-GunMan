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
        .package(path: "Domain"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMinor(from: .init(11, 7, 0))
        )
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]),
    ]
)
