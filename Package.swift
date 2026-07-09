// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Mobile-SDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SalesmartlyChat",
            targets: ["SalesmartlyChat"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "16.1.1")),
    ],
    targets: [
        .target(
            name: "SalesmartlyChat",
            dependencies: [
                .product(name: "SocketIO", package: "socket.io-client-swift"),
            ],
            path: "ios/Sources/SalesmartlyChat",
            resources: [
                .copy("Resources/salesmartly"),
            ]
        ),
        .testTarget(
            name: "SalesmartlyChatTests",
            dependencies: ["SalesmartlyChat"],
            path: "ios/Tests/SalesmartlyChatTests"
        ),
    ]
)
