# SaleSmartly Chat iOS SDK

该目录存放 SaleSmartly Chat iOS SDK 二进制发布包和 Demo 示例工程，不提交 SDK 源码。

## Demo 源码

[查看 Demo 源码](demo/demo-source)

Demo 工程通过 `../../sdk/salesmartly-chat-ios-sdk-v0.1.0.zip` 引入 SDK 二进制包。

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
| 文件大小 | `5286291` bytes |
| SHA-256 | `737cee9c6ab8d13bd1f12df609cb840d2a807b4c60500c78f92f9e718c542f01` |

## 接入方式

### Swift Package Manager

1. 在 Xcode 中打开 `File > Add Package Dependencies...`。
2. 输入仓库地址 `https://github.com/SaleSmartly-Mobile/Mobile-SDK`。
3. 选择版本 `0.1.0`，并添加 `SalesmartlyChat` product。
4. 在 Swift 文件中 `import SalesmartlyChat` 后接入公开 API。

### 手动集成 ZIP

1. 下载并解压 `salesmartly-chat-ios-sdk-v0.1.0.zip`。
2. 将 `SalesmartlyChat.xcframework` 添加到宿主 App Target。
3. 在 `Frameworks, Libraries, and Embedded Content` 中设置为 `Embed & Sign`。
4. 在 Swift 文件中 `import SalesmartlyChat` 后接入公开 API。
