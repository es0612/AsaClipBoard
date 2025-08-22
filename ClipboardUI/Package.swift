// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardUI",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ClipboardUI",
            targets: ["ClipboardUI"]
        )
    ],
    dependencies: [
        .package(path: "../ClipboardCore"),
        .package(path: "../ClipboardSecurity")
    ],
    targets: [
        .target(
            name: "ClipboardUI",
            dependencies: [
                .product(name: "ClipboardCore", package: "ClipboardCore"),
                .product(name: "ClipboardSecurity", package: "ClipboardSecurity")
            ]
        ),
        .testTarget(
            name: "ClipboardUITests",
            dependencies: ["ClipboardUI"]
        )
    ]
)