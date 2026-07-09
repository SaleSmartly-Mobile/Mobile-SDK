// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SalesmartlyChatSample",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "SalesmartlyChatSample",
            dependencies: [
                .product(name: "SalesmartlyChat", package: "salesmartly-chat-ios"),
            ]
        ),
    ]
)
