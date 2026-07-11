// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mindful_minutes",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        // Match Flutter's generated SwiftPM expectation (`mindful-minutes`).
        .library(name: "mindful-minutes", type: .dynamic, targets: ["mindful_minutes"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "mindful_minutes",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
