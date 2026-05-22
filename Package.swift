// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PopupView",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "PopupView", targets: ["PopupView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PopupView",
            dependencies: [],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
