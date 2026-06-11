// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "exelbid_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "exelbid-plugin", targets: ["exelbid_plugin"])
    ],
    dependencies: [
        // Remote distribution of the ExelBid iOS SDK (prebuilt XCFramework).
        // Mirrors the CocoaPods dependency in the podspec — `from: "3.0.4"`
        // resolves to >= 3.0.4, < 4.0.0. 3.0.4 is the minimum that exposes the
        // `EBNativeAdRendering.nativeCallToActionButton()` CTA slot this plugin
        // renders, and matches the mediation adapter's own core SDK floor.
        .package(
            url: "https://github.com/onnuridmc/ExelBid_iOS_Swift.git",
            from: "3.0.4"
        )
    ],
    targets: [
        .target(
            name: "exelbid_plugin",
            dependencies: [
                .product(name: "ExelBidSDK", package: "ExelBid_iOS_Swift")
            ],
            resources: []
        )
    ]
)
