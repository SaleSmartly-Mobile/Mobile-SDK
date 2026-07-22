// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Mobile-SDK",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SalesmartlyChat",
            targets: ["SalesmartlyChat"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SalesmartlyChat",
            path: "ios/sdk/salesmartly-chat-ios-sdk-v0.1.1.zip"
        ),
    ]
)
