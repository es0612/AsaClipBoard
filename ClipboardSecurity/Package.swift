// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardSecurity",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ClipboardSecurity",
            targets: ["ClipboardSecurity"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/evgenyneu/keychain-swift",
            from: "20.0.0"
        )
    ],
    targets: [
        .target(
            name: "ClipboardSecurity",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift")
            ]
        ),
        .testTarget(
            name: "ClipboardSecurityTests",
            dependencies: ["ClipboardSecurity"]
        )
    ]
)