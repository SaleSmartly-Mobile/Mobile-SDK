# SaleSmartly Chat Android SDK Demo

该目录提供 SaleSmartly Chat Android 原生 SDK 的 Demo APK 与 Android 接入说明。Demo 使用原生 SDK UI，不通过 WebView 嵌入聊天插件页面。

## Demo APK 下载

[点击下载 Demo APK](https://raw.githubusercontent.com/SaleSmartly-Demo/SaleSmartly_LiveChat_Mobile_SDK/main/android/apk/salesmartly-chat-android-demo-v1.0.0.apk)

APK 信息：

| 字段 | 值 |
| --- | --- |
| 文件 | `android/apk/salesmartly-chat-android-demo-v1.0.0.apk` |
| applicationId | `com.salesmartly.chatwidget.sample` |
| versionName | `1.0.0` |
| versionCode | `1` |
| minSdk | `23` |
| 构建类型 | `debug` |
| SHA-256 | `7e2a9490497cf8e356e58b55411797d29512202718bec2bf08bcddc9b1c18070` |

Android 设备下载后如提示禁止安装未知来源应用，请在系统设置中允许当前浏览器或文件管理器安装 APK。

## SDK AAR 下载

[点击下载 SDK AAR](https://raw.githubusercontent.com/SaleSmartly-Demo/SaleSmartly_LiveChat_Mobile_SDK/main/android/sdk/salesmartly-chatwidget-sdk-v0.1.0.aar)

AAR 信息：

| 字段 | 值 |
| --- | --- |
| 文件 | `android/sdk/salesmartly-chatwidget-sdk-v0.1.0.aar` |
| Maven 坐标 | `com.salesmartly:chatwidget-sdk:0.1.0` |
| minSdk | `23` |
| 构建类型 | `release` |
| 文件大小 | `1500493` bytes |
| SHA-256 | `a774daac42592a84d9ff8aad5e491f0d11abd94add72fa3407de261465f84cf3` |

## 1. 添加 SDK 依赖

正式接入推荐通过 Maven 依赖引入 SDK：

```kotlin
dependencies {
    implementation("com.salesmartly:chatwidget-sdk:0.1.0")
}
```

如果临时使用本地 AAR，可以下载上方 `salesmartly-chatwidget-sdk-v0.1.0.aar`，放入宿主 App 的 `libs` 目录：

```kotlin
dependencies {
    implementation(files("libs/salesmartly-chatwidget-sdk-v0.1.0.aar"))
}
```

本地 AAR 不会自动携带传递依赖，宿主 App 需要补齐 SDK 使用到的 Compose、Retrofit、OkHttp、Socket.IO、DataStore、Room、Coroutines、kotlinx-serialization 等依赖。正式接入不建议长期使用本地 AAR。

## 2. 注入插件脚本地址

Android SDK 不需要把 Web Widget UI 放入 Android assets，也不需要通过 WebView 加载聊天页。宿主 App 只需要把客户后台生成的 Web 插件脚本地址传给 SDK。

建议通过 `BuildConfig` 注入脚本地址，避免把真实客户脚本地址硬编码到公共源码仓库：

```kotlin
android {
    defaultConfig {
        buildConfigField(
            "String",
            "SALESMARTLY_SCRIPT_URL",
            "\"https://your-domain.example/chat/widget-v2/install.js\"",
        )
    }

    buildFeatures {
        buildConfig = true
    }
}
```

脚本地址也可以由 CI、`local.properties`、远程配置或业务后台下发，只要最终传入 `SalesmartlyChat.initialize(context, scriptUrl)` 即可。

## 3. 初始化 SDK

建议在 `Application` 或首个承载聊天 UI 的 `Activity` 中初始化。回调可以先注册，再初始化：

```kotlin
import com.salesmartly.chatwidget.api.SalesmartlyCallback
import com.salesmartly.chatwidget.api.SalesmartlyChat

SalesmartlyChat.push("onReady", SalesmartlyCallback { payload ->
    // SDK 初始化完成
})

SalesmartlyChat.push("onUnRead", SalesmartlyCallback { payload ->
    val count = payload["num"]
})

SalesmartlyChat.initialize(
    context = applicationContext,
    scriptUrl = BuildConfig.SALESMARTLY_SCRIPT_URL,
)
```

SDK 会下载脚本，读取其中的 `__ssc.license`，再使用原生网络、Socket.IO 与消息处理链路完成初始化。

## 4. 挂载聊天 UI

### Compose 页面

```kotlin
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.salesmartly.chatwidget.api.SalesmartlyChat
import com.salesmartly.chatwidget.ui.SalesmartlyChatHost

@Composable
fun AppScreen() {
    Box(modifier = Modifier.fillMaxSize()) {
        SalesmartlyChatHost(
            runtime = SalesmartlyChat.runtime(),
            modifier = Modifier.fillMaxSize(),
        )
    }
}
```

### View 页面

```kotlin
import android.os.Bundle
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import com.salesmartly.chatwidget.api.SalesmartlyChat

class ChatActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_chat)

        val container = findViewById<ViewGroup>(R.id.chat_container)
        SalesmartlyChat.attach(container)
    }
}
```

调用 `SalesmartlyChat.attach(container)` 或 `SalesmartlyChat.runtime()` 前，需要先完成 `SalesmartlyChat.initialize(...)`。

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
SalesmartlyChat.trackUrl("app://home")
```

也可以使用 Web 兼容命令桥：

```kotlin
SalesmartlyChat.push("chatOpen")
SalesmartlyChat.push("sendTextMessage", "Hello")
SalesmartlyChat.push("onUnRead", SalesmartlyCallback { payload ->
    val count = payload["num"]
})
```

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

支持的回调包括：`onReady`、`onUnRead`、`onSendMessage`、`onReceiveMessage`、`onOpenChat`、`onCloseChat`、`onOpenCollection`、`onCollectionInfo`、`onOverTime`、`onOpenCustom`、`setExclusiveLink`、`onOpenLine`、`onOpenMessenger`、`onOpenEmail`、`onOpenTelegram`、`onOpenWhatsapp`、`onOpenInstagram`、`onOpenTikTok`、`onOpenVKontakte`、`onOpenZalo`、`onOpenWeixin`。

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
