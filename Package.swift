// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "PopupView",
	platforms: [
		.macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
    	.library(
    		name: "PopupView", 
    		targets: ["PopupView"]
    	)
    ],
    targets: [
    	.target(
    		name: "PopupView",
            path: "Source"
        )
    ],
    swiftLanguageVersions: [.v5]
)
