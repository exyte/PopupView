// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "PopupView",
	platforms: [
        .iOS(.v14)
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
