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
    targets: [
    	.target(
    		name: "PopupView",
            path: "Source"
        )
    ]
)
