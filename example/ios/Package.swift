// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Exelbid_Plugin",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Exelbid_Plugin",
            targets: ["Exelbid_Plugin"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/adfit/adfit-spm.git",
            from: "3.19.9"
        ),
    ],
    targets: [
        .target(
            name: "Exelbid_Plugin",
            dependencies: [
                .product(name: "AdfitSDK", package: "adfit-spm")
            ],
            path: "Classes"
        ),
    ]
)