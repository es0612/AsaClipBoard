// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ClipboardCore",
            targets: ["ClipboardCore"]
        )
    ],
    dependencies: [
        .package(path: "../ClipboardSecurity")
    ],
    targets: [
        .target(
            name: "ClipboardCore",
            dependencies: [
                .product(name: "ClipboardSecurity", package: "ClipboardSecurity")
            ]
        ),
        .testTarget(
            name: "ClipboardCoreTests",
            dependencies: ["ClipboardCore"]
        )
    ]
)