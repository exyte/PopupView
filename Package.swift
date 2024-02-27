// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PopupView",
    platforms: [
        .iOS(.v14),
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
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0")
    ],
    targets: [
        .target(name: "PopupView", dependencies: [
            .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        ], path: "Source")
    ]
)
