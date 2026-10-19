# SaleSmartly Chat iOS SDK

该目录存放 SaleSmartly Chat iOS 原生 SDK 二进制发布包和 Demo 示例工程，不提交 SDK 源码。SDK 提供原生聊天运行时、SwiftUI Host 和 UIKit 容器。

## 最新版本

当前版本为 `1.0.5`，2026-10-19 从 `salesmartly-chat-ios` 的 `main` 提交 `7c5dfeaa39a7963a1556f35c1d56d4b1f21451d8` 构建，固定发布提交为 `14db64bf52b33052b55fbb77aaaa30664e86efc1`。

请通过下方固定提交链接下载 `1.0.5` 并核对 SHA-256；已有固定提交链接、旧包和旧标签保持不变，`1.0.4` 包不会自动获得本次修复。

本次修复：

- 修复长文字消息超出气泡宽度后显示不全的问题，保留长按选区及复制选中文字的能力。
- 补齐普通图片、图文图片和搜同款引用的点击预览，缩略图加载成功后打开原图；加载中或失败时不打开预览。

2026-10-16 修订内容继续保留：

- 图片加载接入 Nuke `12.8.0`，按显示尺寸降采样，复用下载和缓存。Nuke 已封装在 SDK 二进制中，宿主无需单独安装，公开接口保持不变。
- 调整顶部栏主行与渠道行的叠层及圆角阴影，保留系统安全区布局，补齐评价完成后的感谢插图与居中布局。
- 普通语音在首次播放前读取并显示时长。MP4 继续使用视频消息和系统预览；确认仅有音轨时隐藏系统 QuickTime 占位图，保留播放控件，正常视频画面不被遮挡，异步识别结果不会恢复用户已暂停的播放。
- 为失败的图片、文件和视频补充可点击失败标识，展示上传失败提示。

2026-09-24 修订中的 Ogg/Opus 语音解码及长按文字消息后拖动选区、仅复制选中文字的能力继续保留。

- [下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/14db64bf52b33052b55fbb77aaaa30664e86efc1/ios/sdk/salesmartly-chat-ios-sdk-v1.0.5.zip)
- [查看 Demo 源码](demo/demo-source)

> **入口说明：** SDK 不提供默认外部入口、悬浮按钮或 Launcher。宿主必须自行实现聊天按钮，并在按钮点击事件中调用 `SalesmartlyChat.openChat()` 打开聊天。

`1.0.3` 修复客服首页已配置的其他渠道入口被侧边栏或单图标设置隐藏的问题，首页显示条件与 Web SDK 保持一致。该版本修订让自定义渠道按 Web 首页规则读取 `entry_url` 并显示原图，覆盖主渠道与其他渠道列表。现有初始化、打开聊天和渠道点击 API 保持不变。

`1.0.0` 将 SDK 版本统一为正式版本，并包含此前版本的隐私清单、通知授权策略、聊天图片缩放预览、主输入区外点击收起键盘，以及聊天窗口底部安全区背景修正。

> 从 `0.1.1` 升级时，如此前依赖 `SalesmartlyChatHost` 自带 Launcher，需要改为宿主自行提供入口并调用 `SalesmartlyChat.openChat()`。

## SDK 信息

| 字段 | 值 |
| --- | --- |
| 文件 | `ios/sdk/salesmartly-chat-ios-sdk-v1.0.5.zip` |
| 版本 | `1.0.5` |
| 类型 | `XCFramework`（动态 Framework） |
| 真机架构 | `arm64` |
| Simulator 架构 | `arm64`、`x86_64` |
| 最低系统 | iOS 15.0 |
| 构建类型 | Release |
| 构建工具 | Xcode 27.1（27A9275）、Swift 6.4（swiftlang-6.4.0.34.1） |
| 文件大小 | `18507512` bytes |
| SHA-256 | `d1c3a25e16610675229dbb5f34858288a3f6397ab8956a10634c2ff67e760381` |

当前 ZIP 包延续 `1.0.2` 的分发方式，启用 `BUILD_LIBRARY_FOR_DISTRIBUTION=YES`，包含三个架构对应的 `.swiftinterface` 文本接口，保留 Xcode 27 模块导入修复。现有初始化和聊天入口 API 保持不变。

本次 App 宿主中 6 项回归全部通过（引用图片 2 项、文字换行与选区复制 4 项），无失败或跳过；覆盖 SwiftUI 无障碍激活动作、原图请求、关闭预览及选区复制。另有 7 项既有图片管线与媒体测试、3 项版本断言通过。引用图片交互通过 `accessibilityActivate` 驱动，未执行真机手势或 XCUITest 触控。

真机 `arm64` 与模拟器 `arm64` / `x86_64` 的 Release 构建、三个架构的 iOS 15 二进制接入类型检查均已通过；dSYM UUID、SDK 资源及 Opus / Nuke 许可证已核验。最低部署目标仍为 iOS 15；本次未执行真机运行或真实客服会话回归，也未验证旧版 Xcode。

分发仓根 SwiftPM 解析及引用新版二进制的 iOS Demo 无签名 Simulator Debug 构建均已通过，校验值与上述 ZIP 一致；本次未运行 Demo UI。

## 安装

### Swift Package Manager

1. 在 Xcode 中选择 `File > Add Package Dependencies...`。
2. 输入仓库地址 `https://github.com/SaleSmartly-Mobile/Mobile-SDK`。
3. 选择 Commit 依赖规则并填写 `14db64bf52b33052b55fbb77aaaa30664e86efc1`，将 `SalesmartlyChat` product 添加到 App Target。该固定提交引用 SDK `1.0.5`。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

也可以在宿主项目的 `Package.swift` 中声明：

```swift
.package(
    url: "https://github.com/SaleSmartly-Mobile/Mobile-SDK.git",
    revision: "14db64bf52b33052b55fbb77aaaa30664e86efc1"
)
```

并在 Target 依赖中添加：

```swift
.product(name: "SalesmartlyChat", package: "Mobile-SDK")
```

### 手动集成 ZIP

1. 下载并解压 `salesmartly-chat-ios-sdk-v1.0.5.zip`。
2. 将 `SalesmartlyChat.xcframework` 拖入宿主工程，并勾选 App Target。
3. 在 `Frameworks, Libraries, and Embedded Content` 中设置为 `Embed & Sign`。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

## 从旧版本升级到 1.0.5

- **SwiftPM：** 将依赖规则改为 Commit/revision `14db64bf52b33052b55fbb77aaaa30664e86efc1`，重新解析依赖并确认 `Package.resolved` 记录该提交，再重新构建。仅刷新缓存或继续锁定旧提交不会获得本次修复。
- **手动集成：** 使用本文新的固定提交下载链接，核对上方 SHA-256，解压并完整替换工程中的 `SalesmartlyChat.xcframework`，保持 `Embed & Sign`。不要复用本地旧 ZIP，也不要只替换内部可执行文件。
- **CocoaPods 包装或本地 Pod：** 如果项目通过自行维护的 Pod 引入旧二进制，需要让该 Pod 的维护方将其引用的完整 XCFramework 更新为新版，再更新对应依赖。本仓库未提供官方 Pod；若项目已维护名为 `SalesmartlyChat` 的 Pod，更新其下载 URL 和 SHA 后，执行 `pod update SalesmartlyChat --no-repo-update` 并提交锁文件，普通 `pod install` 可能继续使用同版本旧包。
- 确认工程只引用一份 SDK。替换后执行 `Product > Clean Build Folder` 再构建；仅当仍加载旧包时，再重置包缓存或清理该工程的 DerivedData。
- Nuke `12.8.0` 已封装在二进制内，无需额外添加 Nuke 依赖；现有初始化和聊天入口 API 保持不变。重新构建 App 后，验证长文字换行、选区复制、引用图片预览及原有聊天功能。
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

Demo 工程通过 `../../sdk/salesmartly-chat-ios-sdk-v1.0.5.zip` 引入 SDK 二进制包，并使用宿主自定义的 `Open chat` 按钮调用 `SalesmartlyChat.openChat()`，可作为 SwiftPM 本地二进制集成和自定义入口参考。运行 Demo 前请完整克隆本仓库，确保相对路径下的 ZIP 安装包存在。
