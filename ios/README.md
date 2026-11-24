# SaleSmartly Chat iOS SDK

该目录存放 SaleSmartly Chat iOS 原生 SDK 二进制发布包和 Demo 示例工程，不提交 SDK 源码。SDK 提供原生聊天运行时、SwiftUI Host 和 UIKit 容器。

有关方法签名、参数、回调和调用示例，请参阅 [iOS API 参考](../docs/ios-api.md)。

## 1.1.x 维护发布

当前版本为 `1.1.1`，于 2026-11-19 发布，从源码标签 `v1.1.1` 对应提交 `77caa78466cd55c7b623811203c52a38d27c440c` 构建，固定发布提交为 `130179239110d014a5e446acffdcc051efa56f52`。

请通过下方固定提交链接下载 `1.1.1` 并核对 SHA-256。

`1.1.1` 修复聊前留资和促销卡对邮箱用户名中连续连字符的误判。发送载荷沿用 `1.1.x`，不再自动附加 `sdk_platform` 和宿主 Bundle ID `host_app`。已使用 `1.2.0` 的接入方如需保留这些字段，可继续使用 [1.2.0 固定 ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/86d1cf20279209b0feb0e120434870e60a33c367/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0.zip) 和 [1.2.0 固定 podspec](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/eed26d3624451b00c66088cfaf3aa325fb5ba56b/ios/sdk/SalesmartlyChat-1.2.0.podspec)。

`1.1.0` 的视频保存功能，见 [历史 ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/cdcb8d3a4aeb8389980398dff84a93e7941a57c2/ios/sdk/salesmartly-chat-ios-sdk-v1.1.0.zip) 和 [历史 podspec](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/c38ffacb0525a3a6afb18ae8939bd9b02d2bd470/ios/sdk/SalesmartlyChat-1.1.0.podspec)。

- 普通视频、视频图文和模板视频的预览页增加保存到系统相册入口。显示保存中状态并禁止重复点击，Photos 完成写入后才提示成功；下载或写入失败、权限拒绝、宿主未配置权限说明分别提示。
- 保存时仅请求新增相册内容的 `.addOnly` 权限，不读取用户已有照片或视频；宿主需配置 `NSPhotoLibraryAddUsageDescription`，见下方[权限说明](#视频保存到相册权限)。
- 保存流程复用消息对应的下载换签，外部视频 URL 直接下载；换签失败时提示保存失败。现有公开 API 和消息协议保持不变。

2026-11-04 的 `1.0.7` 功能继续保留：

- `sendAttachment(fileURL:type:completion:)` 接收本地文件 `URL` 与明确的 `.image` / `.file`，打开聊天并上传发送，不再二次预览。宿主负责截图提示、预览确认及本地日志查找、打包与脱敏。
- 单文件上限为 20 MiB；最终结果以服务端 ACK / 匹配消息 ID 回显为准，支持同消息重试、身份切换取消和关窗保留任务。180 秒总超时在留资等待期间暂停；`hideUpload` 仅隐藏 UI 入口，不阻止宿主 API。

该历史版本从源码提交 `7589142447b6eff5c757cbdf0419a84362954e95` 构建：[下载 1.0.7 ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/b8defdc91e4bdcdc74389c54aefa3dbfc1a84d28/ios/sdk/salesmartly-chat-ios-sdk-v1.0.7.zip)，大小 `18706532` bytes，SHA-256 为 `f90b54184957569d210e2c2e50ad6ee13453dc30cdf3f1e77a2cc5e8e006f968`；[1.0.7 官方 podspec](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/5a736385547a3fcffd1940feb072b91da5c76015/ios/sdk/SalesmartlyChat-1.0.7.podspec) 保持可用。

该批次通过 295 项 SwiftPM 回归和 2 项 iOS 27 App 宿主交互测试，无相关失败或跳过。宿主测试覆盖直接打开聊天、关闭并释放控制器后继续上传，以及点击真实失败气泡后按原消息 ID 重试；交互通过 SwiftUI 无障碍激活与测试传输实现验证，未执行物理真机或线上真实客服会话。

该批次真机 `arm64` 与模拟器 `arm64` / `x86_64` 的 Release 构建、三个架构的 iOS 15 `sendAttachment` API 二进制接入类型检查均已通过；dSYM UUID、SDK 资源及 Opus / Nuke 许可证已核验。分发仓根 SwiftPM 解析及引用 `1.0.7` 的 iOS Demo 无签名 Simulator Debug 构建均已通过，校验值与该版本 ZIP 一致；未运行 Demo UI，也未验证旧版 Xcode。

2026-10-26 的 `1.0.6` 修复继续保留：

- 随 App 生命周期暂停后台 Socket.IO 自动重连、SSE 重试与在线心跳，回前台恢复已有会话，保留用户发送、上传及 ACK。
- 作废迟到的 token / SSE 打开回调，避免后台重新建流；重复前台通知不重复补拉或绕过退避，入房成功清除旧会话错误。
- 错误回调保留 `phase`、`operation`、`code`、`message`，增加可选 `native_error_code`（字符串）、`http_status`（整数）和 `is_transient`（布尔值）。明确断网 / 超时 / 连接中断与 TLS、DNS、HTTP、解析及未知故障分开分类，取消请求不作为故障上报。

2026-10-19 的 `1.0.5` 修复继续保留：

- 修复长文字消息超出气泡宽度后显示不全的问题，保留长按选区及复制选中文字的能力。
- 补齐普通图片、图文图片和搜同款引用的点击预览，缩略图加载成功后打开原图；加载中或失败时不打开预览。

2026-10-16 修订内容继续保留：

- 图片加载接入 Nuke `12.8.0`，按显示尺寸降采样，复用下载和缓存。Nuke 已封装在 SDK 二进制中，宿主无需单独安装，公开接口保持不变。
- 调整顶部栏主行与渠道行的叠层及圆角阴影，保留系统安全区布局，补齐评价完成后的感谢插图与居中布局。
- 普通语音在首次播放前读取并显示时长。MP4 继续使用视频消息和系统预览；确认仅有音轨时隐藏系统 QuickTime 占位图，保留播放控件，正常视频画面不被遮挡，异步识别结果不会恢复用户已暂停的播放。
- 为失败的图片、文件和视频补充可点击失败标识，展示上传失败提示。

2026-09-24 修订中的 Ogg/Opus 语音解码及长按文字消息后拖动选区、仅复制选中文字的能力继续保留。

- [下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/130179239110d014a5e446acffdcc051efa56f52/ios/sdk/salesmartly-chat-ios-sdk-v1.1.1.zip)
- [查看 Demo 源码](demo/demo-source)

> **入口说明：** SDK 不提供默认外部入口、悬浮按钮或 Launcher。宿主必须自行实现聊天按钮，并在按钮点击事件中调用 `SalesmartlyChat.openChat()` 打开聊天。

`1.0.3` 修复客服首页已配置的其他渠道入口被侧边栏或单图标设置隐藏的问题，首页显示条件与 Web SDK 保持一致。该版本修订让自定义渠道按 Web 首页规则读取 `entry_url` 并显示原图，覆盖主渠道与其他渠道列表。现有初始化、打开聊天和渠道点击 API 保持不变。

`1.0.0` 将 SDK 版本统一为正式版本，并包含此前版本的隐私清单、通知授权策略、聊天图片缩放预览、主输入区外点击收起键盘，以及聊天窗口底部安全区背景修正。

> 从 `0.1.1` 升级时，如此前依赖 `SalesmartlyChatHost` 自带 Launcher，需要改为宿主自行提供入口并调用 `SalesmartlyChat.openChat()`。

## 1.2.0 发送成功日志修订

1.2.0 发送成功日志修订于 2026-11-24 发布，覆盖 Socket.IO、普通 HTTP 和 SSE。源码标签为 `v1.2.0-send-log-r1`，从提交 `731bd89ba69ab1b46f66ced17e4fba8e43023def` 构建。

- [iOS XCFramework ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0-send-log-r1.zip) · [校验清单](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0-send-log-r1.manifest.json)
- 文件大小 `18917254` 字节，SHA-256 `5ce22d20bd5489825e85c1432d4dc27ef620af6b2e13ea5f3173322e24399166`。

可下载 ZIP 或通过 [1.2.0 修订版 podspec](sdk/SalesmartlyChat-1.2.0-send-log-r1.podspec) 接入 CocoaPods。

## SDK 信息

| 字段 | 值 |
| --- | --- |
| 文件 | `ios/sdk/salesmartly-chat-ios-sdk-v1.1.1.zip` |
| 版本 | `1.1.1` |
| 类型 | `XCFramework`（动态 Framework） |
| 真机架构 | `arm64` |
| Simulator 架构 | `arm64`、`x86_64` |
| 最低系统 | iOS 15.0 |
| 构建类型 | Release |
| 构建工具 | Xcode 27.1（27A9275）、Swift 6.4（swiftlang-6.4.0.34.1） |
| 文件大小 | `18879141` bytes |
| SHA-256 | `5f076f7313bef6db2363e401bbe5ced0da28b87739e4b985021350c9da51303b` |

当前 ZIP 包延续 `1.0.2` 的分发方式，启用 `BUILD_LIBRARY_FOR_DISTRIBUTION=YES`，包含三个架构对应的 `.swiftinterface` 文本接口，保留 Xcode 27 模块导入修复。现有初始化和聊天入口 API 保持不变。

本次通过 6 项版本、留资和促销卡定向测试。设备 `arm64` 与模拟器 `arm64` / `x86_64` 的 Release 构建及三个架构的消费类型检查通过，dSYM UUID、资源和许可证已核验。

根 SwiftPM 解析及 iOS Demo 的 arm64 模拟器构建通过。Demo 内置版本、arm64 UUID 和资源均与 ZIP 一致。本次验证覆盖定向测试和构建。

## 安装

### Swift Package Manager

1. 在 Xcode 中选择 `File > Add Package Dependencies...`。
2. 输入仓库地址 `https://github.com/SaleSmartly-Mobile/Mobile-SDK`。
3. 选择 Commit 依赖规则并填写 `130179239110d014a5e446acffdcc051efa56f52`，将 `SalesmartlyChat` product 添加到 App Target。该固定提交引用 SDK `1.1.1`。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

也可以在宿主项目的 `Package.swift` 中声明：

```swift
.package(
    url: "https://github.com/SaleSmartly-Mobile/Mobile-SDK.git",
    revision: "130179239110d014a5e446acffdcc051efa56f52"
)
```

并在 Target 依赖中添加：

```swift
.product(name: "SalesmartlyChat", package: "Mobile-SDK")
```

### CocoaPods

在 `Podfile` 的 App target 中加入以下依赖，安装 iOS SDK 1.1.1：

```ruby
pod 'SalesmartlyChat', :podspec => 'https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/e8a6113b9e2e48c1fb0799948b41510bdca5456a/ios/sdk/SalesmartlyChat-1.1.1.podspec'
```

执行 `pod install`，用 Xcode 打开生成的 `.xcworkspace`，在 Swift 文件中添加 `import SalesmartlyChat`。SDK 最低支持 iOS 15.0。

当前通过 GitHub 提供官方 podspec，请保留上述 `:podspec` 地址。此版本尚未发布到 CocoaPods Trunk。

### 手动集成 ZIP

1. 下载并解压 `salesmartly-chat-ios-sdk-v1.1.1.zip`。
2. 将 `SalesmartlyChat.xcframework` 拖入宿主工程，并勾选 App Target。
3. 在 `Frameworks, Libraries, and Embedded Content` 中设置为 `Embed & Sign`。
4. 在 Swift 文件中添加 `import SalesmartlyChat`。

### 视频保存到相册权限

宿主 App 的 `Info.plist` 必须包含非空的新增相册内容用途说明；SDK 无法代替宿主配置该项。例如：

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>用于将聊天中的视频保存到您的相册。</string>
```

用户点击视频预览页的保存按钮时，SDK 通过 Photos 请求 `.addOnly` 授权，仅新增视频，不读取已有照片或视频。本功能无需申请读取图库权限。缺少上述配置时会提示“当前应用未配置相册保存权限”；用户拒绝时会提示前往系统设置允许保存到相册，授权后可再次保存。

## 接入 1.1.1

- **SwiftPM：** 将依赖规则改为 Commit/revision `130179239110d014a5e446acffdcc051efa56f52`，重新解析依赖并确认 `Package.resolved` 记录该提交，再重新构建。仅刷新缓存或继续锁定旧提交不会获得本次功能。
- **手动集成：** 使用本文新的固定提交下载链接，核对上方 SHA-256，解压并完整替换工程中的 `SalesmartlyChat.xcframework`，保持 `Embed & Sign`。不要复用本地旧 ZIP，也不要只替换内部可执行文件。
- **CocoaPods：** 使用上方的官方 `:podspec` 地址后，执行 `pod update SalesmartlyChat --no-repo-update` 并提交更新后的锁文件。若继续使用自维护 Pod，由维护方更新完整 XCFramework 的下载地址及 SHA-256，再更新对应依赖。
- 确认工程只引用一份 SDK。替换后执行 `Product > Clean Build Folder` 再构建；仅当仍加载旧包时，再重置包缓存或清理该工程的 DerivedData。
- 为宿主 `Info.plist` 配置上方 `NSPhotoLibraryAddUsageDescription`；重新构建 App 后验证视频保存、授权和拒绝提示。
- Nuke `12.8.0` 已封装在二进制内，无需额外添加 Nuke 依赖；现有初始化和聊天入口 API 保持不变。重新构建 App 后，验证附件发送、断网恢复、前后台切换及原有聊天功能。
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

Demo 工程通过 `../../sdk/salesmartly-chat-ios-sdk-v1.1.1.zip` 引入 SDK 二进制包，并使用宿主自定义的 `Open chat` 按钮调用 `SalesmartlyChat.openChat()`，可作为 SwiftPM 本地二进制集成和自定义入口参考。Demo 的 `Info.plist` 已配置 `NSPhotoLibraryAddUsageDescription`。运行 Demo 前请完整克隆本仓库，确保相对路径下的 ZIP 安装包存在。
