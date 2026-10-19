# SaleSmartly Chat Android SDK Demo

该目录提供 SaleSmartly Chat Android 原生 SDK 的 Demo APK 与 Android 接入说明。Demo 使用原生 SDK UI，不通过 WebView 嵌入聊天插件页面。

当前 Android SDK `1.0.4` 于 2026-10-19 从 `salesmartly-chat-android` 的 `main` 提交 `f2e31bc2efdcb482a4f36fd53dc2d4e64bba522f` 构建，固定发布提交为 `14db64bf52b33052b55fbb77aaaa30664e86efc1`。请通过下方固定链接下载并核对 SHA-256。

本次修复：

- 补齐普通图片、图文图片和搜同款引用的点击预览，加载成功后打开引用图片的原始 URL。
- 加载中或加载失败的引用缩略图不打开预览，普通图片预览及现有公开接口保持不变。

2026-10-16 修订内容继续保留：

- 使用 Coil `3.4.0` 按显示尺寸加载图片，复用下载和缓存，减少原尺寸位图的内存占用。
- 调整顶部栏安全区、主行与渠道行的叠层以及圆角阴影，补齐评价完成后的感谢插图与居中布局。
- 保留媒体发送失败及 Socket 超时的脱敏说明，支持再次点击失败标识查看。
- 公开接口保持不变；手动 AAR 接入须补充下方两项 Coil 依赖。

此前 `1.0.3` 的首页渠道显示修复继续保留：当渠道配置为聊天窗内展示（`integration_type == "chat"`）时，首页其他渠道入口不再因侧边栏或单图标配置被隐藏，主渠道、渠道排序及入口点击方式保持原有逻辑。

当前公开 Demo APK 仍是使用 SDK `1.0.3` 构建的原 debug 包，包含 Coil 依赖；应用版本为 `1.0.0`（`versionCode` 为 `1`）。下方下载链接和校验值保留不变。Demo 源码已改用 SDK `1.0.4` 并构建通过；验证本次引用图片修复请按第 9 节从源码构建。

## Demo APK 下载

[点击下载 Demo APK](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/8a57a19f19abe8ee72feb471004217c38ef4ba19/android/demo/salesmartly-chat-android-demo-v1.0.0.apk)

APK 信息：

| 字段 | 值 |
| --- | --- |
| 文件 | `android/demo/salesmartly-chat-android-demo-v1.0.0.apk` |
| applicationId | `com.salesmartly.chatwidget.sample` |
| versionName | `1.0.0` |
| versionCode | `1` |
| minSdk | `23` |
| 构建类型 | `debug` |
| 文件大小 | `14282424` bytes |
| SHA-256 | `95fce893e2e99bae86fd72bcd6be883d41ff51394afcd878054def14f6ce7eb9` |

该公开 APK 的独立工程构建及 v1 / v2 签名校验已通过；未执行该 APK 的安装运行验证。

Android 设备下载后如提示禁止安装未知来源应用，请在系统设置中允许当前浏览器或文件管理器安装 APK。

## SDK AAR 下载

[点击下载 SDK AAR](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/14db64bf52b33052b55fbb77aaaa30664e86efc1/android/sdk/salesmartly-chatwidget-sdk-v1.0.4.aar)

AAR 信息：

| 字段 | 值 |
| --- | --- |
| 文件 | `android/sdk/salesmartly-chatwidget-sdk-v1.0.4.aar` |
| Maven 坐标 | `com.salesmartly:chatwidget-sdk:1.0.4` |
| minSdk | `23` |
| 构建类型 | `release` |
| 文件大小 | `1735402` bytes |
| SHA-256 | `d5f0714730cdb139ac2d96c54a6d64e0a861ba1ca9c7f613dd86319a5bd26505` |

本次已通过 636 项单测、6 项 API 36 模拟器真实 Compose 触控回归、Release AAR、示例 debug / release 及 R8 构建验证。触控回归覆盖引用图片原始 URL 回调、普通图片、非图片引用、加载中与失败状态；AAR 内置版本、Maven 元数据与校验值一致。未验证预览层视觉效果，也未执行 Demo UI、真机运行或真实客服会话回归。

## 升级到 1.0.4

1. 下载上方 SDK AAR，替换宿主 App 使用的旧版 AAR，并将 Gradle 的 `implementation(files(...))` 引用更新为 `salesmartly-chatwidget-sdk-v1.0.4.aar`。
2. 保持现有 SDK 初始化、打开聊天及回调代码，并为手动 AAR 接入补充 `io.coil-kt.coil3:coil-compose-core:3.4.0` 与 `io.coil-kt.coil3:coil-network-okhttp:3.4.0`；完整依赖示例见下方。
3. 重新构建 App，验证引用图片点击预览及原有聊天功能，再发布 App 更新。继续引用 `1.0.3` AAR 的项目不会自动获得本次修复。

已安装的 App 需要升级宿主 App 才会使用新 SDK。仅更新后台配置或此仓库不会替换 App 内已有的 SDK。

## 1. 添加 SDK 依赖

当前发布仓库直接提供 AAR。宿主 App 的 `compileSdk` 需为 `36` 或更高，最低运行系统仍为 minSdk `23`。下载上方 `salesmartly-chatwidget-sdk-v1.0.4.aar`，放入宿主 App 的 `libs` 目录：

```kotlin
dependencies {
    implementation(files("libs/salesmartly-chatwidget-sdk-v1.0.4.aar"))
}
```

本地 AAR 不携带 Maven POM 中的传递依赖，宿主 App 需要同时声明 SDK 当前使用的依赖：

```kotlin
dependencies {
    implementation(platform("androidx.compose:compose-bom:2026.03.01"))
    implementation("androidx.activity:activity-compose:1.13.0")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.runtime:runtime")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.10.0")
    implementation("androidx.room:room-runtime:2.8.4")

    implementation(platform("com.squareup.retrofit2:retrofit-bom:3.0.0"))
    implementation("com.squareup.retrofit2:retrofit")
    implementation("com.squareup.retrofit2:converter-kotlinx-serialization")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("io.coil-kt.coil3:coil-compose-core:3.4.0")
    implementation("io.coil-kt.coil3:coil-network-okhttp:3.4.0")
    implementation("io.socket:socket.io-client:2.1.2") {
        exclude(group = "org.json", module = "json")
    }
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.10.0")
}
```

宿主 App 的 release 构建应启用 R8 和资源压缩，移除 SDK 及其依赖中未使用的代码和资源：

```kotlin
android {
    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}
```

SDK 工程已声明 Maven 坐标 `com.salesmartly:chatwidget-sdk:1.0.4`。只有该坐标发布到宿主 App 已配置的 Maven 仓库后，才可以改用以下依赖；当前发布仓库不表示该坐标已经公开发布：

```kotlin
dependencies {
    implementation("com.salesmartly:chatwidget-sdk:1.0.4")
}
```

## 2. 注入项目脚本地址

Android SDK 不需要把 Web Widget UI 放入 Android assets，也不需要通过 WebView 加载聊天页。宿主 App 只需要把客户后台生成的 Web 项目脚本地址传给 SDK。

SDK 会读取项目脚本中的 `__ssc.license`，并根据脚本内容中的 install 路径识别正式、pre 或 dev 环境。

建议通过 `BuildConfig` 注入脚本地址，避免把真实客户脚本地址硬编码到公共源码仓库：

```kotlin
android {
    defaultConfig {
        buildConfigField(
            "String",
            "SALESMARTLY_SCRIPT_URL",
            "\"https://your-domain.example/js/project_xxxxx.js\"",
        )
    }

    buildFeatures {
        buildConfig = true
    }
}
```

脚本地址也可以由 CI、`local.properties`、远程配置或业务后台下发，只要最终传入 `SalesmartlyChat.initialize(context, scriptUrl)` 即可。

## 3. 初始化 SDK

`initialize(context, scriptUrl)` 会发起脚本下载等网络请求，宿主 App 应在用户同意隐私政策后再调用。随仓 Demo 通过“同意隐私政策并初始化”按钮演示这一时序，并将通知权限申请保留为初始化完成后的独立操作。

建议在 `Application` 或首个承载聊天 UI 的 `Activity` 中初始化。回调可以先注册，再初始化：

```kotlin
import com.salesmartly.chatwidget.api.SalesmartlyCallback
import com.salesmartly.chatwidget.api.SalesmartlyChat

SalesmartlyChat.push("onReady", SalesmartlyCallback { payload ->
    // SDK 初始化完成，在这里将界面状态 sdkReady 更新为 true
})

SalesmartlyChat.push("onUnRead", SalesmartlyCallback { payload ->
    val count = payload["num"]
})

SalesmartlyChat.initialize(
    context = applicationContext,
    scriptUrl = BuildConfig.SALESMARTLY_SCRIPT_URL,
)
```

`initialize(context, scriptUrl)` 会异步下载脚本并读取其中的 `__ssc.license`，方法返回时 SDK 不一定已经初始化完成。应在调用初始化前注册 `onReady`；收到 `onReady` 后，才可以调用 `SalesmartlyChat.attach(...)` 或 `SalesmartlyChat.runtime()` 挂载 UI。

## 4. 挂载聊天 UI

SDK 不会渲染悬浮按钮、外部渠道按钮、未读预览或侧边栏等聊天窗口外部入口。
宿主 App 需要提供自己的入口按钮，并在收到 `onReady` 后调用 `SalesmartlyChat.openChat()` 打开聊天窗口。
该调整只影响聊天窗口外部入口；窗口内部的主页与顶部栏渠道入口仍按项目配置显示。

### Compose 页面

```kotlin
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.salesmartly.chatwidget.api.SalesmartlyChat
import com.salesmartly.chatwidget.ui.SalesmartlyChatHost

@Composable
fun AppScreen(sdkReady: Boolean) {
    Box(modifier = Modifier.fillMaxSize()) {
        Button(
            onClick = SalesmartlyChat::openChat,
            enabled = sdkReady,
            modifier = Modifier.align(Alignment.Center),
        ) {
            Text("打开聊天")
        }

        if (sdkReady) {
            SalesmartlyChatHost(
                runtime = SalesmartlyChat.runtime(),
                modifier = Modifier.fillMaxSize(),
            )
        }
    }
}
```

### View 页面

```kotlin
import android.os.Bundle
import android.view.ViewGroup
import androidx.activity.ComponentActivity
import com.salesmartly.chatwidget.api.SalesmartlyCallback
import com.salesmartly.chatwidget.api.SalesmartlyChat

class ChatActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chat)

        val container = findViewById<ViewGroup>(R.id.chat_container)
        SalesmartlyChat.push("onReady", SalesmartlyCallback {
            SalesmartlyChat.attach(container)
        })
        SalesmartlyChat.initialize(
            context = applicationContext,
            scriptUrl = BuildConfig.SALESMARTLY_SCRIPT_URL,
        )
    }
}
```

使用 `scriptUrl` 初始化时，调用 `SalesmartlyChat.attach(container)` 或 `SalesmartlyChat.runtime()` 前必须等待 `onReady`。View 宿主也可以直接在回调中挂载：

```kotlin
SalesmartlyChat.push("onReady", SalesmartlyCallback {
    SalesmartlyChat.attach(container)
})

SalesmartlyChat.initialize(
    context = applicationContext,
    scriptUrl = BuildConfig.SALESMARTLY_SCRIPT_URL,
)
```

View 宿主同样需要提供自己的入口按钮，并在按钮点击监听中调用 `SalesmartlyChat.openChat()`。

## 5. 设置用户信息

登录用户：

```kotlin
import com.salesmartly.chatwidget.api.LoginInfo
import com.salesmartly.chatwidget.api.SalesmartlyChat

SalesmartlyChat.setLoginInfo(
    LoginInfo(
        user_id = "user-123",
        user_name = "Ada",
        language = "zh-CN",
        phone = "10086",
        email = "ada@example.com",
        description = "VIP",
        label_names = listOf("paid"),
        custom_fields_ext = mapOf("level" to "gold"),
    ),
)
```

补充业务信息：

```kotlin
SalesmartlyChat.setUserInfo(
    mapOf(
        "plan" to "pro",
        "source" to "android",
    ),
)
```

退出登录或切换访客：

```kotlin
SalesmartlyChat.clearUser()
```

## 6. 常用命令

```kotlin
SalesmartlyChat.openChat()
SalesmartlyChat.closeChat()
SalesmartlyChat.sendTextMessage("Hello")
SalesmartlyChat.showCollection(true)
SalesmartlyChat.showOffline(true)
SalesmartlyChat.setNotificationStatus(true)
SalesmartlyChat.hideUpload(listOf("img", "document", "video"))
SalesmartlyChat.hideCloseIcon()
SalesmartlyChat.openCustomEntry("custom_1")
SalesmartlyChat.getSidebarHeight { height ->
    // 使用当前入口高度
}
SalesmartlyChat.trackUrl("app://home")
SalesmartlyChat.setDemo(mapOf("scene" to "preview"))
```

也可以使用 Web 兼容命令桥：

```kotlin
SalesmartlyChat.push("chatOpen")
SalesmartlyChat.push("sendTextMessage", "Hello")
SalesmartlyChat.push("onUnRead", SalesmartlyCallback { payload ->
    val count = payload["num"]
})
```

支持的命令包括：`setLoginInfo`、`setUserInfo`、`clearUser`、`chatOpen`、`chatClose`、`setDemo`、`setNotificationStatus`、`trackUrl`、`showCollection`、`showOffline`、`sendTextMessage`、`hideUpload`、`hideCloseIcon`、`openCustomEntry`、`getSidebarHeight`。

## 7. 常用回调

```kotlin
SalesmartlyChat.push("onSendMessage", SalesmartlyCallback { payload ->
    // 用户发送消息
})

SalesmartlyChat.push("onReceiveMessage", SalesmartlyCallback { payload ->
    // 收到消息
})

SalesmartlyChat.push("onOpenWhatsapp", SalesmartlyCallback { payload ->
    // 宿主 App 可在这里打开 WhatsApp
})

SalesmartlyChat.push("onOpenCustom", SalesmartlyCallback { payload ->
    // 用户点击自定义入口
})
```

允许注册的事件名包括：`onUnRead`、`onOverTime`、`onSendMessage`、`onReceiveMessage`、`onOpenChat`、`onCloseChat`、`onOpenCollection`、`onCollectionInfo`、`onHideHumanComponent`、`onQueueAssigned`、`onOpenLine`、`onOpenLineApp`、`onOpenMessenger`、`onOpenEmail`、`onOpenTelegram`、`onOpenWhatsapp`、`onOpenInstagram`、`onOpenTikTok`、`onOpenVKontakte`、`onOpenZalo`、`onOpenWeixin`、`onReady`、`onSetDemo`、`createWhatsappGreeting`、`onOpenCustom`、`setExclusiveLink`。

其中 `onOverTime`、`createWhatsappGreeting`、`setExclusiveLink` 当前仅完成事件名注册，核心运行时尚无触发路径。

## 8. 权限说明

宿主 App 需要网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

如果需要展示系统通知，Android 13 及以上建议由宿主 App 主动申请通知权限：

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

SDK 在发送本地通知前会检查系统授权状态，不主动触发运行时权限弹窗。

## 9. 运行 Demo 源码

`android/demo/demo-source` 会直接依赖同一仓库中的
`android/sdk/salesmartly-chatwidget-sdk-v1.0.4.aar`。在 `android/demo/demo-source/local.properties` 中配置
Android SDK 路径和项目脚本地址：

```properties
sdk.dir=/path/to/Android/sdk
salesmartly.scriptUrl=https://your-domain.example/js/project_xxxxx.js
```

也可以通过环境变量 `SALESMARTLY_SCRIPT_URL` 注入项目脚本地址。构建可安装的 debug APK：

```bash
cd android/demo/demo-source
./gradlew :sample-app:assembleDebug
```

产物位于 `sample-app/build/outputs/apk/debug/sample-app-debug.apk`。
