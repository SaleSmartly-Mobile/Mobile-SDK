# SaleSmartly Chat iOS SDK

该目录只存放 SaleSmartly Chat iOS SDK 二进制发布包，不提交 SDK 源码。

## SDK ZIP 下载

[点击下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/main/ios/sdk/salesmartly-chat-ios-sdk-v0.1.0.zip)

SDK 信息：

| 字段 | 值 |
| --- | --- |
| 文件 | `ios/sdk/salesmartly-chat-ios-sdk-v0.1.0.zip` |
| 版本 | `0.1.0` |
| 类型 | `XCFramework` |
| 平台 | iOS 真机 + iOS Simulator |
| 最低系统 | iOS 15.0 |
| 构建类型 | release |
| Xcode | 26.6 (17F113) |
| 文件大小 | `3692911` bytes |
| SHA-256 | `f8809e6e9c9ee8e242874721664e99a27829bae721447ee9671a0874b8b85fa8` |

## 接入方式

1. 下载并解压 `salesmartly-chat-ios-sdk-v0.1.0.zip`。
2. 将 `SalesmartlyChat.xcframework` 添加到宿主 App Target。
3. 在 `Frameworks, Libraries, and Embedded Content` 中设置为 `Embed & Sign`。
4. 在 Swift 文件中 `import SalesmartlyChat` 后接入公开 API。
