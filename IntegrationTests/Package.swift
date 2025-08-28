// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IntegrationTests",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "IntegrationTests",
            targets: ["IntegrationTests"]
        )
    ],
    dependencies: [
        .package(path: "../ClipboardSecurity"),
        .package(path: "../ClipboardCore"),
        .package(path: "../ClipboardUI")
    ],
    targets: [
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                .product(name: "ClipboardSecurity", package: "ClipboardSecurity"),
                .product(name: "ClipboardCore", package: "ClipboardCore"),
                .product(name: "ClipboardUI", package: "ClipboardUI")
            ],
            path: "Tests"
        )
    ]
)