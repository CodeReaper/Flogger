// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flogger",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Flogger",
            targets: ["Flogger"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Flogger",
            dependencies: []
        ),
        .testTarget(
            name: "FloggerTests",
            dependencies: ["Flogger"]
        )
    ]
)
