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
    targets: [
        .target(
            name: "WeaponControlMotion"),
        .testTarget(
            name: "WeaponControlMotionTests",
            dependencies: ["WeaponControlMotion"]),
    ]
)
