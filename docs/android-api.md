# SaleSmartly Chat Android SDK API 参考

本文适用于 Android SDK **1.0.6**，示例使用 Kotlin。下载 AAR、配置依赖和运行 Demo 请参阅 [Android 接入指南](../android/README.md)。使用 Swift 接入请参阅 [iOS SDK API 参考](ios-api.md)。

- [初始化与界面挂载](#初始化与界面挂载)
- [用户身份与资料](#用户身份与资料)
- [聊天与界面控制](#聊天与界面控制)
- [发送消息](#发送消息)
- [事件与错误](#事件与错误)
- [Web 兼容命令](#web-兼容命令)
- [旧版根包入口](#旧版根包入口)

本文中的 `SalesmartlyChat`、`SalesmartlyCallback` 和配置模型来自 `com.salesmartly.chatwidget.api`。Compose 组件 `SalesmartlyChatHost` 来自 `com.salesmartly.chatwidget.ui`。

## 初始化与界面挂载

| API | 说明 |
| --- | --- |
| `initialize(context: Context, scriptUrl: String)` | 传入宿主 Context 和 SaleSmartly 后台生成的项目脚本地址。SDK 异步加载脚本。 |
| `initialize(context: Context, config: SalesmartlyConfig)` | 直接提供原生配置并创建本地运行时，适用于已经取得完整环境配置的宿主。 |
| `attach(container: ViewGroup)` | 在 View 界面挂载 SDK，SDK 同一时间只保留一个通过此方法挂载的视图。再次调用会替换上一次挂载。 |
| `runtime(): SalesmartlyRuntime` | 获取已创建的 SDK 运行时，供 Compose 组件使用。 |
| `SalesmartlyChatHost(runtime: SalesmartlyRuntime, modifier: Modifier = Modifier)` | 在 Compose 界面挂载 SDK，组件会同步宿主生命周期。 |
| `resetRuntime()` | 释放当前 SDK 实例，移除通过 `attach` 挂载的视图，清空待执行命令及已注册回调。Compose 宿主应同时移除旧的 `SalesmartlyChatHost`。再次使用前重新注册回调和初始化。 |

宿主应在用户同意 App 隐私政策后初始化。使用项目脚本初始化时，在 `onReady` 回调后调用 `attach` 或 `runtime()`。`onReady` 表示本地 SDK 可以使用，实时会话建立结果另行处理，失败可通过 `onError` 观察。脚本加载失败时，SDK 通过 `onError` 报告。

传统 View 可以在 `onReady` 中挂载 SDK，并在宿主自己的按钮点击后打开窗口：

```kotlin
import android.content.Context
import android.view.ViewGroup
import com.salesmartly.chatwidget.api.SalesmartlyChat

fun initializeChat(context: Context, scriptUrl: String, container: ViewGroup) {
    SalesmartlyChat.on("onReady") {
        SalesmartlyChat.attach(container)
    }
    SalesmartlyChat.initialize(context.applicationContext, scriptUrl)
}
```

Compose 宿主在 `onReady` 时更新界面的 `sdkReady` 状态，再挂载：

```kotlin
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.salesmartly.chatwidget.api.SalesmartlyChat
import com.salesmartly.chatwidget.ui.SalesmartlyChatHost

@Composable
fun ChatOverlay(sdkReady: Boolean, modifier: Modifier = Modifier) {
    if (sdkReady) {
        SalesmartlyChatHost(runtime = SalesmartlyChat.runtime(), modifier = modifier)
    }
}
```

自定义宿主若绕过 `attach` 和 `SalesmartlyChatHost`，需用 `SalesmartlyChat.runtime().setHostVisible(visible: Boolean)` 同步可见状态。宿主进入可见生命周期时传 `true`，停止或卸载时传 `false`。

### 原生配置

`SalesmartlyConfig(license: String, setting: SalesmartlySetting = SalesmartlySetting())` 的 `license` 是项目授权标识。`scriptUrl` 方式会读取对应项目的环境配置。

| `SalesmartlySetting` 字段 | 类型与默认值 | 说明 |
| --- | --- | --- |
| `mode` | `String`，`"chat"` | 对应 `ChatMode`。可用枚举值为 `Chat`、`Demo`、`Preview`、`Sandbox`、`ExclusiveLink`，对应 `"chat"`、`"demo"`、`"preview"`、`"sandbox"`、`"exclusiveLink"`。可用 `ChatMode.Chat.value` 取得配置字符串。 |
| `initMobileScreen` | `String`，`""` | `"full"` 隐藏聊天页关闭图标。标准聊天窗口使用全屏宿主布局。 |
| `flowId` | `String`，`""` | 已配置流程的 ID。 |
| `overTime` | `String`，`""` | 获取插件配置时传入的超时参数。 |
| `r_o_url` | `String`，`""` | Base64 编码的服务地址配置。 |
| `widgetHost` | `String`，`""` | Widget 服务基地址。 |
| `showNotification` | `Boolean`，`true` | 系统通知的初始开关。 |
| `isCustomized` | `Boolean`，`false` | 自定义模式配置，影响底部品牌区域显示。 |
| `hideIcon` | `Boolean`，`false` | SDK 入口图标配置。标准聊天宿主由 App 提供外部入口。 |
| `flowRef` | `String`，`""` | 配置模型保留的字段。 |
| `positionHorizontal` | `PositionHorizontal`，`PositionHorizontal()` | 入口位置配置。模型的 `mobile`、`desktop` 都是 `Int`，默认 `0`。标准聊天宿主由 App 布置外部入口。 |

`ChatMode.fromValue(value: String): ChatMode` 将上述字符串转为枚举，未知值会抛出 `NoSuchElementException`。

## 用户身份与资料

### 设置登录身份

`setLoginInfo(info: LoginInfo)` 设置访客身份及客户资料，SDK 会异步建立相应用户会话。切换用户 ID 时会切换本地会话记录。会话失败通过 `onError` 观察。

| `LoginInfo` 字段 | 类型与默认值 | 说明 |
| --- | --- | --- |
| `user_id` | `String`，构造时必传 | 宿主提供的稳定用户标识，最多 300 个 UTF-16 码元，超出时本次调用会被忽略。请为登录用户传入非空值。 |
| `user_name` | `String`，`""` | 客户姓名。 |
| `language` | `String`，`""` | 用户语言，例如 `zh-CN`。 |
| `phone` | `String`，`""` | 客户手机号。 |
| `email` | `String`，`""` | 客户邮箱。 |
| `description` | `String`，`""` | 客户备注。 |
| `label_names` | `List<String>`，空列表 | 项目中已创建的客户标签名称，仅在新建访客会话时发送。 |
| `custom_fields_ext` | `Map<String, Any?>`，空 Map | 以项目配置的自定义字段 ID 为键，仅在新建访客会话时发送。Android 会将各值转换为字符串。 |

```kotlin
import com.salesmartly.chatwidget.api.LoginInfo
import com.salesmartly.chatwidget.api.SalesmartlyChat

fun setChatIdentity(userId: String, userName: String, email: String) {
    SalesmartlyChat.setUserInfo(mapOf("plan" to "pro"))
    SalesmartlyChat.setLoginInfo(
        LoginInfo(
            user_id = userId,
            user_name = userName,
            language = "zh-CN",
            email = email,
        ),
    )
}
```

### 补充资料与退出

| API | 说明 |
| --- | --- |
| `setUserInfo(info: Map<String, Any?>)` | 设置宿主的额外业务信息，供后续会话请求使用。希望在建立指定身份的会话时带上这些信息，可在 `setLoginInfo` 前调用。 |
| `clearUser()` | 清除当前登录信息和额外业务信息，切回访客态。宿主用户退出登录时可调用。 |

## 聊天与界面控制

标准宿主只渲染聊天窗口。由 App 提供按钮等外部入口，并在 SDK 就绪后调用 `open()` 或 `openChat()`。

| API | 说明 |
| --- | --- |
| `open()` | 按项目配置打开窗口。启用主页时进入主页，否则直接进入聊天页。项目配置加载期间的多次请求会合并为一次。 |
| `openChat()` | 打开窗口并直接进入聊天页。Demo 模式开启主页时进入主页。 |
| `closeChat()` | 关闭聊天窗口。 |
| `showCollection(show: Boolean)` | 显示或隐藏聊前留资，并关闭离线留资。 |
| `showOffline(show: Boolean)` | 显示或隐藏离线留资，并关闭聊前留资。 |
| `setNotificationStatus(enabled: Boolean)` | 设置 SDK 的系统通知开关。Android 13 及以上的通知授权由宿主 App 申请。 |
| `hideUpload(types: List<String>)` | 设置 SDK 中要隐藏的上传入口及对应的粘贴预览。可传 `"img"`、`"document"`、`"video"`，分别对应图片、文件、视频。隐藏 `"img"` 同时隐藏搜同款入口。传 `emptyList()` 清除隐藏设置。 |
| `hideCloseIcon()` | 隐藏 SDK 窗口关闭图标。宿主仍可调用 `closeChat()`。 |
| `openCustomEntry(id: String)` | 按项目配置的入口 ID 打开自定义入口。需要聊天窗口已打开、存在该 ID 且 SDK 处于非 Demo 模式。 |
| `getSidebarHeight(callback: (Int) -> Unit)` | 仅在 SDK 已测得正数入口高度时以像素调用回调。标准宿主没有 SDK 外部入口时，App 应直接测量自己的入口。 |
| `trackUrl(url: String)` | 记录当前业务页面地址，供后续会话使用，例如 `"app://home"`。 |
| `setDemo(payload: Map<String, Any?>)` | 保存演示数据。Demo 模式下触发 `onSetDemo`。 |

## 发送消息

### 发送文本

`sendTextMessage(text: String)` 发送文本。SDK 会去除首尾空白，忽略空文本。若当前会话需要先留资，SDK 显示表单，并在收到有效提交后发送。宿主如需同时打开界面，应先调用 `openChat()`。

```kotlin
import com.salesmartly.chatwidget.api.SalesmartlyChat

fun sendChatText(text: String) {
    SalesmartlyChat.openChat()
    SalesmartlyChat.sendTextMessage(text)
}
```

### 发送本地附件

`sendAttachment(uri: Uri, type: SalesmartlyAttachmentType, completion: SalesmartlyCallback)`

SDK 打开聊天页并直接发送宿主已确认的附件，跳过 SDK 内的二次预览。宿主应先完成文件选择、确认及 URI 授权。`hideUpload` 控制 SDK 界面入口，不影响宿主调用 `sendAttachment`。支持可读的 `content://` 或 `file://` URI，单个文件最多 **20 MiB**，文件内容须非空。类型可选 `SalesmartlyAttachmentType.Image`（图片）或 `SalesmartlyAttachmentType.File`（普通文件）。

如果需要留资，发送会等待有效提交。发送总超时为 180 秒，等待填写留资表单时暂停计时。关闭聊天窗口不会取消发送，取消留资、调用 `setLoginInfo` 或 `clearUser`、重置 SDK 会结束受影响的发送。Demo 模式及 SDK 未初始化时会返回失败。

每次调用完成时回调一次。服务端确认发送或回传同一条消息时视为成功。在 SDK 中重试可重试的失败消息时，沿用原 `c_m_id`，原完成回调只会调用一次。

| 回调字段 | 类型 | 说明 |
| --- | --- | --- |
| `c_m_id` | `String` | 客户端消息 ID，可与发送事件关联。 |
| `success` | `Boolean` | 发送是否成功。 |
| `error` | `Map<String, Any?>` | 仅失败时存在，字段见 [错误数据](#错误数据)。 |

```kotlin
import android.net.Uri
import com.salesmartly.chatwidget.api.SalesmartlyAttachmentType
import com.salesmartly.chatwidget.api.SalesmartlyChat

fun sendConfirmedImage(uri: Uri, onResult: (Boolean) -> Unit) {
    SalesmartlyChat.sendAttachment(uri, SalesmartlyAttachmentType.Image) { result ->
        onResult(result["success"] == true)
    }
}
```

## 事件与错误

`on(eventName: String, callback: SalesmartlyCallback)` 注册 SDK 事件。回调签名为 `onEvent(payload: Map<String, Any?>)`。可以在初始化前注册。每个事件名只保留最后注册的回调。SDK 会向晚注册的监听器补发已保存的 `onReady` 或尚未恢复的初始化、会话错误；发生这类错误后不会补发旧的 `onReady`。更新宿主 UI 时应遵守 Android 的主线程要求。

```kotlin
import com.salesmartly.chatwidget.api.SalesmartlyChat

fun registerUnreadListener(onCount: (Int) -> Unit) {
    SalesmartlyChat.on("onUnRead") { payload ->
        onCount(payload["num"] as Int)
    }
}
```

| 事件 | 触发条件与数据 |
| --- | --- |
| `onReady` | 本地 SDK 就绪。包含 `license: String`。 |
| `onError` | 初始化、会话或操作失败。字段见 [错误数据](#错误数据)。 |
| `onOpenChat`、`onCloseChat` | 打开、关闭聊天窗口。数据为空 Map。 |
| `onUnRead` | 未读数变化。包含 `num: Int` 和 `list: List<Map<String, Any?>>`。 |
| `onSendMessage` | 访客消息进入发送流程。包含 `mid`、`msg_type`、`message`、`c_m_id`，部分消息附带 `type`，均为字符串。发送事件可能早于服务端确认。 |
| `onReceiveMessage` | 收到消息或流式消息更新。包含 `mid`、`msg_type`、`message`，均为字符串。 |
| `onOpenCollection` | 调用 `showCollection` 时包含 `show: Boolean`。业务流程打开留资时包含 `type: String`，值为 `"survey"` 或 `"offline"`。 |
| `onCollectionInfo` | 提交留资表单。包含 `type: String` 及表单配置对应的字段和值。 |
| `onHideHumanComponent`、`onQueueAssigned` | 转人工组件需隐藏、排队分配。数据为空 Map。 |
| `onOpenLine`、`onOpenLineApp`、`onOpenMessenger`、`onOpenTelegram`、`onOpenWhatsapp`、`onOpenInstagram`、`onOpenTikTok`、`onOpenVKontakte`、`onOpenZalo`、`onOpenWeixin` | 打开对应渠道时触发，包含 `linkUrl: String`。 |
| `onOpenEmail` | 打开邮件渠道，包含 `email: String`。 |
| `onOpenCustom` | 打开自定义入口，包含 `id: String`、`content: String`。 |
| `onSetDemo` | Demo 模式下调用 `setDemo`。数据为空 Map。 |

未读列表中的每条消息包含 `id`、`mid`、`c_m_id`、`send_type`、`msg_type`、`message`、`chat_user_id`、`sender_avatar`、`sender_name`、`tempId`、`quote_chat` 等字符串字段，`created_time: Long`、`status: Int?` 和 `like_result: Map<String, String>`。`isRead`、`is_withdraw`、`is_stream`、`is_stop` 以字符串 `"0"` 或 `"1"` 表示。

`onOverTime`、`createWhatsappGreeting`、`setExclusiveLink` 在 1.0.6 可注册，但当前没有对应的 Android 事件触发流程。

### 错误数据

`onError` 的数据及附件发送失败时的 `error` 采用以下脱敏字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `phase` | `String` | 出错阶段，可为 `"initialization"`、`"session"`、`"operation"`。 |
| `operation` | `String` | 出错操作。 |
| `code` | `String` | 错误类别，常见值为 `"network"`、`"http"`、`"business"`、`"decode"`、`"internal"`。 |
| `message` | `String` | 脱敏后的错误说明。 |
| `native_error_code` | `String` | Android 原生错误类型。 |
| `is_transient` | `Boolean` | SDK 是否将错误识别为超时或连接中断等瞬时故障。 |
| `http_status` | `Int`，可省略 | 取得 HTTP 状态码时提供。 |

## Web 兼容命令

`push(command: String, payload: Any? = null)` 支持以下命令。事件也可通过 `push(eventName, SalesmartlyCallback { ... })` 注册。

| 命令 | `payload` |
| --- | --- |
| `chatOpen`、`chatClose`、`clearUser`、`hideCloseIcon` | 省略。 |
| `setLoginInfo` | `LoginInfo` 或以 `LoginInfo` 字段名为键的 Map。 |
| `setUserInfo`、`setDemo` | `Map<String, Any?>`。 |
| `sendTextMessage`、`trackUrl` | `String`。 |
| `showCollection`、`showOffline`、`setNotificationStatus` | `Boolean`，省略时按 `true` 处理。 |
| `hideUpload` | `List<String>`。 |
| `openCustomEntry` | 入口 ID 字符串，也可传入包含 `id` 的 Map。 |
| `getSidebarHeight` | `(Int) -> Unit`。 |

Android 的 `push` 只接收命令名与可选参数。Web SDK 的第三参数状态回调不适用于 Android；1.0.6 也不支持 `setInputText` 和 `onDestroy` 命令。附件发送使用原生 `sendAttachment` 的专用完成回调。

```kotlin
import com.salesmartly.chatwidget.api.SalesmartlyCallback
import com.salesmartly.chatwidget.api.SalesmartlyChat

fun openChatAndSend(text: String, onClose: () -> Unit) {
    SalesmartlyChat.push("onCloseChat", SalesmartlyCallback { onClose() })
    SalesmartlyChat.push("chatOpen")
    SalesmartlyChat.push("sendTextMessage", text)
}
```

## 旧版根包入口

AAR 也提供 `com.salesmartly.chatwidget.SalesmartlyChat`。已经使用根包的项目需按对应包的签名调用，避免混用名称相同的模型。

| 项目 | 根包入口的差异 |
| --- | --- |
| 登录资料 | 使用根包的 `LoginInfo`。字段名为 `userId`、`userName`、`language`、`phone`、`email`、`description`、`labelNames` 和 `customFieldsExt`，均有空值默认配置。 |
| 初始化配置 | 使用根包的 `SalesmartlyConfig` 与 `SalesmartlySetting`。根包的 `mode`、`initMobileScreen`、`flowId`、`flowRef`、`r_o_url` 是可空字符串，`overTime` 为 `Long?`。`positionHorizontal` 使用 `SalesmartlyPositionHorizontal`，其 `mobile` 和 `desktop` 均为可空字符串。 |
| 隐藏上传与演示数据 | `hideUpload(types: Set<String>)`、`setDemo(payload: Any?)`。后者应传入 Map。 |
| 回调与附件 | 通过 `push(eventName, SalesmartlyCallback { ... })` 注册根包回调。`sendAttachment` 接收 `com.salesmartly.chatwidget.api.SalesmartlyAttachmentType` 和根包的 `SalesmartlyCallback`。 |
| Compose 与运行时 | 根包的 `SalesmartlyChatHost(modifier: Modifier = Modifier)` 自行读取运行时。需要 `runtime()` 或 `resetRuntime()` 时使用 `com.salesmartly.chatwidget.api.SalesmartlyChat`。 |
