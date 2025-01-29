// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "WeaponControlMotion",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "WeaponControlMotion",
            targets: ["WeaponControlMotion"]),
    ],
    dependencies: [
        .package(path: "Core"),
    ],
    targets: [
        .target(
            name: "WeaponControlMotion",
            dependencies: [
                "Core",
            ]
        ),
        .testTarget(
            name: "WeaponControlMotionTests",
            dependencies: ["WeaponControlMotion"]),
    ]
)
