package com.salesmartly.chatwidget.sample

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.salesmartly.chatwidget.api.SalesmartlyCallback
import com.salesmartly.chatwidget.api.SalesmartlyChat
import com.salesmartly.chatwidget.ui.SalesmartlyChatHost

/**
 * Android SDK 示例页面。
 *
 * 示例配置通过 `local.properties` 或环境变量注入 Web 项目脚本 URL，运行时使用公开
 * `SalesmartlyChat.initialize(context, scriptUrl)` 入口验证用户同意隐私政策后的原生 SDK 初始化、
 * 打开聊天和回调链路。
 */
class MainActivity : ComponentActivity() {
    private val notificationPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) {}
    private var sdkInitialized by mutableStateOf(false)
    private var sdkReady by mutableStateOf(false)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    SampleScreen(
                        sdkInitialized = sdkInitialized,
                        sdkReady = sdkReady,
                        onConsentAndInitialize = {
                            if (!sdkInitialized) {
                                sdkInitialized = true
                                initializeChatSdk()
                            }
                        },
                        onEnableNotifications = ::requestNotificationPermissionIfNeeded,
                    )
                }
            }
        }
    }

    /**
     * 示例宿主在 Android 13+ 主动请求通知权限。
     *
     * SDK 仅在发送本地通知前检查系统授权状态，不主动触发运行时权限弹窗。
     */
    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) return
        notificationPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
    }

    private fun initializeChatSdk() {
        SalesmartlyChat.push("onReady", SalesmartlyCallback { payload ->
            sdkReady = true
            Log.d("SalesmartlySample", "onReady: $payload")
        })
        SalesmartlyChat.push("onUnRead", logCallback("onUnRead"))
        SalesmartlyChat.push("onSendMessage", logCallback("onSendMessage"))
        SalesmartlyChat.push("onReceiveMessage", logCallback("onReceiveMessage"))
        SalesmartlyChat.push("onOpenChat", logCallback("onOpenChat"))
        SalesmartlyChat.push("onOpenWhatsapp", logCallback("onOpenWhatsapp"))
        SalesmartlyChat.push("onOpenCustom", logCallback("onOpenCustom"))

        SalesmartlyChat.initialize(
            context = applicationContext,
            scriptUrl = BuildConfig.SALESMARTLY_SCRIPT_URL,
        )

        SalesmartlyChat.setUserInfo(mapOf("source" to "sample-app"))
        SalesmartlyChat.trackUrl("sample-app://home")
    }

    private fun logCallback(name: String): SalesmartlyCallback = SalesmartlyCallback { payload ->
        Log.d("SalesmartlySample", "$name: $payload")
    }
}

@Composable
private fun SampleScreen(
    sdkInitialized: Boolean,
    sdkReady: Boolean,
    onConsentAndInitialize: () -> Unit,
    onEnableNotifications: () -> Unit,
) {
    val runtime = if (sdkReady) SalesmartlyChat.runtime() else null
    val sdkState = runtime?.state?.collectAsState()?.value
    Box(modifier = Modifier.fillMaxSize()) {
        if (runtime != null) {
            SalesmartlyChatHost(
                runtime = runtime,
                modifier = Modifier.fillMaxSize(),
            )
        }
        if (sdkState?.isChatOpen != true) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(
                    text = "Salesmartly Chat Android Sample",
                    style = MaterialTheme.typography.titleLarge,
                )
                if (!sdkInitialized) {
                    Button(onClick = onConsentAndInitialize) {
                        Text("同意隐私政策并初始化")
                    }
                } else if (!sdkReady) {
                    Text("SDK 初始化中")
                } else {
                    Button(onClick = onEnableNotifications) {
                        Text("启用消息通知")
                    }
                    Button(onClick = SalesmartlyChat::openChat) {
                        Text("Open chat")
                    }
                    Button(onClick = { SalesmartlyChat.sendTextMessage("你好") }) {
                        Text("Send sample message")
                    }
                    Button(onClick = { SalesmartlyChat.showCollection(true) }) {
                        Text("Show collection")
                    }
                    Button(onClick = { SalesmartlyChat.openCustomEntry("custom_1") }) {
                        Text("Open custom entry")
                    }
                }
            }
        }
    }
}
