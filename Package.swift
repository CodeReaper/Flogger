// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "HumioLogger",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "HumioLogger",
            targets: ["HumioLogger"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HumioLogger",
            dependencies: []
        ),
        .testTarget(
            name: "HumioLoggerTests",
            dependencies: ["HumioLogger"]
        )
    ]
)
