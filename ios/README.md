# SaleSmartly Chat iOS SDK

该目录存放 SaleSmartly Chat iOS 原生 SDK 二进制发布包和 Demo 示例工程，不提交 SDK 源码。SDK 提供原生聊天运行时、SwiftUI Host 和 UIKit 容器。

## 最新版本

当前版本为 `1.0.0`。

- [下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/main/ios/sdk/salesmartly-chat-ios-sdk-v1.0.0.zip)
- [查看 Demo 源码](demo/demo-source)

> **入口说明：** SDK 不提供默认外部入口、悬浮按钮或 Launcher。宿主必须自行实现聊天按钮，并在按钮点击事件中调用 `SalesmartlyChat.openChat()` 打开聊天。

`1.0.0` 将 SDK 版本统一为正式版本，并包含此前版本的隐私清单、通知授权策略、聊天图片缩放预览、主输入区外点击收起键盘，以及聊天窗口底部安全区背景修正。

> 从 `0.1.1` 升级时，如此前依赖 `SalesmartlyChatHost` 自带 Launcher，需要改为宿主自行提供入口并调用 `SalesmartlyChat.openChat()`。

## SDK 信息

| 字段 | 值 |
| --- | --- |
| 文件 | `ios/sdk/salesmartly-chat-ios-sdk-v1.0.0.zip` |
| 版本 | `1.0.0` |
| 类型 | `XCFramework`（动态 Framework） |
| 真机架构 | `arm64` |
| Simulator 架构 | `arm64`、`x86_64` |
| 最低系统 | iOS 15.0 |
| 构建类型 | Release |
| 构建工具 | Xcode 26.6（17F113）、Swift 6.3.3 |
| 文件大小 | `7582849` bytes |
| SHA-256 | `8b8b18811575c098ee8565f8f330432c13d0cf20dad52bda8ef61cc0190e5c58` |

当前 ZIP 包发布编译后的 Swift module，已验证的编译环境为 Xcode 26.6（17F113）。使用其他 Swift 编译器版本前，请先在目标工程中完成编译验证。

## 安装

### Swift Package Manager

1. 在 Xcode 中选择 `File > Add Package Dependencies...`。
2. 输入仓库地址 `https://github.com/SaleSmartly-Mobile/Mobile-SDK`。
3. 选择 `1.0.0` 版本，并将 `SalesmartlyChat` product 添加到 App Target。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

也可以在宿主项目的 `Package.swift` 中声明：

```swift
.package(
    url: "https://github.com/SaleSmartly-Mobile/Mobile-SDK.git",
    exact: "1.0.0"
)
```

并在 Target 依赖中添加：

```swift
.product(name: "SalesmartlyChat", package: "Mobile-SDK")
```

### 手动集成 ZIP

1. 下载并解压 `salesmartly-chat-ios-sdk-v1.0.0.zip`。
2. 将 `SalesmartlyChat.xcframework` 拖入宿主工程，并勾选 App Target。
3. 在 `Frameworks, Libraries, and Embedded Content` 中设置为 `Embed & Sign`。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

## 初始化

使用 SaleSmartly 后台提供的 `project_*.js` 地址初始化 SDK。访客 ID 应由宿主首次生成后持久化，并在后续启动中复用。

建议先注册回调，再执行异步初始化：

```swift
import Foundation
import SalesmartlyChat

func startSalesmartlyChat() async throws {
    SalesmartlyChat.push("onReady") { payload in
        print("SaleSmartly ready:", payload)
    }

    let context = SalesmartlyNativeBootstrapContext(
        sourceURL: "your-app://home",
        userAgent: "YourApp iOS",
        navigatorLanguage: Locale.current.identifier,
        beforeSourceURL: "",
        guestUserId: "your-persisted-guest-id"
    )

    try await SalesmartlyChat.initialize(
        scriptURL: "https://your-domain.example/path/project.js",
        nativeBootstrapContext: context
    )
}
```

## 挂载聊天 UI

SDK 只负责展示打开后的聊天 UI，不会自动生成外部入口。接入时需要由宿主完成以下操作：

1. 在宿主页面中实现自定义聊天按钮。
2. 在按钮点击事件中调用 `SalesmartlyChat.openChat()`。
3. SwiftUI 工程挂载 `SalesmartlyChatHost`，UIKit 工程展示 `SalesmartlyChatViewController`。

### SwiftUI

下面的 `Button` 是宿主自定义按钮；点击后通过 `SalesmartlyChat.openChat()` 打开聊天，同时由 `SalesmartlyChatHost` 承载聊天窗口：

```swift
import SalesmartlyChat
import SwiftUI

struct ChatLayer: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Button("Open chat") {
                SalesmartlyChat.openChat()
            }

            SalesmartlyChatHost(runtime: SalesmartlyChat.runtime())
        }
    }
}
```

### UIKit

将以下逻辑放到宿主自定义按钮的点击事件中，通过 API 打开聊天并展示 SDK 容器控制器：

```swift
SalesmartlyChat.openChat()

let chatViewController = SalesmartlyChatViewController(
    runtime: SalesmartlyChat.runtime()
)
chatViewController.modalPresentationStyle = .overFullScreen
present(chatViewController, animated: true)
```

## 用户信息

```swift
SalesmartlyChat.setLoginInfo(
    LoginInfo(
        userId: "user-1001",
        userName: "SaleSmartly User",
        language: "zh-CN",
        phone: "+86 13800000000",
        email: "user@example.com",
        description: "iOS App 用户",
        labelNames: ["ios"],
        customFieldsExt: ["source": "app"]
    )
)

SalesmartlyChat.setUserInfo(["source": "ios-app"])

// 用户退出登录时清理 SDK 用户状态。
SalesmartlyChat.clearUser()
```

## 常用命令

```swift
SalesmartlyChat.openChat()
SalesmartlyChat.closeChat()
SalesmartlyChat.sendTextMessage("你好")

SalesmartlyChat.showCollection(true)
SalesmartlyChat.showOffline(true)
SalesmartlyChat.openCustomEntry("custom_1")

SalesmartlyChat.setNotificationStatus(true)
SalesmartlyChat.hideUpload(["img", "video", "document"])
SalesmartlyChat.hideCloseIcon()
SalesmartlyChat.trackUrl("your-app://home")
```

`hideUpload` 支持 `img`、`video`、`document`。`img` 会同时隐藏图片上传和搜同款入口。

宿主进入前台或后台时，可以同步可见状态：

```swift
SalesmartlyChat.setWindowVisible(true)  // 前台
SalesmartlyChat.setWindowVisible(false) // 后台
```

## 事件回调

使用 `push(_:callback:)` 注册事件，同一事件可以注册多个回调：

```swift
SalesmartlyChat.push("onUnRead") { payload in
    print("Unread:", payload)
}

SalesmartlyChat.push("onReceiveMessage") { payload in
    print("Received:", payload)
}
```

常用事件包括：

| 场景 | 事件 |
| --- | --- |
| 初始化与未读 | `onReady`、`onUnRead` |
| 聊天窗口 | `onOpenChat`、`onCloseChat` |
| 消息 | `onSendMessage`、`onReceiveMessage` |
| 留资 | `onOpenCollection`、`onCollectionInfo` |
| 自定义入口 | `onOpenCustom` |
| 外部渠道 | `onOpenWhatsapp`、`onOpenMessenger`、`onOpenTelegram`、`onOpenEmail`、`onOpenLine`、`onOpenLineApp`、`onOpenInstagram`、`onOpenTikTok`、`onOpenWeixin`、`onOpenVKontakte`、`onOpenZalo` |

回调应在初始化前注册，避免错过 `onReady` 等启动阶段事件。

## Demo 源码

[查看 Demo 源码](demo/demo-source)

Demo 工程通过 `../../sdk/salesmartly-chat-ios-sdk-v1.0.0.zip` 引入 SDK 二进制包，并使用宿主自定义的 `Open chat` 按钮调用 `SalesmartlyChat.openChat()`，可作为 SwiftPM 本地二进制集成和自定义入口参考。运行 Demo 前请完整克隆本仓库，确保相对路径下的 ZIP 安装包存在。
