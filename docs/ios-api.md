# SaleSmartly Chat iOS SDK API 参考

本文适用于 iOS SDK 1.0.7，最低支持 iOS 15。接入工程后导入 `SalesmartlyChat`。安装、版本和 Demo 见 [iOS 接入指南](../ios/README.md)。Android 对应接口见 [Android API 参考](android-api.md)。

- [初始化与聊天容器](#初始化与聊天容器)
- [访客身份与语言](#访客身份与语言)
- [聊天窗口与消息](#聊天窗口与消息)
- [留资、通知与入口](#留资通知与入口)
- [进阶宿主接口](#进阶宿主接口)
- [事件与错误回调](#事件与错误回调)
- [命令方式](#命令方式)

## 初始化与聊天容器

### `initialize`

使用 SaleSmartly 后台提供的 `project_*.js` 地址初始化。建议在宿主启动 SDK 时注册一次事件监听。脚本初始化通过 `async throws` 抛出脚本加载或解析错误，后续插件配置、会话等异步故障可通过 [`onError`](#onerror) 监听。

| 签名 | 用途 |
| --- | --- |
| `initialize(scriptURL: String, nativeBootstrapContext: SalesmartlyNativeBootstrapContext) async throws` | 用脚本地址和宿主上下文启动。另有 `scriptURL: URL` 重载。 |
| `initialize(scriptURL: String) async throws` | 仅用脚本地址初始化。另有 `scriptURL: URL` 重载。访客会话接入请使用带上下文的重载。 |
| `initialize(scriptURL: URL, environment: SalesmartlyEnvironment) async throws` | 用脚本地址和显式环境初始化。可再传 `nativeBootstrapContext:`。 |
| `initialize(config: SalesmartlyConfig)` | 使用 `SalesmartlyConfig(license:setting:)` 直接配置。默认 `setting` 为 `SalesmartlySetting()`，其 `mode` 为 `.chat`。 |

`SalesmartlyNativeBootstrapContext` 的五个参数均为 `String`。

| 参数 | 说明 |
| --- | --- |
| `sourceURL` | 当前宿主页面地址。 |
| `userAgent` | 宿主客户端标识。 |
| `navigatorLanguage` | 宿主语言，例如 `Locale.current.identifier`。 |
| `beforeSourceURL` | 来源页面地址，没有来源时可传空字符串。 |
| `guestUserId` | 宿主持久化的访客 ID。首次生成后在后续启动中复用。 |

```swift
import Foundation
import SalesmartlyChat

@MainActor
func startChatSDK(scriptURL: String, guestUserId: String) async throws {
    SalesmartlyChat.push("onError") { payload in
        if let phase = payload["phase"] as? String, let code = payload["code"] as? String {
            print(phase, code)
        }
    }

    let context = SalesmartlyNativeBootstrapContext(
        sourceURL: "your-app://home",
        userAgent: "YourApp iOS",
        navigatorLanguage: Locale.current.identifier,
        beforeSourceURL: "",
        guestUserId: guestUserId
    )
    try await SalesmartlyChat.initialize(scriptURL: scriptURL, nativeBootstrapContext: context)
}
```

### SwiftUI 和 UIKit

聊天按钮由宿主提供。SwiftUI 将 `SalesmartlyChatHost` 挂在宿主页面，通过按钮打开聊天。UIKit 通过 `SalesmartlyChatViewController` 呈现聊天窗口，可在 `onOpenChat` 到达后呈现控制器，兼顾插件配置仍在加载的情况。两个容器的 `init(runtime:)` 都默认使用 `SalesmartlyChat.runtime()` 返回的共享实例。

```swift
import SalesmartlyChat
import SwiftUI

struct ChatLayer: View {
    var body: some View {
        ZStack {
            Button("联系客服") {
                SalesmartlyChat.openChat()
            }
            SalesmartlyChatHost()
        }
    }
}
```

```swift
import SalesmartlyChat
import UIKit

@MainActor
func registerChatPresentation(from presenter: UIViewController) {
    SalesmartlyChat.push("onOpenChat") { [weak presenter] _ in
        Task { @MainActor in
            guard let presenter, presenter.presentedViewController == nil,
                  SalesmartlyChat.runtime().state.showWrapper else { return }
            let chat = SalesmartlyChatViewController()
            chat.modalPresentationStyle = .overFullScreen
            presenter.present(chat, animated: true)
        }
    }
}
```

在 UIKit 宿主中注册一次上面的监听，再让聊天按钮调用 `SalesmartlyChat.openChat()`。如果宿主维护自己的窗口状态，可用 `SalesmartlyChat.runtime().state` 读取 `ChatRuntimeState`，例如 `showWrapper`、`currentView` 和 `unReadNum`。`observeState(_:) -> Int` 订阅后续状态变更，使用返回值调用 `removeStateObserver(_:)` 解除订阅。`SalesmartlyChat.reset(runtime: SalesmartlyRuntime = SalesmartlyRuntime())` 会替换共享实例，需重新挂载依赖该实例的容器和监听。

## 访客身份与语言

### `setLoginInfo(_ loginInfo: LoginInfo)`

为聊天设置业务用户身份和资料。以下字段均可省略。识别已登录用户时请提供稳定的 `userId` 和显示名称。用户 ID 变化时 SDK 切换本地会话，调用返回后仍可能在处理网络请求。

| 字段 | 类型和默认值 | 说明 |
| --- | --- | --- |
| `userId` | `String? = nil` | 宿主业务用户 ID。上限为 300 个 UTF-16 码元，超出时本次调用会被忽略。 |
| `userName` | `String? = nil` | 用户显示名称。 |
| `language` | `String? = nil` | 聊天语言。不支持的语言代码按 `en-US` 处理。 |
| `phone` | `String? = nil` | 手机号。 |
| `email` | `String? = nil` | 邮箱。 |
| `description` | `String? = nil` | 用户描述。 |
| `labelNames` | `[String] = []` | SaleSmartly 中已配置的标签名称，仅在新建访客会话时发送。 |
| `customFieldsExt` | `[String: String] = [:]` | 自定义字段 ID 与字符串值，仅在新建访客会话时发送。 |

可直接传入的语言代码为 `zh-CN`、`zh-HK`、`en-US`、`ru-RU`、`th-TH`、`vi-VN`、`mn`、`ja-JP`、`fr`、`pt`、`es`、`ar`、`de`、`ro`、`pl`、`id`、`ko`、`nl`、`da`、`it`、`tr`、`bn`。

```swift
import SalesmartlyChat

func identifyChatUser(id: String, name: String) {
    SalesmartlyChat.setUserInfo(["source": "ios-app"])
    SalesmartlyChat.setLoginInfo(LoginInfo(userId: id, userName: name, language: "zh-CN"))
}
```

### `setUserInfo` 和 `clearUser()`

- `setUserInfo(_ userInfo: [String: String])` 和 `setUserInfo(_ userInfo: SalesmartlyPayload)` 在 SDK 本地保存扩展资料。iOS 1.0.7 的创建用户请求不会发送这组资料。使用后者时，字典必须可序列化为 JSON 对象。无法序列化时会发出 `onError`，其中 `operation` 为 `setUserInfo`，`code` 为 `decode`。
- `clearUser()` 用于宿主用户退出登录时清理本地身份状态，切回访客会话。

## 聊天窗口与消息

| 签名 | 行为 |
| --- | --- |
| `openChat()`、`open()` | 打开聊天窗口。启用插件首页时先显示首页，否则进入聊天页。加载插件配置时会保留打开请求。 |
| `closeChat()` | 关闭窗口和自定义入口弹层，取消尚在等待的打开请求。 |
| `setWindowVisible(_ isVisible: Bool) -> SalesmartlyPayload?` | 同步宿主窗口可见性，可能返回已读请求数据。SwiftUI 和 UIKit 容器已接入各自的生命周期。 |
| `sendTextMessage(_ text: String)` | 发送文本。可通过 `onSendMessage` 监听发送事件，当前有流式回复发送时会忽略此调用。 |
| `hideUpload(_ types: [String])` | 替换隐藏的上传入口列表。`img` 同时隐藏图片上传和搜同款，`video` 隐藏视频上传，`document` 隐藏文件上传。对应类型的粘贴上传也会被拦截。传空数组清空本设置。 |
| `hideCloseIcon(_ hidden: Bool = true)` | 控制聊天窗口的关闭按钮。传 `false` 取消此项隐藏设置，实际展示仍受窗口模式影响。 |

插件配置已加载时，可调用 `SalesmartlyChat.runtime().openChat()` 跳过插件首页，直接进入聊天页。

### `sendAttachment(fileURL:type:completion:)`

从 1.0.7 起，宿主可直接发送用户已确认的本地截图或文件。使用已初始化的真实聊天会话，在主 actor 调用 `sendAttachment(fileURL: URL, type: SalesmartlyAttachmentType, completion: @escaping SalesmartlyCallback)`。SDK 会打开聊天页并发送附件。宿主负责预览确认，以及选择、打包和脱敏日志文件。

| 参数 | 类型 | 说明 |
| --- | --- | --- |
| `fileURL` | `URL` | 可读取的本地文件 URL。单文件最大 20 MiB，空文件无效。 |
| `type` | `SalesmartlyAttachmentType` | `.image` 发送图片消息，`.file` 发送普通文件并保留文件名。 |
| `completion` | `SalesmartlyCallback` | 在主线程报告该次调用的最终结果，最多调用一次。收到服务端 ACK 或匹配同一客户端消息 ID 的服务端回显后才报告成功。 |

回调字典始终包含 `success: Bool` 和 `c_m_id: String`（客户端消息 ID）。失败时另带 `error: SalesmartlyPayload`，字段见 [错误回调](#onerror)。SDK 尚未初始化时会立即返回失败。总超时为 180 秒，等待留资期间暂停计时，提交后继续。关闭留资表单会取消正在等待留资的任务。切换或清理用户身份会取消进行中的任务，关闭聊天窗口会保留任务。使用 `hideUpload` 隐藏入口后，宿主仍可调用此方法。失败气泡里的重试沿用原消息，原调用的回调已结束。

```swift
import Foundation
import SalesmartlyChat

@MainActor
func sendConfirmedFile(_ fileURL: URL) {
    SalesmartlyChat.sendAttachment(fileURL: fileURL, type: .file) { result in
        if result["success"] as? Bool == true {
            print("附件发送成功")
        } else if let error = result["error"] as? SalesmartlyPayload,
                  let code = error["code"] as? String {
            print("附件发送失败", code)
        }
    }
}
```

## 留资、通知与入口

| 签名 | 行为 |
| --- | --- |
| `showCollection()`、`showCollection(_ visible: Bool)` | 显示或收起普通留资表单。无参调用等同于传 `true`。打开时会关闭离线留资。 |
| `showOffline()`、`showOffline(_ visible: Bool)` | 显示或收起离线留资表单。无参调用等同于传 `true`。打开时会关闭普通留资。 |
| `openCustomEntry(_ entryId: String)` | 已打开聊天且处于非 Demo 模式时，打开后台已配置的文字或图片入口弹层，例如 `custom_1`。 |
| `trackUrl(_ url: String)` | 记录宿主当前页面地址。 |
| `setNotificationStatus(_ enabled: Bool)` | 开启或关闭 SDK 未读通知。iOS 系统通知权限由宿主申请。 |

## 进阶宿主接口

自定义宿主可使用下列接口同步入口尺寸、通知和计时状态。

| 签名 | 行为 |
| --- | --- |
| `getSidebarHeight() -> Int?`、`getSidebarHeight(callback: SalesmartlySidebarHeightCallback)` | 读取已记录的折叠入口高度。无高度时返回 `nil`，回调版本不会调用闭包。 |
| `setCollapsedSidebarHeight(_ height: Int)`、`setLauncherHeightTargetFrames(_ frames: [SalesmartlyLauncherHeightTargetFrame])` | 自定义入口可直接写入高度或提供 `top`、`bottom`、`height`，SDK 按可见区域整体跨度向上取整。 |
| `setNotificationConfiguration(flashTitle: Bool, soundNotice: Bool)` | 设置未读标题闪烁和声音提醒。 |
| `setNotificationHandler(_ handler: SalesmartlyNotificationHandling?)` | 注入宿主的通知处理器。 |
| `handleUnreadNotificationClick()` | 通知被点击后，调用已配置处理器的 `focusNotificationTarget()` 和 `closeUnreadNotification()`。 |
| `setNotificationTitleConfiguration(originTitle: String, newMessageTitle: String)`、`setNotificationCurrentTitle(_ title: String)` | 宿主自定义未读标题时，配置原始标题和提示标题、同步当前标题。 |
| `advanceNotificationFlashTitle(nowMilliseconds: Int64) -> Bool`、`advanceTypingTimers(nowMilliseconds: Int64) -> Bool` | 自定义宿主可按毫秒时间戳推进标题闪烁或输入状态计时，返回此次是否推进了计时。 |
| `setDemo(_ payload: [String: String])`、`setDemo(_ payload: SalesmartlyPayload)` | 设置演示数据。在 `.demo` 模式下同时触发 `onSetDemo`。 |

自定义通知处理器实现 `SalesmartlyNotificationHandling`，包含 `requestUnreadNotificationPermission(currentStatus: String) -> String`、`showUnreadNotification()`、`playUnreadSound()`、`focusNotificationTarget()` 和 `closeUnreadNotification()`。SDK 默认使用 `SalesmartlyDefaultNotificationHandler`。

调用 `SalesmartlyChat.runtime().setWhatsappGreetingCallback(_ callback: @escaping SalesmartlyWhatsappGreetingCallback)` 可在打开 WhatsApp 前改写问候语。闭包签名为 `(String) -> String?`，返回 `nil` 或空字符串时保留原文。

## 事件与错误回调

### `push(_:callback:)`

使用 `SalesmartlyChat.push(_ eventName: String, callback: @escaping SalesmartlyCallback)` 注册事件。`SalesmartlyCallback` 接收 `SalesmartlyPayload`，即 `[String: Any]`。同一事件支持多个监听，重复注册会追加闭包。建议在初始化前完成注册。

```swift
import SalesmartlyChat

func registerChatEvents() {
    SalesmartlyChat.push("onUnRead") { payload in
        if let count = payload["num"] as? Int {
            print("未读消息", count)
        }
    }
    SalesmartlyChat.push("onReceiveMessage") { payload in
        if let messageID = payload["mid"] as? String {
            print("收到消息", messageID)
        }
    }
}
```

| 事件 | 触发时机与回调字段 |
| --- | --- |
| `onReady` | SDK 本地初始化，字段为 `mode: String`、`showNotification: Bool`。此时插件配置或实时会话可能仍在加载。已就绪且没有未恢复的关键错误时，晚注册的监听会收到当前就绪状态。 |
| `onError` | SDK 初始化、会话或操作故障，字段见下文。 |
| `onOpenChat`、`onCloseChat` | 聊天窗口打开或关闭，回调为空字典。 |
| `onUnRead` | 未读数变化，字段为 `num: Int` 和 `list: [ChatMessage]`。消息可通过 `mid`、`msgType`、`message` 等属性读取。 |
| `onSendMessage` | 发送事件，字段为 `mid: String`、`msg_type: String`、`message: String`。程序发送文本时可在服务端确认前触发，附件最终结果以附件方法的 `completion` 为准。 |
| `onReceiveMessage` | 接收消息，字段为 `mid: String`、`msg_type: String`、`message: String`、`quote_chat: String`。 |
| `onOpenCollection` | 调用普通留资的打开方法时触发，字段为 `show: Bool`，值为 `true`。 |
| `onCollectionInfo` | 表单提交后触发，包含已提交的字段及 `type: String`（普通留资为 `survey`，离线留资为 `offline`）。 |
| `onOpenCustom` | 打开自定义入口，字段为 `id: String` 和 `content: String`。 |
| `onOpenWhatsapp`、`onOpenMessenger`、`onOpenTelegram`、`onOpenLine`、`onOpenLineApp`、`onOpenInstagram`、`onOpenTikTok`、`onOpenWeixin`、`onOpenVKontakte`、`onOpenZalo` | 打开对应外部渠道，字段为 `linkUrl: String`。 |
| `onOpenEmail` | 打开邮箱渠道，字段为 `email: String`。 |
| `onHideHumanComponent`、`onQueueAssigned` | 收到隐藏转人工组件或排队分配通知，回调为空字典。 |
| `onSetDemo` | Demo 模式下设置演示数据时触发，回调为传入的字典。 |

### `onError`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `phase` | `String` | 故障阶段。`initialization` 为初始化，`session` 为会话，`operation` 为具体操作。 |
| `operation` | `String` | 发生故障的操作。 |
| `code` | `String` | 错误分类。`network` 为网络，`http` 为 HTTP，`business` 为服务拒绝，`decode` 为数据解析，`internal` 为 SDK 操作失败。 |
| `message` | `String` | 错误说明。 |
| `is_transient` | `Bool` | 是否属于已识别的临时网络错误，如断网、超时或连接中断。 |
| `native_error_code` | `String?` | 可用时提供 Foundation 网络错误域和数字错误码。 |
| `http_status` | `Int?` | 可用时提供 HTTP 状态码。 |

尚未恢复的初始化或会话故障会回放给晚注册的 `onError` 监听。取消的操作不会作为 `onError` 上报，取消附件任务则通过该次附件的 `completion` 返回失败结果。

## 命令方式

`SalesmartlyChat.push(command: String, payload: Any? = nil)` 和 `SalesmartlyChat.push(_ command: String, _ payload: Any? = nil)` 可以按命令名调用原生接口。

| 命令 | payload |
| --- | --- |
| `chatOpen`、`chatClose`、`clearUser` | 省略。 |
| `setLoginInfo` | `LoginInfo`。 |
| `setUserInfo`、`setDemo` | `[String: String]` 或 `SalesmartlyPayload`。 |
| `sendTextMessage`、`openCustomEntry`、`trackUrl` | `String`。 |
| `showCollection`、`showOffline`、`hideCloseIcon` | `Bool`，可省略，默认 `true`。 |
| `setNotificationStatus` | `Bool`。 |
| `hideUpload` | `[String]`。 |
| `getSidebarHeight` | `SalesmartlySidebarHeightCallback`，即 `(Int) -> Void`。 |
| `createWhatsappGreeting` | `SalesmartlyWhatsappGreetingCallback`，即 `(String) -> String?`。 |

iOS 1.0.7 的命令调用接收命令名和可选参数。原生接口未提供 Web SDK 的三参数状态回调，也未提供同名的 `setInputText`、`onDestroy` 命令。可用 [事件监听](#事件与错误回调) 订阅窗口、消息和留资等事件。附件发送使用带 `completion` 的原生方法。
