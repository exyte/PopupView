// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PopupView",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "PopupView",
            targets: ["PopupView"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
        .package(url: "https://github.com/Amzd/PublishedObject", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        .target(name: "PopupView", dependencies: [
            .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
            .product(name: "PublishedObject", package: "PublishedObject"),
        ], path: "Source")
    ]
)
