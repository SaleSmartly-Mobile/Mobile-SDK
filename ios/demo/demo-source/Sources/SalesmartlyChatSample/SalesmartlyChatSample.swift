#if canImport(SwiftUI)
#if os(macOS)
import AppKit
#endif
import Foundation
import SalesmartlyChat
import SwiftUI

/// 对齐本仓库 Examples/SalesmartlyChatSample 的 SwiftUI 示例入口，用于演示宿主 App 初始化 SDK 并承载 SalesmartlyChatHost。
@main
struct SalesmartlyChatSampleApp: App {
    /// 对齐 Android sample `sdkReady`，脚本初始化 ready 后再把原生 Host 挂到示例页面。
    @State private var sdkReady = false
    /// 对齐 Android sample `onCreate` 只初始化一次 SDK，避免 SwiftUI 窗口重绘重复注册回调。
    @State private var didStartSDK = false

    /// 对齐用户提供的 Web SDK script src，默认使用当前指定插件地址验证 SDK 地址接入。
    private static let defaultScriptURL = "https://plugin-code.salesmartly.com/js/project_1101_1022_1782992011.js"
    /// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo().source_url，sample 使用固定宿主页地址参与 create-user。
    private static let sampleSourceURL = "sample-app://home"
    /// 对齐 widget main:src/constants/plugin.ts 的 GUEST_UUID_KEY，sample 持久化访客 UUID 供 create-user 复用。
    private static let sampleGuestUUIDKey = "salesmartly_sample_guest_uuid"

    /// 对齐 Android sample 的 `SALESMARTLY_SCRIPT_URL` 环境覆盖入口，SwiftPM sample 无 BuildConfig，运行时直接读取环境变量。
    private static var scriptURL: String {
        let value = ProcessInfo.processInfo.environment["SALESMARTLY_SCRIPT_URL"] ?? ""
        if !value.isEmpty {
            return value
        }
        return defaultScriptURL
    }

    /// 对齐 widget main:src/helper/userTool.ts 的 genGuestUUID，sample 用 UserDefaults 保存并复用访客 user_id。
    private static var sampleGuestUserId: String {
        if let value = UserDefaults.standard.string(forKey: sampleGuestUUIDKey), !value.isEmpty {
            return value
        }
        let value = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        UserDefaults.standard.set(value, forKey: sampleGuestUUIDKey)
        return value
    }

    /// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo().ua，sample 使用固定 UA 标识 iOS 示例宿主。
    private static var sampleUserAgent: String {
        "SalesmartlyChatSample iOS"
    }

    /// 对齐 widget main:src/utils/env.ts 与 helper/useLocal.ts 的 create-user 入参，scriptURL 初始化后用于真正创建访客和连接会话。
    private static var nativeBootstrapContext: SalesmartlyNativeBootstrapContext {
        SalesmartlyNativeBootstrapContext(
            sourceURL: sampleSourceURL,
            userAgent: sampleUserAgent,
            navigatorLanguage: Locale.current.identifier,
            beforeSourceURL: "",
            guestUserId: sampleGuestUserId
        )
    }

    /// 对齐 Web SDK 真实宿主页默认只露出插件 Launcher；Android sample 操作区保留为调试入口，通过环境变量显式打开。
    private static var showsSampleControls: Bool {
        ProcessInfo.processInfo.environment["SALESMARTLY_SHOW_SAMPLE_CONTROLS"] == "1"
    }

    init() {
        #if os(macOS)
        // SwiftPM 产物转临时 macOS App 时显式注册为普通前台应用，便于桌面运行验证。
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        #endif

    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
                sampleBackgroundColor
                    .ignoresSafeArea()

                if Self.showsSampleControls {
                    sampleControls
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                if sdkReady {
                    SalesmartlyChatHost(runtime: SalesmartlyChat.runtime())
                }
            }
            .onAppear {
                startSampleSDKIfNeeded()
                activateSampleWindow()
            }
        }
    }

    /// 对齐 Android sample `initializeChatSdk()`，在示例窗口出现时注册回调、用脚本 URL 初始化并写入宿主上下文。
    private func startSampleSDKIfNeeded() {
        guard !didStartSDK else {
            return
        }
        didStartSDK = true
        registerSampleCallbacks()
        SalesmartlyChat.setUserInfo(["source": "sample-app"])
        SalesmartlyChat.trackUrl(Self.sampleSourceURL)
        Task {
            do {
                print("SalesmartlySample initializing: \(Self.scriptURL)")
                try await SalesmartlyChat.initialize(
                    scriptURL: Self.scriptURL,
                    nativeBootstrapContext: Self.nativeBootstrapContext
                )
                print("SalesmartlySample initialize returned")
                await MainActor.run {
                    sdkReady = true
                }
            } catch {
                print("SalesmartlySample initialize failed: \(error)")
            }
        }
    }

    /// 对齐 Android sample `SampleScreen` 的外层操作入口，用于本地验证打开聊天、发送消息、留资和自定义入口。
    private var sampleControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Salesmartly Chat iOS Sample")
                .font(.title2)
                .fontWeight(.semibold)

            Button("Open chat") {
                SalesmartlyChat.openChat()
            }

            Button("Send sample message") {
                SalesmartlyChat.sendTextMessage("你好")
            }

            Button("Show collection") {
                SalesmartlyChat.showCollection(true)
            }

            Button("Open custom entry") {
                SalesmartlyChat.openCustomEntry("custom_1")
            }
        }
        .padding(16)
    }

    /// 对齐 Android sample 的 onReady/onUnRead/onSendMessage/onReceiveMessage/onOpenWhatsapp/onOpenCustom 日志回调。
    private func registerSampleCallbacks() {
        SalesmartlyChat.push("onReady") { payload in
            print("SalesmartlySample onReady: \(payload)")
            Task { @MainActor in
                sdkReady = true
            }
        }
        SalesmartlyChat.push("onUnRead") { payload in
            print("SalesmartlySample onUnRead: \(payload)")
        }
        SalesmartlyChat.push("onSendMessage") { payload in
            print("SalesmartlySample onSendMessage: \(payload)")
        }
        SalesmartlyChat.push("onReceiveMessage") { payload in
            print("SalesmartlySample onReceiveMessage: \(payload)")
        }
        SalesmartlyChat.push("onOpenWhatsapp") { payload in
            print("SalesmartlySample onOpenWhatsapp: \(payload)")
        }
        SalesmartlyChat.push("onOpenCustom") { payload in
            print("SalesmartlySample onOpenCustom: \(payload)")
        }
    }

    /// 对齐 Web SDK 截图中的宿主页面，sample 默认使用纯白画布承载右下角 Launcher。
    private var sampleBackgroundColor: Color {
        Color.white
    }

    /// 对齐 macOS SwiftPM 示例运行场景，窗口创建后将临时 App 激活到前台，便于本地桌面验证。
    private func activateSampleWindow() {
        #if os(macOS)
        DispatchQueue.main.async {
            for window in NSApplication.shared.windows {
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
            }
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        #endif
    }
}
#endif
