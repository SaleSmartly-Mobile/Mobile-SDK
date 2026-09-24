# SaleSmartly Chat iOS SDK

该目录存放 SaleSmartly Chat iOS 原生 SDK 二进制发布包和 Demo 示例工程，不提交 SDK 源码。SDK 提供原生聊天运行时、SwiftUI Host 和 UIKit 容器。

## 最新版本

当前版本为 `1.0.4`，2026-09-24 修订包含 Ogg/Opus 语音解码，并支持长按文字消息后拖动选区、仅复制选中文字。

本次继续使用 `1.0.4` 版本号和 ZIP 文件名。请通过下方固定提交链接下载；早期 `1.0.4` 包不包含文字选区复制功能，已有固定提交链接和旧标签保持不变。

- [下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/6cbc087fcdcba70cad92ee017b97e4a36dcd4f3d/ios/sdk/salesmartly-chat-ios-sdk-v1.0.4.zip)
- [查看 Demo 源码](demo/demo-source)

> **入口说明：** SDK 不提供默认外部入口、悬浮按钮或 Launcher。宿主必须自行实现聊天按钮，并在按钮点击事件中调用 `SalesmartlyChat.openChat()` 打开聊天。

`1.0.3` 修复客服首页已配置的其他渠道入口被侧边栏或单图标设置隐藏的问题，首页显示条件与 Web SDK 保持一致。该版本修订让自定义渠道按 Web 首页规则读取 `entry_url` 并显示原图，覆盖主渠道与其他渠道列表。现有初始化、打开聊天和渠道点击 API 保持不变。

`1.0.0` 将 SDK 版本统一为正式版本，并包含此前版本的隐私清单、通知授权策略、聊天图片缩放预览、主输入区外点击收起键盘，以及聊天窗口底部安全区背景修正。

> 从 `0.1.1` 升级时，如此前依赖 `SalesmartlyChatHost` 自带 Launcher，需要改为宿主自行提供入口并调用 `SalesmartlyChat.openChat()`。

## SDK 信息

| 字段 | 值 |
| --- | --- |
| 文件 | `ios/sdk/salesmartly-chat-ios-sdk-v1.0.4.zip` |
| 版本 | `1.0.4` |
| 类型 | `XCFramework`（动态 Framework） |
| 真机架构 | `arm64` |
| Simulator 架构 | `arm64`、`x86_64` |
| 最低系统 | iOS 15.0 |
| 构建类型 | Release |
| 构建工具 | Xcode 27.0（27A266a）、Swift 6.4 |
| 文件大小 | `15159125` bytes |
| SHA-256 | `a88abd3dc0a85a60c26eaf910d72f612d53d9ac7b0128d281f4f481f0e053516` |

当前 ZIP 包延续 `1.0.2` 的分发方式，启用 `BUILD_LIBRARY_FOR_DISTRIBUTION=YES`，包含三个架构对应的 `.swiftinterface` 文本接口，保留 Xcode 27 模块导入修复。现有初始化和聊天入口 API 保持不变。

已通过真机与模拟器 Release 构建、三个架构的 iOS 15 consumer 类型检查、7 项链接与语音回归测试，以及 iOS 26.5 的 4 项 App 宿主测试和 1 项长按拖动选区后系统复制的 UI 测试。三个架构的公开接口、dSYM UUID、SDK 资源及 Opus 许可证已核验。最低部署目标仍为 iOS 15；本次未验证旧版 Xcode、真机运行或真实客服会话收发。

## 安装

### Swift Package Manager

1. 在 Xcode 中选择 `File > Add Package Dependencies...`。
2. 输入仓库地址 `https://github.com/SaleSmartly-Mobile/Mobile-SDK`。
3. 选择 Commit 依赖规则并填写 `6cbc087fcdcba70cad92ee017b97e4a36dcd4f3d`，将 `SalesmartlyChat` product 添加到 App Target。请使用该固定提交，版本号相同不代表二进制内容相同。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

也可以在宿主项目的 `Package.swift` 中声明：

```swift
.package(
    url: "https://github.com/SaleSmartly-Mobile/Mobile-SDK.git",
    revision: "6cbc087fcdcba70cad92ee017b97e4a36dcd4f3d"
)
```

并在 Target 依赖中添加：

```swift
.product(name: "SalesmartlyChat", package: "Mobile-SDK")
```

### 手动集成 ZIP

1. 下载并解压 `salesmartly-chat-ios-sdk-v1.0.4.zip`。
2. 将 `SalesmartlyChat.xcframework` 拖入宿主工程，并勾选 App Target。
3. 在 `Frameworks, Libraries, and Embedded Content` 中设置为 `Embed & Sign`。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

## 从旧版本或早期 1.0.4 包升级到本次修订

- **SwiftPM：** 将依赖规则改为 Commit/revision `6cbc087fcdcba70cad92ee017b97e4a36dcd4f3d`，重新解析依赖并确认 `Package.resolved` 记录该提交，再重新构建。仅刷新缓存或继续锁定旧提交不会获得本次修订。
- **手动集成：** 使用本文新的固定提交下载链接，核对上方 SHA-256，解压并完整替换工程中的 `SalesmartlyChat.xcframework`，保持 `Embed & Sign`。文件名相同不代表内容相同；不要复用本地旧 ZIP，也不要只替换内部可执行文件。
- **CocoaPods 包装或本地 Pod：** 如果项目通过自行维护的 Pod 引入旧二进制，需要让该 Pod 的维护方将其引用的完整 XCFramework 更新为新版，再更新对应依赖。本仓库未提供官方 Pod；若项目已维护名为 `SalesmartlyChat` 的 Pod，更新其下载 URL 和 SHA 后，执行 `pod update SalesmartlyChat --no-repo-update` 并提交锁文件，普通 `pod install` 可能继续使用同版本旧包。
- 确认工程只引用一份 SDK。替换后执行 `Product > Clean Build Folder` 再构建；仅当仍加载旧包时，再重置包缓存或清理该工程的 DerivedData。
- 现有初始化和聊天入口 API 保持不变。重新构建 App 后，验证语音播放、文字长按拖动选区及复制内容。
- 接入方需重新构建并发布 App 更新；已经安装的 App 不会因 GitHub 仓库更新而自动替换 SDK。
- 从 `1.0.1` 或更早版本升级时，若宿主对 SDK 的公开枚举进行穷举 `switch`，请根据编译诊断补充 `@unknown default` 分支；这是 `1.0.2` 启用 library evolution 后的接入要求。

如果升级后仍出现 Swift 模块导入错误，请提供 Xcode 完整版本、接入方式、实际解析的 SDK 版本、目标为真机或模拟器，以及完整文本构建日志。

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

Demo 工程通过 `../../sdk/salesmartly-chat-ios-sdk-v1.0.4.zip` 引入 SDK 二进制包，并使用宿主自定义的 `Open chat` 按钮调用 `SalesmartlyChat.openChat()`，可作为 SwiftPM 本地二进制集成和自定义入口参考。运行 Demo 前请完整克隆本仓库，确保相对路径下的 ZIP 安装包存在。
