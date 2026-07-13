// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "PHQ9Kit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PHQ9Kit",
            targets: ["PHQ9Kit"]
        )
    ],
    targets: [
        .target(
            name: "PHQ9Kit",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        ),
        .testTarget(
            name: "PHQ9KitTests",
            dependencies: ["PHQ9Kit"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        )
    ]
)
