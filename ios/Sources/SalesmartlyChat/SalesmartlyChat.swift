import Foundation
import CryptoKit

public typealias SalesmartlyPayload = [String: Any]
public typealias SalesmartlyCallback = (SalesmartlyPayload) -> Void
/// 对齐 widget main:src/types/global.d.ts 的 ssq.push("getSidebarHeight", callback)，用于返回 Launcher/Sidebar 折叠入口高度。
public typealias SalesmartlySidebarHeightCallback = (Int) -> Void
/// 对齐 widget main:src/utils/SsmEvent.ts 与 src/components/Channel/useChannel.ts 的 createWhatsappGreeting，用于宿主改写 WhatsApp 跳转问候语。
public typealias SalesmartlyWhatsappGreetingCallback = (String) -> String?
/// 对齐 widget main:src/stores/app.ts 与 src/stores/chat.ts 的 Pinia 响应式状态订阅，用于原生 Host 在异步 Socket/HTTP reducer 后刷新界面。
public typealias SalesmartlyStateObserver = (ChatRuntimeState) -> Void

/// 对齐 widget main:src/utils/sidebarHeight.ts 中 data-ssc-launcher-height-target 元素的 DOMRect，用于 iOS Host 上报可见 Launcher 高度目标。
public struct SalesmartlyLauncherHeightTargetFrame: Equatable {
    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 rect.top，表示可见高度目标在宿主坐标系中的顶部。
    public var top: Double
    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 rect.bottom，表示可见高度目标在宿主坐标系中的底部。
    public var bottom: Double
    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 rect.height，height > 0 的目标才参与高度计算。
    public var height: Double

    public init(top: Double, bottom: Double, height: Double) {
        self.top = top
        self.bottom = bottom
        self.height = height
    }
}

/// 对齐 widget main:src/helper/useNotification.ts 的 Notification、soundElem.play 与点击聚焦动作，由宿主 iOS App 注入真实通知/声音处理。
public protocol SalesmartlyNotificationHandling: AnyObject {
    /// 对齐 widget main:src/helper/useNotification.ts 的 reqNotification，返回当前通知授权状态。
    func requestUnreadNotificationPermission(currentStatus: String) -> String

    /// 对齐 widget main:src/helper/useNotification.ts 的 new window.Notification，展示一条未读通知。
    func showUnreadNotification()

    /// 对齐 widget main:src/helper/useNotification.ts 的 soundElem.play，播放未读声音提醒。
    func playUnreadSound()

    /// 对齐 widget main:src/helper/useNotification.ts 的 msg.onclick 内 focusParentWindow/window.focus，聚焦通知目标。
    func focusNotificationTarget()

    /// 对齐 widget main:src/helper/useNotification.ts 的 msg.onclick 内 this.close，关闭当前未读通知。
    func closeUnreadNotification()
}

public enum ChatMode: String, Equatable {
    case chat
    case demo
    case preview
    case sandbox
    case exclusiveLink
}

public struct PositionHorizontal: Equatable {
    public var mobile: Int
    public var desktop: Int

    public init(mobile: Int = 0, desktop: Int = 0) {
        self.mobile = mobile
        self.desktop = desktop
    }
}

/// 对齐 Android `customEntryPopup` 与 widget main:src/components/Channel/CustomEntry.vue，描述自定义入口文字或图片弹层的当前内容。
public struct SalesmartlyCustomEntryPopup: Equatable {
    /// 对齐 widget show_custom_config 的 `id`，用于标识 custom_1/custom_2/custom_3。
    public var id: String
    /// 对齐 widget show_custom_config 的 `type`，"1" 为文字，"2" 为图片，"3" 为外链。
    public var type: String
    /// 对齐 widget show_custom_config 的 `input_value`，用于弹层正文、图片 URL 或外链 URL。
    public var inputValue: String
}

/// 对齐 Android Toast 队列与 widget 多语言文案，供 iOS SwiftUI Host 展示上传失败、评价错误等短提示。
public struct SalesmartlyToastItem: Equatable, Identifiable {
    /// 对齐 Android Toast 单次入队记录，iOS 用递增 id 稳定驱动 SwiftUI diff。
    public var id: Int
    /// 对齐 widget/Android 当前语言下的 toast 文案。
    public var message: String
}

public struct SalesmartlySetting: Equatable {
    public var mode: ChatMode
    public var hideIcon: Bool?
    public var initMobileScreen: String?
    public var flowId: String?
    public var flowRef: String?
    public var overTime: TimeInterval?
    /// 对齐 Android `SalesmartlySetting.requestOriginURL` / `r_o_url`，用于由 app 域名推导 API、msg 与 Socket 域名。
    public var requestOriginURL: String?
    /// 对齐 Android `SalesmartlySetting.widgetHost` 与 `EndpointResolver`，用于原生 config 初始化时指定 widget/plugin/info 域名。
    public var widgetHost: String?
    public var showNotification: Bool?
    public var positionHorizontal: PositionHorizontal?
    public var isCustomized: Bool?

    public init(
        mode: ChatMode = .chat,
        hideIcon: Bool? = nil,
        initMobileScreen: String? = nil,
        flowId: String? = nil,
        flowRef: String? = nil,
        overTime: TimeInterval? = nil,
        requestOriginURL: String? = nil,
        widgetHost: String? = nil,
        showNotification: Bool? = nil,
        positionHorizontal: PositionHorizontal? = nil,
        isCustomized: Bool? = nil
    ) {
        self.mode = mode
        self.hideIcon = hideIcon
        self.initMobileScreen = initMobileScreen
        self.flowId = flowId
        self.flowRef = flowRef
        self.overTime = overTime
        self.requestOriginURL = requestOriginURL
        self.widgetHost = widgetHost
        self.showNotification = showNotification
        self.positionHorizontal = positionHorizontal
        self.isCustomized = isCustomized
    }
}

public struct SalesmartlyConfig: Equatable {
    public var license: String
    public var setting: SalesmartlySetting

    public init(license: String, setting: SalesmartlySetting = SalesmartlySetting()) {
        self.license = license
        self.setting = setting
    }
}

/// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo/getParentPageInfo 与 main:src/helper/useLocal.ts 的 genGuestUUID 入参来源，由 iOS 宿主提供 create-user 所需页面上下文。
public struct SalesmartlyNativeBootstrapContext: Equatable, Sendable {
    /// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo().source_url。
    public var sourceURL: String
    /// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo().ua。
    public var userAgent: String
    /// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo().language。
    public var navigatorLanguage: String
    /// 对齐 widget main:src/utils/env.ts 的 getParentPageInfo().referrer。
    public var beforeSourceURL: String
    /// 对齐 widget main:src/helper/userTool.ts 的 genGuestUUID，用于 guest create-user 的 user_id。
    public var guestUserId: String

    /// 对齐 widget main:src/utils/env.ts 与 src/helper/useLocal.ts 的 create-user 上下文字段，由 iOS 宿主构造后传入脚本初始化入口。
    public init(
        sourceURL: String,
        userAgent: String,
        navigatorLanguage: String,
        beforeSourceURL: String,
        guestUserId: String
    ) {
        self.sourceURL = sourceURL
        self.userAgent = userAgent
        self.navigatorLanguage = navigatorLanguage
        self.beforeSourceURL = beforeSourceURL
        self.guestUserId = guestUserId
    }
}

public struct LoginInfo: Equatable {
    public var userId: String?
    public var userName: String?
    public var language: String?
    public var phone: String?
    public var email: String?
    public var description: String?
    public var labelNames: [String]
    public var customFieldsExt: [String: String]

    public init(
        userId: String? = nil,
        userName: String? = nil,
        language: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        description: String? = nil,
        labelNames: [String] = [],
        customFieldsExt: [String: String] = [:]
    ) {
        self.userId = userId
        self.userName = userName
        self.language = language
        self.phone = phone
        self.email = email
        self.description = description
        self.labelNames = labelNames
        self.customFieldsExt = customFieldsExt
    }
}

public struct SalesmartlyUploadFile: Equatable {
    public var name: String
    public var size: Int
    public var isImage: Bool
    public var isVideo: Bool
    public var localURL: String?

    public init(
        name: String,
        size: Int,
        isImage: Bool,
        isVideo: Bool,
        localURL: String? = nil
    ) {
        self.name = name
        self.size = size
        self.isImage = isImage
        self.isVideo = isVideo
        self.localURL = localURL
    }
}

struct SalesmartlyUploadTask: Equatable {
    var file: SalesmartlyUploadFile
    var type: String
    var clientExpandInfo: [String: String]
    /// 对齐 widget main:src/helper/useUpload.ts 的 uploadTaskMap，保留同一会话内 picker 文件二进制用于直传和重试。
    var fileData: Data
}

struct SalesmartlyOSSSTSConfig: Equatable {
    var accessKeyId: String
    var accessKeySecret: String
    var expiration: String
    var securityToken: String
}

struct SalesmartlyOSSConfigCache: Equatable {
    var stsConfig: SalesmartlyOSSSTSConfig
    var path: String
    var effectiveTime: Int64
    var dews: String
}

struct SalesmartlyOSSDirectUploadForm: Equatable {
    var url: String
    var headers: [String: String]
    var fields: [String: String]
    var fileFieldName: String
    var objectURL: String
    var timeoutMilliseconds: Int
}

struct SalesmartlyUploadCompressionPlan: Equatable {
    var shouldCompress: Bool
    var quality: Double
    var fallbackToOriginalOnFailure: Bool
}

struct SalesmartlyUploadExecutionRequest: Equatable {
    var file: SalesmartlyUploadFile
    /// 对齐 widget main:src/helper/useUpload.ts 的 File 对象，传给 OSS multipart 直传执行器。
    var fileData: Data
    var tempId: String
    var type: String
    var clientExpandInfo: [String: String]
    var compressionPlan: SalesmartlyUploadCompressionPlan
    var replaceName: String
    var uploadConfigPayload: [String: String]
    var uploadTimeoutMilliseconds: Int
}

public struct SalesmartlyStreamInfo: Equatable {
    public var count: Int
    public var current: Int
    public var size: Int
    public var process: String

    public init(count: Int, current: Int, size: Int, process: String) {
        self.count = count
        self.current = current
        self.size = size
        self.process = process
    }
}

public struct SalesmartlyStreamCurrentInfo: Equatable {
    public var mid: String
    public var msg: String
    public var current: Int

    public init(mid: String = "", msg: String = "", current: Int = 0) {
        self.mid = mid
        self.msg = msg
        self.current = current
    }
}

enum SalesmartlyTransportKind: String, Sendable {
    case socketEvent
    case http
}

enum SalesmartlyHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

/// 对齐 widget main:src/api/axios.ts 中不同接口的 body 形态；默认 form，`swap-object-v2` 与 SSE HTTP `/chat/chat-msg/event` 使用 JSON。
enum SalesmartlyHTTPBodyEncoding: Sendable, Equatable {
    case form
    case json
}

/// 对齐 widget main:package.json 的 `socket.io-client@2.4.0`，Swift Socket.IO 需显式使用 v2/Engine.IO 3。
enum SalesmartlySocketIOProtocolVersion: Int, Sendable, Equatable {
    case two = 2
}

struct SalesmartlySocketConnectionRequest: @unchecked Sendable {
    var query: [String: String]
    var transports: [String]
    var reconnectionAttempts: Int
    /// 对齐 widget main:package.json 的 `socket.io-client@2.4.0`，用于 Socket.IO Swift 连接版本配置。
    var socketIOProtocolVersion: SalesmartlySocketIOProtocolVersion = .two
}

/// 对齐 widget main:src/helper/realtime/sseClient.ts 的 EventSource 连接参数，包含 Centrifugo 地址、sse-connect/sse-disconnect 和 onopen 后的 join-room 请求。
struct SalesmartlySSEConnectionRequest: @unchecked Sendable {
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 拼出的 `connection/uni_sse?cf_connect=...` 地址。
    var eventSourceURL: URL
    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sseConnect，在 EventSource onopen 后通知后端。
    var connectRequest: SalesmartlyTransportRequest
    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sseDisconnect，在释放 SSE 时通知后端。
    var disconnectRequest: SalesmartlyTransportRequest
    /// 对齐 widget main:src/helper/useSocket.ts 的 onOpen -> joinRoom，EventSource 打开后再发送这些实时请求。
    var openRequests: [SalesmartlyTransportRequest]
}

struct SalesmartlyTransportRequest: @unchecked Sendable {
    var kind: SalesmartlyTransportKind
    var eventName: String?
    var path: String?
    var method: SalesmartlyHTTPMethod?
    var query: [String: String]
    var payload: SalesmartlyPayload
    var externalSign: Bool
    var bodyEncoding: SalesmartlyHTTPBodyEncoding = .form

    func payloadJSONString() -> String {
        let data = try! JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }
}

/// 对齐 widget main:src/helper/useLocal.ts 的 getToken 返回路径，描述本次 token 获取应复用缓存还是发起 createUser 请求。
struct SalesmartlyCreateUserTokenDecision {
    /// 对齐 widget main:src/helper/useLocal.ts 的 Promise.resolve(localToken/tokenPad.token)，表示可直接返回的 token。
    var cachedToken: String?
    /// 对齐 widget main:src/helper/useLocal.ts 的 createUser(params)，表示需要交给 transport 执行的创建用户请求。
    var request: SalesmartlyTransportRequest?
    /// 对齐 widget main:src/helper/useLocal.ts 的 setTimeout 延迟，表示距离最近 create-user 记录时间的延迟毫秒数。
    var delayMilliseconds: Int64
}

/// 对齐 widget main:src/helper/getLocalKey.ts 与 src/constants/plugin.ts 的本地缓存 key 集合，用于 token、会话、留资记录和访客 UUID 的宿主存储适配。
struct SalesmartlyLocalStorageKeys: Equatable {
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getTokenKey。
    var tokenKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getTokenDateKey。
    var tokenDateKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getConversationKey。
    var conversationKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getNewUserKey。
    var newUserKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getUserInfoKey。
    var userInfoKey: String
    /// 对齐 widget main:src/constants/plugin.ts 的 GUEST_UUID_KEY。
    var guestUUIDKey: String
    /// 对齐 widget main:src/constants/plugin.ts 的 AUTO_OPEN_KEY。
    var autoOpenKey: String
    /// 对齐 widget main:src/constants/plugin.ts 的 AUTO_OPEN_LAST_KEY。
    var autoOpenLastKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getCustomFieldsLocalKey。
    var customFieldsLocalMapKey: String
}

/// 对齐 widget main:src/helper/getLocalKey.ts 的用户维度本地 key 集合，用于镜像 stores/user.ts 中 userInfo 的 key 上下文。
struct SalesmartlyLocalUserKeys: Equatable {
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getTokenKey。
    var tokenKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getTokenDateKey。
    var tokenDateKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getConversationKey。
    var conversationKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getNewUserKey。
    var newUserKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getUserInfoKey。
    var userInfoKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getCustomFieldsLocalKey。
    var customFieldsLocalKey: String
}

struct SalesmartlyPollingSchedule {
    var startUnreadPolling: Bool
    var stopUnreadPolling: Bool
    var startRecentPolling: Bool
    var stopRecentPolling: Bool
    var requests: [SalesmartlyTransportRequest]
}

typealias SalesmartlyTransportResponseHandler = (SalesmartlyPayload, SalesmartlyTransportRequest) -> Void
typealias SalesmartlySocketInboundEventHandler = (String, SalesmartlyPayload) -> Void
/// 对齐 widget main:src/helper/realtime/sseClient.ts 的 onMessage callback，将 EventSource JSON payload 交给 runtime reducer。
typealias SalesmartlySSEInboundPayloadHandler = (SalesmartlyPayload) -> Void

/// 对齐 widget main:src/utils/storage.ts 的 localRead/localSave/localRemove，由宿主注入真实本地缓存实现。
protocol SalesmartlyLocalStoring: AnyObject {
    /// 对齐 widget main:src/utils/storage.ts 的 localRead，按 key 读取本地字符串。
    func read(_ key: String) -> String

    /// 对齐 widget main:src/utils/storage.ts 的 localSave，按 key 保存本地字符串。
    @discardableResult
    func save(_ key: String, value: String) -> Bool

    /// 对齐 widget main:src/utils/storage.ts 的 localRemove，按 key 删除本地缓存。
    func remove(_ key: String)
}

/// 对齐 widget main:src/utils/storage.ts 的 localStorage 默认实现，iOS SDK 使用 UserDefaults 承载同名本地 key。
final class SalesmartlyUserDefaultsLocalStore: SalesmartlyLocalStoring {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func read(_ key: String) -> String {
        userDefaults.string(forKey: key) ?? ""
    }

    @discardableResult
    func save(_ key: String, value: String) -> Bool {
        userDefaults.set(value, forKey: key)
        return true
    }

    func remove(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

protocol SalesmartlyTransporting: AnyObject {
    func send(_ request: SalesmartlyTransportRequest)
    func setResponseHandler(_ handler: @escaping SalesmartlyTransportResponseHandler)
    func setSocketInboundEventHandler(_ handler: @escaping SalesmartlySocketInboundEventHandler)
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 onMessage，用于传递 EventSource 下行 payload。
    func setSSEInboundPayloadHandler(_ handler: @escaping SalesmartlySSEInboundPayloadHandler)
    func connectSocket(_ request: SalesmartlySocketConnectionRequest)
    func disconnectSocket()
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 start，启动 Centrifugo SSE 下行连接。
    func connectSSE(_ request: SalesmartlySSEConnectionRequest)
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 stop，关闭 SSE 并发送 sse-disconnect。
    func disconnectSSE()
    func removeBufferedSocketEvent(_ eventName: String)
    func removeSocketEventHandlers(_ eventNames: [String])
    func addSocketEventHandlers(_ eventNames: [String])
    func addSocketPongHandler()
    func removeSocketPongHandler()
    func reconnectSocketAfterHeartbeatTimeout(delayMilliseconds: Int)
}

extension SalesmartlyTransporting {
    func setResponseHandler(_ handler: @escaping SalesmartlyTransportResponseHandler) {}
    func setSocketInboundEventHandler(_ handler: @escaping SalesmartlySocketInboundEventHandler) {}
    func setSSEInboundPayloadHandler(_ handler: @escaping SalesmartlySSEInboundPayloadHandler) {}
    func connectSocket(_ request: SalesmartlySocketConnectionRequest) {}
    func disconnectSocket() {}
    func connectSSE(_ request: SalesmartlySSEConnectionRequest) {}
    func disconnectSSE() {}
    func removeBufferedSocketEvent(_ eventName: String) {}
    func removeSocketEventHandlers(_ eventNames: [String]) {}
    func addSocketEventHandlers(_ eventNames: [String]) {}
    func addSocketPongHandler() {}
    func removeSocketPongHandler() {}
    func reconnectSocketAfterHeartbeatTimeout(delayMilliseconds: Int) {}
}

public enum ChatView: String, Equatable {
    case home
    case chat
}

/// 对齐 widget main:src/views/Page/components/ChannelList.vue 的主页渠道展示状态，用于区分主渠道卡片和其他渠道网格。
struct SalesmartlyHomeChannelDisplayState: Equatable {
    /// 对齐 Web `displayList[0]`，首页主卡片使用的渠道。
    var mainChannel: String?
    /// 对齐 Web `otherChannels`，仅 chat integration 且外部未承载渠道时展示。
    var gridChannels: [String]
    /// 对齐 Web `showMainCard`，控制首页主渠道卡片是否展示。
    var showMainCard: Bool
    /// 对齐 Web `showReceptionChatCard`，表示主卡片是否是 chat 接待入口。
    var showReceptionChatCard: Bool
}

/// 对齐 widget main:src/components/Bubble/FileMessage.vue 与 Android `fileAttachmentCardStyleState()` 的文件卡片尺寸。
struct SalesmartlyFileAttachmentCardStyleState: Equatable {
    var width: Int
    var height: Int
    var cornerRadius: Int
    var padding: Int
    var gap: Int
}

/// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 component computed，表示 Launcher 未读预览应使用的消息组件。
public enum SalesmartlyIconPopupPreviewComponent: String, Equatable {
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 msg_type=1 文本预览分支。
    case text = "TextMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 ImageMessage 预览组件。
    case image = "ImageMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 TemplatePreviewMessage 预览组件。
    case template = "TemplatePreviewMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 FileMessage 预览组件。
    case file = "FileMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 VideoMessage 预览组件。
    case video = "VideoMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 EmailMessage 预览组件。
    case email = "EmailMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 AiReplyMessage 预览组件。
    case ai = "AiReplyMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 ProductMessage 预览组件。
    case product = "ProductMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 QuickReplyPreviewMessage 预览组件。
    case quickReply = "QuickReplyPreviewMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 MediaTextMessage 预览组件。
    case mediaText = "MediaTextMessage"
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 default null 分支，表示当前没有可渲染预览组件。
    case unknown = ""
}

public struct ChatMessage: Equatable, Identifiable {
    static let tempPrefix = "temp_"
    static let failPrefix = "fail_"
    static let retryPrefix = "retry_"

    public var id: String
    public var msgType: String
    public var message: String
    public var sendType: String
    public var createdAt: Date
    public var mid: String
    public var tempId: String?
    public var status: Int?
    public var createdTime: Int64
    public var cMId: String?
    public var chatUserId: String?
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 sender_name，用于 Launcher 未读预览展示发送者名称。
    public var senderName: String?
    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 sender_avatar，用于 Launcher 未读预览展示发送者头像。
    public var senderAvatar: String?
    public var clientExpandInfo: [String: String]
    public var isRead: String?
    public var likeResult: [String: String]?
    public var isWithdraw: String?
    public var isStream: String?
    public var isStop: String?
    /// 对齐 widget main:src/helper/useSocket.ts 的 content.quote_chat，用于 iOS 原生引用预览和 onReceiveMessage payload 透传。
    public var quoteChat: String

    public init(
        id: String = UUID().uuidString,
        msgType: String = "text",
        message: String,
        sendType: String = "user",
        createdAt: Date = Date(),
        mid: String? = nil,
        tempId: String? = nil,
        status: Int? = nil,
        createdTime: Int64? = nil,
        cMId: String? = nil,
        chatUserId: String? = nil,
        senderName: String? = nil,
        senderAvatar: String? = nil,
        clientExpandInfo: [String: String] = [:],
        isRead: String? = nil,
        likeResult: [String: String]? = nil,
        isWithdraw: String? = nil,
        isStream: String? = nil,
        isStop: String? = nil,
        quoteChat: String = ""
    ) {
        self.id = id
        self.msgType = msgType
        self.message = message
        self.sendType = sendType
        self.createdAt = createdAt
        if let mid {
            self.mid = mid
        } else {
            self.mid = id
        }
        self.tempId = tempId
        self.status = status
        if let createdTime {
            self.createdTime = createdTime
        } else {
            self.createdTime = ChatMessage.timestamp(from: createdAt)
        }
        self.cMId = cMId
        self.chatUserId = chatUserId
        self.senderName = senderName
        self.senderAvatar = senderAvatar
        self.clientExpandInfo = clientExpandInfo
        self.isRead = isRead
        self.likeResult = likeResult
        self.isWithdraw = isWithdraw
        self.isStream = isStream
        self.isStop = isStop
        self.quoteChat = quoteChat
    }

    public static func makeTempId(createdAt: Date = Date()) -> String {
        "\(tempPrefix)\(timestamp(from: createdAt))"
    }

    public static func makeClientMessageId() -> String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }

    private static func timestamp(from date: Date) -> Int64 {
        Int64(date.timeIntervalSince1970 * 1000)
    }
}

enum SalesmartlyMessageRenderNodeType: Equatable {
    case time
    case message
}

/// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 renderNodes，用于 iOS Host 在消息序列中插入时间分隔。
struct SalesmartlyMessageRenderNode: Equatable, Identifiable {
    var type: SalesmartlyMessageRenderNodeType
    var key: String
    var timestamp: Int64
    var message: ChatMessage?

    var id: String {
        key
    }
}

/// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 renderNodes 计算：撤回和系统消息不参与上一条有效消息时间计算。
func salesmartlyMessageRenderNodes(messages: [ChatMessage], withdrawRecord: Bool = true) -> [SalesmartlyMessageRenderNode] {
    var nodes: [SalesmartlyMessageRenderNode] = []
    var previousTimestamp: Int64 = 0

    messages.forEach { message in
        let withdrawn = message.isWithdraw == "1"
        if withdrawn && !withdrawRecord {
            return
        }

        let system = message.msgType == "8"
        let timestamp = message.createdTime
        if !withdrawn && !system && salesmartlyShouldShowTimeDivider(previousTimestamp: previousTimestamp, currentTimestamp: timestamp) {
            nodes.append(
                SalesmartlyMessageRenderNode(
                    type: .time,
                    key: "time_\(timestamp)_\(message.tempId ?? message.mid)",
                    timestamp: timestamp,
                    message: nil
                )
            )
            previousTimestamp = timestamp
        }
        if !withdrawn && !system && previousTimestamp == 0 {
            previousTimestamp = timestamp
        }
        nodes.append(
            SalesmartlyMessageRenderNode(
                type: .message,
                key: "msg_\(message.tempId ?? message.mid)",
                timestamp: timestamp,
                message: message
            )
        )
    }

    return nodes
}

/// 对齐 widget main:src/components/Bubble/index.vue 的头像 `v-if` 条件，非访客且非 0/19 类型消息在聊天列表展示左侧头像槽位。
func salesmartlyShouldShowMessageAvatar(_ message: ChatMessage) -> Bool {
    message.sendType != "1" && message.msgType != "0" && message.msgType != "19"
}

private func salesmartlyShouldShowTimeDivider(previousTimestamp: Int64, currentTimestamp: Int64) -> Bool {
    if currentTimestamp == 0 {
        return false
    }
    if previousTimestamp == 0 {
        return true
    }
    return abs(currentTimestamp - previousTimestamp) >= 5 * 60 * 1000
}

/// 对齐 widget main:src/components/Bubble/TimeDivider.vue 的日期展示规则：当天、昨天、同年、跨年使用不同格式。
func salesmartlyFormatMessageTime(timestamp: Int64, now: Date = Date(), language: String = "zh-CN") -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    let calendar = Calendar.current
    if calendar.isDate(date, inSameDayAs: now) {
        return salesmartlyFormatDate(date, format: "HH:mm:ss")
    }

    if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
       calendar.isDate(date, inSameDayAs: yesterday) {
        return "\(salesmartlyText("time.yesterday", language: language)) \(salesmartlyFormatDate(date, format: "HH:mm:ss"))"
    }

    if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
        return salesmartlyFormatDate(date, format: "MM/dd HH:mm:ss")
    }

    return salesmartlyFormatDate(date, format: "yyyy/MM/dd HH:mm:ss")
}

private func salesmartlyFormatDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = format
    return formatter.string(from: date)
}

func salesmartlyText(_ key: String, language: String = "zh-CN", replacements: [String: String] = [:]) -> String {
    SalesmartlyI18n.text(key, language: language, replacements: replacements)
}

public struct ChatRuntimeState: Equatable {
    public var isReady: Bool
    public var showWrapper: Bool
    public var currentView: ChatView
    /// 对齐 widget main:src/helper/useNotification.ts 的 onWinVisibilitychange，记录宿主窗口是否处于可见状态并影响未读通知触发。
    public var isWindowVisible: Bool
    public var messages: [ChatMessage]
    public var loginInfo: LoginInfo?
    /// 对齐 widget main:src/locales/index.ts 的 lang ref，记录当前生效的多语言代码。
    public var lang: String
    /// 对齐 widget main:src/utils/SsmEvent.ts 的 setUserInfo 入参，保留 iOS 侧字符串值用户信息镜像。
    public var userInfo: [String: String]
    /// 对齐 widget main:src/utils/SsmEvent.ts 的 userData.user_info，记录 setUserInfo 经 JSON.stringify 后注入 setUserData 的字符串。
    public var userInfoJSONString: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.type，记录当前本地 key 应按 guest 还是 user 派生。
    public var userType: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 localUserId，记录当前参与本地 key 派生的用户标识。
    public var localUserId: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.tokenKey，记录当前 token 本地缓存 key。
    public var tokenKey: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.tokenDateKey，记录当前 token 时间戳缓存 key。
    public var tokenDateKey: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.conversationKey，记录当前会话列表缓存 key。
    public var conversationKey: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.newUserKey，记录当前新访客留资状态缓存 key。
    public var newUserKey: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.userInfoKey，记录当前用户本地资料缓存 key。
    public var userInfoKey: String
    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getCustomFieldsLocalKey，记录当前自定义字段本地缓存 key。
    public var customFieldsLocalKey: String
    /// 对齐 widget main:src/stores/user.ts 的 clearUserData/removeUserLocalInfo，记录本轮需要执行 localRemove 的缓存 key。
    public var pendingLocalRemoveKeys: [String]
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.token，记录 createUser 返回或本地复用的登录 token。
    public var userToken: String
    /// 对齐 widget main:src/helper/userTool.ts 的 getChatUserId，记录用户本地信息中的 chat_user_id。
    public var localChatUserId: String
    /// 对齐 widget main:src/stores/user.ts 的 userInfo.isNewUser，表示当前 token 响应是否为新用户。
    public var isNewUser: Bool
    /// 对齐 widget main:src/helper/useLocal.ts 的 tokenPad.params，记录最近一次 createUser 参数 JSON。
    public var createUserTokenPadParams: String
    /// 对齐 widget main:src/helper/useLocal.ts 的 tokenPad.token，用于相同参数已完成请求后的 token 复用判断。
    public var createUserTokenPadToken: String
    /// 对齐 widget main:src/helper/useLocal.ts 的 tokenPad.xhr，记录当前 createUser 请求是否仍在进行。
    public var isCreateUserTokenRequestActive: Bool
    /// 对齐 widget main:src/helper/useLocal.ts 的 tokenPad.date，记录最近一次 createUser 请求发起时间。
    public var createUserTokenRequestDateMilliseconds: Int64
    /// 对齐 widget main:src/helper/useLocal.ts 的 tokenDateKey，记录最近一次 createUser 成功保存 token 的时间。
    public var createUserTokenSavedDateMilliseconds: Int64
    /// 对齐 widget main:src/helper/useLocal.ts 的 CREATE_USER_LAST_TIME_KEY，记录 guest createUser 成功后的最近创建时间。
    public var createUserLastTimeMilliseconds: Int64
    public var showCollection: Bool
    public var showOffline: Bool
    /// 对齐 widget main:src/components/Collection/index.vue 与 Android `WidgetInfo.collect_information` 的普通留资配置。
    public var collectInformation: SalesmartlyCollectionConfig
    /// 对齐 widget main:src/components/Collection/index.vue 与 Android `WidgetInfo.offline_survey` 的离线留资配置。
    public var offlineSurvey: SalesmartlyCollectionConfig
    /// 对齐 widget main:src/views/Chat/components/BulletinBoard.vue 与 Android `WidgetInfo.bulletin_board` 的公告栏配置。
    public var bulletinBoard: SalesmartlyBulletinBoardConfig
    /// 对齐 Android `bulletinBoardDismissed`，记录当前运行态是否已关闭公告栏。
    public var bulletinBoardDismissed: Bool
    /// 对齐 widget main:src/stores/app.ts 的 showLinePage，用于记录 Launcher 统一承载的 Line 侧边页是否展示。
    public var showLinePage: Bool
    /// 对齐 widget main:src/stores/app.ts 的 launcherShowSideBar，由 Launcher 写入当前是否处于侧边栏展示上下文。
    public var launcherShowSideBar: Bool
    /// 对齐 widget main:src/stores/app.ts 的 launcherShowIcon，由 Launcher 写入当前图标列是否可见。
    public var launcherShowIcon: Bool
    public var notificationEnabled: Bool
    /// 对齐 widget main:src/helper/types.ts 与 src/helper/useNotification.ts 的 flashTitle，表示未读消息是否触发标题闪烁状态。
    public var flashTitle: Bool
    /// 对齐 widget main:src/helper/types.ts 与 src/helper/useNotification.ts 的 soundNotice，表示未读数量变化时是否触发声音提醒状态。
    public var soundNotice: Bool
    /// 对齐 widget main:src/helper/useNotification.ts 的 shouldFlashTitle，用于宿主层观察未读标题闪烁是否处于激活状态。
    public var shouldFlashTitle: Bool
    /// 对齐 widget main:src/helper/useNotification.ts 的 originTitle，记录标题闪烁停止后需要恢复的宿主标题。
    public var notificationOriginTitle: String
    /// 对齐 widget main:src/helper/useNotification.ts 的 parentDoc.title，记录当前应展示的宿主标题。
    public var notificationCurrentTitle: String
    /// 对齐 widget main:src/locales/lang/zh-CN/index.ts 的 title.newMsg，由宿主按当前语言注入新消息标题片段。
    public var notificationNewMessageTitle: String
    /// 对齐 widget main:src/helper/useNotification.ts 的 flashTitle(title) 参数，记录下一次标题闪烁要切换到的标题。
    public var notificationFlashNextTitle: String
    /// 对齐 widget main:src/helper/useNotification.ts 的 800ms flashTimer，记录下一次标题闪烁推进时间戳。
    public var notificationFlashNextTickMilliseconds: Int64
    /// 对齐 widget main:src/constants/plugin.ts 的 UNREAD_KEY，记录最近一次未读数量缓存值。
    public var unreadRecord: Int
    /// 对齐 widget main:src/constants/plugin.ts 的 NOTIFICATION_TIME_KEY，记录声音或通知最近触发时间戳。
    public var notificationLastTimeMilliseconds: Int64
    /// 对齐 widget main:src/helper/useNotification.ts 的浏览器 Notification 触发，用计数暴露 iOS 侧待发送通知次数。
    public var notificationShowCount: Int
    /// 对齐 widget main:src/helper/useNotification.ts 的 notificationStatus，记录宿主通知授权状态。
    public var notificationPermissionStatus: String
    /// 对齐 widget main:src/helper/useNotification.ts 的 msg.onclick，用计数暴露通知点击聚焦次数。
    public var notificationClickCount: Int
    /// 对齐 widget main:src/helper/useNotification.ts 的 soundElem.play，用计数暴露 iOS 侧待播放声音次数。
    public var soundNoticePlayCount: Int
    /// 对齐 Android Toast 状态，记录当前待展示的短提示队列。
    public var toasts: [SalesmartlyToastItem]
    public var hideUploadTypes: [String]
    public var hideCloseIcon: Bool
    public var openCustomEntryId: String?
    /// 对齐 Android `customEntryPopup`，记录自定义入口文字/图片弹层当前内容。
    public var customEntryPopup: SalesmartlyCustomEntryPopup?
    /// 对齐 Android 自定义入口图片预览状态，点击图片缩略图后进入全屏预览。
    public var customEntryPreviewImageURL: String?
    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 getCollapsedSidebarHeight，记录 Launcher 折叠态可量测高度；无有效高度时 getSidebarHeight 不触发回调。
    public var collapsedSidebarHeight: Int?
    public var trackedURL: String?
    public var demoPayload: [String: String]
    public var unReadNum: Int
    /// 对齐 widget main:src/stores/chat.ts 的 lastNoticeMsg，用于 Launcher IconPopup 未读消息预览。
    public var lastNoticeMsg: ChatMessage?
    /// 对齐 widget main:src/helper/types.ts 的 icon_popup，表示插件配置是否允许展示未读预览气泡。
    public var iconPopupEnabled: Bool
    /// 对齐 widget main:src/helper/types.ts 的 icon_popup_type；"0" 保留第一条未读预览，"1" 使用最新命中的未读预览。
    public var iconPopupType: String
    /// 对齐 widget main:src/helper/types.ts 的 channel，用于判断插件渠道是否包含 chat。
    public var channels: [String]
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 channel_sort，用于主页和侧边栏渠道排序。
    public var channelSort: [String]
    /// 对齐 widget main:src/helper/usePluginInfo.ts 写入 widgetInfo.background_color，用于 iOS 原生主题色、Launcher 和 Home 渐变同步 Web。
    public var backgroundColor: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 chatIcon.define，两个自定义图标 URL 都存在时 Web 才启用自定义聊天入口。
    public var chatIconDefine: Bool
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 chatIcon.inIcon，用于 Web hover/active 态聊天入口图标。
    public var chatIconInURL: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 chatIcon.outIcon，用于 Web 默认态聊天入口图标。
    public var chatIconOutURL: String
    /// 对齐 widget main:src/stores/app.ts 的 widgetInfo.position，用于决定 Launcher 和聊天窗贴左或贴右。
    public var position: String
    /// 对齐 widget main:src/stores/app.ts 的 widgetInfo.margin_bottom，用于移动端或未分端配置时的底部间距。
    public var marginBottom: Int
    /// 对齐 widget main:src/stores/app.ts 的 widgetInfo.margin_bottom_pc，用于 PC/Web 大屏下的底部间距。
    public var marginBottomPC: Int
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 mobileScreen，记录移动端窗口是否按 full/cover screen 方式铺满。
    public var mobileScreen: String
    /// 对齐 widget main:src/helper/useChatWrapStyle.ts 的 location_config_divisive，用于选择 PC/移动端底部间距字段。
    public var locationConfigDivisive: Bool
    /// 对齐 widget main:src/components/Channel/useChannel.ts 读取的 show_*_config，保存外部渠道点击所需的已确认字符串字段。
    public var channelOpenConfigs: [String: [String: String]]
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 home_page.enabled，用于决定 Launcher 打开 Home 还是直接进入 Chat。
    public var homePageEnabled: Bool
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 home_page.title，用于 Home 顶部欢迎标题。
    public var homePageTitle: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 welcome，用于 Header 副标题。
    public var welcome: String
    /// 对齐 Android `WidgetInfo.isOnline`，当前 plugin/info 不解析该字段，默认 true。
    public var isOnline: Bool
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 window_subhead_switch，控制 Header 副标题是否展示。
    public var windowSubheadSwitch: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 show_helpdesk_config.switch，控制帮助中心入口是否展示。
    public var helpdeskSwitch: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 show_helpdesk_config.id，保留帮助中心配置标识。
    public var helpdeskId: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 show_helpdesk_config.title，用作帮助中心入口标题。
    public var helpdeskTitle: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 show_helpdesk_config.url，用作帮助中心入口链接。
    public var helpdeskURL: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 show_effect.type，"2" 表示 chat integration，其余为 column。
    public var integrationType: String
    /// 对齐 widget main:src/components/SideBar/index.vue 的 sidebar.show，用于 Home 其他渠道去重。
    public var sidebarShow: Bool
    /// 对齐 widget main:src/components/SideBar/index.vue 的 sidebar.shrinkMode，用于判断 sidebar/single_icon 是否承载外部渠道。
    public var sidebarShrinkMode: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 avatar_url，用于 Home 和 Header 头像展示。
    public var pluginAvatarURL: String
    /// 对齐 widget main:src/helper/types.ts 的 isLimit，限制场景不展示 Launcher 未读预览。
    public var isLimit: Bool
    /// 对齐 widget main:src/helper/types.ts 的 window_name，用作 Launcher 未读文本预览的标题兜底。
    public var iconPopupWindowName: String
    /// 对齐 widget main:src/helper/types.ts 的 showReceptionInfo，决定 Launcher 未读文本预览是否优先展示 sender_name。
    public var iconPopupShowReceptionInfo: Bool
    /// 对齐 widget main:src/helper/types.ts 的 plugin_name，用于底部举报链接参数。
    public var pluginName: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 info.project_id，用于 Socket query 的 _xma_ 项目维度参数。
    public var pluginProjectId: String
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 turn_to_manual_button.type，控制转人工入口是否显示。
    public var humanServiceEnabled: Bool
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 withdraw_notice.type，控制撤回消息是否显示撤回提示。
    public var withdrawRecord: Bool
    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 show_customer_service_name.type，控制客服发送消息是否展示客服名。
    public var showSenderName: Bool
    /// 对齐 widget main:src/views/Chat/components/BottomBar/index.vue 的 report_switch，控制底部举报入口是否展示。
    public var reportSwitch: Bool
    /// 对齐 widget main:src/constants/env.ts 的 WIDGET_HOST，用于 iOS 生成底部举报链接时区分生产和 dev 域名。
    public var widgetHost: String
    /// 对齐 widget main:src/helper/types.ts 的 sse_switch 与 Android `WidgetInfo.sse_switch`，控制实时通道是否切到 HTTP event。
    public var sseSwitch: String
    /// 对齐 widget main:src/helper/realtime/mode.ts 的 getRealtimeMode 与 Android `RealtimeMode`，记录当前实时模式 `socket.io` 或 `sse-http`。
    public var realtimeMode: String
    /// 对齐 widget main:src/helper/types.ts 的 support_retry 与 src/helper/useSendMessage.ts 的 retry 开关，表示是否启用发送失败重试跟踪。
    public var supportRetry: Bool
    /// 对齐 widget main:src/helper/types.ts 的 is_polling 与 src/helper/useSocket.ts 的 checkPolling，表示是否允许通过 HTTP 轮询拉取消息。
    public var isPollingEnabled: Bool
    /// 对齐 widget main:src/helper/types.ts 的 polling_gap 与 src/helper/useSocket.ts 的 refreshMsgListInterval，记录客服消息轮询间隔秒数。
    public var pollingGapSeconds: Int
    /// 对齐 widget main:src/helper/types.ts 的 queue_switch 与 src/helper/useQueueStatus.ts 的 watch，表示是否展示并轮询排队状态。
    public var queueSwitch: String
    /// 对齐 widget main:src/helper/types.ts 的 queue_polling_interval 与 src/helper/useQueueStatus.ts 的 pollingTimer，记录排队状态轮询间隔秒数。
    public var queuePollingIntervalSeconds: Int
    /// 对齐 widget main:src/components/ColumnChannel.vue、src/components/SideBar/index.vue 与 src/components/Launcher/index.vue 的 data-ssc-launcher-height-target，记录当前可见 Launcher 高度目标。
    public var launcherHeightTargetFrames: [SalesmartlyLauncherHeightTargetFrame]
    public var showServiceTyping: Bool
    public var showRobotTyping: Bool
    /// 对齐 widget main:src/helper/useSocket.ts 的 typingTimer，记录人工输入中状态自动隐藏的截止时间戳。
    public var serviceTypingHideAtMilliseconds: Int64
    /// 对齐 widget main:src/helper/useSocket.ts 的 timerHide，记录机器人输入中状态自动隐藏的截止时间戳。
    public var robotTypingHideAtMilliseconds: Int64
    public var assignUserInfo: [String: String]
    public var showHumanService: Bool
    public var showHumanMsg: Bool
    public var showHumanTips: Bool
    public var queueStatus: String
    public var queueCount: Int
    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 requestId，用于忽略旧的排队状态请求响应。
    public var queueStatusPollingRequestId: Int
    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 pollingTimer，记录下一次排队状态轮询触发时间。
    public var queueStatusPollingNextFetchMilliseconds: Int64
    public var isStreamSending: Bool
    public var currentStreamInfo: SalesmartlyStreamCurrentInfo
    public var isStopStream: Bool
    public var streamMsg: String
    public var streamCurrentIndex: Int
    public var isStreamAnimating: Bool
    public var hasJoinRoom: Bool
    public var sendMode: String
    public var pendingSocketEvents: [String]
    public var draftText: String
    public var showModal: Bool
    public var pasteMsgType: String 
    public var tempImgUrl: String
    public var fileName: String
    public var isUnreadPollingActive: Bool
    public var isRecentPollingActive: Bool
    public var conversationAtBottom: Bool
    public var conversationHasNewMessage: Bool

    public init(
        isReady: Bool = false,
        showWrapper: Bool = false,
        currentView: ChatView = .home,
        isWindowVisible: Bool = true,
        messages: [ChatMessage] = [],
        loginInfo: LoginInfo? = nil,
        lang: String = "en-US",
        userInfo: [String: String] = [:],
        userInfoJSONString: String = "",
        userType: String = "guest",
        localUserId: String = "",
        tokenKey: String = "",
        tokenDateKey: String = "",
        conversationKey: String = "",
        newUserKey: String = "",
        userInfoKey: String = "",
        customFieldsLocalKey: String = "",
        pendingLocalRemoveKeys: [String] = [],
        userToken: String = "",
        localChatUserId: String = "",
        isNewUser: Bool = true,
        createUserTokenPadParams: String = "",
        createUserTokenPadToken: String = "",
        isCreateUserTokenRequestActive: Bool = false,
        createUserTokenRequestDateMilliseconds: Int64 = 0,
        createUserTokenSavedDateMilliseconds: Int64 = 0,
        createUserLastTimeMilliseconds: Int64 = 0,
        showCollection: Bool = false,
        showOffline: Bool = false,
        collectInformation: SalesmartlyCollectionConfig = SalesmartlyCollectionConfig(),
        offlineSurvey: SalesmartlyCollectionConfig = SalesmartlyCollectionConfig(guidance: "当前没有客服在线，麻烦留下您的信息，我们后面会联系您！"),
        bulletinBoard: SalesmartlyBulletinBoardConfig = SalesmartlyBulletinBoardConfig(),
        bulletinBoardDismissed: Bool = false,
        showLinePage: Bool = false,
        launcherShowSideBar: Bool = false,
        launcherShowIcon: Bool = false,
        notificationEnabled: Bool = true,
        flashTitle: Bool = false,
        soundNotice: Bool = false,
        shouldFlashTitle: Bool = false,
        notificationOriginTitle: String = "",
        notificationCurrentTitle: String = "",
        notificationNewMessageTitle: String = "",
        notificationFlashNextTitle: String = "",
        notificationFlashNextTickMilliseconds: Int64 = 0,
        unreadRecord: Int = 0,
        notificationLastTimeMilliseconds: Int64 = 0,
        notificationShowCount: Int = 0,
        notificationPermissionStatus: String = "",
        notificationClickCount: Int = 0,
        soundNoticePlayCount: Int = 0,
        toasts: [SalesmartlyToastItem] = [],
        hideUploadTypes: [String] = [],
        hideCloseIcon: Bool = false,
        openCustomEntryId: String? = nil,
        customEntryPopup: SalesmartlyCustomEntryPopup? = nil,
        customEntryPreviewImageURL: String? = nil,
        collapsedSidebarHeight: Int? = nil,
        trackedURL: String? = nil,
        demoPayload: [String: String] = [:],
        unReadNum: Int = 0,
        lastNoticeMsg: ChatMessage? = nil,
        iconPopupEnabled: Bool = false,
        iconPopupType: String = "0",
        channels: [String] = [],
        channelSort: [String] = [],
        backgroundColor: String = "#1762F6",
        chatIconDefine: Bool = false,
        chatIconInURL: String = "",
        chatIconOutURL: String = "",
        position: String = "right",
        marginBottom: Int = 30,
        marginBottomPC: Int = 30,
        mobileScreen: String = "",
        locationConfigDivisive: Bool = false,
        channelOpenConfigs: [String: [String: String]] = [:],
        homePageEnabled: Bool = false,
        homePageTitle: String = "",
        welcome: String = "",
        isOnline: Bool = true,
        windowSubheadSwitch: String = "0",
        helpdeskSwitch: String = "0",
        helpdeskId: String = "",
        helpdeskTitle: String = "",
        helpdeskURL: String = "",
        integrationType: String = "column",
        sidebarShow: Bool = false,
        sidebarShrinkMode: String = "sidebar",
        pluginAvatarURL: String = "",
        isLimit: Bool = false,
        iconPopupWindowName: String = "",
        iconPopupShowReceptionInfo: Bool = true,
        pluginName: String = "",
        pluginProjectId: String = "",
        humanServiceEnabled: Bool = true,
        withdrawRecord: Bool = true,
        showSenderName: Bool = false,
        reportSwitch: Bool = false,
        widgetHost: String = "https://widget.salesmartly.com/",
        sseSwitch: String = "0",
        realtimeMode: String = "socket.io",
        supportRetry: Bool = false,
        isPollingEnabled: Bool = false,
        pollingGapSeconds: Int = 10,
        queueSwitch: String = "0",
        queuePollingIntervalSeconds: Int = 0,
        launcherHeightTargetFrames: [SalesmartlyLauncherHeightTargetFrame] = [],
        showServiceTyping: Bool = false,
        showRobotTyping: Bool = false,
        serviceTypingHideAtMilliseconds: Int64 = 0,
        robotTypingHideAtMilliseconds: Int64 = 0,
        assignUserInfo: [String: String] = ["avatar": "", "nickname": "", "sys_user_id": ""],
        showHumanService: Bool = false,
        showHumanMsg: Bool = false,
        showHumanTips: Bool = false,
        queueStatus: String = "",
        queueCount: Int = 0,
        queueStatusPollingRequestId: Int = 0,
        queueStatusPollingNextFetchMilliseconds: Int64 = 0,
        isStreamSending: Bool = false,
        currentStreamInfo: SalesmartlyStreamCurrentInfo = SalesmartlyStreamCurrentInfo(),
        isStopStream: Bool = false,
        streamMsg: String = "",
        streamCurrentIndex: Int = 0,
        isStreamAnimating: Bool = false,
        hasJoinRoom: Bool = false,
        sendMode: String = "ws",
        pendingSocketEvents: [String] = [],
        draftText: String = "",
        showModal: Bool = false,
        pasteMsgType: String = "",
        tempImgUrl: String = "",
        fileName: String = "",
        isUnreadPollingActive: Bool = false,
        isRecentPollingActive: Bool = false,
        conversationAtBottom: Bool = true,
        conversationHasNewMessage: Bool = false
    ) {
        self.isReady = isReady
        self.showWrapper = showWrapper
        self.currentView = currentView
        self.isWindowVisible = isWindowVisible
        self.messages = messages
        self.loginInfo = loginInfo
        self.lang = lang
        self.userInfo = userInfo
        self.userInfoJSONString = userInfoJSONString
        self.userType = userType
        self.localUserId = localUserId
        self.tokenKey = tokenKey
        self.tokenDateKey = tokenDateKey
        self.conversationKey = conversationKey
        self.newUserKey = newUserKey
        self.userInfoKey = userInfoKey
        self.customFieldsLocalKey = customFieldsLocalKey
        self.pendingLocalRemoveKeys = pendingLocalRemoveKeys
        self.userToken = userToken
        self.localChatUserId = localChatUserId
        self.isNewUser = isNewUser
        self.createUserTokenPadParams = createUserTokenPadParams
        self.createUserTokenPadToken = createUserTokenPadToken
        self.isCreateUserTokenRequestActive = isCreateUserTokenRequestActive
        self.createUserTokenRequestDateMilliseconds = createUserTokenRequestDateMilliseconds
        self.createUserTokenSavedDateMilliseconds = createUserTokenSavedDateMilliseconds
        self.createUserLastTimeMilliseconds = createUserLastTimeMilliseconds
        self.showCollection = showCollection
        self.showOffline = showOffline
        self.collectInformation = collectInformation
        self.offlineSurvey = offlineSurvey
        self.bulletinBoard = bulletinBoard
        self.bulletinBoardDismissed = bulletinBoardDismissed
        self.showLinePage = showLinePage
        self.launcherShowSideBar = launcherShowSideBar
        self.launcherShowIcon = launcherShowIcon
        self.notificationEnabled = notificationEnabled
        self.flashTitle = flashTitle
        self.soundNotice = soundNotice
        self.shouldFlashTitle = shouldFlashTitle
        self.notificationOriginTitle = notificationOriginTitle
        self.notificationCurrentTitle = notificationCurrentTitle
        self.notificationNewMessageTitle = notificationNewMessageTitle
        self.notificationFlashNextTitle = notificationFlashNextTitle
        self.notificationFlashNextTickMilliseconds = notificationFlashNextTickMilliseconds
        self.unreadRecord = unreadRecord
        self.notificationLastTimeMilliseconds = notificationLastTimeMilliseconds
        self.notificationShowCount = notificationShowCount
        self.notificationPermissionStatus = notificationPermissionStatus
        self.notificationClickCount = notificationClickCount
        self.soundNoticePlayCount = soundNoticePlayCount
        self.toasts = toasts
        self.hideUploadTypes = hideUploadTypes
        self.hideCloseIcon = hideCloseIcon
        self.openCustomEntryId = openCustomEntryId
        self.customEntryPopup = customEntryPopup
        self.customEntryPreviewImageURL = customEntryPreviewImageURL
        self.collapsedSidebarHeight = collapsedSidebarHeight
        self.trackedURL = trackedURL
        self.demoPayload = demoPayload
        self.unReadNum = unReadNum
        self.lastNoticeMsg = lastNoticeMsg
        self.iconPopupEnabled = iconPopupEnabled
        self.iconPopupType = iconPopupType
        self.channels = channels
        self.channelSort = channelSort
        self.backgroundColor = backgroundColor
        self.chatIconDefine = chatIconDefine
        self.chatIconInURL = chatIconInURL
        self.chatIconOutURL = chatIconOutURL
        self.position = position
        self.marginBottom = marginBottom
        self.marginBottomPC = marginBottomPC
        self.mobileScreen = mobileScreen
        self.locationConfigDivisive = locationConfigDivisive
        self.channelOpenConfigs = channelOpenConfigs
        self.homePageEnabled = homePageEnabled
        self.homePageTitle = homePageTitle
        self.welcome = welcome
        self.isOnline = isOnline
        self.windowSubheadSwitch = windowSubheadSwitch
        self.helpdeskSwitch = helpdeskSwitch
        self.helpdeskId = helpdeskId
        self.helpdeskTitle = helpdeskTitle
        self.helpdeskURL = helpdeskURL
        self.integrationType = integrationType
        self.sidebarShow = sidebarShow
        self.sidebarShrinkMode = sidebarShrinkMode
        self.pluginAvatarURL = pluginAvatarURL
        self.isLimit = isLimit
        self.iconPopupWindowName = iconPopupWindowName
        self.iconPopupShowReceptionInfo = iconPopupShowReceptionInfo
        self.pluginName = pluginName
        self.pluginProjectId = pluginProjectId
        self.humanServiceEnabled = humanServiceEnabled
        self.withdrawRecord = withdrawRecord
        self.showSenderName = showSenderName
        self.reportSwitch = reportSwitch
        self.widgetHost = widgetHost
        self.sseSwitch = sseSwitch
        self.realtimeMode = realtimeMode
        self.supportRetry = supportRetry
        self.isPollingEnabled = isPollingEnabled
        self.pollingGapSeconds = pollingGapSeconds
        self.queueSwitch = queueSwitch
        self.queuePollingIntervalSeconds = queuePollingIntervalSeconds
        self.launcherHeightTargetFrames = launcherHeightTargetFrames
        self.showServiceTyping = showServiceTyping
        self.showRobotTyping = showRobotTyping
        self.serviceTypingHideAtMilliseconds = serviceTypingHideAtMilliseconds
        self.robotTypingHideAtMilliseconds = robotTypingHideAtMilliseconds
        self.assignUserInfo = assignUserInfo
        self.showHumanService = showHumanService
        self.showHumanMsg = showHumanMsg
        self.showHumanTips = showHumanTips
        self.queueStatus = queueStatus
        self.queueCount = queueCount
        self.queueStatusPollingRequestId = queueStatusPollingRequestId
        self.queueStatusPollingNextFetchMilliseconds = queueStatusPollingNextFetchMilliseconds
        self.isStreamSending = isStreamSending
        self.currentStreamInfo = currentStreamInfo
        self.isStopStream = isStopStream
        self.streamMsg = streamMsg
        self.streamCurrentIndex = streamCurrentIndex
        self.isStreamAnimating = isStreamAnimating
        self.hasJoinRoom = hasJoinRoom
        self.sendMode = sendMode
        self.pendingSocketEvents = pendingSocketEvents
        self.draftText = draftText
        self.showModal = showModal
        self.pasteMsgType = pasteMsgType
        self.tempImgUrl = tempImgUrl
        self.fileName = fileName
        self.isUnreadPollingActive = isUnreadPollingActive
        self.isRecentPollingActive = isRecentPollingActive
        self.conversationAtBottom = conversationAtBottom
        self.conversationHasNewMessage = conversationHasNewMessage
    }
}

public final class SalesmartlyRuntime {
    private struct QuestionContext {
        var branches: [[String: String]]
        var questionId: String
    }

    private struct SendMessageTransportAck {
        var sequenceId: String
        var message: String
        var sendTime: Int64
    }

    private struct ReceiveMessageTransportData {
        var sequenceId: String
        var senderType: String
        var msgType: String
        var message: String
        var sendTime: Int64
        var chatUserId: String
        var clientMessageId: String?
        var senderName: String?
        var senderAvatar: String?
        var readTime: Int64?
        var isWithdraw: String?
        var streamInfo: SalesmartlyStreamInfo?
        var quoteChat: String
    }

    private struct PendingPostMessage {
        var msgType: String
        var message: Any
        var tempId: String?
        var type: String?
        var sequenceId: String?
        var status: Int?
        var mid: String?
        var clientExpandInfo: [String: String]?
        var chatUserId: String?
    }

    /// 对齐 Android `LocalFileDownloadResolver` 与 widget main:src/helper/useSwapObject.ts 的文件下载换签回调。
    private struct PendingDownloadResolution {
        var reportId: String
        var onResolved: (String) -> Void
        var onFinished: () -> Void
    }

    /// 对齐 widget main:src/helper/useUpload.ts 的 swapObjectV2 上传收尾，记录直传成功后等待换签的上传任务。
    private struct PendingUploadSwapObject {
        var tempId: String
        var fileURL: String
    }

    private static let roomType = 6
    private static let httpRef = "chat-plugin"
    private static let sendModeWS = "ws"
    private static let sendModeHTTP = "http"
    private static let realtimeModeSocketIO = "socket.io"
    private static let realtimeModeSSEHTTP = "sse-http"
    private static let openFrameEvent = "open-frame"
    private static let joinRoomEvent = "join-room"
    private static let leaveRoomEvent = "leave-room"
    private static let readMessageEvent = "read-message"
    private static let sendMessageEvent = "send-message"
    private static let humanServiceEvent = "human-service"
    private static let streamStopEvent = "stream-stop"
    private static let evalutionEvent = "evalution"
    /// 对齐 widget main:src/helper/realtime/types.ts 的 ChatRealtimeEvent.like，用于 SSE HTTP 赞踩事件。
    private static let likeEvent = "like"
    private static let receiveMessageEvent = "receive-message"
    private static let receiveNoticeEvent = "sdk-receive-notice"
    /// 对齐 widget main:src/helper/realtime/types.ts 的 SseDownstreamEvent.receive-notice，用于 SSE 下行公告/typing/撤回通知。
    private static let sseReceiveNoticeEvent = "receive-notice"
    private static let reconnectEvent = "reconnect"
    private static let disconnectEvent = "disconnect"
    private static let reconnectErrorEvent = "reconnect_error"
    private static let reconnectFailedEvent = "reconnect_failed"
    private static let reconnectAttemptEvent = "reconnect_attempt"
    private static let socketErrorEvent = "error"
    private static let testToMessageEvent = "test-to-message"
    private static let ssevlEvent = "ssevl"
    /// 对齐 widget main:src/constants/plugin.ts 的 COMMON_KEY，本地缓存 key 均以 salesmartly_p 开头。
    private static let localStorageCommonKey = "salesmartly_p"
    /// 对齐 widget main:src/constants/plugin.ts 的 TOKEN_KEY。
    private static let localStorageTokenKey = "token"
    /// 对齐 widget main:src/constants/plugin.ts 的 TOKEN_DATE_KEY。
    private static let localStorageTokenDateKey = "token_date"
    /// 对齐 widget main:src/constants/plugin.ts 的 CONVERSATION。
    private static let localStorageConversationKey = "list"
    /// 对齐 widget main:src/constants/plugin.ts 的 NEW_USER_KEY。
    private static let localStorageNewUserKey = "n_u"
    /// 对齐 widget main:src/constants/plugin.ts 的 USER_INFO_KEY。
    private static let localStorageUserInfoKey = "u_i"
    /// 对齐 widget main:src/constants/plugin.ts 的 GUEST_UUID_KEY 后缀。
    private static let localStorageGuestUUIDKey = "g_uid"
    /// 对齐 widget main:src/constants/plugin.ts 的 AUTO_OPEN_KEY 后缀。
    private static let localStorageAutoOpenKey = "a_o"
    /// 对齐 widget main:src/constants/plugin.ts 的 AUTO_OPEN_LAST_KEY 后缀。
    private static let localStorageAutoOpenLastKey = "a_o_last"
    /// 对齐 widget main:src/constants/plugin.ts 的 CUSTOM_FIELDS_LOCAL_MAP。
    private static let localStorageCustomFieldsLocalMapKey = "custom_fields_local_map"
    /// 对齐 widget main:src/constants/plugin.ts 的 CREATE_USER_LAST_TIME_KEY。
    private static let createUserLastTimeLocalKey = "create_user_last_time"
    /// 对齐 widget main:src/utils/tool.ts 的 regular.email，用于 PromotionalCard 邮箱留资校验。
    private static let promotionalCardEmailPattern = #"^[A-Za-z\d]+([-_.][A-Za-z\d]+)*@([A-Za-z\d]+[-.])+[A-Za-z\d]{2,12}$"#
    /// 对齐 widget main:src/locales/index.ts 的 lang 初始值和不支持语言 fallback。
    private static let defaultLang = "en-US"
    /// 对齐 widget main:src/locales/index.ts 的 supportLang，限定 iOS runtime 可接受的语言代码。
    private static let supportLang = [
        "zh-CN",
        "en-US",
        "ru-RU",
        "zh-HK",
        "th-TH",
        "mn",
        "vi-VN",
        "ja-JP",
        "fr",
        "pt",
        "ar",
        "es",
        "de",
        "ro",
        "pl",
        "id",
        "ko",
        "nl",
        "da",
        "it",
        "tr",
        "bn",
    ]
    private static let socketJoinLifecycleEventNames = [
        reconnectEvent,
        disconnectEvent,
        receiveMessageEvent,
        receiveNoticeEvent,
        socketErrorEvent,
        reconnectErrorEvent,
        reconnectFailedEvent,
        reconnectAttemptEvent,
        testToMessageEvent,
        ssevlEvent,
    ]
    private static let socketReleaseLifecycleEventNames = [
        reconnectEvent,
        socketErrorEvent,
        reconnectErrorEvent,
        reconnectFailedEvent,
        reconnectAttemptEvent,
        testToMessageEvent,
        ssevlEvent,
    ]
    private static let uploadModule = "chat"
    private static let uploadPlatform = "pc0"
    private static let uploadBType = "mix_ads"
    private static let socketTransportWebsocket = "websocket"
    private static let socketReconnectionAttempts = 30
    private static let socketPongExtraBufferMilliseconds: Int64 = 30 * 1000
    private static let socketPongReconnectDelayMilliseconds = 100
    private static let channelIconSort = [
        "custom_3",
        "custom_2",
        "custom_1",
        "zalo",
        "tiktok",
        "vkontakte",
        "weixin",
        "instagram",
        "telegram",
        "whatsapp",
        "messenger",
        "email",
        "lineApp",
        "line",
    ]
    private static let iconPopupMessageTypes = ["1", "2", "3", "4", "6", "7", "11", "14", "21", "40"]
    /// 对齐 widget main:src/api/plugin.ts 的 getPluginInfo，请求插件配置用于后续配置归一化和初始化链路。
    private static let pluginInfoHTTPPath = "plugin/info"
    private static let sendMessageHTTPPath = "/chat/chat-msg/send-message"
    private static let chatMsgEventHTTPPath = "/chat/chat-msg/event"
    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 getCentrifugoToken，用于 SSE EventSource token 预检。
    private static let centrifugoTokenHTTPPath = "/chat/chat-msg/centrifugo-token"
    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sseConnect，用于 EventSource onopen 后通知后端连接已建立。
    private static let sseConnectHTTPPath = "/chat/chat-msg/sse-connect"
    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sseDisconnect，用于释放 SSE 实时连接。
    private static let sseDisconnectHTTPPath = "/chat/chat-msg/sse-disconnect"
    private static let unreadMsgListHTTPPath = "/chat/chat-msg/unread-msg-list-v2"
    private static let recentMsgListHTTPPath = "/chat/chat-msg/recent-msg-list-v2"
    private static let queueStatusHTTPPath = "user/plugin-queue-status"
    private static let triggerUserHTTPPath = "chat/chat-auto/user/trigger"
    private static let triggerHTTPPath = "chat/chat-auto/trigger"
    private static let updateUserHTTPPath = "chat/msg-user/update-user"
    private static let swapObjectHTTPPath = "sys/project/project/swap-object-v2"
    private static let createUserHTTPPath = "chat/msg-user/create-user"
    private static let uploadTimeoutMillisecondsValue = 150 * 1000
    private static let uploadDirectTimeoutMillisecondsValue = 120 * 1000
    private static let uploadConfigEffectiveMilliseconds: Int64 = 10 * 60 * 1000
    private static let historyMsgIntervalMilliseconds: Int64 = 10 * 60 * 1000
    private static let uploadObjectMaxSize = 1024 * 1024 * 1024
    private static let uploadFailToastIntervalMilliseconds: Int64 = 1500
    private static let notificationThrottleMilliseconds: Int64 = 10 * 1000
    private static let notificationFlashIntervalMilliseconds: Int64 = 800
    private static let notificationInvisibleTitle = "\u{200E}"
    private static let robotTypingHideDelayMilliseconds: Int64 = 60 * 1000
    /// 对齐 widget main:src/helper/useSocket.ts 的 noticeType 24 random(2, 3)，Helplook 无响应结果后延迟隐藏机器人 typing。
    private static let helplookNoResponseHideDelaySeconds = 2...3
    private static let serviceTypingHideDelayMilliseconds: Int64 = 10 * 1000
    private static let uploadCompressionMinSize = 1024 * 1024
    private static let uploadCompressionQuality = 0.85
    private static let salesmartlyOssHost = "https://mix-ads.oss-accelerate.aliyuncs.com"
    private static let v1BucketName = "v1"
    private static let v2BucketName = "v2"
    private static let dewsMap = [
        "1": "default",
        "2": "public-read-write",
        "3": "public-read",
        "4": "private",
    ]
    private static let v1BucketDomainURLs = [
        "assets.salesmartly.com",
        "assets-cdn.salesmartly.com",
        "mix-ads.oss-ap-southeast-1.aliyuncs.com",
        "mix-ads.oss-accelerate.aliyuncs.com",
        "static-cdn.salesmartly.com",
        "assets-cdn.salesmartly.cn",
        "assets.salesmartly.cn",
    ]
    private static let v2BucketDomainURLs = [
        "static.salesmartly.com",
        "salesmartly.oss-ap-southeast-1.aliyuncs.com",
        "salesmartly.oss-accelerate.aliyuncs.com",
        "static.salesmartly.cn",
    ]
    private static let uploadImageFormats = ["jpg", "jpeg", "png"]
    private static let uploadVideoFormats = ["mp4", "mov"]
    private static let ossImageResizeFormats = ["png", "jpg", "jpeg", "tiff", "avif"]
    private static let base64SourceCharacters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
    private static let base64TargetCharacters = Array("6YdeOu3TyHxBlIMUocC2DXnNsr1Pft0bR+hAvVQGKEJZpw/W8jq54a9SkmigFzL7")
    private static let encodeURIComponentAllowedCharacters: CharacterSet = {
        var characters = CharacterSet.alphanumerics
        characters.insert(charactersIn: "-_.!~*'()")
        return characters
    }()
    public private(set) var config: SalesmartlyConfig?
    /// 对齐 widget main:src/stores/user.ts 与 src/helper/useLocal.ts 的 runtime 状态聚合；SDK 外部只读，测试通过 internal setter 注入已确认的本地 token 场景。
    public internal(set) var state: ChatRuntimeState {
        didSet {
            notifyStateObservers()
        }
    }
    private(set) var sendMessageMap: [String: ChatMessage]
    private(set) var retryingMap: [String: ChatMessage]
    private(set) var uploadTaskMap: [String: SalesmartlyUploadTask]
    private(set) var sendAssetsList: [[String: String]]
    private(set) var uploadFailNotificationCount: Int
    private(set) var socketLastPongTime: Int64

    private var callbacks: [String: [SalesmartlyCallback]]
    /// 对齐 widget main:src/stores/app.ts 与 src/stores/chat.ts 的响应式订阅者集合，承载 SwiftUI/UIKit Host 的状态刷新回调。
    private var stateObservers: [Int: SalesmartlyStateObserver]
    private var nextStateObserverId: Int
    private var uploadOSSConfigCacheMap: [String: SalesmartlyOSSConfigCache]
    private var triggeredNewUserKeys: Set<String>
    private var triggeringChatUserId: String
    private var tempMessage: PendingPostMessage?
    private var tempRetryMsg: ChatMessage?
    private var pasteFile: SalesmartlyUploadFile?
    private var sendType: String
    private var uploadFailNotifiedTempIds: Set<String>
    private var uploadFailToastTimestamp: Int64
    /// 对齐 Android Toast 队列，iOS 用递增 id 保持 SwiftUI 提示项稳定。
    private var nextToastId: Int
    /// 对齐 Android `SalesmartlyRuntime.resolveDownloadFileUrl`，按本次 swap-object 请求记录等待回调的文件下载。
    private var pendingDownloadResolutions: [String: PendingDownloadResolution]
    private var pendingUploadSwapObjects: [String: PendingUploadSwapObject]
    private var transport: SalesmartlyTransporting?
    /// 对齐 Android config 初始化默认 transport 安装，同时保留宿主/测试显式注入 transport 的优先级。
    private var transportInstalledBySDK: Bool
    private var uploadExecutor: SalesmartlyUploadExecuting?
    /// 对齐 Android config 初始化默认上传执行器安装，同时保留宿主/测试显式注入上传执行器。
    private var uploadExecutorInstalledBySDK: Bool
    /// 对齐 widget main:src/constants/env.ts 的 CENTRIFUGO_HOST，脚本初始化后用于 SSE EventSource 下行连接。
    private var realtimeCentrifugoURL: URL?
    /// 对齐 widget main:src/utils/storage.ts 的 localStorage 访问点，承载 token、userInfo、newUser 和自动打开标记读写。
    private var localStore: SalesmartlyLocalStoring?
    /// 对齐 widget main:src/utils/env.ts 与 src/helper/useLocal.ts 的浏览上下文来源，脚本入口无本地 token 时用于 create-user。
    private var nativeBootstrapContext: SalesmartlyNativeBootstrapContext?
    private var notificationHandler: SalesmartlyNotificationHandling?
    /// 对齐 widget main:src/utils/SsmEvent.ts 写入 window.createWhatsappGreeting 的宿主回调，用于 WhatsApp 跳转前改写文案。
    private var whatsappGreetingCallback: SalesmartlyWhatsappGreetingCallback?
    private var joinRoomTransportConfirmed: Bool

    public init(state: ChatRuntimeState = ChatRuntimeState()) {
        self.state = state
        self.sendMessageMap = [:]
        self.retryingMap = [:]
        self.uploadTaskMap = [:]
        self.sendAssetsList = []
        self.uploadFailNotificationCount = 0
        self.socketLastPongTime = 0
        self.callbacks = [:]
        self.stateObservers = [:]
        self.nextStateObserverId = 0
        self.uploadOSSConfigCacheMap = [:]
        self.triggeredNewUserKeys = []
        self.triggeringChatUserId = ""
        self.tempMessage = nil
        self.tempRetryMsg = nil
        self.pasteFile = nil
        self.sendType = "send"
        self.uploadFailNotifiedTempIds = []
        self.uploadFailToastTimestamp = 0
        self.nextToastId = 0
        self.pendingDownloadResolutions = [:]
        self.pendingUploadSwapObjects = [:]
        self.transport = nil
        self.transportInstalledBySDK = false
        self.uploadExecutor = nil
        self.uploadExecutorInstalledBySDK = false
        self.realtimeCentrifugoURL = nil
        self.localStore = SalesmartlyUserDefaultsLocalStore()
        self.nativeBootstrapContext = nil
        self.notificationHandler = SalesmartlyDefaultNotificationHandler()
        self.whatsappGreetingCallback = nil
        self.joinRoomTransportConfirmed = false
    }

    public func initialize(config: SalesmartlyConfig) {
        self.config = config
        applyLocalUserKeyContext(userId: state.loginInfo?.userId ?? "")
        loadLocalUserState()
        loadLocalConversationState()
        state.isReady = true
        state.notificationEnabled = config.setting.showNotification ?? state.notificationEnabled
        // 对齐 widget main:src/constants/plugin.ts 的 INIT_MOBILE_SCREEN，初始化配置为 full 时移动端窗口采用全屏布局。
        state.mobileScreen = config.setting.initMobileScreen == "full" ? "full" : ""
        dispatch("onReady", payload: [
            "mode": config.setting.mode.rawValue,
            "showNotification": state.notificationEnabled,
        ])
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 connectRoom/connectRoomByHttp，进入房间后根据实时模式保持 ws/http 发送态。
    @discardableResult
    func joinRoom() -> SalesmartlyPayload? {
        guard !state.hasJoinRoom, let config, !config.license.isEmpty else {
            if state.hasJoinRoom {
                state.sendMode = isSseHTTPMode() ? Self.sendModeHTTP : Self.sendModeWS
            }
            return nil
        }

        state.hasJoinRoom = true
        state.sendMode = isSseHTTPMode() ? Self.sendModeHTTP : Self.sendModeWS
        joinRoomTransportConfirmed = false
        return makeJoinRoomPayload()
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 releaseSocket，离开房间后回到 HTTP 发送态。
    @discardableResult
    func leaveRoom() -> SalesmartlyPayload? {
        guard state.hasJoinRoom else {
            state.sendMode = Self.sendModeHTTP
            return nil
        }

        state.hasJoinRoom = false
        state.sendMode = Self.sendModeHTTP
        joinRoomTransportConfirmed = false
        return makeLeaveRoomPayload()
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 openFrame，未入房时先入队，入房后再按实时模式发送。
    @discardableResult
    func openFrame() -> SalesmartlyPayload? {
        guard state.hasJoinRoom else {
            if !state.pendingSocketEvents.contains(Self.openFrameEvent) {
                state.pendingSocketEvents.append(Self.openFrameEvent)
            }
            return nil
        }

        return makeOpenFramePayload()
    }

    func flushPendingSocketEvents() -> [SalesmartlyPayload] {
        let events = state.pendingSocketEvents
        state.pendingSocketEvents = []
        return events.map { eventName in
            [
                "event": eventName,
                "payload": commonSocketPayload(),
            ]
        }
    }

    func onDisconnect(loginToken: String, chatUserId: String) -> [SalesmartlyPayload] {
        state.hasJoinRoom = false
        state.sendMode = Self.sendModeHTTP
        joinRoomTransportConfirmed = false
        let payloads = retryPostMessage(loginToken: loginToken, chatUserId: chatUserId)
        markPendingMessagesFailed()
        return payloads
    }

    public func registerCallback(_ eventName: String, callback: @escaping SalesmartlyCallback) {
        callbacks[eventName, default: []].append(callback)

        if eventName == "onReady", state.isReady {
            callback([
                "mode": config?.setting.mode.rawValue ?? ChatMode.chat.rawValue,
                "showNotification": state.notificationEnabled,
            ])
        }
    }

    /// 对齐 widget main:src/stores/app.ts 与 src/stores/chat.ts 的响应式 store 订阅，供原生 Host 监听异步 reducer 后的完整 runtime state。
    @discardableResult
    public func observeState(_ observer: @escaping SalesmartlyStateObserver) -> Int {
        nextStateObserverId += 1
        stateObservers[nextStateObserverId] = observer
        return nextStateObserverId
    }

    /// 对齐 widget main:src/stores/app.ts 与 src/stores/chat.ts 的组件卸载清理语义，移除原生 Host 的状态订阅。
    public func removeStateObserver(_ observerId: Int) {
        stateObservers.removeValue(forKey: observerId)
    }

    /// 对齐 widget main:src/utils/storage.ts 的 localRead/localSave/localRemove，注入宿主本地缓存适配器供 token/userInfoKey 同步使用。
    func setLocalStore(_ store: SalesmartlyLocalStoring) {
        localStore = store
    }

    /// 对齐 widget main:src/utils/env.ts 的 getBrowseInfo/getParentPageInfo，注入 iOS 宿主页面上下文供脚本初始化后的 create-user 使用。
    func setNativeBootstrapContext(_ context: SalesmartlyNativeBootstrapContext) {
        nativeBootstrapContext = context
    }

    /// 对齐 widget main:src/utils/SsmEvent.ts 的 createWhatsappGreeting 注册语义，供 WhatsApp 渠道跳转前改写问候语。
    public func setWhatsappGreetingCallback(_ callback: @escaping SalesmartlyWhatsappGreetingCallback) {
        whatsappGreetingCallback = callback
    }

    public func push(command: String, payload: Any? = nil) {
        switch command {
        case "chatOpen":
            openChatEntry()
        case "chatClose":
            closeChat()
        case "setLoginInfo":
            if let loginInfo = payload as? LoginInfo {
                setLoginInfo(loginInfo)
            }
        case "setUserInfo":
            if let userInfo = payload as? [String: String] {
                setUserInfo(userInfo)
            } else if let userInfo = payload as? SalesmartlyPayload {
                setUserInfo(userInfo)
            }
        case "clearUser":
            clearUser()
        case "sendTextMessage":
            if let text = payload as? String {
                sendTextMessage(text)
            }
        case "showCollection":
            if let visible = payload as? Bool {
                showCollection(visible)
            } else {
                showCollection()
            }
        case "showOffline":
            if let visible = payload as? Bool {
                showOffline(visible)
            } else {
                showOffline()
            }
        case "setNotificationStatus":
            if let enabled = payload as? Bool {
                setNotificationStatus(enabled)
            }
        case "hideUpload":
            if let types = payload as? [String] {
                hideUpload(types)
            }
        case "hideCloseIcon":
            if let hidden = payload as? Bool {
                hideCloseIcon(hidden)
            } else {
                hideCloseIcon(true)
            }
        case "openCustomEntry":
            if let entryId = payload as? String {
                openCustomEntry(entryId)
            }
        case "getSidebarHeight":
            if let callback = payload as? SalesmartlySidebarHeightCallback {
                getSidebarHeight(callback: callback)
            }
        case "trackUrl":
            if let url = payload as? String {
                trackUrl(url)
            }
        case "setDemo":
            if let demoPayload = payload as? SalesmartlyPayload {
                setDemo(demoPayload)
            } else if let demoPayload = payload as? [String: String] {
                setDemo(demoPayload)
            }
        case "createWhatsappGreeting":
            if let callback = payload as? SalesmartlyWhatsappGreetingCallback {
                setWhatsappGreetingCallback(callback)
            }
        default:
            dispatch(command, payload: ["payload": payload as Any])
        }
    }

    /// 对齐 widget main:src/App.vue 的 handleShowChat，打开聊天窗口时清理非 demo 的 IconPopup 未读预览、进入 chat 视图并发送 openFrame。
    public func openChat() {
        if config?.setting.mode != .demo {
            clearLastNoticeMsg()
        }
        state.showWrapper = true
        state.currentView = .chat
        clearUnreadOnEnterChat()
        if config?.setting.mode != .demo {
            sendOpenFrameTransportRequest()
        }
        sendVisibilityPollingRequestsIfReady()
        dispatch("onOpenChat", payload: [:])
    }

    /// 对齐 widget main:src/components/Launcher/index.vue 的 Launcher 点击入口，插件启用 Home 时先进入主页，否则直接进入聊天。
    func openLauncherEntry() {
        openChatEntry()
    }

    /// 对齐 widget main:src/stores/app.ts 的 toggleChat(true) + resetView，外部打开入口在 Home 开启时默认回到主页。
    func openChatEntry() {
        if state.homePageEnabled {
            openHome()
        } else {
            openChat()
        }
    }

    /// 对齐 widget main:src/views/Page/index.vue 的首页展示入口，只打开窗口和 Home 视图，不触发进入 Chat 后的已读和 openFrame。
    func openHome() {
        if config?.setting.mode != .demo {
            clearLastNoticeMsg()
        }
        state.showWrapper = true
        state.currentView = .home
        dispatch("onOpenChat", payload: [:])
    }

    /// 对齐 widget main:src/App.vue 的 handleCloseChat/closeWindow，关闭聊天窗口并清理非 demo 的 IconPopup 未读预览。
    public func closeChat() {
        state.showWrapper = false
        closeCustomEntryPopup()
        if config?.setting.mode != .demo {
            clearLastNoticeMsg()
        }
        dispatch("onCloseChat", payload: [:])
    }

    /// 对齐 widget main:src/App.vue 与 src/stores/user.ts 的 setLoginInfo/setUserData，切换用户身份后清理 IconPopup，并在 language 存在时同步 setLang。
    public func setLoginInfo(_ loginInfo: LoginInfo) {
        var normalizedLoginInfo = loginInfo
        if let userId = normalizedLoginInfo.userId, !userId.isEmpty {
            guard let normalizedUserId = normalizeUserId(userId) else {
                return
            }
            normalizedLoginInfo.userId = normalizedUserId
        }
        if let language = normalizedLoginInfo.language, !language.isEmpty {
            normalizedLoginInfo.language = setLang(language, navigatorLanguage: "")
        }
        clearLastNoticeMsg()
        state.loginInfo = normalizedLoginInfo
        var localUserId = ""
        if let normalizedUserId = normalizedLoginInfo.userId, !normalizedUserId.isEmpty {
            localUserId = normalizedUserId
        }
        applyLocalUserKeyContext(userId: localUserId)
        loadLocalUserState()
    }

    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getTokenKey/getUserInfoKey 等方法，默认按当前登录 user_id 派生；显式传空字符串表示 guest key。
    func makeLocalStorageKeys(userId: String? = nil) -> SalesmartlyLocalStorageKeys {
        let pluginId = config!.license
        var resolvedUserId = userId ?? ""
        if userId == nil,
           resolvedUserId.isEmpty,
           let loginInfo = state.loginInfo,
           let currentUserId = loginInfo.userId,
           !currentUserId.isEmpty {
            resolvedUserId = currentUserId
        }

        return makeLocalStorageKeys(pluginId: pluginId, userId: resolvedUserId)
    }

    /// 对齐 widget main:src/constants/plugin.ts 的插件级本地 key，以及 getLocalKey.ts 的用户维度 key 拼接。
    func makeLocalStorageKeys(pluginId: String, userId: String) -> SalesmartlyLocalStorageKeys {
        let userKeys = makeLocalUserKeys(pluginId: pluginId, userId: userId)
        return SalesmartlyLocalStorageKeys(
            tokenKey: userKeys.tokenKey,
            tokenDateKey: userKeys.tokenDateKey,
            conversationKey: userKeys.conversationKey,
            newUserKey: userKeys.newUserKey,
            userInfoKey: userKeys.userInfoKey,
            guestUUIDKey: "\(Self.localStorageCommonKey)_\(pluginId)_\(Self.localStorageGuestUUIDKey)",
            autoOpenKey: "\(Self.localStorageCommonKey)_\(pluginId)_\(Self.localStorageAutoOpenKey)",
            autoOpenLastKey: "\(Self.localStorageCommonKey)_\(pluginId)_\(Self.localStorageAutoOpenLastKey)",
            customFieldsLocalMapKey: userKeys.customFieldsLocalKey
        )
    }

    /// 对齐 widget main:src/helper/getLocalKey.ts 的 getTokenKey/getConversationKey 等方法，按指定 pluginId 与 user_id 派生用户态本地缓存 key。
    func makeLocalUserKeys(pluginId: String, userId: String) -> SalesmartlyLocalUserKeys {
        SalesmartlyLocalUserKeys(
            tokenKey: makeLocalStorageKey(pluginId: pluginId, userId: userId, suffix: Self.localStorageTokenKey),
            tokenDateKey: makeLocalStorageKey(pluginId: pluginId, userId: userId, suffix: Self.localStorageTokenDateKey),
            conversationKey: makeLocalStorageKey(pluginId: pluginId, userId: userId, suffix: Self.localStorageConversationKey),
            newUserKey: makeLocalStorageKey(pluginId: pluginId, userId: userId, suffix: Self.localStorageNewUserKey),
            userInfoKey: makeLocalStorageKey(pluginId: pluginId, userId: userId, suffix: Self.localStorageUserInfoKey),
            customFieldsLocalKey: makeLocalStorageKey(
                pluginId: pluginId,
                userId: userId,
                suffix: Self.localStorageCustomFieldsLocalMapKey
            )
        )
    }

    /// 对齐 widget main:src/stores/user.ts 的 userInfo.*Key 当前上下文，返回当前 guest/user 身份下的本地缓存 key。
    func makeUserLocalKeys(userId: String? = nil) -> SalesmartlyLocalStorageKeys {
        makeLocalStorageKeys(userId: userId)
    }

    /// 对齐 widget main:src/stores/user.ts 的 saveLocalToken，并同步 useLocal.ts 在 createUser 成功后写入 tokenDateKey 的时间。
    @discardableResult
    func saveLocalToken(_ token: String, key: String) -> Bool {
        state.userToken = token
        let savedToken = localSave(key, value: token)
        if state.createUserTokenSavedDateMilliseconds > 0 {
            localSave(state.tokenDateKey, value: "\(state.createUserTokenSavedDateMilliseconds)")
        }
        return savedToken
    }

    /// 对齐 widget main:src/stores/user.ts 的 clearUserData，切回 guest key，并返回需要执行 localRemove 的本地缓存 key。
    @discardableResult
    func clearUserData(localGuestToken: String) -> [String] {
        let previousToken = state.userToken
        let previousType = state.userType

        state.loginInfo = nil
        state.userInfo = [:]
        state.userInfoJSONString = ""
        state.localChatUserId = ""
        applyLocalUserKeyContext(userId: "")

        guard config != nil else {
            state.userToken = ""
            state.isNewUser = true
            state.pendingLocalRemoveKeys = []
            return []
        }

        var nextToken = localGuestToken
        var removedKeys: [String] = []
        let guestKeys = makeLocalStorageKeys(userId: "")
        if previousType != state.userType,
           !previousToken.isEmpty,
           previousToken == nextToken {
            nextToken = ""
            removedKeys.append(guestKeys.conversationKey)
            removedKeys.append(guestKeys.userInfoKey)
            removedKeys.append(guestKeys.guestUUIDKey)
            removedKeys.append(guestKeys.autoOpenLastKey)
        }

        state.userToken = nextToken
        state.isNewUser = state.userToken.isEmpty
        if state.isNewUser {
            removedKeys.append(guestKeys.newUserKey)
        }
        state.pendingLocalRemoveKeys = removedKeys
        return removedKeys
    }

    /// 对齐 widget main:src/locales/index.ts 的 dealLanguageMap，处理产品要求的语言别名和前缀匹配。
    func dealLanguageMap(_ language: String) -> String {
        var result = language
        switch language {
        case "zh-TW":
            result = "zh-HK"
        case "ru":
            result = "ru-RU"
        case "zh":
            result = "zh-CN"
        case "ja":
            result = "ja-JP"
        case "ind":
            result = "id"
        case "ko-KR":
            result = "ko"
        case "nl-NL", "nl-BE":
            result = "nl"
        case "da-DK":
            result = "da"
        case "it-CH", "it-IT":
            result = "it"
        case "tr-TR":
            result = "tr"
        default:
            break
        }

        let lowercasedResult = result.lowercased()
        if lowercasedResult.hasPrefix("th") {
            result = "th-TH"
        }
        if lowercasedResult.hasPrefix("vi") {
            result = "vi-VN"
        }
        if lowercasedResult.hasPrefix("mn") {
            result = "mn"
        }
        if lowercasedResult.hasPrefix("ja") {
            result = "ja-JP"
        }
        if lowercasedResult.hasPrefix("fr") {
            result = "fr"
        }
        if lowercasedResult.hasPrefix("es") {
            result = "es"
        }
        if lowercasedResult.hasPrefix("ar") {
            result = "ar"
        }
        if lowercasedResult.hasPrefix("pt") {
            result = "pt"
        }
        if lowercasedResult.hasPrefix("de") {
            result = "de"
        }
        if lowercasedResult.hasPrefix("ro") {
            result = "ro"
        }
        if lowercasedResult.hasPrefix("pl") {
            result = "pl"
        }
        if lowercasedResult.hasPrefix("id") {
            result = "id"
        }
        if lowercasedResult.hasPrefix("ko") {
            result = "ko"
        }
        if lowercasedResult.hasPrefix("nl") {
            result = "nl"
        }
        if lowercasedResult.hasPrefix("da") {
            result = "da"
        }
        if lowercasedResult.hasPrefix("it") {
            result = "it"
        }
        if lowercasedResult.hasPrefix("tr") {
            result = "tr"
        }
        if lowercasedResult.hasPrefix("bn") {
            result = "bn"
        }

        return result
    }

    /// 对齐 widget main:src/locales/index.ts 的 setLang；iOS 没有 navigator.language，由宿主传入等价的当前系统语言。
    @discardableResult
    func setLang(_ str: String, navigatorLanguage: String) -> String {
        if str != "auto" {
            let mappedLang = dealLanguageMap(str)
            if Self.supportLang.contains(mappedLang) {
                state.lang = mappedLang
            } else {
                state.lang = Self.defaultLang
            }
            return state.lang
        }

        let navLang = dealLanguageMap(navigatorLanguage)
        if Self.supportLang.contains(navLang) {
            state.lang = navLang
        } else {
            state.lang = Self.defaultLang
        }
        return state.lang
    }

    /// 对齐 widget main:src/locales/index.ts 的 getLang，返回当前 runtime 语言。
    func getLang() -> String {
        state.lang
    }

    /// 对齐 widget main:src/locales/index.ts 的 checkZh，判断当前语言是否为简体或繁体中文。
    func checkZh() -> Bool {
        ["zh-CN", "zh-HK"].contains(state.lang)
    }

    /// 对齐 widget main:src/utils/SsmEvent.ts 的 setUserInfo，保留字符串字典镜像并写入 user_info JSON 字符串。
    public func setUserInfo(_ userInfo: [String: String]) {
        state.userInfo = userInfo
        state.userInfoJSONString = jsonString(from: userInfo)
    }

    /// 对齐 widget main:src/utils/SsmEvent.ts 的 setUserInfo(data:any)，按 JSON.stringify(data) 语义记录任意 JSON 对象 payload。
    public func setUserInfo(_ userInfo: SalesmartlyPayload) {
        state.userInfo = stringUserInfo(from: userInfo)
        state.userInfoJSONString = jsonString(from: userInfo)
    }

    /// 对齐 widget main:src/utils/SsmEvent.ts 的 setUserData 聚合事件，汇总 setLoginInfo 与 setUserInfo 后续链路需要的用户字段。
    func makeSetUserDataPayload() -> SalesmartlyPayload {
        let loginInfo = state.loginInfo
        return [
            "user_id": loginInfo?.userId ?? "",
            "user_name": loginInfo?.userName ?? "",
            "language": loginInfo?.language ?? "",
            "phone": loginInfo?.phone ?? "",
            "email": loginInfo?.email ?? "",
            "description": loginInfo?.description ?? "",
            "user_info": state.userInfoJSONString,
            "label_names": jsonString(from: loginInfo?.labelNames ?? []),
            "custom_fields_ext": jsonString(from: loginInfo?.customFieldsExt ?? [:]),
        ]
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 getToken/createUser 入参构造，按 guest 与已知 user_id 两条分支生成 token 请求 payload。
    func makeCreateUserPayload(
        sourceURL: String,
        userAgent: String,
        navigatorLanguage: String,
        beforeSourceURL: String,
        guestUserId: String
    ) -> SalesmartlyPayload {
        let userData = makeSetUserDataPayload()
        let phone = stringValue(userData["phone"]) ?? ""
        let email = stringValue(userData["email"]) ?? ""
        let description = stringValue(userData["description"]) ?? ""
        let paramsData: SalesmartlyPayload = [
            "phone": phone,
            "email": email,
            "description": description,
        ]
        let encodedData = encodeDefaultBase64(jsonString(from: paramsData))
        var payload: SalesmartlyPayload = [
            "source_url": sourceURL,
            "language": navigatorLanguage,
            "ua": userAgent,
        ]

        if let userId = stringValue(userData["user_id"]), !userId.isEmpty {
            payload["user_id"] = userId
            payload["user_name"] = stringValue(userData["user_name"]) ?? ""
            payload["language"] = stringValue(userData["language"]) ?? navigatorLanguage
            payload["phone"] = phone
            payload["email"] = email
            payload["data"] = encodedData
            return payload
        }

        payload["user_id"] = guestUserId
        payload["data"] = encodedData
        payload["is_sandbox"] = [ChatMode.sandbox, ChatMode.preview].contains(config?.setting.mode) ? 1 : 0
        payload["before_source_url"] = beforeSourceURL
        payload["label_names"] = stringValue(userData["label_names"]) ?? ""
        payload["custom_fields_ext"] = stringValue(userData["custom_fields_ext"]) ?? ""
        if let flowId = config?.setting.flowId, !flowId.isEmpty {
            payload["from"] = jsonString(from: [
                "key": "flow_test",
                "value": flowId,
            ])
        }
        return payload
    }

    public func clearUser() {
        var localGuestToken = ""
        if config != nil, let localStore {
            let guestKeys = makeLocalStorageKeys(userId: "")
            localGuestToken = localStore.read(guestKeys.tokenKey)
        }
        let removedKeys = clearUserData(localGuestToken: localGuestToken)
        removeLocalKeys(removedKeys)
        stopNotificationFlash()
    }

    public func sendTextMessage(_ text: String) {
        guard !state.isStreamSending else {
            return
        }

        let createdAt = Date()
        let tempId = ChatMessage.makeTempId(createdAt: createdAt)
        let clientMessageId = ChatMessage.makeClientMessageId()
        let clientExpandInfo = ["c_m_id": clientMessageId]
        let message = ChatMessage(
            id: tempId,
            msgType: "1",
            message: text,
            sendType: "1",
            createdAt: createdAt,
            mid: tempId,
            tempId: tempId,
            cMId: clientMessageId,
            clientExpandInfo: clientExpandInfo
        )
        state.messages.append(message)
        addSendMessageItem(message)
        sendTextMessageTransportRequestIfReady(for: message)
        dispatch("onSendMessage", payload: [
            "mid": message.mid,
            "msg_type": message.msgType,
            "message": message.message,
        ])
    }

    @discardableResult
    func beforePostMessage(
        msgType: String,
        message: Any,
        tempId: String? = nil,
        type: String? = nil,
        sequenceId: String? = nil,
        status: Int? = nil,
        mid: String? = nil,
        clientExpandInfo: [String: String]? = nil,
        chatUserId: String? = nil,
        enabledCollect: Bool,
        requiredCollect: Bool
    ) -> Bool {
        if shouldInterceptBeforePostMessage(
            msgType: msgType,
            type: type,
            enabledCollect: enabledCollect,
            requiredCollect: requiredCollect
        ) {
            tempMessage = PendingPostMessage(
                msgType: msgType,
                message: message,
                tempId: tempId ?? ChatMessage.makeTempId(),
                type: type,
                sequenceId: sequenceId,
                status: status,
                mid: mid,
                clientExpandInfo: clientExpandInfo,
                chatUserId: chatUserId
            )
            sendType = "send"
            showCollectionFromInterception()
            return false
        }

        postMessage(
            msgType: msgType,
            message: message,
            tempId: tempId,
            type: type,
            sequenceId: sequenceId,
            status: status,
            mid: mid,
            clientExpandInfo: clientExpandInfo,
            chatUserId: chatUserId
        )
        return true
    }

    @discardableResult
    func beforeRetrySendMessage(tempId: String, enabledCollect: Bool, requiredCollect: Bool) -> Bool {
        guard let message = state.messages.first(where: { $0.tempId == tempId }) else {
            return false
        }

        if isUploadStageAttachment(message) {
            return false
        }

        guard canRetrySendMessage(message) else {
            return false
        }

        if shouldInterceptBeforeRetryMessage(
            msgType: message.msgType,
            enabledCollect: enabledCollect,
            requiredCollect: requiredCollect
        ) {
            tempRetryMsg = message
            sendType = "retry"
            showCollectionFromInterception()
            return false
        }

        return retrySendMessage(tempId: tempId)
    }

    @discardableResult
    func beforeSendPasteFile(enabledCollect: Bool) -> Bool {
        if enabledCollect {
            sendType = "sendPasteFile"
            if !state.showWrapper {
                openChat()
            }
            state.showCollection = true
            return false
        }

        return sendPasteFile()
    }

    @discardableResult
    func handleClickUploadBtn(enabledCollect: Bool) -> Bool {
        guard enabledCollect else {
            return false
        }

        state.showCollection = true
        return true
    }

    @discardableResult
    func collectionFromBtn() -> Bool {
        tempMessage = nil
        if !state.showWrapper {
            openChat()
        }
        state.showCollection = true
        return true
    }

    @discardableResult
    func onPaste(_ file: SalesmartlyUploadFile) -> Bool {
        let type = uploadMsgType(file, requestedMsgType: nil)
        if state.hideUploadTypes.contains(hiddenUploadType(for: type)) {
            return false
        }

        pasteFile = file
        state.tempImgUrl = file.localURL ?? ""
        state.fileName = file.name
        state.showModal = true
        state.pasteMsgType = type
        return true
    }

    @discardableResult
    func sendPasteFile(delayMilliseconds: Int? = nil) -> Bool {
        state.showModal = false
        resetPastePreview()
        guard let pasteFile else {
            return false
        }
        return onUpload(pasteFile)
    }

    @discardableResult
    func onUpload(
        _ file: SalesmartlyUploadFile,
        msgType: String? = nil,
        tempId: String? = nil,
        clientExpandInfo: [String: String]? = nil,
        fileData: Data = Data()
    ) -> Bool {
        let nextMsgType = uploadMsgType(file, requestedMsgType: msgType)
        if file.size == 0, ["2", "6"].contains(nextMsgType) {
            return false
        }

        let nextTempId = tempId ?? "\(ChatMessage.tempPrefix)\(currentTimestamp())-\(Int.random(in: 1...1_000_000))"
        let nextClientExpandInfo = clientExpandInfo ?? ["c_m_id": ChatMessage.makeClientMessageId()]

        uploadTaskMap[nextTempId] = SalesmartlyUploadTask(
            file: file,
            type: nextMsgType,
            clientExpandInfo: nextClientExpandInfo,
            fileData: fileData
        )
        uploadFailNotifiedTempIds.remove(nextTempId)

        postMessage(
            msgType: nextMsgType,
            message: uploadPlaceholderMessage(file, msgType: nextMsgType),
            tempId: nextTempId,
            clientExpandInfo: nextClientExpandInfo
        )
        return true
    }

    /// 对齐 widget main:src/helper/useUpload.ts 的 uploadFile，系统 picker 选中文件后插入本地占位、OSS 直传并发起 swap-object 换签。
    @MainActor
    @discardableResult
    func uploadPickedFile(_ pickedFile: SalesmartlyPickedUploadFile, requestedMsgType: String? = nil) async -> Bool {
        guard let config, let uploadExecutor else {
            return false
        }

        let tempId = "\(ChatMessage.tempPrefix)\(currentTimestamp())-\(Int.random(in: 1...1_000_000))"
        let clientExpandInfo = ["c_m_id": ChatMessage.makeClientMessageId()]
        let uploadFile = SalesmartlyUploadFile(
            name: pickedFile.name,
            size: pickedFile.data.count,
            isImage: pickedFile.isImage,
            isVideo: pickedFile.isVideo,
            localURL: pickedFile.localURL
        )
        guard onUpload(
            uploadFile,
            msgType: requestedMsgType,
            tempId: tempId,
            clientExpandInfo: clientExpandInfo,
            fileData: pickedFile.data
        ),
            let request = makeUploadExecutionRequest(
                tempId: tempId,
                pluginId: config.license,
                env: config.setting.mode.rawValue,
                random: Int.random(in: 1...1_000_000),
                nowMilliseconds: currentTimestamp()
            ) else {
            return false
        }

        do {
            let fileURL = try await uploadExecutor.upload(request)
            guard let payload = handleUploadDirectSuccess(tempId: tempId, fileURL: fileURL) else {
                return false
            }
            sendUploadSwapObjectTransportRequest(tempId: tempId, fileURL: fileURL, payload: payload)
            return true
        } catch {
            handleUploadFailure(tempId: tempId)
            return false
        }
    }

    @discardableResult
    func handleUploadSuccess(
        tempId: String,
        fileURL: String,
        sendURL: String? = nil,
        assetURL: String? = nil
    ) -> Bool {
        guard let task = uploadTaskMap[tempId] else {
            return false
        }

        let messageURL = sendURL ?? fileURL
        postMessage(
            msgType: task.type,
            message: messageURL,
            tempId: tempId,
            clientExpandInfo: task.clientExpandInfo
        )

        if sendURL != nil,
           let assetURL,
           let clientMessageId = task.clientExpandInfo["c_m_id"] {
            sendAssetsList.append([
                "c_m_id": clientMessageId,
                "url": assetURL,
            ])
        }

        uploadTaskMap.removeValue(forKey: tempId)
        uploadFailNotifiedTempIds.remove(tempId)
        return true
    }

    @discardableResult
    func handleUploadFailure(tempId: String, nowMilliseconds: Int64? = nil) -> Bool {
        let didNotify = notifyUploadFail(tempId: tempId, nowMilliseconds: nowMilliseconds)
        markUploadFail(tempId: tempId)
        return didNotify
    }

    @discardableResult
    func retryUploadByTempId(_ tempId: String, isOnline: Bool = true, nowMilliseconds: Int64? = nil) -> Bool {
        guard uploadTaskMap[tempId] != nil else {
            return false
        }
        if !isOnline {
            handleUploadFailure(tempId: tempId, nowMilliseconds: nowMilliseconds)
            return true
        }

        uploadFailNotifiedTempIds.remove(tempId)
        markUploadRetry(tempId: tempId)
        return true
    }

    @discardableResult
    func handleOfflineUploadTasks(nowMilliseconds: Int64? = nil) -> Int {
        guard !uploadTaskMap.isEmpty else {
            return 0
        }

        uploadTaskMap.keys.forEach { tempId in
            uploadFailNotifiedTempIds.insert(tempId)
            markUploadFail(tempId: tempId)
        }
        notifyUploadFail(nowMilliseconds: nowMilliseconds)
        return uploadTaskMap.count
    }

    func postMessage(
        msgType: String,
        message: Any,
        tempId: String? = nil,
        type: String? = nil,
        sequenceId: String? = nil,
        status: Int? = nil,
        mid: String? = nil,
        clientExpandInfo: [String: String]? = nil,
        chatUserId: String? = nil
    ) {
        guard !state.isStreamSending else {
            return
        }

        let createdAt = Date()
        var nextTempId = tempId ?? ChatMessage.makeTempId(createdAt: createdAt)
        var nextMessage = message
        let nextClientExpandInfo = clientExpandInfo ?? ["c_m_id": ChatMessage.makeClientMessageId()]
        let clientMessageId = nextClientExpandInfo["c_m_id"]

        var insertIndex = state.messages.firstIndex { item in
            item.tempId == nextTempId
        }
        if type == "like", let sequenceId {
            insertIndex = state.messages.firstIndex { item in
                item.id == sequenceId
            }
        }

        if type == "promotionalCard", let insertIndex {
            state.messages[insertIndex].status = 1
        }

        var insertedMessage: ChatMessage?
        if insertIndex == nil || type == "promotionalCard" {
            if type == "promotionalCard" {
                nextTempId = ChatMessage.makeTempId()
            }

            if ["5", "11"].contains(msgType) {
                nextMessage = jsonString(from: nextMessage)
                if status == 1, let mid, let targetIndex = state.messages.firstIndex(where: { $0.mid == mid }) {
                    state.messages[targetIndex].status = 1
                }
            }

            markLastAIGuideMessageCompleted()

            let localMessage = ChatMessage(
                id: nextTempId,
                msgType: msgType,
                message: messageText(from: nextMessage),
                sendType: "1",
                createdAt: createdAt,
                mid: nextTempId,
                tempId: nextTempId,
                cMId: clientMessageId,
                chatUserId: chatUserId,
                clientExpandInfo: nextClientExpandInfo
            )
            state.messages.append(localMessage)
            insertedMessage = localMessage
        }

        if let insertedMessage, shouldSendPostMessage(insertedMessage) {
            addSendMessageItem(insertedMessage)
            // 对齐 widget main:src/helper/useUpload.ts 上传成功后的二次 postMessage，真实 https URL 到达后立即触发发送。
            sendTextMessageTransportRequestIfReady(for: insertedMessage)
        } else if let insertIndex {
            var sendCandidate = state.messages[insertIndex]
            sendCandidate.message = messageText(from: nextMessage)
            sendCandidate.cMId = clientMessageId
            sendCandidate.clientExpandInfo = nextClientExpandInfo
            if shouldSendExistingPostMessage(sendCandidate) {
                addSendMessageItem(sendCandidate)
                // 对齐 widget main:src/helper/useUpload.ts 的占位消息替换，已有 tempId 的真实 URL 也要立刻发送给客服端。
                sendTextMessageTransportRequestIfReady(for: sendCandidate)
            }
        }
        saveLocalConversation()
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/PromotionalCard.vue 的 postback，提交邮箱留资后发送 source=3 的 updateUserInfo 并回传按钮 postback。
    @discardableResult
    func submitPromotionalCardEmail(
        email: String,
        button: SalesmartlyNativeTemplateButton,
        tempId: String?
    ) -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            return "请输入邮箱"
        }
        if !Self.isPromotionalCardEmail(trimmedEmail) {
            return "邮箱格式错误"
        }

        sendUpdateUserInfoTransportRequests(
            token: state.userToken,
            email: trimmedEmail,
            chatUserId: state.localChatUserId,
            source: "3"
        )
        savePromotionalCardEmail(trimmedEmail)
        postMessage(
            msgType: "5",
            message: [
                "text": button.text,
                "postback": button.payload,
            ],
            tempId: tempId,
            type: "promotionalCard",
            chatUserId: state.localChatUserId
        )
        return nil
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 evalutionMessage 与 ScoreTpl.vue 的 handleScore，评分大于 0 时按实时模式提交 evalution 事件。
    @discardableResult
    func submitEvalutionMessage(
        message: ChatMessage,
        score: Int,
        comment: String
    ) -> String? {
        if score == 0 {
            return "请选择评分"
        }

        let payload = inviteEvalutionPayload(from: message.message)
        let requestPayload = makeEvalutionPayload(
            sessionId: stringValue(payload["session_id"]),
            sequenceId: message.id,
            flowId: stringValue(payload["flow_id"]),
            stepLogId: stringValue(payload["step_log_id"]),
            score: "\(score)",
            comment: comment,
            inviteEvaluationId: stringValue(payload["invite_evaluation_id"]),
            inviteEvaluationOrderId: stringValue(payload["invite_evaluation_order_id"]),
            clientExpandInfo: ["c_m_id": ChatMessage.makeClientMessageId()]
        )
        sendTransportRequest(makeEvalutionTransportRequest(payload: requestPayload))
        return nil
    }

    func handleSendMessageSuccess(
        sequenceId: String,
        message: String? = nil,
        sendTime: Int64? = nil,
        tempId: String? = nil,
        clientMessageId: String? = nil
    ) {
        let indexByClientMessageId = clientMessageId.flatMap { cMId in
            state.messages.firstIndex { item in
                item.cMId == cMId
            }
        }
        let indexByTempId = tempId.flatMap { value in
            state.messages.firstIndex { item in
                item.id == value || item.tempId == value
            }
        }
        let indexBySequenceId = state.messages.firstIndex { item in
            item.id == sequenceId
        }

        guard let targetIndex = indexByClientMessageId ?? indexByTempId ?? indexBySequenceId else {
            return
        }

        var nextMessage = state.messages[targetIndex]
        if let message, !message.isEmpty {
            nextMessage.message = normalizePostbackSendSuccessMessage(message, msgType: nextMessage.msgType)
        }
        if let sendTime {
            nextMessage.createdTime = transformSendTime(sendTime)
            nextMessage.createdAt = Date(timeIntervalSince1970: TimeInterval(nextMessage.createdTime) / 1000)
        }
        if !sequenceId.isEmpty {
            nextMessage.id = sequenceId
            nextMessage.mid = sequenceId
        }
        if nextMessage.cMId == nil {
            nextMessage.cMId = clientMessageId
        }
        if let clientMessageId, nextMessage.clientExpandInfo["c_m_id"] == nil {
            nextMessage.clientExpandInfo["c_m_id"] = clientMessageId
        }

        state.messages.remove(at: targetIndex)
        state.messages.append(nextMessage)
        removeDuplicateMessages(id: sequenceId)

        if let clientMessageId {
            sendMessageMap.removeValue(forKey: clientMessageId)
            retryingMap.removeValue(forKey: clientMessageId)
        }
        saveLocalConversation()
    }

    // 对齐 widget main:src/helper/useSocket.ts 的 postMessage(msg_type=5) 与 main:src/helper/useSendMessage.ts 的 handleSendMsgSuccess：
    // Web 本地先 JSON.stringify postback 对象，发送成功后再用 ACK 的 content.msg 覆盖本地项；当后端返回 JSON 字符串字面量时，iOS 需解回 PostbackMessage.vue 可 JSON.parse 的对象字符串。
    private func normalizePostbackSendSuccessMessage(_ message: String, msgType: String) -> String {
        guard msgType == "5",
              let data = message.data(using: .utf8),
              let decodedMessage = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? String,
              let decodedData = decodedMessage.data(using: .utf8),
              let decodedPayload = try? JSONSerialization.jsonObject(with: decodedData) as? SalesmartlyPayload,
              decodedPayload["text"] is String else {
            return message
        }

        return decodedMessage
    }

    @discardableResult
    func handleSocketSendMessageAck(
        sequenceId: String,
        message: String,
        sendTime: Int64,
        tempId: String,
        clientMessageId: String
    ) -> SalesmartlyPayload? {
        guard handleHTTPSendMessageAck(
            sequenceId: sequenceId,
            message: message,
            sendTime: sendTime,
            tempId: tempId,
            clientMessageId: clientMessageId
        ) else {
            return nil
        }

        guard let currentIndex = state.messages.firstIndex(where: { $0.id == sequenceId }),
              currentIndex > 0,
              state.messages[currentIndex - 1].sendType != "1" else {
            return nil
        }

        return readMessage(sequenceId: sequenceId)
    }

    @discardableResult
    func handleHTTPSendMessageAck(
        sequenceId: String,
        message: String,
        sendTime: Int64,
        tempId: String,
        clientMessageId: String
    ) -> Bool {
        handleSendMessageSuccess(
            sequenceId: sequenceId,
            message: message,
            sendTime: sendTime,
            tempId: tempId,
            clientMessageId: clientMessageId
        )

        guard let acknowledgedMessage = state.messages.first(where: { $0.id == sequenceId }) else {
            return false
        }

        dispatch("onSendMessage", payload: [
            "mid": acknowledgedMessage.mid,
            "msg_type": acknowledgedMessage.msgType,
            "message": acknowledgedMessage.message,
        ])
        return true
    }

    @discardableResult
    func handleSocketSendMessageTransportAck(
        _ response: SalesmartlyPayload,
        tempId: String,
        clientMessageId: String
    ) -> SalesmartlyPayload? {
        guard response["code"] as? Int == 0,
              let data = response["data"] as? SalesmartlyPayload,
              let messageData = data["message"] as? SalesmartlyPayload,
              let ack = makeSendMessageTransportAck(from: messageData) else {
            return nil
        }

        return handleSocketSendMessageAck(
            sequenceId: ack.sequenceId,
            message: ack.message,
            sendTime: ack.sendTime,
            tempId: tempId,
            clientMessageId: clientMessageId
        )
    }

    @discardableResult
    func handleHTTPSendMessageTransportResponse(
        _ response: SalesmartlyPayload,
        tempId: String,
        clientMessageId: String
    ) -> Bool {
        guard let data = response["data"] as? SalesmartlyPayload else {
            return false
        }

        // 对齐 widget main:src/helper/useSocket.ts 的 sendMessageByHttpEventCb：真实响应为 data.message，旧 HTTP 夹具为 data.data/message。
        let responseData = (data["data"] as? SalesmartlyPayload) ?? data
        let messageData: SalesmartlyPayload
        if let wrappedMessageData = responseData["message"] as? SalesmartlyPayload {
            messageData = wrappedMessageData
        } else {
            messageData = responseData
        }

        guard let ack = makeSendMessageTransportAck(from: messageData) else {
            return false
        }

        return handleHTTPSendMessageAck(
            sequenceId: ack.sequenceId,
            message: ack.message,
            sendTime: ack.sendTime,
            tempId: tempId,
            clientMessageId: clientMessageId
        )
    }

    @discardableResult
    func handleReceiveMessageTransportPayload(_ response: SalesmartlyPayload) -> Bool {
        applyReceiveMessageTransportPayload(response).handled
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 receiveMessage/showSession，解析 socket 入站消息并在可视聊天窗口中派生已读回传。
    private func applyReceiveMessageTransportPayload(
        _ response: SalesmartlyPayload
    ) -> (handled: Bool, readPayload: SalesmartlyPayload?) {
        guard let data = response["data"] as? SalesmartlyPayload,
              let messageData = makeReceiveMessageTransportData(from: data) else {
            return (false, nil)
        }

        let readPayload = receiveMessage(
            sequenceId: messageData.sequenceId,
            senderType: messageData.senderType,
            msgType: messageData.msgType,
            message: messageData.message,
            sendTime: messageData.sendTime,
            chatUserId: messageData.chatUserId,
            senderName: messageData.senderName,
            senderAvatar: messageData.senderAvatar,
            clientMessageId: messageData.clientMessageId,
            readTime: messageData.readTime,
            streamInfo: messageData.streamInfo,
            isWithdraw: messageData.isWithdraw,
            quoteChat: messageData.quoteChat
        )
        return (true, readPayload)
    }

    @discardableResult
    func handleReceiveNoticeTransportPayload(_ response: SalesmartlyPayload) -> Bool {
        guard let data = response["data"] as? SalesmartlyPayload,
              let noticeType = intValue(data["notice_type"]),
              let notice = data["notice"] as? SalesmartlyPayload else {
            return false
        }

        return receiveNotice(
            noticeType: noticeType,
            sequenceId: stringValue(notice["sequence_id"]),
            pushTime: int64Value(data["push_time"]),
            chatUserId: stringValue(notice["chat_user_id"]),
            sysUserId: stringValue(notice["sys_user_id"]),
            nickname: stringValue(notice["nickname"]),
            avatar: stringValue(notice["avatar"]),
            sysUserAvatar: stringValue(notice["sys_user_avatar"])
        )
    }

    @discardableResult
    func handleUnreadMsgListTransportResponse(_ response: SalesmartlyPayload, currentChatUserId: String) -> Int {
        guard let messages = makeMessageListFromHTTPTransportResponse(response) else {
            return 0
        }

        applyUnreadMessageList(messages, currentChatUserId: currentChatUserId)
        return messages.count
    }

    @discardableResult
    func handleRecentMsgListTransportResponse(_ response: SalesmartlyPayload, currentChatUserId: String) -> Int {
        guard let messages = makeMessageListFromHTTPTransportResponse(response) else {
            return 0
        }

        applyRecentMessageList(messages, currentChatUserId: currentChatUserId)
        return messages.count
    }

    @discardableResult
    func handleTriggerTransportResponse(_ response: SalesmartlyPayload) -> Int {
        guard let messages = makeMessageListFromHTTPTransportResponse(response) else {
            return 0
        }

        return applyTriggeredMessageList(messages)
    }

    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 getInfo.then，将 plugin/info 中已确认可映射的配置落到 iOS runtime state。
    @discardableResult
    func handlePluginInfoTransportResponse(_ response: SalesmartlyPayload) -> Bool {
        // Web `getInfo()` 中的 `res.data.data` 包含 Axios 响应体外层；iOS URLSession 解出的 response 已是接口 JSON，配置位于顶层 `data`。
        guard let info = response["data"] as? SalesmartlyPayload,
              !info.isEmpty else {
            return false
        }

        let channels = makePluginInfoChannels(from: info)
        state.channelSort = channelSortFromPluginInfo(info["channel_sort"])
        state.channelOpenConfigs = channelOpenConfigsFromPluginInfo(info)
        if let backgroundColor = stringValue(info["background_color"]) {
            state.backgroundColor = backgroundColor
        }
        let chatIconOutURL = stringValue(info["plugin_iconv_url"]) ?? ""
        let chatIconInURL = stringValue(info["plugin_iconv_active_url"]) ?? ""
        state.chatIconDefine = !chatIconOutURL.isEmpty && !chatIconInURL.isEmpty
        state.chatIconOutURL = chatIconOutURL
        state.chatIconInURL = chatIconInURL
        if let position = stringValue(info["position"]) {
            state.position = position
        }
        if let marginBottom = intValue(info["margin_bottom"]) {
            state.marginBottom = marginBottom
        }
        if let marginBottomPC = intValue(info["margin_bottom_pc"]) {
            state.marginBottomPC = marginBottomPC
        }
        let mobileDisplay = payloadValue(info["mobile_display"])
        let coverTheScreen = mobileDisplay.flatMap { stringValue($0["cover_the_screen"]) } == "1"
        // 对齐 widget main:src/helper/usePluginInfo.ts 的 mobileScreen 派生：INIT_MOBILE_SCREEN 或 mobile_display.cover_the_screen 任一为 full 即进入全屏窗口。
        state.mobileScreen = config?.setting.initMobileScreen == "full" || coverTheScreen ? "full" : ""
        state.locationConfigDivisive = pluginInfoSwitchEnabled(info["location_config_divisive"])
        state.integrationType = integrationTypeFromShowEffect(info["show_effect"])
        if let homePage = payloadValue(info["home_page"]) {
            state.homePageEnabled = stringValue(homePage["enabled"]) == "1"
            state.homePageTitle = stringValue(homePage["title"])?.replacingOccurrences(of: "\\n", with: "\n") ?? ""
        } else {
            state.homePageEnabled = false
            state.homePageTitle = ""
        }
        state.welcome = stringValue(info["welcome"]) ?? ""
        state.windowSubheadSwitch = stringValue(info["window_subhead_switch"]) ?? "1"
        if let helpdeskConfig = payloadValue(info["show_helpdesk_config"]) {
            state.helpdeskSwitch = stringValue(helpdeskConfig["switch"]) ?? "0"
            state.helpdeskId = stringValue(helpdeskConfig["id"]) ?? ""
            state.helpdeskTitle = stringValue(helpdeskConfig["title"]) ?? ""
            state.helpdeskURL = stringValue(helpdeskConfig["url"]) ?? ""
        } else {
            state.helpdeskSwitch = "0"
            state.helpdeskId = ""
            state.helpdeskTitle = ""
            state.helpdeskURL = ""
        }
        state.collectInformation = collectionConfigFromPluginInfo(
            info["collect_information"],
            defaultConfig: SalesmartlyCollectionConfig(guidance: "")
        )
        state.offlineSurvey = collectionConfigFromPluginInfo(
            info["offline_survey"],
            defaultConfig: SalesmartlyCollectionConfig(guidance: "")
        )
        state.bulletinBoard = bulletinBoardFromPluginInfo(info["bulletin_board"])
        let sidebarState = sidebarStateFromShowSideConfig(info["show_side_config"])
        state.sidebarShow = sidebarState.show
        state.sidebarShrinkMode = sidebarState.shrinkMode
        if let avatarURL = stringValue(info["avatar_url"]) {
            state.pluginAvatarURL = avatarURL
        }
        let autoFrame = payloadValue(info["auto_frame"])
        let iconPopupEnabled: Bool
        var iconPopupType = state.iconPopupType
        if let autoFrame {
            iconPopupEnabled = pluginInfoSwitchEnabled(autoFrame["icon_popup"])
            if let nextIconPopupType = stringValue(autoFrame["icon_popup_type"]) {
                iconPopupType = nextIconPopupType
            }
        } else {
            iconPopupEnabled = false
        }
        var windowName = state.iconPopupWindowName
        if let nextWindowName = stringValue(info["window_name"]) {
            windowName = nextWindowName
        }
        if let pluginName = stringValue(info["plugin_name"]) {
            state.pluginName = pluginName
        }
        state.humanServiceEnabled = payloadValue(info["turn_to_manual_button"]).flatMap { config in
            stringValue(config["type"])
        } != "0"
        state.withdrawRecord = payloadValue(info["withdraw_notice"]).flatMap { config in
            stringValue(config["type"])
        } != "0"
        state.showSenderName = payloadValue(info["show_customer_service_name"]).flatMap { config in
            stringValue(config["type"])
        } != "0"
        let mode = config?.setting.mode
        let isLimit = mode != .sandbox && mode != .preview && pluginInfoStringEqualsOne(info["is_limit"])
        if let projectId = stringValue(info["project_id"]) {
            state.pluginProjectId = projectId
        }
        state.reportSwitch = pluginInfoSwitchEnabled(info["report_switch"])
        applyRealtimeMode(sseSwitch: stringValue(info["sse_switch"]) ?? "0")
        state.supportRetry = pluginInfoSwitchEnabled(info["support_retry"])
        state.isPollingEnabled = pluginInfoSwitchEnabled(info["is_polling"])
        if let pollingGap = intValue(info["polling_gap"]), pollingGap != 0 {
            state.pollingGapSeconds = pollingGap
        } else {
            state.pollingGapSeconds = 10
        }
        if let queueSwitch = stringValue(info["queue_switch"]) {
            state.queueSwitch = queueSwitch
        }
        if let queuePollingInterval = intValue(info["queue_polling_interval"]) {
            state.queuePollingIntervalSeconds = queuePollingInterval
        } else {
            state.queuePollingIntervalSeconds = 0
        }

        setIconPopupConfiguration(
            iconPopupEnabled: iconPopupEnabled,
            iconPopupType: iconPopupType,
            channels: channels,
            isLimit: isLimit
        )
        setIconPopupDisplayConfiguration(
            windowName: windowName,
            showReceptionInfo: stringValue(info["show_reception_info"]) != "0"
        )

        if let messageNotice = stringValue(info["sdk_message_notice"]),
           let noticeConfig = messageJSONObject(messageNotice) {
            setNotificationConfiguration(
                flashTitle: pluginInfoSwitchEnabled(noticeConfig["browser_tab_tips"]),
                soundNotice: pluginInfoSwitchEnabled(noticeConfig["sound_notice"])
            )
        }

        if connectCachedGuestTokenAfterPluginInfo() == nil {
            sendCreateUserTokenRequestAfterPluginInfo()
        }
        return true
    }

    @discardableResult
    func handleQueueStatusTransportResponse(_ response: SalesmartlyPayload) -> Bool {
        guard let data = response["data"] as? SalesmartlyPayload,
              let responseData = data["data"] as? SalesmartlyPayload,
              let status = stringValue(responseData["status"]),
              let queueCount = intValue(responseData["queue_count"]) else {
            return false
        }

        return applyQueueStatus(status: status, queueCount: queueCount)
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 fetchQueueStatus.then：只处理当前 requestId，waiting/其他状态继续调度，assigned 停止轮询。
    @discardableResult
    func handleQueueStatusTransportResponse(
        _ response: SalesmartlyPayload,
        requestId: Int,
        queuePollingIntervalSeconds: Int,
        nowMilliseconds: Int64
    ) -> Bool {
        guard requestId == state.queueStatusPollingRequestId,
              let data = response["data"] as? SalesmartlyPayload,
              let responseData = data["data"] as? SalesmartlyPayload,
              let status = stringValue(responseData["status"]),
              let queueCount = intValue(responseData["queue_count"]) else {
            return false
        }

        if status == "waiting" {
            setQueueWaiting(queueCount)
            scheduleQueueStatusPolling(
                queuePollingIntervalSeconds: queuePollingIntervalSeconds,
                nowMilliseconds: nowMilliseconds
            )
            return true
        }

        clearQueueStatus()
        stopQueueStatusPolling()

        if status == "assigned" {
            return false
        }

        scheduleQueueStatusPolling(
            queuePollingIntervalSeconds: queuePollingIntervalSeconds,
            nowMilliseconds: nowMilliseconds
        )
        return true
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 fetchQueueStatus.then，从 plugin/info 落到 state 的 queue_polling_interval 读取排队轮询间隔。
    @discardableResult
    func handleQueueStatusTransportResponse(
        _ response: SalesmartlyPayload,
        requestId: Int,
        nowMilliseconds: Int64
    ) -> Bool {
        handleQueueStatusTransportResponse(
            response,
            requestId: requestId,
            queuePollingIntervalSeconds: state.queuePollingIntervalSeconds,
            nowMilliseconds: nowMilliseconds
        )
    }

    @discardableResult
    func handleSocketJoinRoomTransportResponse(_ response: SalesmartlyPayload, currentChatUserId: String) -> Int {
        joinRoomTransportConfirmed = true
        guard let messages = makeMessageListFromSocketJoinTransportResponse(response) else {
            return 0
        }

        applyUnreadMessageList(messages, currentChatUserId: currentChatUserId)
        return messages.count
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 evalution ack，非 140001/140002 错误时标记邀评消息 status=1。
    @discardableResult
    func handleEvalutionTransportResponse(_ response: SalesmartlyPayload, request: SalesmartlyTransportRequest) -> Bool {
        var data: SalesmartlyPayload = response
        if let responseData = response["data"] as? SalesmartlyPayload {
            data = responseData
        }
        if let errorCode = data["error_code"] as? Int,
           [140001, 140002].contains(errorCode) {
            showToast(salesmartlyText("errorCode.\(errorCode)", language: state.lang))
            return false
        }
        let requestData = chatMsgEventDataPayload(from: request.payload) ?? request.payload
        guard let sequenceId = requestData["sequence_id"] as? String,
              let index = state.messages.firstIndex(where: { $0.id == sequenceId }) else {
            return false
        }

        state.messages[index].status = 1
        return true
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 getTokenData/connect，收到 token/channels 后创建 Centrifugo EventSource 连接。
    @discardableResult
    func handleCentrifugoTokenTransportResponse(_ response: SalesmartlyPayload, request: SalesmartlyTransportRequest) -> Bool {
        guard let baseURL = realtimeCentrifugoURL,
              let loginToken = request.query["login_token"],
              let chatUserId = request.query["chat_user_id"],
              let data = response["data"] as? SalesmartlyPayload,
              let token = stringValue(data["token"]),
              let channels = data["channels"] as? [String],
              let eventSourceURL = makeCentrifugoEventSourceURL(
                baseURL: baseURL,
                token: token,
                channels: channels
              ) else {
            return false
        }

        let joinRequest = makeJoinRoomTransportRequest()
        let connectionRequest = SalesmartlySSEConnectionRequest(
            eventSourceURL: eventSourceURL,
            connectRequest: makeSseConnectTransportRequest(
                loginToken: loginToken,
                chatUserId: chatUserId
            ),
            disconnectRequest: makeSseDisconnectTransportRequest(
                loginToken: loginToken,
                chatUserId: chatUserId
            ),
            openRequests: joinRequest.map { [$0] } ?? []
        )
        transport?.connectSSE(connectionRequest)
        return true
    }

    @discardableResult
    func handleJoinRoomTransportTimeout() -> Bool {
        state.hasJoinRoom = joinRoomTransportConfirmed
        state.sendMode = joinRoomTransportConfirmed ? Self.sendModeWS : Self.sendModeHTTP
        return joinRoomTransportConfirmed
    }

    @discardableResult
    func handleTransportResponse(
        _ response: SalesmartlyPayload,
        for request: SalesmartlyTransportRequest,
        currentChatUserId: String
    ) -> [SalesmartlyTransportRequest] {
        var followUpRequests: [SalesmartlyTransportRequest] = []

        if request.kind == .socketEvent {
            if request.eventName == Self.joinRoomEvent {
                handleSocketJoinRoomTransportResponse(response, currentChatUserId: currentChatUserId)
            }

            if request.eventName == Self.sendMessageEvent,
               let identity = makeTransportSendMessageIdentity(from: request),
               let readPayload = handleSocketSendMessageTransportAck(
                   response,
                   tempId: identity.tempId,
                   clientMessageId: identity.clientMessageId
               ) {
                followUpRequests.append(
                    makeSocketEventTransportRequest(
                        eventName: Self.readMessageEvent,
                        payload: readPayload
                    )
                )
            }

            if request.eventName == Self.evalutionEvent {
                handleEvalutionTransportResponse(response, request: request)
            }

            return followUpRequests
        }

        if (request.path == Self.sendMessageHTTPPath ||
            (request.path == Self.chatMsgEventHTTPPath && request.payload["event"] as? String == Self.sendMessageEvent)),
           let identity = makeTransportSendMessageIdentity(from: request) {
            handleHTTPSendMessageTransportResponse(
                response,
                tempId: identity.tempId,
                clientMessageId: identity.clientMessageId
            )
        }

        if request.path == Self.chatMsgEventHTTPPath,
           request.payload["event"] as? String == Self.joinRoomEvent {
            handleSocketJoinRoomTransportResponse(response, currentChatUserId: currentChatUserId)
            sendPendingSocketTransportRequests()
            flushPendingMessageTransportRequestsAfterConnection()
        }

        if request.path == Self.chatMsgEventHTTPPath,
           request.payload["event"] as? String == Self.evalutionEvent {
            handleEvalutionTransportResponse(response, request: request)
        }

        if request.path == Self.unreadMsgListHTTPPath {
            handleUnreadMsgListTransportResponse(response, currentChatUserId: currentChatUserId)
        }

        if request.path == Self.recentMsgListHTTPPath {
            handleRecentMsgListTransportResponse(response, currentChatUserId: currentChatUserId)
        }

        if request.path == Self.triggerHTTPPath || request.path == Self.triggerUserHTTPPath {
            handleTriggerTransportResponse(response)
        }

        if request.path == Self.pluginInfoHTTPPath {
            handlePluginInfoTransportResponse(response)
        }

        if request.path == Self.queueStatusHTTPPath {
            handleQueueStatusTransportResponse(response)
        }

        if request.path == Self.createUserHTTPPath {
            handleCreateUserTransportResponse(response)
        }

        if request.path == Self.centrifugoTokenHTTPPath {
            handleCentrifugoTokenTransportResponse(response, request: request)
        }

        if request.path == Self.swapObjectHTTPPath {
            if !handleUploadSwapObjectTransportResponse(response, request: request) {
                handleDownloadSwapObjectTransportResponse(response, request: request)
            }
        }

        return followUpRequests
    }

    @discardableResult
    func handleSocketInboundEvent(eventName: String, payload: SalesmartlyPayload) -> [SalesmartlyTransportRequest] {
        if eventName == Self.receiveMessageEvent {
            let result = applyReceiveMessageTransportPayload(payload)
            if let readPayload = result.readPayload {
                return [
                    makeSocketEventTransportRequest(
                        eventName: Self.readMessageEvent,
                        payload: readPayload
                    ),
                ]
            }
            return []
        }

        if eventName == Self.receiveNoticeEvent {
            handleReceiveNoticeTransportPayload(payload)
            return []
        }

        if eventName == Self.reconnectEvent {
            if let request = makeJoinRoomTransportRequest() {
                return [request]
            }
            return []
        }

        if eventName == Self.disconnectEvent {
            return handleSocketDisconnectTransportEvent(payload)
        }

        if eventName == Self.reconnectErrorEvent || eventName == Self.reconnectFailedEvent {
            state.hasJoinRoom = false
            joinRoomTransportConfirmed = false
            return []
        }

        if eventName == Self.reconnectAttemptEvent {
            transport?.removeBufferedSocketEvent(Self.openFrameEvent)
            removePendingSocketEvent(Self.openFrameEvent)
            return []
        }

        return []
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 parseSseEnvelope 与 useSocket.ts 的 handleSseEnvelope，解析 Centrifugo `pub.data` 后路由下行事件。
    @discardableResult
    func handleSseRealtimePayload(_ payload: SalesmartlyPayload) -> [SalesmartlyTransportRequest] {
        guard let envelope = makeSseRealtimeEnvelope(from: payload) else {
            return []
        }

        return handleSseRealtimeEnvelope(eventName: envelope.eventName, data: envelope.data)
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 handleSseEnvelope，SSE receive-message 派生的已读回传继续走 HTTP event。
    @discardableResult
    func handleSseRealtimeEnvelope(eventName: String, data: SalesmartlyPayload) -> [SalesmartlyTransportRequest] {
        if eventName == Self.receiveMessageEvent {
            let result = applyReceiveMessageTransportPayload(["data": data])
            if let readPayload = result.readPayload {
                return [
                    makeRealtimeEventTransportRequest(
                        eventName: Self.readMessageEvent,
                        payload: readPayload
                    ),
                ]
            }
            return []
        }

        if eventName == Self.sseReceiveNoticeEvent || eventName == Self.receiveNoticeEvent {
            handleReceiveNoticeTransportPayload(["data": data])
            return []
        }

        return []
    }

    @discardableResult
    func handleSocketDisconnectTransportEvent(_ payload: SalesmartlyPayload) -> [SalesmartlyTransportRequest] {
        guard let loginToken = stringValue(payload["login_token"]),
              let chatUserId = stringValue(payload["chat_user_id"]) else {
            state.hasJoinRoom = false
            state.sendMode = Self.sendModeHTTP
            joinRoomTransportConfirmed = false
            markPendingMessagesFailed()
            return []
        }

        return onDisconnect(loginToken: loginToken, chatUserId: chatUserId).map { retryPayload in
            makeHTTPTransportRequest(
                path: Self.sendMessageHTTPPath,
                method: .post,
                payload: retryPayload,
                externalSign: true
            )
        }
    }

    @discardableResult
    func receiveMessage(
        sequenceId: String,
        senderType: String,
        msgType: String,
        message: String,
        sendTime: Int64,
        chatUserId: String,
        senderName: String? = nil,
        senderAvatar: String? = nil,
        clientMessageId: String? = nil,
        readTime: Int64? = nil,
        streamInfo: SalesmartlyStreamInfo? = nil,
        isWithdraw: String? = nil,
        quoteChat: String = ""
    ) -> SalesmartlyPayload? {
        state.showServiceTyping = false
        state.showRobotTyping = false
        state.serviceTypingHideAtMilliseconds = 0
        state.robotTypingHideAtMilliseconds = 0
        var readPayload: SalesmartlyPayload?

        let streamMessage = isStreamMessage(senderType: senderType, msgType: msgType)
        if streamMessage {
            handleStreamSending(sequenceId: sequenceId, message: message, streamInfo: streamInfo)
        }

        var mergedLocalTemp = false
        if senderType == "1", let clientMessageId {
            let localTempItem = state.messages.first { item in
                item.cMId == clientMessageId && item.id != sequenceId
            }
            if let localTempItem {
                handleSendMessageSuccess(
                    sequenceId: sequenceId,
                    message: message,
                    sendTime: sendTime,
                    tempId: localTempItem.id,
                    clientMessageId: clientMessageId
                )
                if let index = state.messages.firstIndex(where: { $0.id == sequenceId }) {
                    state.messages[index].chatUserId = chatUserId
                }
                mergedLocalTemp = true
            }
        }

        if !mergedLocalTemp, msgType != "8", !state.messages.contains(where: { $0.id == sequenceId }) {
            if senderType == "1" {
                markLastInteractiveMessageCompleted()
            }
            let pendingState = makeInteractivePendingState(msgType: msgType, message: message)
            state.messages.append(
                ChatMessage(
                    id: sequenceId,
                    msgType: msgType,
                    message: message,
                    sendType: senderType,
                    createdAt: Date(timeIntervalSince1970: TimeInterval(transformSendTime(sendTime)) / 1000),
                    mid: sequenceId,
                    tempId: pendingState.tempId,
                    status: pendingState.status,
                    createdTime: transformSendTime(sendTime),
                    cMId: clientMessageId,
                    chatUserId: chatUserId,
                    senderName: senderName,
                    senderAvatar: senderAvatar,
                    clientExpandInfo: clientMessageId.map { ["c_m_id": $0] } ?? [:],
                    isRead: makeReadStatus(readTime: readTime),
                    likeResult: makeLikeResult(msgType: msgType, message: message),
                    isWithdraw: isWithdraw,
                    isStream: streamMessage ? "1" : nil,
                    quoteChat: quoteChat
                )
            )
            if let noticeMessage = state.messages.last {
                updateLastNoticeMsgIfNeeded(noticeMessage)
            }
            markConversationHasNewMessage()
            updateUnreadNumFromMessages()
            if shouldReadVisibleReceivedMessage() {
                readPayload = readMessage(sequenceId: sequenceId)
            }
            saveLocalConversation()
        }

        dispatch("onReceiveMessage", payload: [
            "mid": sequenceId,
            "msg_type": msgType,
            "message": message,
            "quote_chat": quoteChat,
        ])
        return readPayload
    }

    @discardableResult
    func receiveNotice(
        noticeType: Int,
        sequenceId: String? = nil,
        pushTime: Int64? = nil,
        chatUserId: String? = nil,
        sysUserId: String? = nil,
        nickname: String? = nil,
        avatar: String? = nil,
        sysUserAvatar: String? = nil,
        nowMilliseconds: Int64? = nil
    ) -> Bool {
        var handled = false
        let now = nowMilliseconds ?? currentTimestamp()

        if noticeType == 3 {
            dispatch("onHideHumanComponent", payload: [:])
            dispatch("onQueueAssigned", payload: [:])
            hideHumanComponent()
            clearQueueStatus()
            pushJoinSessionSystemMessage(pushTime: pushTime, chatUserId: chatUserId, nickname: nickname)
            handled = true
        }

        if noticeType == 4 {
            dispatch("onHideHumanComponent", payload: [:])
            hideHumanComponent()
            resetAssignUserInfo()
            handled = true
        }

        if noticeType == 19 {
            // 对齐 widget main:src/helper/useSocket.ts 的 noticeType 19：展示机器人 typing，并用 timerHide 在 60 秒后隐藏。
            state.showRobotTyping = true
            state.robotTypingHideAtMilliseconds = now + Self.robotTypingHideDelayMilliseconds
            handled = true
        }

        if noticeType == 20,
           let sequenceId,
           let index = state.messages.firstIndex(where: { $0.id == sequenceId }) {
            state.messages[index].message = "{}"
            state.messages[index].isWithdraw = "1"
            updateUnreadNumFromMessages()
            handled = true
        }

        if noticeType == 24 {
            // 对齐 widget main:src/helper/useSocket.ts 的 noticeType 24：清理旧 timer 后随机 2-3 秒再隐藏 Helplook typing。
            let delaySeconds = Int64(Int.random(in: Self.helplookNoResponseHideDelaySeconds))
            state.robotTypingHideAtMilliseconds = now + delaySeconds * 1000
            handled = true
        }

        if noticeType == 33 {
            // 对齐 widget main:src/helper/useSocket.ts 的 noticeType 33：展示人工 typing，重复通知会重置 10 秒 typingTimer。
            state.showServiceTyping = true
            state.serviceTypingHideAtMilliseconds = now + Self.serviceTypingHideDelayMilliseconds
            handled = true
        }

        if let sysUserId, let nickname {
            setAssignUserInfo(sysUserId: sysUserId, nickname: nickname, avatar: avatar, sysUserAvatar: sysUserAvatar)
        }

        return handled
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 timerHide/typingTimer，由宿主定时器推进人工与机器人 typing 自动隐藏状态。
    @discardableResult
    public func advanceTypingTimers(nowMilliseconds: Int64) -> Bool {
        var didAdvance = false

        if state.robotTypingHideAtMilliseconds != 0,
           nowMilliseconds >= state.robotTypingHideAtMilliseconds {
            state.showRobotTyping = false
            state.robotTypingHideAtMilliseconds = 0
            didAdvance = true
        }

        if state.serviceTypingHideAtMilliseconds != 0,
           nowMilliseconds >= state.serviceTypingHideAtMilliseconds {
            state.showServiceTyping = false
            state.serviceTypingHideAtMilliseconds = 0
            didAdvance = true
        }

        return didAdvance
    }

    func markPendingMessagesFailed() {
        for index in state.messages.indices where shouldMarkFailed(state.messages[index]) {
            state.messages[index].mid = "\(ChatMessage.failPrefix)\(currentTimestamp())"
        }
    }

    @discardableResult
    func retrySendMessage(tempId: String) -> Bool {
        guard let index = state.messages.firstIndex(where: { $0.tempId == tempId }),
              canRetrySendMessage(state.messages[index]) else {
            return false
        }

        state.messages[index].mid = "\(ChatMessage.retryPrefix)\(currentTimestamp())"
        if let clientMessageId = state.messages[index].cMId {
            retryingMap[clientMessageId] = state.messages[index]
        }
        return true
    }

    @discardableResult
    func retryPostMessage(loginToken: String, chatUserId: String) -> [SalesmartlyPayload] {
        // 对齐 widget main:src/helper/useSendMessage.ts 的 retryPostMessage：sendMessageMap 只有 support_retry 开启时才参与重试。
        guard state.supportRetry else {
            return []
        }

        var payloads: [SalesmartlyPayload] = []

        sendMessageMap.values.forEach { message in
            guard let clientMessageId = message.cMId, retryingMap[clientMessageId] == nil else {
                return
            }
            guard let tempId = message.tempId, retrySendMessage(tempId: tempId) else {
                return
            }
            guard let retryMessage = state.messages.first(where: { item in
                item.cMId == clientMessageId
            }) else {
                return
            }
            payloads.append(
                makeHTTPSendMessagePayload(
                    for: retryMessage,
                    loginToken: loginToken,
                    chatUserId: chatUserId
                )
            )
        }

        return payloads
    }

    @discardableResult
    func handleLikeMessageSuccess(sequenceId: String, likeResult: String) -> Bool {
        guard let index = state.messages.firstIndex(where: { $0.id == sequenceId }),
              state.messages[index].likeResult != nil,
              !likeResult.isEmpty else {
            return false
        }

        state.messages[index].likeResult?["like"] = likeResult
        return true
    }

    @discardableResult
    func handleEvalutionMessageSuccess(tempId: String) -> Bool {
        guard let index = state.messages.firstIndex(where: { $0.tempId == tempId }) else {
            return false
        }

        state.messages[index].status = 1
        return true
    }

    @discardableResult
    func readMessage(sequenceId: String? = nil) -> SalesmartlyPayload {
        markMessagesRead(upTo: sequenceId)
        return makeReadMessagePayload(sequenceId: sequenceId)
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 visibilitychange 监听，由 iOS 宿主同步前后台/可见性状态并在可见聊天页触发已读。
    @discardableResult
    public func setWindowVisible(_ isVisible: Bool) -> SalesmartlyPayload? {
        state.isWindowVisible = isVisible
        let readPayload = readOnVisible()
        sendVisibilityPollingRequestsIfReady()
        return readPayload
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 showSession/readMessage(newMessage.id)，仅在已入房且聊天窗口可视时回传单条已读。
    private func shouldReadVisibleReceivedMessage() -> Bool {
        state.isWindowVisible &&
            state.showWrapper &&
            state.currentView == .chat &&
            state.hasJoinRoom
    }

    func checkPolling(isPollingEnabled: Bool) -> Bool {
        config?.setting.mode != .demo && state.isWindowVisible && isPollingEnabled
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 winVisibe/showChat watcher，窗口可见状态变化后立即触发一次 unread/recent 补偿请求。
    @discardableResult
    func sendVisibilityPollingRequestsIfReady() -> SalesmartlyPollingSchedule? {
        guard !state.userToken.isEmpty,
              !state.localChatUserId.isEmpty else {
            return nil
        }
        return applyVisibilityPollingSchedule(
            isWindowVisible: state.isWindowVisible,
            showWrapper: state.showWrapper,
            currentView: state.currentView,
            loginToken: state.userToken,
            chatUserId: state.localChatUserId
        )
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 refreshMsgListInterval，按 polling_gap 计算客服消息轮询毫秒间隔且最小为 10 秒。
    func messagePollingIntervalMilliseconds() -> Int {
        let pollingGap = state.pollingGapSeconds > 10 ? state.pollingGapSeconds : 10
        return pollingGap * 1000
    }

    func shouldRefreshHistoryMessages(
        isNewUser: Bool,
        isPollingEnabled: Bool,
        lastRecentTimeMilliseconds: Int64?,
        nowMilliseconds: Int64
    ) -> Bool {
        if config?.setting.mode == .sandbox {
            return false
        }

        if isNewUser {
            return false
        }

        guard checkPolling(isPollingEnabled: isPollingEnabled) else {
            return false
        }

        guard let lastRecentTimeMilliseconds else {
            return true
        }

        return nowMilliseconds - lastRecentTimeMilliseconds > Self.historyMsgIntervalMilliseconds
    }

    @discardableResult
    func applyVisibilityPollingSchedule(
        isWindowVisible: Bool,
        showWrapper: Bool,
        currentView: ChatView,
        isPollingEnabled: Bool,
        loginToken: String,
        chatUserId: String
    ) -> SalesmartlyPollingSchedule {
        let oldWindowVisible = state.isWindowVisible
        let oldShowWrapper = state.showWrapper
        let oldCurrentView = state.currentView

        state.isWindowVisible = isWindowVisible
        state.showWrapper = showWrapper
        state.currentView = currentView

        let pollingAllowed = checkPolling(isPollingEnabled: isPollingEnabled)
        let startUnreadPolling = isWindowVisible && !showWrapper && pollingAllowed
        let startRecentPolling = isWindowVisible && showWrapper && pollingAllowed
        let stopUnreadPolling = !startUnreadPolling
        let stopRecentPolling = !startRecentPolling

        state.isUnreadPollingActive = startUnreadPolling
        state.isRecentPollingActive = startRecentPolling

        var requests: [SalesmartlyTransportRequest] = []
        if startUnreadPolling {
            requests.append(sendUnreadMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
        }
        if startRecentPolling {
            requests.append(sendRecentMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
            // 对齐 widget main:src/helper/useSocket.ts 的 getHistoryMsg，已有访客进入聊天时补拉 sender_type=0 的全量历史，避免仅 recent 客服消息导致访客消息缺失。
            if shouldRefreshHistoryMessages(
                isNewUser: state.isNewUser,
                isPollingEnabled: isPollingEnabled,
                lastRecentTimeMilliseconds: nil,
                nowMilliseconds: currentTimestamp()
            ) {
                requests.append(sendInitialHistoryMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
            }
        }

        if isWindowVisible,
           showWrapper,
           currentView == .chat,
           (oldWindowVisible != isWindowVisible || oldShowWrapper != showWrapper || oldCurrentView != currentView),
           clearUnreadOnEnterChat() != nil {
            requests.append(sendReadMessageTransportRequest())
        }

        return SalesmartlyPollingSchedule(
            startUnreadPolling: startUnreadPolling,
            stopUnreadPolling: stopUnreadPolling,
            startRecentPolling: startRecentPolling,
            stopRecentPolling: stopRecentPolling,
            requests: requests
        )
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 checkPolling，从 plugin/info 落到 state 的 is_polling 读取轮询开关。
    @discardableResult
    func applyVisibilityPollingSchedule(
        isWindowVisible: Bool,
        showWrapper: Bool,
        currentView: ChatView,
        loginToken: String,
        chatUserId: String
    ) -> SalesmartlyPollingSchedule {
        applyVisibilityPollingSchedule(
            isWindowVisible: isWindowVisible,
            showWrapper: showWrapper,
            currentView: currentView,
            isPollingEnabled: state.isPollingEnabled,
            loginToken: loginToken,
            chatUserId: chatUserId
        )
    }

    @discardableResult
    func readOnVisible() -> SalesmartlyPayload? {
        guard state.isWindowVisible,
              state.showWrapper,
              state.currentView == .chat,
              state.hasJoinRoom,
              state.unReadNum > 0 else {
            return nil
        }

        return readMessage()
    }

    @discardableResult
    func clearUnreadOnEnterChat() -> SalesmartlyPayload? {
        guard state.isWindowVisible,
              state.showWrapper,
              state.currentView == .chat else {
            return nil
        }

        let hasUnread = state.messages.contains { message in
            message.sendType != "1" && message.isRead == "0"
        }
        guard hasUnread || state.unReadNum > 0 else {
            markMessagesRead()
            return nil
        }

        if state.hasJoinRoom {
            return readMessage()
        }

        markMessagesRead()
        return nil
    }

    func applyUnreadMessageList(_ messages: [ChatMessage], currentChatUserId: String) {
        mergePollingMessageList(messages, currentChatUserId: currentChatUserId, marksReadWhenFirstMessageRead: false)
    }

    func applyRecentMessageList(_ messages: [ChatMessage], currentChatUserId: String) {
        mergePollingMessageList(messages, currentChatUserId: currentChatUserId, marksReadWhenFirstMessageRead: true)
    }

    @discardableResult
    func applyLocalConversationList(_ messages: [ChatMessage]) -> [ChatMessage] {
        var localConversation = messages.sorted { current, next in
            if current.createdTime == next.createdTime {
                if let currentId = Int64(current.id), let nextId = Int64(next.id) {
                    return currentId < nextId
                }
                return current.id < next.id
            }
            return current.createdTime < next.createdTime
        }

        localConversation = localConversation.filter { message in
            !shouldFilterLocalConversationMessage(message)
        }

        for index in localConversation.indices {
            if shouldMarkFailed(localConversation[index]) || checkInterruptedUploadItem(localConversation[index]) {
                localConversation[index].mid = "\(ChatMessage.failPrefix)\(currentTimestamp())"
            }

            if localConversation[index].msgType == "3" {
                if isInviteEvalutionMessage(localConversation[index].message) || isPromotionalCardMessage(localConversation[index].message) {
                    if localConversation[index].tempId == nil {
                        localConversation[index].tempId = ChatMessage.makeTempId()
                    }
                    if localConversation[index].status == nil {
                        localConversation[index].status = 0
                    }
                }

                if localConversation[index].likeResult == nil,
                   let likeResult = makeLikeResult(msgType: localConversation[index].msgType, message: localConversation[index].message) {
                    localConversation[index].likeResult = likeResult
                }
            }

            if localConversation[index].msgType == "11", isAIGuideMessage(localConversation[index].message) {
                if localConversation[index].tempId == nil {
                    localConversation[index].tempId = ChatMessage.makeTempId()
                }
                if localConversation[index].status == nil {
                    localConversation[index].status = 0
                }
            }
        }

        var ids: [String] = []
        state.messages = localConversation.filter { message in
            if ids.contains(message.id) {
                return false
            }
            ids.append(message.id)
            return true
        }
        updateUnreadNumFromMessages()
        saveLocalConversation()
        return state.messages
    }

    @discardableResult
    func applyTriggeredMessageList(_ messages: [ChatMessage]) -> Int {
        guard !state.hasJoinRoom else {
            return 0
        }

        var appliedCount = 0
        messages.forEach { message in
            _ = receiveMessage(
                sequenceId: message.id,
                senderType: message.sendType,
                msgType: message.msgType,
                message: message.message,
                sendTime: message.createdTime,
                chatUserId: message.chatUserId!,
                senderName: message.senderName,
                senderAvatar: message.senderAvatar,
                clientMessageId: message.cMId,
                readTime: message.isRead == "1" ? 1 : nil,
                quoteChat: message.quoteChat
            )
            appliedCount += 1
        }
        return appliedCount
    }

    @discardableResult
    func afterCollection(
        title: String,
        payload: SalesmartlyPayload,
        customFieldTitle: [String: String],
        currentFieldOptionKeys: [String],
        collectionType: String,
        chatUserId: String? = nil
    ) -> Bool {
        var infoData: SalesmartlyPayload = [:]

        currentFieldOptionKeys.forEach { key in
            guard let value = payload[key], shouldIncludeCollectionPayloadValue(value) else {
                return
            }
            if let list = value as? [String] {
                infoData[key] = list.filter { !$0.isEmpty }
            } else {
                infoData[key] = value
            }
        }

        guard !infoData.isEmpty else {
            closeCollection()
            return false
        }

        postMessage(
            msgType: "19",
            message: jsonString(from: [
                "source": collectionType,
                "title": title,
                "payload": infoData,
                "custom_field_title": customFieldTitle,
            ]),
            chatUserId: chatUserId
        )

        if let tempMessage, sendType == "send" {
            postMessage(
                msgType: tempMessage.msgType,
                message: tempMessage.message,
                tempId: tempMessage.tempId,
                type: tempMessage.type,
                sequenceId: tempMessage.sequenceId,
                status: tempMessage.status,
                mid: tempMessage.mid,
                clientExpandInfo: tempMessage.clientExpandInfo,
                chatUserId: tempMessage.chatUserId
            )
            self.tempMessage = nil
        }

        if let tempRetryMsg, sendType == "retry", let tempId = tempRetryMsg.tempId {
            retrySendMessage(tempId: tempId)
            self.tempRetryMsg = nil
        }

        if sendType == "sendPasteFile" {
            tempRetryMsg = nil
            sendPasteFile(delayMilliseconds: 300)
        }

        state.showCollection = false
        state.showOffline = false
        dispatch("onCollectionInfo", payload: collectionInfoPayload(payload: payload, collectionType: collectionType))
        return true
    }

    /// 对齐 Android `submitCollection`，将 overlay 表单值转换为 widget `msg_type=19` 留资消息并复用 `afterCollection` 发送。
    @discardableResult
    func submitCollection(type: String, values: SalesmartlyPayload, area: String = "") -> Bool {
        let config = collectionConfig(for: type)
        let submitState = config.collectionSubmitState(
            title: salesmartlyText("title.collectionSuccess", language: state.lang),
            type: type,
            values: values,
            area: area
        )
        return afterCollection(
            title: submitState.title,
            payload: submitState.payload,
            customFieldTitle: submitState.custom_field_title,
            currentFieldOptionKeys: config.activeFieldOptions().map(\.key),
            collectionType: type,
            chatUserId: state.localChatUserId.isEmpty ? nil : state.localChatUserId
        )
    }

    /// 对齐 Android `CollectionType` 分支，普通留资使用 collect_information，离线留资使用 offline_survey。
    func collectionConfig(for type: String) -> SalesmartlyCollectionConfig {
        if type == "offline" {
            return state.offlineSurvey
        }
        return state.collectInformation
    }

    /// 对齐 widget main:src/helper/realtime/mode.ts 与 Android `RealtimeMode.kt`，只在 sse_switch 为 "1" 时切到 HTTP event 实时模式。
    func realtimeMode(for sseSwitch: String) -> String {
        sseSwitch == "1" ? Self.realtimeModeSSEHTTP : Self.realtimeModeSocketIO
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 isSseHttpMode，sse_switch=1 或当前 realtimeMode 为 sse-http 都视为 HTTP event 实时模式。
    func isSseHTTPMode() -> Bool {
        state.sseSwitch == "1" || state.realtimeMode == Self.realtimeModeSSEHTTP
    }

    /// 对齐 widget main:src/helper/usePluginInfo.ts 写入 `realtime_mode` 的语义，并在 SSE HTTP 模式下关闭 socket 发送态。
    @discardableResult
    func applyRealtimeMode(sseSwitch: String) -> String {
        state.sseSwitch = sseSwitch
        state.realtimeMode = realtimeMode(for: sseSwitch)
        if state.realtimeMode == Self.realtimeModeSSEHTTP {
            state.hasJoinRoom = false
            state.sendMode = Self.sendModeHTTP
            joinRoomTransportConfirmed = false
        }
        return state.realtimeMode
    }

    func makeSocketSendMessagePayload(for message: ChatMessage) -> SalesmartlyPayload {
        var payload = commonSocketPayload()
        payload.merge([
            "msg_type": message.msgType,
            "message": message.message,
            "client_expand_info": message.clientExpandInfo,
        ]) { _, next in next }
        if let questionContext = makeQuestionContext(for: message) {
            payload["branches"] = questionContext.branches
            payload["question_id"] = questionContext.questionId
        }
        return payload
    }

    func makeHTTPSendMessagePayload(for message: ChatMessage, loginToken: String, chatUserId: String) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "ref": Self.httpRef,
            "msg_type": message.msgType,
            "message": message.message,
            "client_expand_info": clientExpandInfoJSONString(message.clientExpandInfo),
            "login_token": loginToken,
            "chat_user_id": chatUserId,
        ]
        if let questionContext = makeQuestionContext(for: message) {
            payload["branches"] = branchesJSONString(questionContext.branches)
            payload["question_id"] = questionContext.questionId
        }
        return payload
    }

    func makeSendMessagePayloadByMode(
        for message: ChatMessage,
        loginToken: String,
        chatUserId: String,
        type: String = "success"
    ) -> SalesmartlyPayload? {
        if config?.setting.mode == .demo {
            return nil
        }
        // 对齐 widget main:src/helper/useSocket.ts 的 sendMessageByHttpEvent，SSE HTTP 模式复用 commonSocketParams 作为 event.data。
        if isSseHTTPMode() {
            return makeSocketSendMessagePayload(for: message)
        }
        // 对齐 widget main:src/helper/useSocket.ts 的 sendMessageByMode：只有开启 support_retry 时，http 模式或 retry 操作才走 HTTP。
        if state.supportRetry && (state.sendMode == Self.sendModeHTTP || type == "retry") {
            return makeHTTPSendMessagePayload(for: message, loginToken: loginToken, chatUserId: chatUserId)
        }
        return makeSocketSendMessagePayload(for: message)
    }

    @discardableResult
    func connectSocketTransport(
        loginToken: String,
        chatUserId: String,
        pluginId: String,
        projectId: String
    ) -> SalesmartlyTransportRequest? {
        // 对齐 widget main:src/helper/useSocket.ts 的 prepareRealtimeConnection：sse_switch=1 时预取 Centrifugo token，并由 SSE EventSource 建连后 join-room。
        if isSseHTTPMode() {
            return connectSSETransport(loginToken: loginToken, chatUserId: chatUserId)
        }

        guard !state.hasJoinRoom, let config, !config.license.isEmpty else {
            if state.hasJoinRoom {
                state.sendMode = Self.sendModeWS
            }
            return nil
        }

        let connectionRequest = makeSocketConnectionRequest(
            loginToken: loginToken,
            chatUserId: chatUserId,
            pluginId: pluginId,
            projectId: projectId
        )
        transport?.removeSocketEventHandlers(Self.socketJoinLifecycleEventNames)
        transport?.connectSocket(connectionRequest)
        transport?.addSocketPongHandler()
        transport?.removeBufferedSocketEvent(Self.joinRoomEvent)
        guard let joinRequest = sendJoinRoomTransportRequest() else {
            return nil
        }
        transport?.addSocketEventHandlers(Self.socketJoinLifecycleEventNames)
        return joinRequest
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 getCentrifugoToken/start，SSE 模式先请求 token，onopen 后再 join-room。
    @discardableResult
    func connectSSETransport(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest? {
        state.hasJoinRoom = false
        state.sendMode = Self.sendModeHTTP
        joinRoomTransportConfirmed = false
        guard realtimeCentrifugoURL != nil else {
            return nil
        }

        return sendTransportRequest(
            makeCentrifugoTokenTransportRequest(
                loginToken: loginToken,
                chatUserId: chatUserId
            )
        )
    }

    @discardableResult
    func releaseSocketTransport() -> SalesmartlyTransportRequest? {
        if isSseHTTPMode() {
            let leaveRequest = state.hasJoinRoom ? sendLeaveRoomTransportRequest() : nil
            transport?.disconnectSSE()
            state.hasJoinRoom = false
            state.sendMode = Self.sendModeHTTP
            joinRoomTransportConfirmed = false
            return leaveRequest
        }

        guard state.hasJoinRoom else {
            transport?.disconnectSocket()
            transport?.removeSocketPongHandler()
            return nil
        }

        transport?.removeSocketEventHandlers([Self.receiveMessageEvent])
        guard let leaveRequest = sendLeaveRoomTransportRequest() else {
            transport?.disconnectSocket()
            transport?.removeSocketPongHandler()
            return nil
        }
        transport?.removeSocketEventHandlers(Self.socketReleaseLifecycleEventNames)
        transport?.disconnectSocket()
        transport?.removeSocketPongHandler()
        return leaveRequest
    }

    @discardableResult
    func handleSocketPong(
        nowMilliseconds: Int64? = nil,
        pingIntervalMilliseconds: Int64,
        pingTimeoutMilliseconds: Int64
    ) -> Bool {
        let now = nowMilliseconds ?? currentTimestamp()
        let previousPongTime = socketLastPongTime
        let elapsedTime = now - previousPongTime
        let validTime = pingIntervalMilliseconds + pingTimeoutMilliseconds + Self.socketPongExtraBufferMilliseconds
        let shouldReconnect = previousPongTime != 0 && elapsedTime >= validTime

        if shouldReconnect {
            transport?.reconnectSocketAfterHeartbeatTimeout(
                delayMilliseconds: Self.socketPongReconnectDelayMilliseconds
            )
        }

        socketLastPongTime = now
        return shouldReconnect
    }

    func setTransport(_ transport: SalesmartlyTransporting?) {
        setTransport(transport, installedBySDK: false)
    }

    /// 对齐 Android 初始化链路安装默认 transport；如果宿主已注入 transport，静态初始化不会覆盖。
    func installDefaultTransport(_ transport: SalesmartlyTransporting?) {
        setTransport(transport, installedBySDK: true)
    }

    func shouldInstallDefaultTransport() -> Bool {
        transport == nil || transportInstalledBySDK
    }

    private func setTransport(_ transport: SalesmartlyTransporting?, installedBySDK: Bool) {
        self.transport = transport
        self.transportInstalledBySDK = transport != nil && installedBySDK
        transport?.setResponseHandler { [weak self] response, request in
            self?.handleTransportCallback(response, for: request)
        }
        transport?.setSocketInboundEventHandler { [weak self] eventName, payload in
            self?.handleSocketInboundCallback(eventName: eventName, payload: payload)
        }
        transport?.setSSEInboundPayloadHandler { [weak self] payload in
            self?.handleSSEInboundCallback(payload: payload)
        }
    }

    /// 对齐 widget main:src/helper/useUpload.ts 的 uploadOSSByUrl 执行入口，脚本初始化后由 URLSession executor 承担真实 OSS 直传。
    func setUploadExecutor(_ uploadExecutor: SalesmartlyUploadExecuting?) {
        self.uploadExecutor = uploadExecutor
        uploadExecutorInstalledBySDK = false
    }

    /// 对齐 Android 初始化链路安装默认 upload executor；如果宿主已注入上传执行器则保持注入实现。
    func installDefaultUploadExecutor(_ uploadExecutor: SalesmartlyUploadExecuting?) {
        self.uploadExecutor = uploadExecutor
        uploadExecutorInstalledBySDK = uploadExecutor != nil
    }

    func shouldInstallDefaultUploadExecutor() -> Bool {
        uploadExecutor == nil || uploadExecutorInstalledBySDK
    }

    /// 对齐 widget main:src/constants/env.ts 的 CENTRIFUGO_HOST 注入点；project_*.js 初始化根据 install path 选择对应构建环境。
    func setRealtimeCentrifugoURL(_ url: URL?) {
        realtimeCentrifugoURL = url
    }

    @discardableResult
    func sendTransportRequest(_ request: SalesmartlyTransportRequest) -> SalesmartlyTransportRequest {
        transport?.send(request)
        return request
    }

    func handleTransportCallback(_ response: SalesmartlyPayload, for request: SalesmartlyTransportRequest) {
        let followUpRequests = handleTransportResponse(
            response,
            for: request,
            currentChatUserId: transportChatUserId(from: request)
        )
        followUpRequests.forEach { sendTransportRequest($0) }
    }

    func handleSocketInboundCallback(eventName: String, payload: SalesmartlyPayload) {
        let followUpRequests = handleSocketInboundEvent(eventName: eventName, payload: payload)
        followUpRequests.forEach { sendTransportRequest($0) }
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 onMessage，SSE 下行 payload 进入同一 receive-message/notice reducer。
    func handleSSEInboundCallback(payload: SalesmartlyPayload) {
        let followUpRequests = handleSseRealtimePayload(payload)
        followUpRequests.forEach { sendTransportRequest($0) }
    }

    @discardableResult
    func sendJoinRoomTransportRequest() -> SalesmartlyTransportRequest? {
        guard let request = makeJoinRoomTransportRequest() else {
            return nil
        }

        return sendTransportRequest(request)
    }

    @discardableResult
    func sendLeaveRoomTransportRequest() -> SalesmartlyTransportRequest? {
        guard let request = makeLeaveRoomTransportRequest() else {
            return nil
        }

        return sendTransportRequest(request)
    }

    @discardableResult
    func sendOpenFrameTransportRequest() -> SalesmartlyTransportRequest? {
        guard let request = makeOpenFrameTransportRequest() else {
            return nil
        }

        return sendTransportRequest(request)
    }

    @discardableResult
    func sendPendingSocketTransportRequests() -> [SalesmartlyTransportRequest] {
        let requests = flushPendingSocketTransportRequests()
        requests.forEach { sendTransportRequest($0) }
        return requests
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 sendMessageByMode 与 main:src/helper/useSendMessage.ts 的 sendMessageMap，按会话顺序发送当前待发送消息。
    @discardableResult
    func sendPendingMessageTransportRequests(
        loginToken: String,
        chatUserId: String,
        type: String = "success"
    ) -> [SalesmartlyTransportRequest] {
        state.messages.compactMap { message in
            guard let clientMessageId = message.cMId, sendMessageMap[clientMessageId] != nil else {
                return nil
            }
            return sendMessageTransportRequest(
                for: message,
                loginToken: loginToken,
                chatUserId: chatUserId,
                type: type
            )
        }
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 postMessage -> sendMessageByMode，文本入队后在 token 与连接状态满足时立即发送。
    @discardableResult
    func sendTextMessageTransportRequestIfReady(for message: ChatMessage) -> SalesmartlyTransportRequest? {
        guard !state.userToken.isEmpty,
              !state.localChatUserId.isEmpty,
              state.hasJoinRoom || state.sendMode == Self.sendModeHTTP else {
            return nil
        }

        return sendMessageTransportRequest(
            for: message,
            loginToken: state.userToken,
            chatUserId: state.localChatUserId
        )
    }

    @discardableResult
    func sendMessageTransportRequest(
        for message: ChatMessage,
        loginToken: String,
        chatUserId: String,
        type: String = "success"
    ) -> SalesmartlyTransportRequest? {
        guard let request = makeSendMessageTransportRequest(
            for: message,
            loginToken: loginToken,
            chatUserId: chatUserId,
            type: type
        ) else {
            return nil
        }

        return sendTransportRequest(request)
    }

    /// 对齐 widget main:src/api/plugin.ts 的 getPluginInfo，脚本入口解析 license 后立即拉取插件配置。
    @discardableResult
    func sendPluginInfoTransportRequest() -> SalesmartlyTransportRequest {
        sendTransportRequest(makePluginInfoTransportRequest())
    }

    @discardableResult
    func sendReadMessageTransportRequest(sequenceId: String? = nil) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeReadMessageTransportRequest(sequenceId: sequenceId))
    }

    @discardableResult
    func sendHumanServiceTransportRequest() -> SalesmartlyTransportRequest {
        sendTransportRequest(makeHumanServiceTransportRequest())
    }

    @discardableResult
    func sendStreamStopTransportRequest(mid: String, chatUserId: String) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeStreamStopTransportRequest(mid: mid, chatUserId: chatUserId))
    }

    @discardableResult
    func sendUnreadMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeUnreadMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
    }

    @discardableResult
    func sendRecentMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeRecentMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
    }

    @discardableResult
    func sendHistoryMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeHistoryMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
    }

    @discardableResult
    func sendInitialHistoryMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeInitialHistoryMsgListTransportRequest(loginToken: loginToken, chatUserId: chatUserId))
    }

    @discardableResult
    func sendQueueStatusTransportRequest(chatUserId: String) -> SalesmartlyTransportRequest {
        sendTransportRequest(makeQueueStatusTransportRequest(chatUserId: chatUserId))
    }

    /// 对齐 Android `SalesmartlyRuntime.resolveDownloadFileUrl`：文件卡片下载前先请求 `swap-object-v2` 刷新临时签名 URL。
    @discardableResult
    func resolveDownloadFileURL(
        reportId: String,
        fileURL: String,
        onResolved: @escaping (String) -> Void,
        onFinished: @escaping () -> Void
    ) -> SalesmartlyTransportRequest {
        let request = makeSwapObjectTransportRequest(reportId: reportId, fileURL: fileURL)
        pendingDownloadResolutions[downloadResolutionKey(from: request)] = PendingDownloadResolution(
            reportId: reportId,
            onResolved: onResolved,
            onFinished: onFinished
        )
        return sendTransportRequest(request)
    }

    @discardableResult
    func sendTriggerUserTransportRequest(
        token: String,
        chatUserId: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        sendTransportRequest(
            makeTriggerUserTransportRequest(
                token: token,
                chatUserId: chatUserId,
                payload: payload
            )
        )
    }

    @discardableResult
    func sendTriggerTransportRequest(
        token: String,
        chatUserId: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        sendTransportRequest(
            makeTriggerTransportRequest(
                token: token,
                chatUserId: chatUserId,
                payload: payload
            )
        )
    }

    @discardableResult
    func sendUpdateUserInfoTransportRequests(
        token: String,
        userName: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        language: String? = nil,
        data: String? = nil,
        company: String? = nil,
        chatUserId: String,
        source: String? = nil
    ) -> (updateUser: SalesmartlyTransportRequest, trigger: SalesmartlyTransportRequest) {
        let requests = makeUpdateUserInfoTransportRequests(
            token: token,
            userName: userName,
            phone: phone,
            email: email,
            language: language,
            data: data,
            company: company,
            chatUserId: chatUserId,
            source: source
        )
        sendTransportRequest(requests.updateUser)
        sendTransportRequest(requests.trigger)
        return requests
    }

    func makeSocketConnectionRequest(
        loginToken: String,
        chatUserId: String,
        pluginId: String,
        projectId: String
    ) -> SalesmartlySocketConnectionRequest {
        SalesmartlySocketConnectionRequest(
            query: [
                "ref": Self.httpRef,
                "login_token": loginToken,
                "chat_user_id": chatUserId,
                "plugin_id": pluginId,
                "_xma_": projectId,
            ],
            transports: [Self.socketTransportWebsocket],
            reconnectionAttempts: Self.socketReconnectionAttempts
        )
    }

    /// 对齐 widget main:src/api/plugin.ts 的 getPluginInfo，请求路径为 widget 域名下的 plugin/info 且使用 external-sign。
    func makePluginInfoTransportRequest() -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.pluginInfoHTTPPath,
            method: .get,
            externalSign: true
        )
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 sendRealtimeEvent，SSE HTTP 模式下把实时事件转为 `/chat/chat-msg/event`，否则保持 Socket.IO event。
    func makeRealtimeEventTransportRequest(
        eventName: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        if isSseHTTPMode() {
            return makeChatMsgEventTransportRequest(
                eventName: eventName,
                data: payload,
                loginToken: state.userToken,
                chatUserId: state.localChatUserId
            )
        }

        return makeSocketEventTransportRequest(eventName: eventName, payload: payload)
    }

    @discardableResult
    func makeJoinRoomTransportRequest() -> SalesmartlyTransportRequest? {
        guard let payload = joinRoom() else {
            return nil
        }
        if isSseHTTPMode() {
            return makeRealtimeEventTransportRequest(
                eventName: Self.joinRoomEvent,
                payload: makeRoomEventPayload(from: payload)
            )
        }
        return makeSocketEventTransportRequest(eventName: Self.joinRoomEvent, payload: payload)
    }

    @discardableResult
    func makeLeaveRoomTransportRequest() -> SalesmartlyTransportRequest? {
        guard let payload = leaveRoom() else {
            return nil
        }
        if isSseHTTPMode() {
            return makeRealtimeEventTransportRequest(
                eventName: Self.leaveRoomEvent,
                payload: makeRoomEventPayload(from: payload)
            )
        }
        return makeSocketEventTransportRequest(eventName: Self.leaveRoomEvent, payload: payload)
    }

    @discardableResult
    func makeOpenFrameTransportRequest() -> SalesmartlyTransportRequest? {
        guard let payload = openFrame() else {
            return nil
        }
        return makeRealtimeEventTransportRequest(eventName: Self.openFrameEvent, payload: payload)
    }

    func flushPendingSocketTransportRequests() -> [SalesmartlyTransportRequest] {
        let events = state.pendingSocketEvents
        state.pendingSocketEvents = []
        return events.map { eventName in
            makeRealtimeEventTransportRequest(eventName: eventName, payload: commonSocketPayload())
        }
    }

    func makeSendMessageTransportRequest(
        for message: ChatMessage,
        loginToken: String,
        chatUserId: String,
        type: String = "success"
    ) -> SalesmartlyTransportRequest? {
        guard let payload = makeSendMessagePayloadByMode(
            for: message,
            loginToken: loginToken,
            chatUserId: chatUserId,
            type: type
        ) else {
            return nil
        }

        if payload["ref"] as? String == Self.httpRef {
            return makeHTTPTransportRequest(
                path: Self.sendMessageHTTPPath,
                method: .post,
                payload: payload,
                externalSign: true
            )
        }

        if isSseHTTPMode() {
            return makeChatMsgEventTransportRequest(
                eventName: Self.sendMessageEvent,
                data: payload,
                loginToken: loginToken,
                chatUserId: chatUserId
            )
        }

        return makeSocketEventTransportRequest(eventName: Self.sendMessageEvent, payload: payload)
    }

    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sendChatMsgEvent 与 Android `ChatMsgEventRequestFactory`，将实时事件包成 JSON HTTP event。
    func makeChatMsgEventTransportRequest(
        eventName: String,
        data: SalesmartlyPayload,
        loginToken: String,
        chatUserId: String
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.chatMsgEventHTTPPath,
            method: .post,
            payload: [
                "login_token": loginToken,
                "chat_user_id": chatUserId,
                "event": eventName,
                "data": jsonString(from: data),
            ],
            externalSign: true,
            bodyEncoding: .json
        )
    }

    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 getCentrifugoToken，SSE 预检 token 使用 GET query 和 external-sign。
    func makeCentrifugoTokenTransportRequest(
        loginToken: String,
        chatUserId: String
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.centrifugoTokenHTTPPath,
            method: .get,
            query: realtimeAuthQuery(loginToken: loginToken, chatUserId: chatUserId),
            externalSign: true
        )
    }

    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sseConnect，EventSource onopen 后用 JSON body 通知后端连接已建立。
    func makeSseConnectTransportRequest(
        loginToken: String,
        chatUserId: String
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.sseConnectHTTPPath,
            method: .post,
            payload: realtimeAuthPayload(loginToken: loginToken, chatUserId: chatUserId),
            externalSign: true,
            bodyEncoding: .json
        )
    }

    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sseDisconnect，释放 SSE 实时连接时用 JSON body 通知后端断开。
    func makeSseDisconnectTransportRequest(
        loginToken: String,
        chatUserId: String
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.sseDisconnectHTTPPath,
            method: .post,
            payload: realtimeAuthPayload(loginToken: loginToken, chatUserId: chatUserId),
            externalSign: true,
            bodyEncoding: .json
        )
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 Centrifugo `uni_sse` 地址，`cf_connect` 必须包含 token、name 和 channels 生成的 subs。
    func makeCentrifugoEventSourceURL(
        baseURL: URL,
        token: String,
        channels: [String]
    ) -> URL? {
        let subs = channels
            .map { #""\#(jsonStringLiteral($0))":{}"# }
            .joined(separator: ",")
        let connectData = #"{"token":"\#(jsonStringLiteral(token))","name":"js","subs":{\#(subs)}}"#
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
        guard let encodedConnectData = connectData.addingPercentEncoding(withAllowedCharacters: allowed) else {
            return nil
        }
        let normalizedBaseURL = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(normalizedBaseURL)/connection/uni_sse?cf_connect=\(encodedConnectData)")
    }

    func makeReadMessageTransportRequest(sequenceId: String? = nil) -> SalesmartlyTransportRequest {
        makeRealtimeEventTransportRequest(
            eventName: Self.readMessageEvent,
            payload: makeReadMessagePayload(sequenceId: sequenceId)
        )
    }

    func makeHumanServiceTransportRequest() -> SalesmartlyTransportRequest {
        makeRealtimeEventTransportRequest(
            eventName: Self.humanServiceEvent,
            payload: makeHumanServicePayload()
        )
    }

    func makeStreamStopTransportRequest(mid: String, chatUserId: String) -> SalesmartlyTransportRequest {
        makeRealtimeEventTransportRequest(
            eventName: Self.streamStopEvent,
            payload: makeStreamStopPayload(mid: mid, chatUserId: chatUserId)
        )
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 evalutionMessage，SSE HTTP 模式下改用 sendRealtimeEvent('evalution', params)。
    func makeEvalutionTransportRequest(payload: SalesmartlyPayload) -> SalesmartlyTransportRequest {
        makeRealtimeEventTransportRequest(eventName: Self.evalutionEvent, payload: payload)
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 likeMessage，SSE HTTP 模式下改用 sendRealtimeEvent('like', params)。
    func makeLikeTransportRequest(payload: SalesmartlyPayload) -> SalesmartlyTransportRequest {
        makeRealtimeEventTransportRequest(eventName: Self.likeEvent, payload: payload)
    }

    func makeUnreadMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.unreadMsgListHTTPPath,
            method: .get,
            query: transportQuery(from: makeUnreadMsgListPayload(loginToken: loginToken, chatUserId: chatUserId)),
            externalSign: true
        )
    }

    func makeRecentMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.recentMsgListHTTPPath,
            method: .get,
            query: transportQuery(from: makeRecentMsgListPayload(loginToken: loginToken, chatUserId: chatUserId)),
            externalSign: true
        )
    }

    func makeHistoryMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.recentMsgListHTTPPath,
            method: .get,
            query: transportQuery(from: makeHistoryMsgListPayload(loginToken: loginToken, chatUserId: chatUserId)),
            externalSign: true
        )
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 getHistoryMsg；iOS 进入聊天的首次历史补偿不传 sequence_id，用于恢复本地缓存曾缺失的访客消息。
    func makeInitialHistoryMsgListTransportRequest(loginToken: String, chatUserId: String) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.recentMsgListHTTPPath,
            method: .get,
            query: transportQuery(from: makeInitialHistoryMsgListPayload(loginToken: loginToken, chatUserId: chatUserId)),
            externalSign: true
        )
    }

    func makeQueueStatusTransportRequest(chatUserId: String) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.queueStatusHTTPPath,
            method: .get,
            query: transportQuery(from: makeQueueStatusPayload(chatUserId: chatUserId)),
            externalSign: true
        )
    }

    /// 对齐 widget main:src/helper/useSwapObject.ts 的 swapObjectV2，请求 JSON body 并用 object 生成 query plugin_sign。
    func makeSwapObjectTransportRequest(reportId: String, fileURL: String) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.swapObjectHTTPPath,
            method: .post,
            payload: makeSwapObjectPayload(tempId: reportId, fileURL: fileURL),
            externalSign: false,
            bodyEncoding: .json
        )
    }

    /// 对齐 widget main:src/helper/useUpload.ts 的 swapObjectV2 上传收尾，用直传 URL 请求后端换签并等待对应响应。
    @discardableResult
    func sendUploadSwapObjectTransportRequest(
        tempId: String,
        fileURL: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        let request = makeHTTPTransportRequest(
            path: Self.swapObjectHTTPPath,
            method: .post,
            payload: payload,
            externalSign: false,
            bodyEncoding: .json
        )
        pendingUploadSwapObjects[downloadResolutionKey(from: request)] = PendingUploadSwapObject(
            tempId: tempId,
            fileURL: fileURL
        )
        return sendTransportRequest(request)
    }

    /// 对齐 widget main:src/api/chat/msgUser.ts 的 createUser，请求 chat/msg-user/create-user 创建或获取访客 token。
    func makeCreateUserTransportRequest(
        sourceURL: String,
        userAgent: String,
        navigatorLanguage: String,
        beforeSourceURL: String,
        guestUserId: String
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.createUserHTTPPath,
            method: .post,
            payload: makeCreateUserPayload(
                sourceURL: sourceURL,
                userAgent: userAgent,
                navigatorLanguage: navigatorLanguage,
                beforeSourceURL: beforeSourceURL,
                guestUserId: guestUserId
            )
        )
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 getToken，按 guest 本地 token、tokenPad 已完成缓存、同参进行中请求和 createUser 请求四条路径决策。
    func prepareCreateUserTokenRequest(
        sourceURL: String,
        userAgent: String,
        navigatorLanguage: String,
        beforeSourceURL: String,
        guestUserId: String,
        nowMilliseconds: Int64
    ) -> SalesmartlyCreateUserTokenDecision {
        let knownUserId = state.loginInfo?.userId ?? ""
        if knownUserId.isEmpty, !state.userToken.isEmpty {
            return SalesmartlyCreateUserTokenDecision(
                cachedToken: state.userToken,
                request: nil,
                delayMilliseconds: 0
            )
        }

        let request = makeCreateUserTransportRequest(
            sourceURL: sourceURL,
            userAgent: userAgent,
            navigatorLanguage: navigatorLanguage,
            beforeSourceURL: beforeSourceURL,
            guestUserId: guestUserId
        )
        let params = request.payloadJSONString()

        if params == state.createUserTokenPadParams,
           !state.createUserTokenPadToken.isEmpty,
           !state.userToken.isEmpty {
            return SalesmartlyCreateUserTokenDecision(
                cachedToken: state.createUserTokenPadToken,
                request: nil,
                delayMilliseconds: 0
            )
        }

        if state.isCreateUserTokenRequestActive, params == state.createUserTokenPadParams {
            return SalesmartlyCreateUserTokenDecision(
                cachedToken: nil,
                request: nil,
                delayMilliseconds: 0
            )
        }

        state.createUserTokenPadParams = params
        state.createUserTokenRequestDateMilliseconds = nowMilliseconds
        state.isCreateUserTokenRequestActive = true

        return SalesmartlyCreateUserTokenDecision(
            cachedToken: nil,
            request: request,
            delayMilliseconds: makeCreateUserRequestDelay(nowMilliseconds: nowMilliseconds)
        )
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 createUser(params) 触发点，将需要请求的决策交给注入 transport。
    @discardableResult
    func sendCreateUserTokenRequest(
        sourceURL: String,
        userAgent: String,
        navigatorLanguage: String,
        beforeSourceURL: String,
        guestUserId: String,
        nowMilliseconds: Int64? = nil
    ) -> SalesmartlyCreateUserTokenDecision {
        let decision = prepareCreateUserTokenRequest(
            sourceURL: sourceURL,
            userAgent: userAgent,
            navigatorLanguage: navigatorLanguage,
            beforeSourceURL: beforeSourceURL,
            guestUserId: guestUserId,
            nowMilliseconds: nowMilliseconds ?? currentTimestamp()
        )
        if let request = decision.request {
            sendTransportRequest(request)
        }
        return decision
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 createUser.then，落盘 token、chat_user_id、is_new_user 与 tokenPad 完成态。
    @discardableResult
    func handleCreateUserTransportResponse(
        _ response: SalesmartlyPayload,
        nowMilliseconds: Int64? = nil
    ) -> String {
        guard let data = response["data"] as? SalesmartlyPayload else {
            return ""
        }
        // 对齐 Web `chat/msg-user/create-user` 真实响应：线上接口返回 data.token，部分测试夹具保留 data.data.token。
        let responseData = (data["data"] as? SalesmartlyPayload) ?? data
        guard let token = stringValue(responseData["token"]),
              let chatUserId = stringValue(responseData["chat_user_id"]),
              let isNewUser = stringValue(responseData["is_new_user"]) else {
            return ""
        }

        let now = nowMilliseconds ?? currentTimestamp()
        state.userToken = token
        state.createUserTokenPadToken = token
        state.isCreateUserTokenRequestActive = false
        state.createUserTokenSavedDateMilliseconds = now
        state.localChatUserId = chatUserId
        state.isNewUser = isNewUser == "1"

        if (state.loginInfo?.userId ?? "").isEmpty {
            state.createUserLastTimeMilliseconds = now
        }
        saveLocalToken(token, key: state.tokenKey)
        saveCreateUserLocalState(chatUserId: chatUserId, isNewUser: state.isNewUser, nowMilliseconds: now)
        connectCreatedUserTokenAfterCreateUser()

        return token
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 createUser.catch，失败后清空 tokenPad 请求态并返回空 token。
    @discardableResult
    func handleCreateUserTransportFailure() -> String {
        state.isCreateUserTokenRequestActive = false
        state.createUserTokenPadParams = ""
        state.createUserTokenPadToken = ""
        return ""
    }

    func makeTriggerUserTransportRequest(
        token: String,
        chatUserId: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.triggerUserHTTPPath,
            method: .post,
            query: [
                "login_token": token,
                "chat_user_id": chatUserId,
            ],
            payload: payload
        )
    }

    func makeTriggerTransportRequest(
        token: String,
        chatUserId: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        makeHTTPTransportRequest(
            path: Self.triggerHTTPPath,
            method: .post,
            query: [
                "login_token": token,
                "chat_user_id": chatUserId,
            ],
            payload: payload
        )
    }

    func makeUpdateUserInfoTransportRequests(
        token: String,
        userName: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        language: String? = nil,
        data: String? = nil,
        company: String? = nil,
        chatUserId: String,
        source: String? = nil
    ) -> (updateUser: SalesmartlyTransportRequest, trigger: SalesmartlyTransportRequest) {
        let payloads = makeUpdateUserInfoPayloads(
            token: token,
            userName: userName,
            phone: phone,
            email: email,
            language: language,
            data: data,
            company: company,
            chatUserId: chatUserId,
            source: source
        )
        return (
            makeHTTPTransportRequest(
                path: Self.updateUserHTTPPath,
                method: .post,
                payload: payloads.updateUser
            ),
            makeTriggerTransportRequest(
                token: token,
                chatUserId: chatUserId,
                payload: payloads.trigger
            )
        )
    }

    func makeTriggerUserPayload(
        newUserKey: String,
        chatUserId: String,
        isNewUser: Bool,
        isInvalidRefresh: Bool,
        hasLocalRecord: Bool,
        isSandbox: Bool,
        data: String? = nil
    ) -> SalesmartlyPayload? {
        if !isInvalidRefresh,
           (hasLocalRecord || triggeredNewUserKeys.contains(newUserKey)),
           isNewUser,
           !isSandbox {
            return nil
        }

        if !isSandbox,
           (chatUserId.isEmpty || triggeringChatUserId == chatUserId) {
            return nil
        }

        var payload: SalesmartlyPayload = [
            "is_new_user": isNewUser ? "1" : "0",
        ]
        if let flowId = config?.setting.flowId, !flowId.isEmpty {
            payload["flow_id"] = flowId
        }
        if let data {
            payload["data"] = data
        }

        triggeringChatUserId = chatUserId
        triggeredNewUserKeys.insert(newUserKey)
        return payload
    }

    func makeTriggerUrlPayload(
        sourceURL: String,
        uniqueId: String,
        scrollNum: Int,
        delayNum: Int
    ) -> SalesmartlyPayload {
        let paramData: SalesmartlyPayload = [
            "url": sourceURL,
            "unique_id": uniqueId,
            "scroll_num": scrollNum,
            "delay_num": delayNum,
        ]
        var payload: SalesmartlyPayload = [
            "trigger_type": "11",
            "data": jsonString(from: paramData),
        ]
        if let flowId = config?.setting.flowId, !flowId.isEmpty {
            payload["flow_id"] = flowId
        }
        return payload
    }

    func makeUpdateUserInfoPayloads(
        token: String,
        userName: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        language: String? = nil,
        data: String? = nil,
        company: String? = nil,
        chatUserId: String,
        source: String? = nil
    ) -> (updateUser: SalesmartlyPayload, trigger: SalesmartlyPayload) {
        var updateUserPayload: SalesmartlyPayload = [
            "token": token,
            "chat_user_id": chatUserId,
        ]
        var triggerData: SalesmartlyPayload = [
            "chat_user_id": chatUserId,
        ]

        appendUpdateUserInfoFields(
            to: &updateUserPayload,
            userName: userName,
            phone: phone,
            email: email,
            language: language,
            data: data,
            company: company
        )
        appendUpdateUserInfoFields(
            to: &triggerData,
            userName: userName,
            phone: phone,
            email: email,
            language: language,
            data: data,
            company: company
        )

        var triggerPayload: SalesmartlyPayload = [
            "trigger_type": "16",
            "data": jsonString(from: triggerData),
        ]
        if let source {
            triggerPayload["source"] = source
        }
        if let flowId = config?.setting.flowId, !flowId.isEmpty {
            triggerPayload["flow_id"] = flowId
        }

        return (updateUserPayload, triggerPayload)
    }

    func makeUploadOSSConfigPayload(pluginId: String, env: String, msgType: String) -> SalesmartlyPayload {
        [
            "module": Self.uploadModule,
            "module_path": "plugin/\(pluginId)/\(msgType)",
            "plugin_id": pluginId,
            "env": env,
            "platform": Self.uploadPlatform,
            "btype": Self.uploadBType,
        ]
    }

    @discardableResult
    func saveUploadOSSConfig(
        module: String,
        modulePath: String,
        stsConfig: SalesmartlyOSSSTSConfig,
        path: String,
        dewsCode: String,
        nowMilliseconds: Int64
    ) -> SalesmartlyOSSConfigCache {
        let cache = SalesmartlyOSSConfigCache(
            stsConfig: stsConfig,
            path: path,
            effectiveTime: nowMilliseconds + Self.uploadConfigEffectiveMilliseconds,
            dews: Self.dewsMap[dewsCode] ?? "default"
        )
        uploadOSSConfigCacheMap[uploadOSSConfigCacheKey(module: module, modulePath: modulePath)] = cache
        return cache
    }

    func cachedUploadOSSConfig(module: String, modulePath: String, nowMilliseconds: Int64) -> SalesmartlyOSSConfigCache? {
        let cache = uploadOSSConfigCacheMap[uploadOSSConfigCacheKey(module: module, modulePath: modulePath)]
        guard let cache,
              cache.effectiveTime > nowMilliseconds,
              milliseconds(fromISO8601: cache.stsConfig.expiration) > nowMilliseconds else {
            return nil
        }
        return cache
    }

    func makeUploadOSSDirectForm(
        config: SalesmartlyOSSConfigCache,
        fileName: String,
        replaceName: String = "",
        nowMilliseconds: Int64,
        timeoutMilliseconds: Int = 120_000
    ) -> SalesmartlyOSSDirectUploadForm {
        let cleanedFileName = replaceName.isEmpty ? fileName : replaceName
        let path = "\(config.path)\(nowMilliseconds)"
        let policy = uploadPolicyBase64(expiration: config.stsConfig.expiration)
        let encodedFileName = cleanedFileName.addingPercentEncoding(withAllowedCharacters: Self.encodeURIComponentAllowedCharacters)!
        let objectURL = replaceUploadAcceleratedDomain("\(Self.salesmartlyOssHost)/\(path)/\(encodedFileName)")

        return SalesmartlyOSSDirectUploadForm(
            url: Self.salesmartlyOssHost,
            headers: [
                "Content-Type": "multipart/form-data",
            ],
            fields: [
                "signature": hmacSHA1Base64(value: policy, key: config.stsConfig.accessKeySecret),
                "ossAccessKeyId": config.stsConfig.accessKeyId,
                "policy": policy,
                "x-oss-security-token": config.stsConfig.securityToken,
                "x-oss-object-acl": config.dews,
                "key": "\(path)/\(cleanedFileName)",
            ],
            fileFieldName: "file",
            objectURL: objectURL,
            timeoutMilliseconds: timeoutMilliseconds
        )
    }

    func makeUploadMsgType(fileName: String, requestedMsgType: String? = nil) -> String {
        if isAllowImage(fileName: fileName) {
            return requestedMsgType ?? "2"
        }
        if isAllowVideo(fileName: fileName) {
            return "6"
        }
        return "4"
    }

    func makeUploadCompressionPlan(for file: SalesmartlyUploadFile) -> SalesmartlyUploadCompressionPlan {
        let shouldCompress = isAllowImage(fileName: file.name) && file.size >= Self.uploadCompressionMinSize
        return SalesmartlyUploadCompressionPlan(
            shouldCompress: shouldCompress,
            quality: Self.uploadCompressionQuality,
            fallbackToOriginalOnFailure: shouldCompress
        )
    }

    func makeUploadExecutionRequest(
        tempId: String,
        pluginId: String,
        env: String,
        random: Int,
        nowMilliseconds: Int64
    ) -> SalesmartlyUploadExecutionRequest? {
        guard let task = uploadTaskMap[tempId] else {
            return nil
        }

        return SalesmartlyUploadExecutionRequest(
            file: task.file,
            fileData: task.fileData,
            tempId: tempId,
            type: task.type,
            clientExpandInfo: task.clientExpandInfo,
            compressionPlan: makeUploadCompressionPlan(for: task.file),
            replaceName: makeUploadReplaceName(
                fileName: task.file.name,
                msgType: task.type,
                pluginId: pluginId,
                random: random,
                nowMilliseconds: nowMilliseconds
            ),
            uploadConfigPayload: [
                "module": Self.uploadModule,
                "module_path": "plugin/\(pluginId)/\(task.type)",
                "plugin_id": pluginId,
                "env": env,
                "platform": Self.uploadPlatform,
                "btype": Self.uploadBType,
            ],
            uploadTimeoutMilliseconds: uploadTimeoutMilliseconds()
        )
    }

    func shouldLogCompressedUpload(originalSize: Int, compressedSize: Int) -> Bool {
        Double(compressedSize) < Double(originalSize) / 2
    }

    func makeUploadReplaceName(
        fileName: String,
        msgType: String,
        pluginId: String,
        random: Int,
        nowMilliseconds: Int64
    ) -> String {
        guard ["2", "6"].contains(msgType) else {
            return ""
        }

        let digest = Insecure.MD5.hash(data: Data("\(pluginId)\(random)\(nowMilliseconds)".utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "\(digest).\(fileExtension(from: fileName))"
    }

    func uploadTimeoutMilliseconds() -> Int {
        Self.uploadTimeoutMillisecondsValue
    }

    func normalizedUploadFileURL(_ fileURL: String) -> String {
        fileURL
            .replacingOccurrences(of: "mix-ads.oss-accelerate.aliyuncs.com", with: "assets.salesmartly.com")
            .replacingOccurrences(of: "http://", with: "https://")
    }

    func resizeOssImgUrl(_ url: String, height: Int = 0, width: Int = 280) -> String {
        if url.contains("x-oss") || url.hasPrefix("blob") {
            return url
        }

        if !Self.ossImageResizeFormats.contains(imageExtension(from: url)) {
            return replaceUploadAcceleratedDomain(url)
        }

        var nextURL = url.replacingOccurrences(
            of: "salesmartly.oss-accelerate.aliyuncs.com",
            with: "static.salesmartly.com"
        )
        var xossResize = "x-oss-process=image/resize"
        if height != 0 {
            xossResize = "\(xossResize),h_\(height)"
        }
        if width != 0 {
            xossResize = "\(xossResize),w_\(width)"
        }
        nextURL = replaceUploadAcceleratedDomain(nextURL)
        let separator = nextURL.contains("?") ? "&" : "?"
        return "\(nextURL)\(separator)\(xossResize)"
    }

    func resizeOssVideoUrl(_ url: String) -> String {
        url.replacingOccurrences(
            of: "salesmartly.oss-accelerate.aliyuncs.com",
            with: "static.salesmartly.com"
        )
    }

    func makeSwapObjectPayload(tempId: String, fileURL: String) -> SalesmartlyPayload {
        let normalizedURL = normalizedUploadFileURL(fileURL)
        let url = URL(string: normalizedURL)!
        let domain = url.host ?? ""
        let object = String(url.path.dropFirst())
        let bucket = bucketName(for: domain)
        let json = swapObjectJSONString(tempId: tempId, bucket: bucket, object: object)
        return [
            "object": encodeSalesmartlyBase64(json),
        ]
    }

    /// 对齐 Android `refreshDownloadFileUrl` 与 Web `useSwapObject.ts`：下载使用返回 item 的 `url`，并将 http 链接转为 https。
    func resolvedDownloadFileURL(reportId: String, response: SalesmartlyPayload) -> String {
        let data = response["data"] as? SalesmartlyPayload
        guard let result = stringValue(data?["result"]) else {
            return ""
        }
        let swapObjectList = decodeSwapObjectResult(result)
        let swapObjectItem = swapObjectList.first { item in
            item["id"] as? String == reportId
        }
        guard let resolvedURL = stringValue(swapObjectItem?["url"]) else {
            return ""
        }
        return resolvedURL.replacingOccurrences(of: "http://", with: "https://")
    }

    /// 对齐 Android `LocalFileDownloadResolver` 的完成回调：swap-object 响应回来后通知 UI 继续系统下载并关闭 loading。
    @discardableResult
    func handleDownloadSwapObjectTransportResponse(
        _ response: SalesmartlyPayload,
        request: SalesmartlyTransportRequest
    ) -> Bool {
        let key = downloadResolutionKey(from: request)
        guard let pending = pendingDownloadResolutions.removeValue(forKey: key) else {
            return false
        }
        let resolvedURL = resolvedDownloadFileURL(reportId: pending.reportId, response: response)
        if !resolvedURL.isEmpty {
            pending.onResolved(resolvedURL)
        }
        pending.onFinished()
        return !resolvedURL.isEmpty
    }

    /// 对齐 widget main:src/helper/useUpload.ts 的 handleUploadSuccess，swap-object 响应命中上传 pending 后替换本地占位消息。
    @discardableResult
    func handleUploadSwapObjectTransportResponse(
        _ response: SalesmartlyPayload,
        request: SalesmartlyTransportRequest
    ) -> Bool {
        let key = downloadResolutionKey(from: request)
        guard let pending = pendingUploadSwapObjects.removeValue(forKey: key) else {
            return false
        }
        let data = response["data"] as? SalesmartlyPayload
        guard let result = stringValue(data?["result"]),
              handleUploadSwapObjectResult(
                tempId: pending.tempId,
                fileURL: pending.fileURL,
                result: result
              ) else {
            handleUploadFailure(tempId: pending.tempId)
            return true
        }
        return true
    }

    @discardableResult
    func handleUploadSwapObjectResult(tempId: String, fileURL: String, result: String) -> Bool {
        let swapObjectList = decodeSwapObjectResult(result)
        let swapObjectItem = swapObjectList.first { item in
            item["id"] as? String == tempId
        }
        let sendURL = stringValue(swapObjectItem?["send_url"])
        let assetURL = stringValue(swapObjectItem?["url"])

        return handleUploadSuccess(
            tempId: tempId,
            fileURL: normalizedUploadFileURL(fileURL),
            sendURL: sendURL,
            assetURL: assetURL
        )
    }

    func handleUploadDirectSuccess(tempId: String, fileURL: String) -> SalesmartlyPayload? {
        guard uploadTaskMap[tempId] != nil else {
            return nil
        }

        return makeSwapObjectPayload(tempId: tempId, fileURL: fileURL)
    }

    func makeUnreadMsgListPayload(loginToken: String, chatUserId: String) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "login_token": loginToken,
            "chat_user_id": chatUserId,
            "direction_type": "1",
        ]

        let unreadMessageId = lastUnreadMessageId()
        if !unreadMessageId.isEmpty {
            payload["sequence_id"] = unreadMessageId
            return payload
        }

        let notUnreadMessageId = lastNotUnreadMessageId()
        if !notUnreadMessageId.isEmpty {
            payload["sequence_id"] = notUnreadMessageId
        }

        return payload
    }

    func makeRecentMsgListPayload(loginToken: String, chatUserId: String) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "login_token": loginToken,
            "chat_user_id": chatUserId,
            "direction_type": "1",
            "sender_type": 2,
            "limit": 10,
        ]

        let notUnreadMessageId = lastNotUnreadMessageId()
        if !notUnreadMessageId.isEmpty {
            payload["sequence_id"] = notUnreadMessageId
        }

        return payload
    }

    func makeHistoryMsgListPayload(loginToken: String, chatUserId: String) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "login_token": loginToken,
            "limit": 20,
            "sender_type": 0,
            "chat_user_id": chatUserId,
            "direction_type": "1",
        ]

        let notUnreadMessageId = lastNotUnreadMessageId()
        if !notUnreadMessageId.isEmpty {
            payload["sequence_id"] = notUnreadMessageId
        }

        return payload
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 getHistoryMsg；iOS 首次补偿不带 sequence_id，确保 sender_type=0 能返回最近完整会话。
    func makeInitialHistoryMsgListPayload(loginToken: String, chatUserId: String) -> SalesmartlyPayload {
        [
            "login_token": loginToken,
            "limit": 20,
            "sender_type": 0,
            "chat_user_id": chatUserId,
            "direction_type": "1",
        ]
    }

    func makeQueueStatusPayload(chatUserId: String) -> SalesmartlyPayload {
        [
            "chat_user_id": chatUserId,
        ]
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 watch：先清理旧轮询，再在 showWrapper、queue_switch 和 chat_user_id 都满足时发起排队状态请求。
    @discardableResult
    func applyQueueStatusPolling(
        showWrapper: Bool,
        queueSwitch: String,
        chatUserId: String,
        queuePollingIntervalSeconds: Int,
        nowMilliseconds: Int64
    ) -> SalesmartlyTransportRequest? {
        clearQueueStatusPolling()

        guard showWrapper, queueSwitch == "1", !chatUserId.isEmpty else {
            return nil
        }

        state.queueStatusPollingRequestId += 1
        stopQueueStatusPolling()
        let request = makeQueueStatusTransportRequest(chatUserId: chatUserId)
        return sendTransportRequest(request)
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 watch，从 plugin/info 落到 state 的 queue_switch/queue_polling_interval 驱动排队状态请求。
    @discardableResult
    func applyQueueStatusPolling(
        showWrapper: Bool,
        chatUserId: String,
        nowMilliseconds: Int64
    ) -> SalesmartlyTransportRequest? {
        applyQueueStatusPolling(
            showWrapper: showWrapper,
            queueSwitch: state.queueSwitch,
            chatUserId: chatUserId,
            queuePollingIntervalSeconds: state.queuePollingIntervalSeconds,
            nowMilliseconds: nowMilliseconds
        )
    }

    @discardableResult
    func applyQueueStatus(status: String, queueCount: Int) -> Bool {
        if status == "waiting" {
            setQueueWaiting(queueCount)
            return true
        }

        clearQueueStatus()

        if status == "assigned" {
            return false
        }

        return true
    }

    func makeJoinRoomPayload() -> SalesmartlyPayload {
        commonSocketPayload()
    }

    func makeLeaveRoomPayload() -> SalesmartlyPayload {
        commonSocketPayload()
    }

    func makeOpenFramePayload() -> SalesmartlyPayload {
        commonSocketPayload()
    }

    func makeHumanServicePayload() -> SalesmartlyPayload {
        [
            "room_type": Self.roomType,
        ]
    }

    func requestHumanService() -> SalesmartlyPayload {
        makeHumanServicePayload()
    }

    public func setStreamSending(_ val: Bool) {
        state.isStreamSending = val
    }

    public func resetStreamInfo() {
        state.currentStreamInfo = SalesmartlyStreamCurrentInfo()
    }

    @discardableResult
    func startStreamMessageRendering(mid: String) -> Bool {
        guard !state.isStreamAnimating else {
            return false
        }
        guard state.currentStreamInfo.mid == mid else {
            return false
        }
        guard state.messages.contains(where: { $0.mid == mid && $0.isStream == "1" }) else {
            return false
        }

        state.streamMsg = ""
        state.streamCurrentIndex = 0
        state.isStreamAnimating = true
        state.isStreamSending = true
        return advanceStreamMessageRendering()
    }

    @discardableResult
    func advanceStreamMessageRendering() -> Bool {
        guard state.isStreamAnimating else {
            return false
        }

        if state.isStopStream {
            state.isStreamSending = false
            state.isStreamAnimating = false
            return false
        }

        let message = state.currentStreamInfo.msg
        if state.streamCurrentIndex < message.count {
            let index = message.index(message.startIndex, offsetBy: state.streamCurrentIndex)
            state.streamMsg.append(message[index])
            state.streamCurrentIndex += 1
            return true
        }

        completeStreamMessageRendering()
        return false
    }

    func setDraftText(_ text: String) {
        state.draftText = text
    }

    /// 对齐 widget main:src/components/TextBox/index.vue 的 onSelectEmoji，点击 emoji 后将 label 追加到输入框内容。
    func appendComposerEmoji(_ emojiLabel: String) {
        state.draftText += emojiLabel
    }

    @discardableResult
    func handleComposerSubmit() -> SalesmartlyPayload? {
        if state.isStreamSending {
            return stopCurrentStreamMessage()
        }

        if state.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }

        let text = state.draftText
        sendTextMessage(text)
        state.draftText = ""
        return nil
    }

    public func stopStream() {
        state.isStreamSending = false
        state.isStopStream = true
        state.isStreamAnimating = false
    }

    @discardableResult
    func stopCurrentStreamMessage() -> SalesmartlyPayload? {
        let streamInfo = state.currentStreamInfo
        guard !streamInfo.mid.isEmpty else {
            stopStream()
            return nil
        }

        guard let index = state.messages.firstIndex(where: { $0.mid == streamInfo.mid }) else {
            stopStream()
            return nil
        }

        state.messages[index].message = state.streamMsg.isEmpty ? streamInfo.msg : state.streamMsg
        state.messages[index].isStop = "1"

        let chatUserId = state.messages[index].chatUserId ?? ""
        stopStream()

        guard !chatUserId.isEmpty else {
            return nil
        }

        return makeStreamStopPayload(mid: streamInfo.mid, chatUserId: chatUserId)
    }

    @discardableResult
    func stopStreamMessage(mid: String, message: String, chatUserId: String) -> SalesmartlyPayload? {
        guard let index = state.messages.firstIndex(where: { $0.mid == mid }) else {
            return nil
        }

        state.messages[index].message = message
        state.messages[index].isStop = "1"
        stopStream()
        return makeStreamStopPayload(mid: mid, chatUserId: chatUserId)
    }

    func makeStreamStopPayload(mid: String, chatUserId: String) -> SalesmartlyPayload {
        [
            "sequence_id": mid,
            "chat_user_id": chatUserId,
        ]
    }

    func makeEvalutionPayload(
        sessionId: String?,
        sequenceId: String?,
        flowId: String?,
        stepLogId: String?,
        score: String?,
        comment: String?,
        inviteEvaluationId: String?,
        inviteEvaluationOrderId: String?,
        clientExpandInfo: [String: String]?
    ) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "room_type": Self.roomType,
            "flow_id": emptyStringWhenMissing(flowId),
            "step_log_id": emptyStringWhenMissing(stepLogId),
        ]
        if let sessionId {
            payload["session_id"] = sessionId
        }
        if let sequenceId {
            payload["sequence_id"] = sequenceId
        }
        if let score {
            payload["score"] = score
        }
        if let comment {
            payload["comment"] = comment
        }
        if let inviteEvaluationId {
            payload["invite_evaluation_id"] = inviteEvaluationId
        }
        if let inviteEvaluationOrderId {
            payload["invite_evaluation_order_id"] = inviteEvaluationOrderId
        }
        if let clientExpandInfo {
            payload["client_expand_info"] = clientExpandInfo
        }
        return payload
    }

    func makeLikePayload(
        sequenceId: String?,
        flowId: String?,
        likeResult: String?,
        postback: String?,
        clientExpandInfo: [String: String]?
    ) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "room_type": Self.roomType,
            "flow_id": emptyStringWhenMissing(flowId),
            "like_result": emptyStringWhenMissing(likeResult),
            "postback": emptyStringWhenMissing(postback),
        ]
        if let sequenceId {
            payload["sequence_id"] = sequenceId
        }
        if let clientExpandInfo {
            payload["client_expand_info"] = clientExpandInfo
        }
        return payload
    }

    func makeReadMessagePayload(sequenceId: String? = nil) -> SalesmartlyPayload {
        // 对齐 widget main:src/helper/useSocket.ts 的 readMessage，已读事件基于 commonSocketParams，flow_id 由插件初始化配置透传。
        var payload = commonSocketPayload()
        if let sequenceId {
            payload["sequence_id"] = sequenceId
        }
        return payload
    }

    func makeChannelList(channels: [String], channelSort: [String]) -> [String] {
        let sort = channelSort.isEmpty ? Self.channelIconSort : channelSort
        return sort.filter { channels.contains($0) }
    }

    func makeReverseChannelList(channels: [String], channelSort: [String]) -> [String] {
        let sort = channelSort.isEmpty ? Self.channelIconSort : channelSort.reversed()
        return sort.filter { channels.contains($0) }
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的 `displayList`，chat 渠道固定作为首页首项，其余渠道按 channel_sort 或默认顺序排列。
    func homePageDisplayChannelList() -> [String] {
        var displayList: [String] = []
        if state.channels.contains("chat") {
            displayList.append("chat")
        }

        let sort = state.channelSort.isEmpty ? Self.channelIconSort : state.channelSort
        sort.forEach { channel in
            if channel != "chat", state.channels.contains(channel) {
                displayList.append(channel)
            }
        }
        return displayList
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的主卡片与其他渠道网格显示条件。
    func homeChannelDisplayState() -> SalesmartlyHomeChannelDisplayState {
        let displayList = homePageDisplayChannelList()
        let mainChannel = displayList.first
        let showMainCard = (state.channels.contains("chat") || state.integrationType == "chat") && mainChannel != nil
        let gridChannels = state.integrationType == "chat" && !homeChannelsHandledOutsideHome()
            ? Array(displayList.dropFirst())
            : []

        return SalesmartlyHomeChannelDisplayState(
            mainChannel: mainChannel,
            gridChannels: gridChannels,
            showMainCard: showMainCard,
            showReceptionChatCard: mainChannel == "chat" && state.channels.contains("chat")
        )
    }

    /// 对齐 widget main:src/components/SideBar/index.vue 的 sidebar/single_icon 承载外部渠道后 Home 不重复渲染其他渠道网格。
    private func homeChannelsHandledOutsideHome() -> Bool {
        guard state.sidebarShow else {
            return false
        }
        guard state.sidebarShrinkMode == "sidebar" || state.sidebarShrinkMode == "single_icon" else {
            return false
        }
        return state.channels.contains { $0 != "chat" }
    }

    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的文件卡片宽高、圆角、内边距和间距。
    func fileAttachmentCardStyleState() -> SalesmartlyFileAttachmentCardStyleState {
        SalesmartlyFileAttachmentCardStyleState(
            width: 280,
            height: 54,
            cornerRadius: 6,
            padding: 12,
            gap: 8
        )
    }

    /// 对齐 Android `FileMessageState.reportId`：下载上报 id 优先使用 `c_m_id`，否则使用消息 id。
    func fileDownloadReportId(for message: ChatMessage) -> String {
        message.cMId ?? message.id
    }

    /// 对齐 Web `FileMessage.vue` 上传中判断：`mid` 包含 `temp_` 时降低透明度并隐藏下载按钮。
    func fileMessageIsUploading(_ message: ChatMessage) -> Bool {
        message.mid.contains(ChatMessage.tempPrefix)
    }

    /// 对齐 widget main:src/helper/usePluginInfo.ts 的 channel.push 顺序，从 plugin/info 字段生成 Launcher 渠道列表。
    func makePluginInfoChannels(from info: SalesmartlyPayload) -> [String] {
        var channels: [String] = []

        if pluginInfoNestedSwitchEnabled(info, key: "show_line_app_config") {
            channels.append("lineApp")
        }
        if pluginInfoStringEqualsOne(info["show_line"]) {
            channels.append("line")
        }
        if pluginInfoStringEqualsOne(info["show_plugin"]) {
            channels.append("chat")
        }
        if pluginInfoStringEqualsOne(info["show_messenger"]) {
            channels.append("messenger")
        }
        if pluginInfoStringEqualsOne(info["show_whatsapp"]) {
            channels.append("whatsapp")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_email_config") {
            channels.append("email")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_telegram_config") {
            channels.append("telegram")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_instagram_config") {
            channels.append("instagram")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_tiktok_config") {
            channels.append("tiktok")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_zalo_config") {
            channels.append("zalo")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_vkontakte_config") {
            channels.append("vkontakte")
        }
        if pluginInfoNestedSwitchEnabled(info, key: "show_work_weixin_config") {
            channels.append("weixin")
        }
        channels.append(contentsOf: makePluginInfoCustomChannels(from: info))

        return channels
    }

    /// 对齐 widget main:src/components/Channel/useChannel.ts 的 show_*_config 读取逻辑，只保存点击跳转所需且已在 Web 类型中确认的字段。
    func channelOpenConfigsFromPluginInfo(_ info: SalesmartlyPayload) -> [String: [String: String]] {
        var configs: [String: [String: String]] = [:]
        configs["line"] = channelOpenConfig(
            info["show_line_config"],
            keys: ["redirect_url", "bot_url", "type", "enable_browse_url", "liff_url", "qr_code"]
        )
        configs["lineApp"] = channelOpenConfig(
            info["show_line_app_config"],
            keys: ["redirect_url"]
        )
        configs["messenger"] = channelOpenConfig(
            info["show_messenger_config"],
            keys: ["redirect_url"]
        )
        configs["whatsapp"] = channelOpenConfig(
            info["show_whatsapp_config"],
            keys: ["redirect_url", "send_page_link", "type", "prolusion"]
        )
        configs["email"] = channelOpenConfig(
            info["show_email_config"],
            keys: ["email"]
        )
        configs["telegram"] = channelOpenConfig(
            info["show_telegram_config"],
            keys: ["redirect_url", "link_params"]
        )
        configs["instagram"] = channelOpenConfig(
            info["show_instagram_config"],
            keys: ["redirect_url"]
        )
        configs["tiktok"] = channelOpenConfig(
            info["show_tiktok_config"],
            keys: ["redirect_url"]
        )
        configs["zalo"] = channelOpenConfig(
            info["show_zalo_config"],
            keys: ["redirect_url"]
        )
        configs["vkontakte"] = channelOpenConfig(
            info["show_vkontakte_config"],
            keys: ["redirect_url"]
        )
        configs["weixin"] = channelOpenConfig(
            info["show_work_weixin_config"],
            keys: ["kf_url"]
        )
        customEntryOpenConfigsFromPluginInfo(info).forEach { id, config in
            configs[id] = config
        }
        return configs.filter { !$0.value.isEmpty }
    }

    /// 对齐 widget main:src/types/plugin.d.ts 的已确认字符串字段，避免为未知 schema 补默认值。
    private func channelOpenConfig(_ rawConfig: Any?, keys: [String]) -> [String: String] {
        guard let config = payloadValue(rawConfig) else {
            return [:]
        }
        var values: [String: String] = [:]
        keys.forEach { key in
            if let value = stringValue(config[key]) {
                values[key] = value
            }
        }
        return values
    }

    /// 对齐 widget main:src/helper/usePluginInfo.ts 与 Channel/useChannel.ts 的 show_custom_config JSON.parse 结果，保存 custom entry 点击和弹层所需字段。
    private func customEntryOpenConfigsFromPluginInfo(_ info: SalesmartlyPayload) -> [String: [String: String]] {
        guard let showCustomConfig = stringValue(info["show_custom_config"]),
              let customEntries = pluginInfoPayloadListJSONObject(showCustomConfig) else {
            return [:]
        }

        var configs: [String: [String: String]] = [:]
        customEntries.forEach { item in
            guard let id = stringValue(item["id"]), pluginInfoSwitchEnabled(item["switch"]) else {
                return
            }
            configs[id] = channelOpenConfig(
                item,
                keys: ["id", "type", "input_value", "entry_url", "chat_url"]
            )
        }
        return configs
    }

    /// 对齐 widget main:src/helper/useAppLoad.ts 的 userInfo.type === 'guest' && userInfo.token 分支，plugin/info 完成后复用本地 token 直接 joinRoom。
    @discardableResult
    func connectCachedGuestTokenAfterPluginInfo() -> SalesmartlyTransportRequest? {
        guard state.userType == "guest",
              !state.userToken.isEmpty,
              !state.localChatUserId.isEmpty,
              !state.pluginProjectId.isEmpty,
              let pluginId = config?.license,
              !pluginId.isEmpty else {
            return nil
        }

        let joinRequest = connectSocketTransport(
            loginToken: state.userToken,
            chatUserId: state.localChatUserId,
            pluginId: pluginId,
            projectId: state.pluginProjectId
        )
        if !isSseHTTPMode() {
            flushPendingMessageTransportRequestsAfterConnection()
        }
        return joinRequest
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 getToken 无缓存分支，plugin/info 完成后用宿主上下文发起 create-user。
    @discardableResult
    func sendCreateUserTokenRequestAfterPluginInfo() -> SalesmartlyCreateUserTokenDecision? {
        guard let nativeBootstrapContext,
              !state.pluginProjectId.isEmpty else {
            return nil
        }

        return sendCreateUserTokenRequest(
            sourceURL: nativeBootstrapContext.sourceURL,
            userAgent: nativeBootstrapContext.userAgent,
            navigatorLanguage: nativeBootstrapContext.navigatorLanguage,
            beforeSourceURL: nativeBootstrapContext.beforeSourceURL,
            guestUserId: nativeBootstrapContext.guestUserId
        )
    }

    /// 对齐 widget main:src/helper/useLocal.ts 的 createUser.then 与 main:src/App.vue 的 handleShowChat，脚本启动创建 token 后继续连接 Socket 并 joinRoom。
    @discardableResult
    func connectCreatedUserTokenAfterCreateUser() -> SalesmartlyTransportRequest? {
        guard nativeBootstrapContext != nil,
              !state.userToken.isEmpty,
              !state.localChatUserId.isEmpty,
              !state.pluginProjectId.isEmpty,
              let pluginId = config?.license,
              !pluginId.isEmpty else {
            return nil
        }

        let joinRequest = connectSocketTransport(
            loginToken: state.userToken,
            chatUserId: state.localChatUserId,
            pluginId: pluginId,
            projectId: state.pluginProjectId
        )
        if !isSseHTTPMode() {
            flushPendingMessageTransportRequestsAfterConnection()
        }
        return joinRequest
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 postMessage/sendMessageByMode，Socket 加入后补发 token 建立前已经入队的消息。
    @discardableResult
    func flushPendingMessageTransportRequestsAfterConnection() -> [SalesmartlyTransportRequest] {
        guard !state.userToken.isEmpty,
              !state.localChatUserId.isEmpty,
              state.hasJoinRoom || state.sendMode == Self.sendModeHTTP else {
            return []
        }

        return sendPendingMessageTransportRequests(
            loginToken: state.userToken,
            chatUserId: state.localChatUserId
        )
    }

    func channelComponentName(for id: String) -> String {
        switch id {
        case "chat":
            return "ChannelChat"
        case "line":
            return "ChannelLine"
        case "lineApp":
            return "ChannelLineApp"
        case "messenger":
            return "ChannelMessenger"
        case "email":
            return "ChannelEmail"
        case "whatsapp":
            return "ChannelWhatsapp"
        case "telegram":
            return "ChannelTelegram"
        case "instagram":
            return "ChannelInstagram"
        case "weixin":
            return "ChannelWeixin"
        case "tiktok":
            return "ChannelTikTok"
        case "vkontakte":
            return "ChannelVKontakte"
        case "zalo":
            return "ChannelZalo"
        case "custom_1", "custom_2", "custom_3":
            return "CustomEntry"
        default:
            return ""
        }
    }

    func channelIconSize(for size: String) -> Int {
        switch size {
        case "small":
            return 22
        case "medium":
            return 28
        case "side", "xs":
            return 16
        default:
            return 36
        }
    }

    /// 对齐 widget main:src/stores/app.ts 的 setLauncherContext，记录 Launcher 当前 showSideBar/showIcon 上下文供 Line 点击判断。
    func setLauncherContext(showSideBar: Bool, showIcon: Bool) {
        state.launcherShowSideBar = showSideBar
        state.launcherShowIcon = showIcon
    }

    /// 对齐 widget main:src/stores/app.ts 的 openLinePage，强制打开 Launcher 承载的 Line 侧边页。
    func openLinePage() {
        state.showLinePage = true
    }

    /// 对齐 widget main:src/stores/app.ts 的 closeLinePage，关闭 Launcher 承载的 Line 侧边页。
    func closeLinePage() {
        state.showLinePage = false
    }

    /// 对齐 widget main:src/stores/app.ts 的 toggleLinePage，点击同一 Line 图标时切换侧边页开关。
    func toggleLinePage() {
        state.showLinePage.toggle()
    }

    /// 对齐 widget main:src/components/Channel/Line.vue 的 handleClick，返回 true 表示宿主应继续执行 Line 外链跳转。
    @discardableResult
    func handleLineChannelClick(
        hasQRCode: Bool,
        sidebarShow: Bool,
        isColumnIntegration: Bool
    ) -> Bool {
        if isDemoMode() {
            return false
        }

        if state.showWrapper {
            return true
        }

        let inLauncherColumn = isColumnIntegration &&
            !sidebarShow &&
            !state.launcherShowSideBar &&
            (state.launcherShowIcon || isDemoMode())

        if inLauncherColumn && hasQRCode {
            toggleLinePage()
            return false
        }

        if state.showLinePage {
            closeLinePage()
        }
        return true
    }

    /// 对齐 widget main:src/components/Channel/Line.vue 与 src/components/Launcher/index.vue 的 watch，配置变化或窗口打开时关闭 Line 侧边页。
    @discardableResult
    func applyLinePageVisibilityRules(
        hasQRCode: Bool,
        sidebarShow: Bool,
        isColumnIntegration: Bool
    ) -> Bool {
        guard state.showLinePage else {
            return false
        }

        let showLauncherColumn = isColumnIntegration &&
            !sidebarShow &&
            !state.launcherShowSideBar &&
            (state.launcherShowIcon || isDemoMode())

        if state.showWrapper || !showLauncherColumn || (!hasQRCode && !isDemoMode()) {
            closeLinePage()
            return true
        }

        return false
    }

    @discardableResult
    func openWhatsappChannel(
        redirectURL: String,
        sendPageLink: String,
        type: String,
        prolusion: String,
        sourceURL: String,
        whatsappLinkText: String
    ) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        var jumpURL = redirectURL
        var text = prolusion
        if sendPageLink == "1" {
            let sourceURL = sourceURL.addingPercentEncoding(withAllowedCharacters: Self.encodeURIComponentAllowedCharacters)!
            text = "\(whatsappLinkText) \(sourceURL)"
        }

        text = applyWhatsappGreetingCallback(text)

        if !text.isEmpty {
            jumpURL = type == "3" ? "\(jumpURL)?text=\(text)" : "\(jumpURL)&text=\(text)"
        }

        dispatch("onOpenWhatsapp", payload: ["linkUrl": jumpURL])
        return jumpURL
    }

    /// 对齐 widget main:src/components/Channel/useChannel.ts 的 win.createWhatsappGreeting(text) || text，空返回值保留原问候语。
    private func applyWhatsappGreetingCallback(_ text: String) -> String {
        guard let callbackText = whatsappGreetingCallback?(text), !callbackText.isEmpty else {
            return text
        }
        return callbackText
    }

    @discardableResult
    func openMessengerChannel(redirectURL: String, isMobile: Bool) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        let linkURL = isMobile
            ? redirectURL.replacingOccurrences(of: "www.facebook.com/messages/t/", with: "m.me/")
            : redirectURL
        dispatch("onOpenMessenger", payload: ["linkUrl": linkURL])
        return linkURL
    }

    @discardableResult
    func openTelegramChannel(redirectURL: String, linkParams: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        let jumpURL = linkParams.isEmpty ? redirectURL : "\(redirectURL)?start=\(linkParams)"
        dispatch("onOpenTelegram", payload: ["linkUrl": jumpURL])
        return jumpURL
    }

    /// 对齐 widget main:src/components/Channel/useChannel.ts 的侧边栏渠道点击分发，使用 plugin/info 已保存配置打开外部渠道。
    @discardableResult
    func openConfiguredExternalChannel(
        _ channel: String,
        sourceURL: String,
        whatsappLinkText: String
    ) -> String? {
        let config = state.channelOpenConfigs[channel] ?? [:]
        switch channel {
        case "line":
            return openLineChannel(
                redirectURL: config["redirect_url"] ?? "",
                botURL: config["bot_url"] ?? "",
                type: config["type"] ?? "",
                enableBrowseURL: config["enable_browse_url"] ?? "",
                liffURL: config["liff_url"] ?? "",
                pluginId: self.config?.license ?? "",
                sourceURL: sourceURL,
                uid: state.localUserId,
                isInLineApp: false,
                isMobile: false
            )
        case "lineApp":
            return openLineAppChannel(redirectURL: config["redirect_url"] ?? "")
        case "messenger":
            return openMessengerChannel(
                redirectURL: config["redirect_url"] ?? "",
                isMobile: false
            )
        case "whatsapp":
            return openWhatsappChannel(
                redirectURL: config["redirect_url"] ?? "",
                sendPageLink: config["send_page_link"] ?? "",
                type: config["type"] ?? "",
                prolusion: config["prolusion"] ?? "",
                sourceURL: sourceURL,
                whatsappLinkText: whatsappLinkText
            )
        case "email":
            return openEmailChannel(email: config["email"] ?? "")
        case "telegram":
            return openTelegramChannel(
                redirectURL: config["redirect_url"] ?? "",
                linkParams: config["link_params"] ?? ""
            )
        case "instagram":
            return openInstagramChannel(redirectURL: config["redirect_url"] ?? "")
        case "tiktok":
            return openTikTokChannel(redirectURL: config["redirect_url"] ?? "")
        case "zalo":
            return openZaloChannel(redirectURL: config["redirect_url"] ?? "")
        case "vkontakte":
            return openVKontakteChannel(redirectURL: config["redirect_url"] ?? "")
        case "weixin":
            return openWeixinChannel(kfURL: config["kf_url"] ?? "")
        case "custom_1", "custom_2", "custom_3":
            return openCustomEntryChannel(
                id: channel,
                type: config["type"] ?? "",
                inputValue: config["input_value"] ?? "",
                open: true
            )
        default:
            return nil
        }
    }

    /// 对齐 Android `handleChannelClick` 与 widget main:src/components/Channel/useChannel.ts，将 Launcher/Home/Header 渠道点击收敛到同一分发入口。
    @discardableResult
    func handleChannelClick(
        _ channel: String,
        sourceURL: String = "",
        whatsappLinkText: String = "",
        isMobile: Bool = false,
        isInLineApp: Bool = false
    ) -> String? {
        if channel == "chat" {
            openChat()
            return nil
        }

        let config = state.channelOpenConfigs[channel] ?? [:]
        if channel == "line" {
            let shouldOpenURL = handleLineChannelClick(
                hasQRCode: !(config["qr_code"] ?? "").isEmpty,
                sidebarShow: state.sidebarShow,
                isColumnIntegration: state.integrationType == "column"
            )
            guard shouldOpenURL else {
                return nil
            }
            return openLineChannel(
                redirectURL: config["redirect_url"] ?? "",
                botURL: config["bot_url"] ?? "",
                type: config["type"] ?? "",
                enableBrowseURL: config["enable_browse_url"] ?? "",
                liffURL: config["liff_url"] ?? "",
                pluginId: self.config?.license ?? "",
                sourceURL: sourceURL,
                uid: state.localUserId,
                isInLineApp: isInLineApp,
                isMobile: isMobile
            )
        }

        if ["custom_1", "custom_2", "custom_3"].contains(channel),
           config["type"] != "3" {
            _ = openCustomEntry(channel)
            return nil
        }

        switch channel {
        case "messenger":
            return openMessengerChannel(redirectURL: config["redirect_url"] ?? "", isMobile: isMobile)
        case "lineApp":
            return openLineAppChannel(redirectURL: config["redirect_url"] ?? "")
        default:
            return openConfiguredExternalChannel(
                channel,
                sourceURL: sourceURL,
                whatsappLinkText: whatsappLinkText
            )
        }
    }

    @discardableResult
    func openEmailChannel(email: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenEmail", payload: ["email": email])
        return "mailto:\(email)"
    }

    @discardableResult
    func openLineChannel(
        redirectURL: String,
        botURL: String,
        type: String,
        enableBrowseURL: String,
        liffURL: String,
        pluginId: String,
        sourceURL: String,
        uid: String,
        isInLineApp: Bool,
        isMobile: Bool
    ) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        let linkURL = type == "1" ? botURL : redirectURL
        let encodedSourceURL = sourceURL.addingPercentEncoding(withAllowedCharacters: Self.encodeURIComponentAllowedCharacters)!
        let liffId = liffURL.replacingOccurrences(of: "https://liff.line.me/", with: "")
        let authURL = "\(liffURL)?plugin_id=\(pluginId)&current_url=\(encodedSourceURL)&uid=\(uid)"
        let mobileAuthURL = "https://line.me/R/app/\(liffId)?plugin_id=\(pluginId)&current_url=\(encodedSourceURL)&uid=\(uid)"
        let useBrowseURL = type == "1" && enableBrowseURL == "1"

        dispatch("onOpenLine", payload: ["linkUrl": linkURL])

        if isInLineApp {
            return useBrowseURL ? authURL : redirectURL
        }

        if isMobile {
            return useBrowseURL ? mobileAuthURL : linkURL
        }

        return linkURL
    }

    @discardableResult
    func openLineAppChannel(redirectURL: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenLineApp", payload: ["linkUrl": redirectURL])
        return redirectURL
    }

    @discardableResult
    func openInstagramChannel(redirectURL: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenInstagram", payload: ["linkUrl": redirectURL])
        return redirectURL
    }

    @discardableResult
    func openTikTokChannel(redirectURL: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenTikTok", payload: ["linkUrl": redirectURL])
        return redirectURL
    }

    @discardableResult
    func openWeixinChannel(kfURL: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenWeixin", payload: ["linkUrl": kfURL])
        return kfURL
    }

    @discardableResult
    func openVKontakteChannel(redirectURL: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenVKontakte", payload: ["linkUrl": redirectURL])
        return redirectURL
    }

    @discardableResult
    func openZaloChannel(redirectURL: String) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        dispatch("onOpenZalo", payload: ["linkUrl": redirectURL])
        return redirectURL
    }

    @discardableResult
    func openCustomEntryChannel(id: String, type: String, inputValue: String, open: Bool) -> String? {
        guard !isDemoMode() else {
            return nil
        }

        let linkURL = type == "3" ? inputValue : nil

        if open {
            if ["1", "2"].contains(type) {
                _ = openCustomEntry(id)
            } else {
                dispatch("onOpenCustom", payload: ["id": id, "content": inputValue])
            }
        }

        return linkURL
    }

    public func showCollection() {
        showCollection(true)
    }

    /// 对齐 Android `showCollection(show)`，普通留资打开时关闭离线留资，关闭时同步关闭留资 overlay。
    public func showCollection(_ visible: Bool) {
        if visible {
            state.showCollection = true
            state.showOffline = false
            dispatch("onOpenCollection", payload: ["show": true])
        } else {
            closeCollection()
        }
    }

    func closeCollection() {
        state.showCollection = false
        state.showOffline = false

        if tempMessage?.msgType == "1", let message = tempMessage?.message as? String, !message.isEmpty {
            state.draftText = message
        }
    }

    public func showOffline() {
        showOffline(true)
    }

    /// 对齐 Android `showOffline(show)`，离线留资打开时关闭普通留资，关闭时只收起离线 overlay。
    public func showOffline(_ visible: Bool) {
        if visible {
            state.showCollection = false
            state.showOffline = true
        } else {
            state.showOffline = false
        }
    }

    public func setNotificationStatus(_ enabled: Bool) {
        state.notificationEnabled = enabled
    }

    /// 对齐 Android Toast 入队能力，供上传失败、评价错误等平台提示进入 SwiftUI Host 展示。
    @discardableResult
    public func showToast(_ message: String) -> SalesmartlyToastItem {
        nextToastId += 1
        let item = SalesmartlyToastItem(id: nextToastId, message: message)
        state.toasts.append(item)
        return item
    }

    /// 对齐 Android Toast 消失动作，SwiftUI Host 动画结束后按 id 移除提示。
    public func dismissToast(id: Int) {
        state.toasts.removeAll { $0.id == id }
    }

    /// 对齐 widget main:src/helper/types.ts 的 flashTitle/soundNotice 插件配置，供未读变化时派生标题闪烁与声音提醒状态。
    public func setNotificationConfiguration(flashTitle: Bool, soundNotice: Bool) {
        state.flashTitle = flashTitle
        state.soundNotice = soundNotice
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 originTitle 与 $t("title.newMsg")，由宿主同步当前标题和本地化新消息标题。
    public func setNotificationTitleConfiguration(originTitle: String, newMessageTitle: String) {
        state.notificationOriginTitle = originTitle
        state.notificationCurrentTitle = originTitle
        state.notificationNewMessageTitle = newMessageTitle
        state.notificationFlashNextTitle = ""
        state.notificationFlashNextTickMilliseconds = 0
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 parentDoc.title，宿主标题变化时同步当前标题供 stopFlashTitle 恢复使用。
    public func setNotificationCurrentTitle(_ title: String) {
        state.notificationCurrentTitle = title
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的浏览器通知动作，设置 iOS 宿主提供的通知处理器。
    public func setNotificationHandler(_ handler: SalesmartlyNotificationHandling?) {
        notificationHandler = handler
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 msg.onclick，通知点击后聚焦目标并关闭通知。
    public func handleUnreadNotificationClick() {
        state.notificationClickCount += 1
        notificationHandler?.focusNotificationTarget()
        notificationHandler?.closeUnreadNotification()
    }

    public func hideUpload(_ types: [String]) {
        state.hideUploadTypes = types
    }

    public func hideCloseIcon(_ hidden: Bool = true) {
        state.hideCloseIcon = hidden
    }

    /// 对齐 widget main:src/components/ChatWindow.vue 与 src/views/Page/index.vue 的关闭入口显示条件；专属链接、hideCloseIcon 或移动端 full 首屏时隐藏关闭按钮。
    func shouldShowWindowCloseButton() -> Bool {
        chatHeaderShowsCloseIcon()
    }

    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的接待人判断，sys_user_id 为正数时才认为已有接待客服。
    func chatHeaderHasAssignUserInfo() -> Bool {
        guard let sysUserId = state.assignUserInfo["sys_user_id"],
              let sysUserNumber = Double(sysUserId) else {
            return false
        }
        return sysUserNumber > 0
    }

    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的标题优先级：输入中、接待客服昵称、窗口名。
    func chatHeaderTitle() -> String {
        if state.showServiceTyping {
            return salesmartlyText("msg.typing", language: state.lang)
        }
        if state.iconPopupShowReceptionInfo,
           chatHeaderHasAssignUserInfo(),
           let nickname = state.assignUserInfo["nickname"] {
            return nickname
        }
        return state.iconPopupWindowName.isEmpty ? "Salesmartly" : state.iconPopupWindowName
    }

    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的头像优先级：接待客服头像优先，否则使用插件品牌头像。
    func chatHeaderAvatarURL() -> String {
        if state.iconPopupShowReceptionInfo,
           chatHeaderHasAssignUserInfo(),
           let avatar = state.assignUserInfo["avatar"] {
            return avatar
        }
        return state.pluginAvatarURL
    }

    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 rect.height > 0 过滤，Host 只写入有效 Launcher 折叠态高度。
    public func setCollapsedSidebarHeight(_ height: Int) {
        state.collapsedSidebarHeight = height > 0 ? height : nil
    }

    /// 对齐 widget main:src/App.vue 的 handleGetSidebarHeight，记录 SwiftUI Host 当前可参与折叠入口高度计算的目标区域。
    public func setLauncherHeightTargetFrames(_ frames: [SalesmartlyLauncherHeightTargetFrame]) {
        state.launcherHeightTargetFrames = frames
        state.collapsedSidebarHeight = makeCollapsedSidebarHeight(from: frames)
    }

    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 getCollapsedSidebarHeight，按可见目标 top/bottom 聚合并向上取整。
    public func getSidebarHeight() -> Int? {
        state.collapsedSidebarHeight
    }

    /// 对齐 widget main:src/types/global.d.ts 的 getSidebarHeight callback；无可见高度时不调用回调。
    public func getSidebarHeight(callback: SalesmartlySidebarHeightCallback) {
        guard let height = getSidebarHeight() else {
            return
        }

        callback(height)
    }

    /// 对齐 Android `openCustomEntry` 与 `WidgetInfo.customEntryPopup`，仅在非 demo、聊天窗已打开且配置存在时展示 custom entry 弹层。
    @discardableResult
    public func openCustomEntry(_ entryId: String) -> Bool {
        guard !isDemoMode(),
              state.showWrapper,
              let config = state.channelOpenConfigs[entryId],
              let type = config["type"],
              ["1", "2"].contains(type),
              let inputValue = config["input_value"],
              !inputValue.isEmpty else {
            return false
        }

        state.openCustomEntryId = entryId
        state.customEntryPopup = SalesmartlyCustomEntryPopup(
            id: entryId,
            type: type,
            inputValue: inputValue
        )
        state.customEntryPreviewImageURL = nil
        dispatch("onOpenCustom", payload: ["id": entryId, "content": inputValue])
        return true
    }

    /// 对齐 Android custom entry popup 关闭动作，关闭弹层时同步清理图片预览与当前入口 id。
    public func closeCustomEntryPopup() {
        state.openCustomEntryId = nil
        state.customEntryPopup = nil
        state.customEntryPreviewImageURL = nil
    }

    /// 对齐 Android 图片 custom entry 预览动作，只有 type=2 图片弹层可进入全屏预览。
    @discardableResult
    public func previewCustomEntryPopupImage() -> Bool {
        guard let popup = state.customEntryPopup, popup.type == "2" else {
            return false
        }
        state.customEntryPreviewImageURL = popup.inputValue
        return true
    }

    /// 对齐 Android 图片 custom entry 全屏预览关闭动作。
    public func closeCustomEntryPopupImagePreview() {
        state.customEntryPreviewImageURL = nil
    }

    public func trackUrl(_ url: String) {
        state.trackedURL = url
    }

    public func setDemo(_ payload: [String: String]) {
        setDemo(payload.reduce(into: SalesmartlyPayload()) { result, item in
            result[item.key] = item.value
        })
    }

    /// 对齐 Android `setDemo(SalesmartlyPayload)`，demo 模式下透传 onSetDemo，状态中保留字符串镜像兼容既有 iOS 读取方。
    public func setDemo(_ payload: SalesmartlyPayload) {
        state.demoPayload = demoStringPayload(from: payload)
        guard isDemoMode() else {
            return
        }
        dispatch("onSetDemo", payload: payload)
    }

    private func demoStringPayload(from payload: SalesmartlyPayload) -> [String: String] {
        var result: [String: String] = [:]
        payload.forEach { key, value in
            if let string = value as? String {
                result[key] = string
            } else if JSONSerialization.isValidJSONObject(value),
                      let data = try? JSONSerialization.data(withJSONObject: value, options: [.sortedKeys]),
                      let string = String(data: data, encoding: .utf8) {
                result[key] = string
            } else {
                result[key] = String(describing: value)
            }
        }
        return result
    }

    /// 对齐 widget main:src/helper/types.ts 的 icon_popup/icon_popup_type/channel/isLimit 配置，供 Launcher 未读预览派生状态使用。
    public func setIconPopupConfiguration(
        iconPopupEnabled: Bool,
        iconPopupType: String,
        channels: [String],
        isLimit: Bool
    ) {
        state.iconPopupEnabled = iconPopupEnabled
        state.iconPopupType = iconPopupType
        state.channels = channels
        state.isLimit = isLimit
    }

    /// 对齐 widget main:src/helper/types.ts 的 window_name/showReceptionInfo，供 Launcher 未读文本预览展示标题使用。
    public func setIconPopupDisplayConfiguration(windowName: String, showReceptionInfo: Bool) {
        state.iconPopupWindowName = windowName
        state.iconPopupShowReceptionInfo = showReceptionInfo
    }

    /// 对齐 widget main:src/stores/chat.ts 的 showIconPopup computed，判断 Launcher 是否展示未读消息预览气泡。
    public func showIconPopup() -> Bool {
        state.lastNoticeMsg != nil &&
            state.iconPopupEnabled &&
            state.channels.contains("chat") &&
            !state.isLimit &&
            !state.showWrapper
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 previewName，派生 Launcher 未读文本预览标题。
    public func iconPopupPreviewTitle() -> String {
        if !state.iconPopupShowReceptionInfo {
            return state.iconPopupWindowName
        }

        if let senderName = state.lastNoticeMsg?.senderName, !senderName.isEmpty {
            return senderName
        }

        return state.iconPopupWindowName
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 与 Bubble 预览组件，派生 Launcher 未读预览摘要。
    public func iconPopupPreviewText() -> String {
        guard let message = state.lastNoticeMsg else {
            return ""
        }

        switch message.msgType {
        case "1":
            return normalizedIconPopupPreviewText(message.message)
        case "2":
            return "图片"
        case "3":
            return iconPopupTemplatePreviewText(message.message)
        case "4":
            return originFileName(message.message)
        case "6":
            return "视频"
        case "7":
            return "您有一封邮件，请查收"
        case "12":
            return "[\(salesmartlyText("msgType.12", language: state.lang))]"
        case "11":
            return iconPopupAIPreviewText(message.message)
        case "14":
            return iconPopupProductPreviewText(message.message)
        case "21":
            return iconPopupQuickReplyPreviewText(message.message)
        case "40":
            return iconPopupMediaTextPreviewText(message.message)
        default:
            return "[暂不支持此消息类型]"
        }
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 component computed，按 msg_type 派生未读预览组件。
    public func iconPopupPreviewComponent() -> SalesmartlyIconPopupPreviewComponent {
        guard let message = state.lastNoticeMsg else {
            return .unknown
        }

        switch message.msgType {
        case "1":
            return .text
        case "2":
            return .image
        case "3":
            return .template
        case "4":
            return .file
        case "6":
            return .video
        case "7":
            return .email
        case "11":
            return .ai
        case "14":
            return .product
        case "21":
            return .quickReply
        case "40":
            return .mediaText
        default:
            return .unknown
        }
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 needPreviewPadding，图片和视频预览需要额外内边距。
    public func iconPopupPreviewNeedsPadding() -> Bool {
        guard let message = state.lastNoticeMsg else {
            return false
        }

        return ["2", "6"].contains(message.msgType)
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 isPromotionalCard，用于 Host 区分推广卡片预览样式。
    public func iconPopupPreviewIsPromotionalCard() -> Bool {
        guard let message = state.lastNoticeMsg, message.msgType == "3" else {
            return false
        }

        return isPromotionalCardMessage(message.message)
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/TemplatePreviewMessage.vue 的模板预览内容。
    private func iconPopupTemplatePreviewText(_ message: String) -> String {
        guard let msgData = messageJSONObject(message) else {
            return "[暂不支持此消息类型]"
        }

        if msgData["type"] as? String == "invite_evalution" {
            return "您对本次服务满意吗？"
        }

        guard let payload = msgData["payload"] as? [String: Any] else {
            return "[暂不支持此消息类型]"
        }

        if payload["promotional_card"] != nil {
            return "收到1张优惠券"
        }

        if let text = stringValue(payload["text"]) {
            return normalizedIconPopupPreviewText(text)
        }

        if let attachments = payload["attachments"] as? [[String: Any]],
           let mediaType = stringValue(attachments.first?["media_type"]) {
            if mediaType == "image" {
                return "图片"
            }
            if mediaType == "video" {
                return "视频"
            }
            if mediaType == "audio" {
                return "音频"
            }
        }

        if let buttons = payload["buttons"] as? [[String: Any]],
           let text = stringValue(buttons.first?["text"]) {
            return normalizedIconPopupPreviewText(text)
        }

        return "[暂不支持此消息类型]"
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 AI guide/postback/reply 预览内容。
    private func iconPopupAIPreviewText(_ message: String) -> String {
        guard let msgData = messageJSONObject(message),
              let type = stringValue(msgData["type"]) else {
            return "[暂不支持此消息类型]"
        }

        if type == "guide" {
            return "请选择以下您想咨询的内容"
        }

        if type == "postback",
           let data = msgData["data"] as? [String: Any],
           let question = stringValue(data["question"]) {
            return normalizedIconPopupPreviewText(question)
        }

        if type == "reply",
           let data = msgData["data"] as? [[String: Any]] {
            let text = data.compactMap { item -> String? in
                if stringValue(item["context_type"]) == "media",
                   let context = stringValue(item["context"]) {
                    return originFileName(context)
                }
                return stringValue(item["context"])
            }.joined(separator: " ")
            return text.isEmpty ? "[暂不支持此消息类型]" : normalizedIconPopupPreviewText(text)
        }

        return "[暂不支持此消息类型]"
    }

    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 product_info 商品预览内容。
    private func iconPopupProductPreviewText(_ message: String) -> String {
        guard let msgData = messageJSONObject(message),
              let productInfo = msgData["product_info"] as? [String: Any] else {
            return "[暂不支持此消息类型]"
        }

        if let productName = stringValue(productInfo["product_name"]) {
            return normalizedIconPopupPreviewText(productName)
        }

        return "[暂不支持此消息类型]"
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/QuickReplyPreviewMessage.vue 的快捷回复预览内容。
    private func iconPopupQuickReplyPreviewText(_ message: String) -> String {
        guard let msgData = messageJSONObject(message),
              let payload = msgData["payload"] as? [String: Any] else {
            return "[暂不支持此消息类型]"
        }

        if let text = stringValue(payload["text"]) {
            return normalizedIconPopupPreviewText(text)
        }

        if let buttons = payload["buttons"] as? [[String: Any]],
           let text = stringValue(buttons.first?["text"]) {
            return normalizedIconPopupPreviewText(text)
        }

        return "[暂不支持此消息类型]"
    }

    /// 对齐 widget main:src/components/Bubble/MediaTextMessage.vue 的 caption/file_type 预览内容。
    private func iconPopupMediaTextPreviewText(_ message: String) -> String {
        guard let msgData = messageJSONObject(message) else {
            return "[暂不支持此消息类型]"
        }

        if let caption = stringValue(msgData["caption"]) {
            return normalizedIconPopupPreviewText(caption)
        }

        let fileType = stringValue(msgData["file_type"])
        if fileType == "image" {
            return "图片"
        }
        if fileType == "video" {
            return "视频"
        }
        if fileType == "document" {
            if let fileName = stringValue(msgData["file_name"]) {
                return fileName
            }
            if let fileURL = stringValue(msgData["file_url"]) {
                return originFileName(fileURL)
            }
        }

        return "[暂不支持此消息类型]"
    }

    /// 对齐 widget main:src/utils/tool.ts 的 originFileName，从 URL 路径中提取去 query 后的文件名。
    private func originFileName(_ url: String) -> String {
        let filename = url.split(separator: "/").last.map(String.init) ?? ""
        let filenameWithoutQuery = filename.split(separator: "?").first.map(String.init) ?? filename
        return filenameWithoutQuery.removingPercentEncoding ?? filenameWithoutQuery
    }

    /// 对齐 widget main:src/stores/chat.ts 的 setLastNoticeMsg(null)，用于关闭或进入未读预览时清理气泡消息。
    public func clearLastNoticeMsg() {
        state.lastNoticeMsg = nil
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 handleOpen，点击 IconPopup 时先清理预览再打开聊天。
    public func openChatFromIconPopup() {
        clearLastNoticeMsg()
        openChat()
    }

    /// 对齐 widget main:src/stores/chat.ts 的 setQueueWaiting，记录访客当前处于人工排队等待和排队人数。
    public func setQueueWaiting(_ count: Int) {
        state.queueStatus = "waiting"
        state.queueCount = count
    }

    /// 对齐 widget main:src/stores/chat.ts 的 clearQueueStatus，只清理队列展示状态，不递增轮询 requestId。
    public func clearQueueStatus() {
        state.queueStatus = ""
        state.queueCount = 0
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 clearQueueStatus，清理队列状态并使旧请求响应失效。
    func clearQueueStatusPolling() {
        state.queueStatusPollingRequestId += 1
        stopQueueStatusPolling()
        clearQueueStatus()
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 schedulePolling，根据 queue_polling_interval 记录下一次轮询触发时间。
    func scheduleQueueStatusPolling(queuePollingIntervalSeconds: Int, nowMilliseconds: Int64) {
        state.queueStatusPollingNextFetchMilliseconds = nowMilliseconds + Int64(queuePollingIntervalSeconds) * 1000
    }

    /// 对齐 widget main:src/helper/useQueueStatus.ts 的 stopPolling，清理当前排队状态轮询计时器标记。
    func stopQueueStatusPolling() {
        state.queueStatusPollingNextFetchMilliseconds = 0
    }

    public func setConversationAtBottom(_ val: Bool) {
        state.conversationAtBottom = val
        if val {
            state.conversationHasNewMessage = false
        }
    }

    public func markConversationHasNewMessage() {
        if state.conversationAtBottom {
            return
        }
        state.conversationHasNewMessage = true
    }

    public func clearConversationNewMessage() {
        state.conversationHasNewMessage = false
    }

    /// 对齐 widget main:src/views/Chat/components/BottomBar/index.vue 与 Android BottomBarState.bottomBarReportUrl，生成带插件、项目、会话和来源页参数的举报链接。
    public func bottomBarReportURL() -> URL? {
        guard let pluginId = config?.license, !pluginId.isEmpty else {
            return nil
        }
        let baseURL = state.widgetHost.contains("widget-dev.salesmartly.com") ?
            "https://cellus-test.salesmartly.com/" :
            "https://cellus.salesmartly.com/"
        let sourceURL = state.trackedURL ?? config?.setting.requestOriginURL ?? nativeBootstrapContext?.sourceURL ?? ""
        let urlString = "\(baseURL)report?plugin_id=\(encodeReportParam(pluginId))" +
            "&plugin_name=\(encodeReportParam(state.pluginName))" +
            "&window_name=\(encodeReportParam(state.iconPopupWindowName))" +
            "&project_id=\(encodeReportParam(state.pluginProjectId))" +
            "&chat_user_id=\(encodeReportParam(state.localChatUserId))" +
            "&exclusive_link=\(encodeReportParam(sourceURL))"
        return URL(string: urlString)
    }

    @discardableResult
    public func handleSendMessageRequiresHumanService(sysUserId: String?, humanServiceEnabled: Bool) -> Bool {
        guard sysUserId == "-1", humanServiceEnabled else {
            return false
        }

        state.showHumanMsg = false
        state.showHumanTips = false
        state.showHumanService = true
        return true
    }

    public func closeHumanService() {
        state.showHumanService = true
        state.showHumanMsg = true
        state.showHumanTips = false
    }

    public func hideJoinSessionTips() {
        state.showHumanService = true
        state.showHumanTips = true
        state.showHumanMsg = false
    }

    public func hideHumanComponent() {
        state.showHumanTips = false
        state.showHumanMsg = false
        state.showHumanService = false
    }

    public func dispatch(_ eventName: String, payload: SalesmartlyPayload) {
        callbacks[eventName]?.forEach { callback in
            callback(payload)
        }
    }

    private func notifyStateObservers() {
        stateObservers.values.forEach { observer in
            observer(state)
        }
    }

    private func makeSocketEventTransportRequest(
        eventName: String,
        payload: SalesmartlyPayload
    ) -> SalesmartlyTransportRequest {
        SalesmartlyTransportRequest(
            kind: .socketEvent,
            eventName: eventName,
            path: nil,
            method: nil,
            query: [:],
            payload: payload,
            externalSign: false
        )
    }

    private func makeHTTPTransportRequest(
        path: String,
        method: SalesmartlyHTTPMethod,
        query: [String: String] = [:],
        payload: SalesmartlyPayload = [:],
        externalSign: Bool = false,
        bodyEncoding: SalesmartlyHTTPBodyEncoding = .form
    ) -> SalesmartlyTransportRequest {
        SalesmartlyTransportRequest(
            kind: .http,
            eventName: nil,
            path: path,
            method: method,
            query: query,
            payload: payload,
            externalSign: externalSign,
            bodyEncoding: bodyEncoding
        )
    }

    private func transportQuery(from payload: SalesmartlyPayload) -> [String: String] {
        var query: [String: String] = [:]
        payload.forEach { key, value in
            if let value = value as? String {
                query[key] = value
            }
            if let value = value as? Int {
                query[key] = String(value)
            }
        }
        return query
    }

    private func addSendMessageItem(_ message: ChatMessage) {
        guard let clientMessageId = message.cMId, sendMessageMap[clientMessageId] == nil else {
            return
        }
        sendMessageMap[clientMessageId] = message
    }

    private func shouldSendPostMessage(_ message: ChatMessage) -> Bool {
        if ["1", "5", "11", "19"].contains(message.msgType) {
            return true
        }
        if ["2", "4", "6", "45"].contains(message.msgType) {
            return message.message.hasPrefix("https://")
        }
        return false
    }

    private func shouldSendExistingPostMessage(_ message: ChatMessage) -> Bool {
        ["2", "4", "6", "45"].contains(message.msgType) && message.message.hasPrefix("https://")
    }

    private func uploadMsgType(_ file: SalesmartlyUploadFile, requestedMsgType: String?) -> String {
        makeUploadMsgType(fileName: file.name, requestedMsgType: requestedMsgType)
    }

    private func uploadPlaceholderMessage(_ file: SalesmartlyUploadFile, msgType: String) -> String {
        if ["2", "45"].contains(msgType), let localURL = file.localURL {
            return localURL
        }
        if msgType == "6" {
            return "blob:\(file.name)"
        }
        return file.name
    }

    private func hiddenUploadType(for msgType: String) -> String {
        if ["2", "45"].contains(msgType) {
            return "img"
        }
        if msgType == "6" {
            return "video"
        }
        return "document"
    }

    private func bucketName(for domain: String) -> String {
        if Self.v1BucketDomainURLs.contains(domain) {
            return Self.v1BucketName
        }
        if Self.v2BucketDomainURLs.contains(domain) {
            return Self.v2BucketName
        }
        return ""
    }

    private func uploadOSSConfigCacheKey(module: String, modulePath: String) -> String {
        "\(module)/\(modulePath)"
    }

    private func milliseconds(fromISO8601 value: String) -> Int64 {
        let date = ISO8601DateFormatter().date(from: value)!
        return Int64(date.timeIntervalSince1970 * 1000)
    }

    private func uploadPolicyBase64(expiration: String) -> String {
        let policy = #"{"expiration":"\#(expiration)","conditions":[["content-length-range",0,\#(Self.uploadObjectMaxSize)]]}"#
        return Data(policy.utf8).base64EncodedString()
    }

    private func hmacSHA1Base64(value: String, key: String) -> String {
        let signature = HMAC<Insecure.SHA1>.authenticationCode(
            for: Data(value.utf8),
            using: SymmetricKey(data: Data(key.utf8))
        )
        return Data(signature).base64EncodedString()
    }

    private func replaceUploadAcceleratedDomain(_ fileURL: String) -> String {
        var url = fileURL
        if url.contains("assets.salesmartly.com") {
            url = url.replacingOccurrences(of: "assets.salesmartly.com", with: "assets-cdn.salesmartly.com")
        } else if url.contains("mix-ads.oss-ap-southeast-1.aliyuncs.com") {
            url = url.replacingOccurrences(of: "mix-ads.oss-ap-southeast-1.aliyuncs.com", with: "assets-cdn.salesmartly.com")
        } else if url.contains("mix-ads.oss-accelerate.aliyuncs.com") {
            url = url.replacingOccurrences(of: "mix-ads.oss-accelerate.aliyuncs.com", with: "assets-cdn.salesmartly.com")
        } else if url.contains("salesmartly.oss-accelerate.aliyuncs.com") {
            url = url.replacingOccurrences(of: "salesmartly.oss-accelerate.aliyuncs.com", with: "static.salesmartly.com")
        } else if url.contains("salesmartly.oss-ap-southeast-1.aliyuncs.com") {
            url = url.replacingOccurrences(of: "salesmartly.oss-ap-southeast-1.aliyuncs.com", with: "static.salesmartly.com")
        }
        return url.replacingOccurrences(of: "http://", with: "https://")
    }

    private func imageExtension(from url: String) -> String {
        let pattern = #"\.([a-zA-Z0-9]+)(?=(\?|#|$))"#
        let range = NSRange(url.startIndex..<url.endIndex, in: url)
        let regex = try! NSRegularExpression(pattern: pattern)
        guard let match = regex.firstMatch(in: url, range: range),
              let extensionRange = Range(match.range(at: 1), in: url) else {
            return ""
        }
        return url[extensionRange].lowercased()
    }

    private func fileExtension(from fileName: String) -> String {
        fileName.split(separator: ".").last.map { String($0) } ?? ""
    }

    private func isAllowImage(fileName: String) -> Bool {
        Self.uploadImageFormats.contains(fileExtension(from: fileName).lowercased())
    }

    private func isAllowVideo(fileName: String) -> Bool {
        Self.uploadVideoFormats.contains(fileExtension(from: fileName).lowercased())
    }

    private func swapObjectJSONString(tempId: String, bucket: String, object: String) -> String {
        #"[{"id":"\#(jsonStringLiteral(tempId))","bucket":"\#(jsonStringLiteral(bucket))","object":"\#(jsonStringLiteral(object))"}]"#
    }

    private func downloadResolutionKey(from request: SalesmartlyTransportRequest) -> String {
        stringValue(request.payload["object"]) ?? ""
    }

    private func jsonStringLiteral(_ value: String) -> String {
        let data = try! JSONSerialization.data(withJSONObject: [value])
        let valueList = String(data: data, encoding: .utf8)!
        return String(valueList.dropFirst(2).dropLast(2)).replacingOccurrences(of: "\\/", with: "/")
    }

    private func encodeSalesmartlyBase64(_ value: String) -> String {
        let base64Value = value.data(using: .utf8)!.base64EncodedString()
        var result = ""
        base64Value.forEach { character in
            if let index = Self.base64SourceCharacters.firstIndex(of: character) {
                result.append(Self.base64TargetCharacters[index])
            } else {
                result.append(character)
            }
        }
        return result
    }

    private func decodeSwapObjectResult(_ result: String) -> [SalesmartlyPayload] {
        let data = Data(base64Encoded: result)!
        return try! JSONSerialization.jsonObject(with: data) as! [SalesmartlyPayload]
    }

    private func stringValue(_ value: Any?) -> String? {
        guard let value = value as? String, !value.isEmpty else {
            return nil
        }
        return value
    }

    private func encodeReportParam(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.!~*'()")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    private func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }
        if let value = value as? Int64 {
            return Int(value)
        }
        if let value = value as? String {
            return Int(value)
        }
        return nil
    }

    private func int64Value(_ value: Any?) -> Int64? {
        if let value = value as? Int64 {
            return value
        }
        if let value = value as? Int {
            return Int64(value)
        }
        if let value = value as? String {
            return Int64(value)
        }
        return nil
    }

    private func makeReceiveMessageTransportData(from data: SalesmartlyPayload) -> ReceiveMessageTransportData? {
        guard let sequenceId = stringValue(data["sequence_id"]),
              let senderType = stringValue(data["sender_type"]),
              let msgType = stringValue(data["msg_type"]),
              let sendTime = int64Value(data["send_time"]),
              let chatUserId = stringValue(data["chat_user_id"]),
              let content = data["content"] as? SalesmartlyPayload else {
            return nil
        }

        let clientExpandInfo = data["client_expand_info"] as? SalesmartlyPayload
        return ReceiveMessageTransportData(
            sequenceId: sequenceId,
            senderType: senderType,
            msgType: msgType,
            message: receiveMessageTransportContentMessage(from: content),
            sendTime: sendTime,
            chatUserId: chatUserId,
            clientMessageId: stringValue(clientExpandInfo?["c_m_id"]),
            senderName: stringValue(data["sender_name"]),
            senderAvatar: stringValue(data["sender_avatar"]),
            readTime: int64Value(data["read_time"]),
            isWithdraw: stringValue(data["is_withdraw"]),
            streamInfo: makeStreamInfo(from: content["stream_info"]),
            quoteChat: stringValue(content["quote_chat"]) ?? ""
        )
    }

    private func makeMessageListFromHTTPTransportResponse(_ response: SalesmartlyPayload) -> [ChatMessage]? {
        guard let data = response["data"] as? SalesmartlyPayload,
              let rawMessages = data["messages"] as? [SalesmartlyPayload] else {
            return nil
        }

        return rawMessages.compactMap { rawMessage in
            makeChatMessage(from: rawMessage)
        }
    }

    private func makeMessageListFromSocketJoinTransportResponse(_ response: SalesmartlyPayload) -> [ChatMessage]? {
        guard let data = response["data"] as? SalesmartlyPayload,
              let rawMessages = data["messages"] as? [SalesmartlyPayload] else {
            return nil
        }

        return rawMessages.compactMap { rawMessage in
            makeChatMessage(from: rawMessage)
        }
    }

    private func makeChatMessage(from data: SalesmartlyPayload) -> ChatMessage? {
        guard let messageData = makeReceiveMessageTransportData(from: data) else {
            return nil
        }

        let pendingState = makeInteractivePendingState(
            msgType: messageData.msgType,
            message: messageData.message
        )
        let streamMessage = isStreamMessage(senderType: messageData.senderType, msgType: messageData.msgType)
        return ChatMessage(
            id: messageData.sequenceId,
            msgType: messageData.msgType,
            message: messageData.message,
            sendType: messageData.senderType,
            createdAt: Date(timeIntervalSince1970: TimeInterval(transformSendTime(messageData.sendTime)) / 1000),
            mid: messageData.sequenceId,
            tempId: pendingState.tempId,
            status: pendingState.status,
            createdTime: transformSendTime(messageData.sendTime),
            cMId: messageData.clientMessageId,
            chatUserId: messageData.chatUserId,
            senderName: messageData.senderName,
            senderAvatar: messageData.senderAvatar,
            clientExpandInfo: messageData.clientMessageId.map { ["c_m_id": $0] } ?? [:],
            isRead: makeReadStatus(readTime: messageData.readTime),
            likeResult: makeLikeResult(msgType: messageData.msgType, message: messageData.message),
            isWithdraw: messageData.isWithdraw,
            isStream: streamMessage ? "1" : nil,
            quoteChat: messageData.quoteChat
        )
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 `message: content.msg || '{}'`，对象型 msg 在 iOS 以 JSON 字符串承载供原生 Bubble 解析。
    private func receiveMessageTransportContentMessage(from content: SalesmartlyPayload) -> String {
        if let message = stringValue(content["msg"]) {
            return message
        }
        if let messagePayload = content["msg"] as? SalesmartlyPayload {
            return jsonString(from: messagePayload)
        }
        return "{}"
    }

    private func makeStreamInfo(from value: Any?) -> SalesmartlyStreamInfo? {
        guard let payload = value as? SalesmartlyPayload,
              let count = intValue(payload["count"]),
              let current = intValue(payload["current"]),
              let size = intValue(payload["size"]),
              let process = stringValue(payload["process"]) else {
            return nil
        }

        return SalesmartlyStreamInfo(
            count: count,
            current: current,
            size: size,
            process: process
        )
    }

    private func makeSendMessageTransportAck(from data: SalesmartlyPayload) -> SendMessageTransportAck? {
        guard let sequenceId = stringValue(data["sequence_id"]),
              let sendTime = int64Value(data["send_time"]) else {
            return nil
        }

        return SendMessageTransportAck(
            sequenceId: sequenceId,
            message: sendMessageTransportContentMessage(from: data["content"]),
            sendTime: sendTime
        )
    }

    private func sendMessageTransportContentMessage(from content: Any?) -> String {
        if let contentPayload = content as? SalesmartlyPayload,
           let message = stringValue(contentPayload["msg"]) {
            return message
        }

        if let message = stringValue(content) {
            return message
        }

        return ""
    }

    private func makeTransportSendMessageIdentity(
        from request: SalesmartlyTransportRequest
    ) -> (tempId: String, clientMessageId: String)? {
        guard let clientMessageId = transportClientMessageId(from: request.payload),
              let message = sendMessageMap[clientMessageId],
              let tempId = message.tempId else {
            return nil
        }

        return (tempId, clientMessageId)
    }

    private func transportChatUserId(from request: SalesmartlyTransportRequest) -> String {
        if let chatUserId = stringValue(request.payload["chat_user_id"]) {
            return chatUserId
        }

        if let chatUserId = stringValue(request.query["chat_user_id"]) {
            return chatUserId
        }

        return ""
    }

    private func transportClientMessageId(from payload: SalesmartlyPayload) -> String? {
        if let clientExpandInfo = payload["client_expand_info"] as? [String: String] {
            return stringValue(clientExpandInfo["c_m_id"])
        }

        if let clientExpandInfo = payload["client_expand_info"] as? String {
            let data = clientExpandInfo.data(using: .utf8)!
            let parsedClientExpandInfo = try! JSONSerialization.jsonObject(with: data) as! [String: String]
            return stringValue(parsedClientExpandInfo["c_m_id"])
        }

        // 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sendChatMsgEvent，SSE HTTP 的 client_expand_info 位于顶层 data JSON 字符串内。
        if let eventData = chatMsgEventDataPayload(from: payload) {
            return transportClientMessageId(from: eventData)
        }

        return nil
    }

    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 sendChatMsgEvent，HTTP event body 中 data 是字符串化后的事件业务 payload。
    private func chatMsgEventDataPayload(from payload: SalesmartlyPayload) -> SalesmartlyPayload? {
        guard let eventDataString = payload["data"] as? String else {
            return nil
        }
        return messageJSONObject(eventDataString)
    }

    private func removePendingSocketEvent(_ eventName: String) {
        state.pendingSocketEvents.removeAll { $0 == eventName }
    }

    private func resetPastePreview() {
        state.pasteMsgType = ""
        state.tempImgUrl = ""
        state.fileName = ""
    }

    @discardableResult
    private func notifyUploadFail(tempId: String? = nil, nowMilliseconds: Int64? = nil) -> Bool {
        if let tempId {
            if uploadFailNotifiedTempIds.contains(tempId) {
                return false
            }
            uploadFailNotifiedTempIds.insert(tempId)
        }

        let now = nowMilliseconds ?? currentTimestamp()
        if now - uploadFailToastTimestamp < Self.uploadFailToastIntervalMilliseconds {
            return false
        }

        uploadFailToastTimestamp = now
        uploadFailNotificationCount += 1
        showToast(salesmartlyText("tips.uploadFail", language: state.lang))
        return true
    }

    private func markUploadFail(tempId: String) {
        guard let index = state.messages.firstIndex(where: { $0.tempId == tempId }) else {
            return
        }
        state.messages[index].mid = "\(ChatMessage.failPrefix)\(currentTimestamp())"
    }

    private func markUploadRetry(tempId: String) {
        guard let index = state.messages.firstIndex(where: { $0.tempId == tempId }) else {
            return
        }
        state.messages[index].mid = "\(ChatMessage.retryPrefix)\(currentTimestamp())"
    }

    private func removeDuplicateMessages(id: String) {
        guard !id.isEmpty, let lastIndex = state.messages.lastIndex(where: { $0.id == id }) else {
            return
        }
        state.messages = state.messages.enumerated().compactMap { index, message in
            if message.id == id, index != lastIndex {
                return nil
            }
            return message
        }
    }

    private func shouldMarkFailed(_ message: ChatMessage) -> Bool {
        let messageId = message.id.isEmpty ? message.mid : message.id
        let isPending = messageId.hasPrefix(ChatMessage.tempPrefix) || messageId.hasPrefix(ChatMessage.retryPrefix)
        guard isPending else {
            return false
        }

        if ["1", "5"].contains(message.msgType) {
            return true
        }

        if ["2", "4", "6", "45"].contains(message.msgType) {
            return message.message.hasPrefix("https://")
        }

        return false
    }

    private func canRetrySendMessage(_ message: ChatMessage) -> Bool {
        guard message.tempId != nil else {
            return false
        }

        if ["1", "5"].contains(message.msgType) {
            return true
        }

        if ["2", "4", "6", "45"].contains(message.msgType) {
            return message.message.hasPrefix("https://")
        }

        return false
    }

    private func isUploadStageAttachment(_ message: ChatMessage) -> Bool {
        ["2", "4", "6", "45"].contains(message.msgType) && !message.message.hasPrefix("https://")
    }

    private func checkInterruptedUploadItem(_ message: ChatMessage) -> Bool {
        guard ["2", "4", "6", "45"].contains(message.msgType) else {
            return false
        }

        let messageId = message.id.isEmpty ? message.mid : message.id
        guard messageId.hasPrefix(ChatMessage.tempPrefix) || messageId.hasPrefix(ChatMessage.retryPrefix) else {
            return false
        }

        return !message.message.hasPrefix("https://")
    }

    private func shouldFilterLocalConversationMessage(_ message: ChatMessage) -> Bool {
        message.msgType == "8" && !isJoinSessionSystemMessage(message)
    }

    private func isJoinSessionSystemMessage(_ message: ChatMessage) -> Bool {
        guard message.msgType == "8",
              let msgData = messageJSONObject(message.message) else {
            return false
        }
        return msgData["type"] as? String == "join_session"
    }

    private func shouldInterceptBeforePostMessage(
        msgType: String,
        type: String?,
        enabledCollect: Bool,
        requiredCollect: Bool
    ) -> Bool {
        if enabledCollect, type != "promotionalCard", !["5", "11"].contains(msgType) {
            return true
        }
        if requiredCollect, enabledCollect {
            return true
        }
        return false
    }

    private func shouldInterceptBeforeRetryMessage(
        msgType: String,
        enabledCollect: Bool,
        requiredCollect: Bool
    ) -> Bool {
        if enabledCollect, !["5", "11"].contains(msgType) {
            return true
        }
        if requiredCollect, enabledCollect {
            return true
        }
        return false
    }

    private func showCollectionFromInterception() {
        if !state.showWrapper {
            openChat()
        }
        state.showCollection = true
    }

    private func makeReadStatus(readTime: Int64?) -> String {
        if state.showWrapper && state.currentView == .chat {
            return "1"
        }
        if let readTime, readTime != 0 {
            return "1"
        }
        return "0"
    }

    private func markMessagesRead(upTo sequenceId: String? = nil) {
        if let sequenceId {
            guard let targetId = Int64(sequenceId) else {
                setUnReadNum(0)
                return
            }

            for index in state.messages.indices {
                guard let messageId = Int64(state.messages[index].id) else {
                    return
                }
                if messageId <= targetId {
                    state.messages[index].isRead = "1"
                } else {
                    break
                }
            }
        } else {
            for index in state.messages.indices where state.messages[index].isRead != "1" {
                state.messages[index].isRead = "1"
            }
        }

        updateUnreadNumFromMessages()
        saveLocalConversation()
    }

    private func mergePollingMessageList(
        _ messages: [ChatMessage],
        currentChatUserId: String,
        marksReadWhenFirstMessageRead: Bool
    ) {
        let firstMessageId = messages.first?.id

        messages.forEach { message in
            guard isSameChatUser(message, currentChatUserId: currentChatUserId),
                  !isFilteredPollingMessage(message) else {
                return
            }

            if let index = state.messages.firstIndex(where: { $0.id == message.id }) {
                state.messages[index].isRead = normalizedPollingReadStatus(message)
                if message.isWithdraw == "1" {
                    state.messages[index].message = "{}"
                    state.messages[index].isWithdraw = "1"
                }
            } else {
                var nextMessage = message
                nextMessage.isRead = normalizedPollingReadStatus(message)
                state.messages.append(nextMessage)
            }
        }

        sortAndUniqueMessages()

        if marksReadWhenFirstMessageRead,
           let firstMessageId,
           let index = state.messages.firstIndex(where: { $0.id == firstMessageId }),
           state.messages[index].isRead == "1" {
            markMessagesRead(upTo: firstMessageId)
        } else {
            updateUnreadNumFromMessages()
        }
        saveLocalConversation()
    }

    private func updateUnreadNumFromMessages() {
        setUnReadNum(
            state.messages.filter { message in
                message.sendType != "1" && message.isRead == "0" && message.isWithdraw != "1"
            }.count
        )
    }

    private func updateLastNoticeMsgIfNeeded(_ message: ChatMessage) {
        guard message.sendType != "1",
              message.isWithdraw != "1",
              !state.showWrapper,
              checkPopupMessage(message) else {
            return
        }

        state.lastNoticeMsg = message
    }

    private func checkPopupMessage(_ message: ChatMessage) -> Bool {
        // 对齐 widget main:src/utils/msg.ts 的 checkPopupMsg：类型白名单、推广卡片优先、首条/最新未读预览策略。
        guard Self.iconPopupMessageTypes.contains(message.msgType) else {
            return false
        }

        if let lastNoticeMsg = state.lastNoticeMsg,
           lastNoticeMsg.msgType == "3",
           isPromotionalCardMessage(lastNoticeMsg.message) {
            return false
        }

        if message.msgType == "3" {
            guard let msgData = messageJSONObject(message.message) else {
                return false
            }

            let type = msgData["type"] as? String
            guard type == nil || type == "default" || type == "invite_evalution" else {
                return false
            }

            if isPromotionalCardMessage(message.message) {
                return true
            }

            if state.lastNoticeMsg != nil, state.iconPopupType == "0" {
                return false
            }

            return true
        }

        if state.lastNoticeMsg != nil, state.iconPopupType == "0" {
            return false
        }

        if message.msgType == "11" {
            guard let msgData = messageJSONObject(message.message),
                  let type = msgData["type"] as? String else {
                return false
            }

            return type == "guide" || type == "reply"
        }

        return true
    }

    private func normalizedIconPopupPreviewText(_ text: String) -> String {
        // 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的 previewText：连续空白合并为单个空格并裁剪首尾。
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func makeCollapsedSidebarHeight(from frames: [SalesmartlyLauncherHeightTargetFrame]) -> Int? {
        // 对齐 widget main:src/utils/sidebarHeight.ts：只取可见高度目标，按整体 top/bottom 跨度向上取整。
        let visibleFrames = frames.filter { $0.height > 0 }
        guard !visibleFrames.isEmpty else {
            return nil
        }

        let top = visibleFrames.map(\.top).min()!
        let bottom = visibleFrames.map(\.bottom).max()!
        return Int(ceil(bottom - top))
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的未读 watch：写入 UNREAD_KEY、启动标题闪烁、触发声音提醒，并按 NOTIFICATION_TIME_KEY 节流通知。
    @discardableResult
    func updateUnreadNotificationState(unreadMsgNum: Int, nowMilliseconds: Int64) -> Bool {
        let oldRecord = state.unreadRecord
        if unreadMsgNum != 0 {
            state.unreadRecord = unreadMsgNum
        } else {
            state.unreadRecord = 0
        }

        guard unreadMsgNum != 0 else {
            stopNotificationFlash()
            return false
        }

        if state.flashTitle {
            startNotificationFlashTitle(nowMilliseconds: nowMilliseconds)
        }

        if state.soundNotice, oldRecord != unreadMsgNum {
            state.soundNoticePlayCount += 1
            notificationHandler?.playUnreadSound()
            state.notificationLastTimeMilliseconds = nowMilliseconds
        }

        return showUnreadNotificationIfNeeded(nowMilliseconds: nowMilliseconds)
    }

    private func showUnreadNotificationIfNeeded(nowMilliseconds: Int64) -> Bool {
        // 对齐 widget main:src/helper/useNotification.ts 的 showNotification：通知关闭、10 秒内已触发或窗口可见时不发送通知。
        guard state.notificationEnabled else {
            return false
        }

        guard nowMilliseconds - state.notificationLastTimeMilliseconds > Self.notificationThrottleMilliseconds else {
            return false
        }

        guard !state.isWindowVisible else {
            return false
        }

        guard requestUnreadNotificationPermissionIfNeeded() else {
            return false
        }

        state.notificationShowCount += 1
        notificationHandler?.showUnreadNotification()
        state.notificationLastTimeMilliseconds = nowMilliseconds
        return true
    }

    private func requestUnreadNotificationPermissionIfNeeded() -> Bool {
        guard let notificationHandler else {
            return true
        }

        if state.notificationPermissionStatus == "granted" {
            return true
        }

        state.notificationPermissionStatus = notificationHandler.requestUnreadNotificationPermission(
            currentStatus: state.notificationPermissionStatus
        )
        return state.notificationPermissionStatus == "default" || state.notificationPermissionStatus == "granted"
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 flashTitle，按 800ms 节拍推进一次宿主标题闪烁。
    @discardableResult
    public func advanceNotificationFlashTitle(nowMilliseconds: Int64) -> Bool {
        guard state.shouldFlashTitle else {
            stopNotificationFlash()
            return false
        }

        guard state.notificationFlashNextTickMilliseconds != 0,
              nowMilliseconds >= state.notificationFlashNextTickMilliseconds else {
            return false
        }

        let lastTitle = state.notificationCurrentTitle
        state.notificationCurrentTitle = state.notificationFlashNextTitle
        state.notificationFlashNextTitle = lastTitle
        state.notificationFlashNextTickMilliseconds = nowMilliseconds + Self.notificationFlashIntervalMilliseconds
        return true
    }

    private func startNotificationFlashTitle(nowMilliseconds: Int64) {
        let currentTitle = notificationTitleWithoutNewMessagePrefix(state.notificationCurrentTitle)
        if !currentTitle.isEmpty, currentTitle != Self.notificationInvisibleTitle {
            state.notificationOriginTitle = currentTitle
        }

        state.notificationCurrentTitle = "\(state.notificationNewMessageTitle)\(state.notificationOriginTitle)"
        state.shouldFlashTitle = true
        state.notificationFlashNextTitle = Self.notificationInvisibleTitle
        state.notificationFlashNextTickMilliseconds = nowMilliseconds + Self.notificationFlashIntervalMilliseconds
    }

    private func stopNotificationFlash() {
        let currentTitle = notificationTitleWithoutNewMessagePrefix(state.notificationCurrentTitle)
        if !currentTitle.isEmpty, currentTitle != Self.notificationInvisibleTitle {
            state.notificationOriginTitle = currentTitle
        }

        state.notificationCurrentTitle = state.notificationOriginTitle
        state.shouldFlashTitle = false
        state.notificationFlashNextTitle = ""
        state.notificationFlashNextTickMilliseconds = 0
    }

    private func notificationTitleWithoutNewMessagePrefix(_ title: String) -> String {
        var rawTitle = title
        if !state.notificationNewMessageTitle.isEmpty,
           let range = rawTitle.range(of: state.notificationNewMessageTitle) {
            rawTitle.removeSubrange(range)
        }
        return rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func setUnReadNum(_ num: Int) {
        let previousNum = state.unReadNum
        state.unReadNum = num
        guard previousNum != num else {
            return
        }
        updateUnreadNotificationState(unreadMsgNum: num, nowMilliseconds: currentTimestamp())
        dispatch("onUnRead", payload: [
            "num": num,
            "list": Array(state.messages.suffix(num)),
        ])
    }

    private func lastNotUnreadMessageId() -> String {
        if let message = state.messages.reversed().first(where: { item in
            item.sendType != "1" && item.isRead != "0" && !item.id.contains("temp")
        }) {
            return message.id
        }
        return ""
    }

    private func lastUnreadMessageId() -> String {
        let receiveMessages = state.messages.filter { item in
            item.sendType != "1"
        }
        let lastTenMessages = receiveMessages.suffix(10)
        if let message = lastTenMessages.reversed().first(where: { item in
            item.isRead == "0" && item.isWithdraw != "1"
        }) {
            return message.id
        }
        return ""
    }

    private func isSameChatUser(_ message: ChatMessage, currentChatUserId: String) -> Bool {
        if currentChatUserId.isEmpty {
            return true
        }
        return message.chatUserId == currentChatUserId
    }

    private func isFilteredPollingMessage(_ message: ChatMessage) -> Bool {
        message.msgType == "8"
    }

    private func normalizedPollingReadStatus(_ message: ChatMessage) -> String {
        if state.showWrapper && state.currentView == .chat {
            return "1"
        }
        if let isRead = message.isRead {
            return isRead
        }
        return "0"
    }

    private func sortAndUniqueMessages() {
        state.messages.sort { current, next in
            if current.createdTime == next.createdTime {
                if let currentId = Int64(current.id), let nextId = Int64(next.id) {
                    return currentId < nextId
                }
                return current.id < next.id
            }
            return current.createdTime < next.createdTime
        }

        var ids: [String] = []
        state.messages = state.messages.filter { message in
            if ids.contains(message.id) {
                return false
            }
            ids.append(message.id)
            return true
        }
    }

    private func clientExpandInfoJSONString(_ clientExpandInfo: [String: String]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: clientExpandInfo, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }

    private func branchesJSONString(_ branches: [[String: String]]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: branches, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }

    private func commonSocketPayload() -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "room_type": Self.roomType,
        ]
        if let flowId = config?.setting.flowId, !flowId.isEmpty {
            payload["flow_id"] = flowId
        }
        return payload
    }

    /// 对齐 widget main:src/helper/realtime/types.ts 的 RealtimeAuthParams，用于 SSE token/connect/disconnect 请求体。
    private func realtimeAuthPayload(loginToken: String, chatUserId: String) -> SalesmartlyPayload {
        [
            "login_token": loginToken,
            "chat_user_id": chatUserId,
        ]
    }

    /// 对齐 widget main:src/api/ws/chat/chatMsg.ts 的 getCentrifugoToken params，用于 SSE token GET query。
    private func realtimeAuthQuery(loginToken: String, chatUserId: String) -> [String: String] {
        [
            "login_token": loginToken,
            "chat_user_id": chatUserId,
        ]
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 getRoomEventData，SSE join-room/leave-room 需在 commonSocketParams 上追加 room_id。
    private func makeRoomEventPayload(from payload: SalesmartlyPayload) -> SalesmartlyPayload {
        var nextPayload = payload
        nextPayload["room_id"] = state.localChatUserId
        return nextPayload
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 parseSseEnvelope，仅接收 receive-message/receive-notice/sdk-receive-notice。
    private func makeSseRealtimeEnvelope(from payload: SalesmartlyPayload) -> (eventName: String, data: SalesmartlyPayload)? {
        if payload.isEmpty || payload["connect"] is SalesmartlyPayload {
            return nil
        }
        guard payload["channel"] is String,
              let pub = payload["pub"] as? SalesmartlyPayload,
              let eventData = pub["data"] as? SalesmartlyPayload,
              let eventName = stringValue(eventData["event"]),
              [Self.receiveMessageEvent, Self.sseReceiveNoticeEvent, Self.receiveNoticeEvent].contains(eventName),
              let data = eventData["data"] as? SalesmartlyPayload else {
            return nil
        }
        return (eventName, data)
    }

    private func makeLikeResult(msgType: String, message: String) -> [String: String]? {
        guard msgType == "3",
              let data = message.data(using: .utf8),
              let msgData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let payload = msgData["payload"] as? [String: Any],
              payload["likes"] != nil else {
            return nil
        }

        if let likeResult = msgData["like_result"] as? [String: String] {
            return likeResult
        }

        return ["like": ""]
    }

    private func makeInteractivePendingState(msgType: String, message: String) -> (tempId: String?, status: Int?) {
        if msgType == "3", isInviteEvalutionMessage(message) || isPromotionalCardMessage(message) {
            return (ChatMessage.makeTempId(), 0)
        }
        if msgType == "11", isAIGuideMessage(message) {
            return (ChatMessage.makeTempId(), 0)
        }
        if msgType == "21", isQuickReplyWaitingMessage(message) {
            return (ChatMessage.makeTempId(), 0)
        }
        return (nil, nil)
    }

    private func markLastInteractiveMessageCompleted() {
        guard let lastIndex = state.messages.indices.last else {
            return
        }

        let message = state.messages[lastIndex]
        if message.msgType == "11", isAIGuideMessage(message.message) {
            state.messages[lastIndex].status = 1
        }
        if message.msgType == "21", isQuickReplyWaitingMessage(message.message) {
            state.messages[lastIndex].status = 1
        }
    }

    private func markLastAIGuideMessageCompleted() {
        guard let lastIndex = state.messages.indices.last else {
            return
        }

        let message = state.messages[lastIndex]
        if message.msgType == "11", isAIGuideMessage(message.message) {
            state.messages[lastIndex].status = 1
        }
    }

    private func isStreamMessage(senderType: String, msgType: String) -> Bool {
        senderType == "3" && msgType == "1"
    }

    private func handleStreamSending(sequenceId: String, message: String, streamInfo: SalesmartlyStreamInfo?) {
        state.isStopStream = false
        state.streamMsg = ""
        state.streamCurrentIndex = 0
        state.isStreamAnimating = false
        state.currentStreamInfo = SalesmartlyStreamCurrentInfo(
            mid: sequenceId,
            msg: message,
            current: streamInfo?.current ?? 0
        )
    }

    private func completeStreamMessageRendering() {
        state.streamMsg = ""
        state.streamCurrentIndex = 0
        state.isStreamAnimating = false
        state.isStreamSending = false
        resetStreamInfo()
    }

    private func isAIGuideMessage(_ message: String) -> Bool {
        guard let msgData = messageJSONObject(message) else {
            return false
        }
        return msgData["type"] as? String == "guide"
    }

    private func isInviteEvalutionMessage(_ message: String) -> Bool {
        guard let msgData = messageJSONObject(message) else {
            return false
        }
        return msgData["type"] as? String == "invite_evalution"
    }

    // 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 JSON.parse(info.message).payload。
    private func inviteEvalutionPayload(from message: String) -> SalesmartlyPayload {
        guard let msgData = messageJSONObject(message),
              let payload = msgData["payload"] as? SalesmartlyPayload else {
            return [:]
        }
        return payload
    }

    private func isPromotionalCardMessage(_ message: String) -> Bool {
        guard let msgData = messageJSONObject(message),
              let payload = msgData["payload"] as? [String: Any] else {
            return false
        }
        return payload["promotional_card"] != nil
    }

    private func isQuickReplyWaitingMessage(_ message: String) -> Bool {
        guard let msgData = messageJSONObject(message) else {
            return false
        }
        if let status = msgData["status"] as? Int {
            return status == 0
        }
        return msgData["status"] == nil
    }

    private func unusedTrailingIconPopupTemplatePreviewText(_ message: String) -> String {
        // 对齐 widget main:src/components/UnreadPreviewPopup/TemplatePreviewMessage.vue：默认模板展示 payload.text，推广卡展示 promotional_card 内容。
        guard let msgData = messageJSONObject(message),
              let payload = msgData["payload"] as? [String: Any] else {
            return ""
        }

        if let text = stringValue(payload["text"]) {
            return normalizedIconPopupPreviewText(text)
        }

        if let promotionalCard = payload["promotional_card"] as? [String: Any],
           let title = stringValue(promotionalCard["title"]) {
            return normalizedIconPopupPreviewText(title)
        }

        return ""
    }

    private func unusedTrailingOriginFileName(_ url: String) -> String {
        // 对齐 widget main:src/utils/tool.ts 的 originFileName：取最后一个路径片段、移除 query 并做 percent decode。
        let lastPath = url.split(separator: "/").last.map(String.init) ?? ""
        let filename = lastPath.split(separator: "?").first.map(String.init) ?? ""
        return filename.removingPercentEncoding ?? filename
    }

    private func unusedTrailingIconPopupAIPreviewText(_ message: String) -> String {
        // 对齐 widget main:src/components/Bubble/AiReplyMessage.vue：guide 展示问题项，postback 展示 question，reply 展示 text context。
        guard let msgData = messageJSONObject(message),
              let type = stringValue(msgData["type"]) else {
            return ""
        }

        if type == "postback",
           let data = msgData["data"] as? [String: Any],
           let question = stringValue(data["question"]) {
            return normalizedIconPopupPreviewText(question)
        }

        if type == "guide",
           let dataList = msgData["data"] as? [[String: Any]],
           let question = dataList.compactMap({ stringValue($0["question"]) }).first {
            return normalizedIconPopupPreviewText(question)
        }

        if type == "reply",
           let dataList = msgData["data"] as? [[String: Any]],
           let text = dataList.first(where: { stringValue($0["context_type"]) == "text" }).flatMap({ stringValue($0["context"]) }) {
            return normalizedIconPopupPreviewText(text)
        }

        return ""
    }

    private func unusedTrailingIconPopupProductPreviewText(_ message: String) -> String {
        // 对齐 widget main:src/components/Bubble/ProductMessage.vue：商品卡片主可见文本为 product_info.product_name。
        guard let msgData = messageJSONObject(message),
              let productInfo = msgData["product_info"] as? [String: Any],
              let productName = stringValue(productInfo["product_name"]) else {
            return ""
        }

        return normalizedIconPopupPreviewText(productName)
    }

    private func unusedTrailingIconPopupQuickReplyPreviewText(_ message: String) -> String {
        // 对齐 widget main:src/components/UnreadPreviewPopup/QuickReplyPreviewMessage.vue：快捷回复预览主文案来自 payload.text。
        guard let msgData = messageJSONObject(message),
              let payload = msgData["payload"] as? [String: Any],
              let text = stringValue(payload["text"]) else {
            return ""
        }

        return normalizedIconPopupPreviewText(text)
    }

    private func unusedTrailingIconPopupMediaTextPreviewText(_ message: String) -> String {
        // 对齐 widget main:src/components/Bubble/MediaTextMessage.vue：媒体+文字优先展示 caption，文档分支展示文件名。
        guard let msgData = messageJSONObject(message) else {
            return ""
        }

        if let caption = stringValue(msgData["caption"]) {
            return normalizedIconPopupPreviewText(caption)
        }

        if stringValue(msgData["file_type"]) == "document",
           let fileURL = stringValue(msgData["file_url"]) {
            return originFileName(fileURL)
        }

        return ""
    }

    private func messageJSONObject(_ message: String) -> [String: Any]? {
        guard let data = message.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 JSON.parse(info.channel_sort).filter(item !== 'chat')。
    private func channelSortFromPluginInfo(_ value: Any?) -> [String] {
        guard let rawChannelSort = stringValue(value),
              let data = rawChannelSort.data(using: .utf8),
              let list = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return []
        }
        return list.filter { $0 != "chat" }
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 show_effect.type，只有 type === '2' 表示 chat integration。
    private func integrationTypeFromShowEffect(_ value: Any?) -> String {
        guard let showEffect = pluginInfoObjectOrStringPayload(value) else {
            return "column"
        }
        return stringValue(showEffect["type"]) == "2" ? "chat" : "column"
    }

    // 对齐 widget main:src/components/SideBar/index.vue 的 show_side_config，解析 sidebar/single_icon 是否在 iOS 移动端承载渠道。
    private func sidebarStateFromShowSideConfig(_ value: Any?) -> (show: Bool, shrinkMode: String) {
        guard let sideConfig = pluginInfoObjectOrStringPayload(value) else {
            return (false, "sidebar")
        }

        let shrinkMode = stringValue(sideConfig["shrinkMode"]) == "2" ? "single_icon" : "sidebar"
        let visible = stringValue(sideConfig["type"]) == "2" ? "mobile" : stringValue(sideConfig["type"]) == "3" ? "desktop" : "all"
        let enabled = pluginInfoSwitchEnabled(sideConfig["switch"])
        let mode = config?.setting.mode
        let show: Bool
        if mode == .exclusiveLink {
            show = false
        } else if mode == .demo {
            show = enabled
        } else {
            show = enabled && (shrinkMode == "single_icon" || (shrinkMode == "sidebar" && (visible == "all" || visible == "mobile")))
        }

        return (show, shrinkMode)
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 show_*_config.switch === '1' 判断。
    private func pluginInfoNestedSwitchEnabled(_ info: SalesmartlyPayload, key: String) -> Bool {
        guard let payload = payloadValue(info[key]) else {
            return false
        }
        return pluginInfoSwitchEnabled(payload["switch"])
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 !!Number(value) 判断，仅处理 fact source 中出现的数字/数字字符串。
    private func pluginInfoSwitchEnabled(_ value: Any?) -> Bool {
        intValue(value) == 1
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 info.xxx === '1' 字符串开关判断。
    private func pluginInfoStringEqualsOne(_ value: Any?) -> Bool {
        stringValue(value) == "1"
    }

    // 对齐 Android `bulletinBoardFromRemote`，从 plugin/info 的 bulletin_board 生成公告栏配置。
    private func bulletinBoardFromPluginInfo(_ value: Any?) -> SalesmartlyBulletinBoardConfig {
        let defaultConfig = SalesmartlyBulletinBoardConfig()
        guard let rawBoard = payloadValue(value) else {
            return defaultConfig
        }

        let enableLink: Bool
        if let rawEnableLink = stringValue(rawBoard["enable_link"]),
           let number = Double(rawEnableLink) {
            enableLink = number == 1
        } else {
            enableLink = defaultConfig.enable_link
        }

        return SalesmartlyBulletinBoardConfig(
            enabled: pluginInfoSwitchEnabled(rawBoard["enabled"]),
            content: stringValue(rawBoard["content"]) ?? defaultConfig.content,
            link: stringValue(rawBoard["link"]) ?? defaultConfig.link,
            background_color: stringValue(rawBoard["background_color"]) ?? defaultConfig.background_color,
            enable_link: enableLink,
            board_mode: stringValue(rawBoard["board_mode"]) ?? defaultConfig.board_mode
        )
    }

    // 对齐 Android `collectionConfigFromRemote`，从 plugin/info 的 collect_information/offline_survey 生成留资配置。
    private func collectionConfigFromPluginInfo(_ value: Any?, defaultConfig: SalesmartlyCollectionConfig) -> SalesmartlyCollectionConfig {
        guard let rawCollection = payloadValue(value) else {
            return defaultConfig
        }

        let fieldOptions = collectionFieldOptionsFromPluginInfo(rawCollection["field_options"])
        return SalesmartlyCollectionConfig(
            collect_switch: pluginInfoSwitchEnabled(rawCollection["collect_switch"]),
            collect_required: pluginInfoSwitchEnabled(rawCollection["collect_required"]),
            collect_btn_switch: pluginInfoSwitchEnabled(rawCollection["collect_btn_switch"]),
            guidance: stringValue(rawCollection["guidance"]) ?? defaultConfig.guidance,
            status_text: stringValue(rawCollection["status_text"]) ?? defaultConfig.status_text,
            field_options: fieldOptions.isEmpty ? defaultConfig.field_options : fieldOptions
        )
    }

    // 对齐 Android `collectionFieldOptionFromRemote`，不扩展远端字段集合。
    private func collectionFieldOptionsFromPluginInfo(_ value: Any?) -> [SalesmartlyCollectionFieldOption] {
        guard let items = value as? [SalesmartlyPayload] else {
            return []
        }

        return items.map { item in
            SalesmartlyCollectionFieldOption(
                id: stringValue(item["id"]) ?? "",
                name: stringValue(item["name"]) ?? "",
                field_type: stringValue(item["field_type"]) ?? "0",
                required: stringValue(item["required"]) ?? "0",
                key: stringValue(item["key"]) ?? "",
                field_name: stringValue(item["field_name"]) ?? "",
                select_type: stringValue(item["select_type"]) ?? "0",
                select_content: collectionSelectOptionsFromPluginInfo(item["select_content"])
            )
        }
    }

    // 对齐 Android `collectionSelectOptionFromRemote`。
    private func collectionSelectOptionsFromPluginInfo(_ value: Any?) -> [SalesmartlyCollectionSelectOption] {
        guard let items = value as? [SalesmartlyPayload] else {
            return []
        }

        return items.map { item in
            SalesmartlyCollectionSelectOption(
                id: stringValue(item["id"]) ?? "",
                value: stringValue(item["value"]) ?? ""
            )
        }
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 show_custom_config JSON.parse 后 switch/id 读取。
    private func makePluginInfoCustomChannels(from info: SalesmartlyPayload) -> [String] {
        guard let showCustomConfig = stringValue(info["show_custom_config"]),
              let customEntries = pluginInfoPayloadListJSONObject(showCustomConfig) else {
            return []
        }

        return customEntries.compactMap { item in
            if pluginInfoSwitchEnabled(item["switch"]) {
                return stringValue(item["id"])
            }
            return nil
        }
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 中已确认的对象字段读取。
    private func payloadValue(_ value: Any?) -> SalesmartlyPayload? {
        value as? SalesmartlyPayload
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 中 show_effect/show_side_config 可能以对象或 JSON 字符串出现的远端形态。
    private func pluginInfoObjectOrStringPayload(_ value: Any?) -> SalesmartlyPayload? {
        if let payload = payloadValue(value) {
            return payload
        }
        guard let raw = stringValue(value),
              let data = raw.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload
    }

    // 对齐 widget main:src/helper/usePluginInfo.ts 的 JSON.parse(info.show_custom_config)。
    private func pluginInfoPayloadListJSONObject(_ value: String) -> [SalesmartlyPayload]? {
        guard let data = value.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data) as? [SalesmartlyPayload]
    }

    // 对齐 widget main:src/helper/useMessages.ts 的 readLocalConversation，从 conversationKey 读取本地会话并恢复到内存。
    private func loadLocalConversationState() {
        guard !state.conversationKey.isEmpty else {
            return
        }
        let rawValue = localRead(state.conversationKey)
        guard let data = rawValue.data(using: .utf8),
              let list = try? JSONSerialization.jsonObject(with: data) as? [SalesmartlyPayload] else {
            return
        }
        applyLocalConversationList(list.compactMap { makeChatMessageFromLocalConversationPayload($0) })
    }

    // 对齐 widget main:src/helper/useSocket.ts 的 saveConversation，消息变更后写回 conversationKey。
    private func saveLocalConversation() {
        guard !state.conversationKey.isEmpty, !state.messages.isEmpty else {
            return
        }
        let list = state.messages
            .filter { !shouldSkipLocalConversationSave($0) }
            .map { localConversationPayload(from: $0) }
        localSave(state.conversationKey, value: jsonString(from: list))
    }

    // 对齐 widget main:src/helper/useSocket.ts 的 saveConversation，过滤本地 blob 媒体临时地址。
    private func shouldSkipLocalConversationSave(_ message: ChatMessage) -> Bool {
        ["2", "45"].contains(message.msgType) && message.message.hasPrefix("blob")
    }

    // 对齐 widget main:src/helper/types.ts 的 MessageItem，本地会话使用 widget 字段名持久化。
    private func localConversationPayload(from message: ChatMessage) -> SalesmartlyPayload {
        var payload: SalesmartlyPayload = [
            "id": message.id,
            "send_type": message.sendType,
            "msg_type": message.msgType,
            "message": message.message,
            "mid": message.mid,
            "created_time": message.createdTime,
            "chat_user_id": message.chatUserId ?? "",
            "quote_chat": message.quoteChat,
        ]
        if let tempId = message.tempId {
            payload["tempId"] = tempId
        }
        if let status = message.status {
            payload["status"] = status
        }
        if let senderAvatar = message.senderAvatar {
            payload["sender_avatar"] = senderAvatar
        }
        if let senderName = message.senderName {
            payload["sender_name"] = senderName
        }
        if let clientMessageId = message.cMId {
            payload["c_m_id"] = clientMessageId
        }
        if let isRead = message.isRead {
            payload["isRead"] = isRead
        }
        if let likeResult = message.likeResult {
            payload["like_result"] = likeResult
        }
        if let isWithdraw = message.isWithdraw {
            payload["is_withdraw"] = isWithdraw
        }
        if let isStream = message.isStream {
            payload["is_stream"] = isStream
        }
        if let isStop = message.isStop {
            payload["is_stop"] = isStop
        }
        return payload
    }

    // 对齐 widget main:src/helper/types.ts 的 MessageItem，将 conversationKey 本地记录还原为 iOS ChatMessage。
    private func makeChatMessageFromLocalConversationPayload(_ payload: SalesmartlyPayload) -> ChatMessage? {
        guard let id = stringValue(payload["id"]),
              let msgType = stringValue(payload["msg_type"]),
              let message = stringValue(payload["message"]),
              let sendType = stringValue(payload["send_type"]),
              let mid = stringValue(payload["mid"]),
              let createdTime = int64Value(payload["created_time"]) else {
            return nil
        }
        let clientMessageId = stringValue(payload["c_m_id"])
        var clientExpandInfo: [String: String] = [:]
        if let clientMessageId {
            clientExpandInfo["c_m_id"] = clientMessageId
        }
        return ChatMessage(
            id: id,
            msgType: msgType,
            message: message,
            sendType: sendType,
            createdAt: Date(timeIntervalSince1970: TimeInterval(createdTime) / 1000),
            mid: mid,
            tempId: stringValue(payload["tempId"]),
            status: intValue(payload["status"]),
            createdTime: createdTime,
            cMId: clientMessageId,
            chatUserId: stringValue(payload["chat_user_id"]),
            senderName: stringValue(payload["sender_name"]),
            senderAvatar: stringValue(payload["sender_avatar"]),
            clientExpandInfo: clientExpandInfo,
            isRead: stringValue(payload["isRead"]),
            likeResult: payload["like_result"] as? [String: String],
            isWithdraw: stringValue(payload["is_withdraw"]),
            isStream: stringValue(payload["is_stream"]),
            isStop: stringValue(payload["is_stop"]),
            quoteChat: stringValue(payload["quote_chat"]) ?? ""
        )
    }

    private func jsonString(from value: Any) -> String {
        let data = try! JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }

    // 对齐 widget main:src/utils/storage.ts 的 encodeDefault，create-user data 使用标准 Base64 编码。
    private func encodeDefaultBase64(_ value: String) -> String {
        Data(value.utf8).base64EncodedString()
    }

    // 对齐 widget main:src/helper/getLocalKey.ts 的 key 拼接格式：guest 使用 common_plugin_suffix，user 使用 common_plugin_user_suffix。
    private func makeLocalStorageKey(pluginId: String, userId: String, suffix: String) -> String {
        if userId.isEmpty {
            return "\(Self.localStorageCommonKey)_\(pluginId)_\(suffix)"
        }

        return "\(Self.localStorageCommonKey)_\(pluginId)_\(userId)_\(suffix)"
    }

    // 对齐 widget main:src/stores/user.ts 的 setUserData/clearUserData，切换用户身份时同步 tokenKey、conversationKey、userInfoKey 等本地 key。
    private func applyLocalUserKeyContext(userId: String) {
        state.userType = userId.isEmpty ? "guest" : "user"
        state.localUserId = userId
        guard let pluginId = config?.license else {
            return
        }

        let keys = makeLocalUserKeys(pluginId: pluginId, userId: userId)
        state.tokenKey = keys.tokenKey
        state.tokenDateKey = keys.tokenDateKey
        state.conversationKey = keys.conversationKey
        state.newUserKey = keys.newUserKey
        state.userInfoKey = keys.userInfoKey
        state.customFieldsLocalKey = keys.customFieldsLocalKey
    }

    // 对齐 widget main:src/utils/storage.ts 的 sandbox 读禁用语义，沙盒模式不读取本地缓存。
    private func localRead(_ key: String) -> String {
        if config?.setting.mode == .sandbox {
            return ""
        }
        return localStore?.read(key) ?? ""
    }

    // 对齐 widget main:src/utils/storage.ts 的 sandbox 写禁用语义，沙盒模式不保存本地缓存。
    @discardableResult
    private func localSave(_ key: String, value: String) -> Bool {
        if config?.setting.mode == .sandbox {
            return false
        }
        return localStore?.save(key, value: value) ?? false
    }

    // 对齐 widget main:src/utils/storage.ts 的 sandbox 删除禁用语义，沙盒模式不清理本地缓存。
    private func localRemove(_ key: String) {
        if config?.setting.mode == .sandbox {
            return
        }
        localStore?.remove(key)
    }

    // 对齐 widget main:src/stores/user.ts 初始化 userInfo 时的 localRead(tokenKey) 与 getUserRecordInfo(userInfoKey)。
    private func loadLocalUserState() {
        guard !state.tokenKey.isEmpty, !state.userInfoKey.isEmpty else {
            return
        }

        let localToken = localRead(state.tokenKey)
        let record = readLocalUserRecord()
        if !localToken.isEmpty || state.userToken.isEmpty {
            state.userToken = localToken
        }
        state.isNewUser = state.userToken.isEmpty
        state.localChatUserId = stringValue(record["chat_user_id"]) ?? ""
    }

    // 对齐 widget main:src/helper/userTool.ts 的 getUserRecordInfo，读取失败时使用 { info: {} }。
    private func readLocalUserRecord() -> SalesmartlyPayload {
        guard !state.userInfoKey.isEmpty else {
            return ["info": SalesmartlyPayload()]
        }

        let rawValue = localRead(state.userInfoKey)
        guard let data = rawValue.data(using: .utf8),
              let record = try? JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload else {
            return ["info": SalesmartlyPayload()]
        }
        return record
    }

    // 对齐 widget main:src/helper/userTool.ts 的 saveUserRecordInfo，合并已确认字段后写回 userInfoKey。
    private func saveLocalUserRecord(_ record: SalesmartlyPayload) {
        guard !state.userInfoKey.isEmpty else {
            return
        }
        localSave(state.userInfoKey, value: jsonString(from: record))
    }

    // 对齐 widget main:src/components/Bubble/TemplateMessage/PromotionalCard.vue 的 saveUserRecordInfo(userInfoKey,{ info:{ email } })。
    private func savePromotionalCardEmail(_ email: String) {
        var record = readLocalUserRecord()
        var info: SalesmartlyPayload = [:]
        if let existingInfo = record["info"] as? SalesmartlyPayload {
            info = existingInfo
        }
        info["email"] = email
        record["info"] = info
        saveLocalUserRecord(record)
    }

    // 对齐 widget main:src/helper/useLocal.ts 的 createUser.then，保存 tokenDateKey、chat_user_id、新用户标记和访客创建时间。
    private func saveCreateUserLocalState(chatUserId: String, isNewUser: Bool, nowMilliseconds: Int64) {
        localSave(state.tokenDateKey, value: "\(nowMilliseconds)")
        var record = readLocalUserRecord()
        record["chat_user_id"] = chatUserId
        if (state.loginInfo?.userId ?? "").isEmpty {
            record[Self.createUserLastTimeLocalKey] = "\(nowMilliseconds)"
        }
        saveLocalUserRecord(record)
        if isNewUser {
            localRemove(state.newUserKey)
        }
    }

    // 对齐 widget main:src/utils/storage.ts 的 localRemove，执行 clearUserData/removeUserLocalInfo 产出的删除列表。
    private func removeLocalKeys(_ keys: [String]) {
        keys.forEach { key in
            localRemove(key)
        }
    }

    // 对齐 widget main:src/helper/useLocal.ts 的 lessTime/setTimeout 计算，3 秒内按已过去时间延迟，超过 3 秒立即请求。
    private func makeCreateUserRequestDelay(nowMilliseconds: Int64) -> Int64 {
        guard state.createUserTokenSavedDateMilliseconds > 0 else {
            return 0
        }
        let elapsedMilliseconds = max(0, nowMilliseconds - state.createUserTokenSavedDateMilliseconds)
        return elapsedMilliseconds > 3 * 1000 ? 0 : elapsedMilliseconds
    }

    // 对齐 widget main:src/utils/SsmEvent.ts 的 setUserInfo(data:any)，仅为现有 iOS 字符串字典状态提取字符串值；完整对象以 userInfoJSONString 为准。
    private func stringUserInfo(from payload: SalesmartlyPayload) -> [String: String] {
        payload.compactMapValues { $0 as? String }
    }

    private func appendUpdateUserInfoFields(
        to payload: inout SalesmartlyPayload,
        userName: String?,
        phone: String?,
        email: String?,
        language: String?,
        data: String?,
        company: String?
    ) {
        if let userName {
            payload["user_name"] = userName
        }
        if let phone {
            payload["phone"] = phone
        }
        if let email {
            payload["email"] = email
        }
        if let language {
            payload["language"] = language
        }
        if let data {
            payload["data"] = data
        }
        if let company {
            payload["company"] = company
        }
    }

    // 对齐 widget main:src/utils/tool.ts 的 regular.email。
    private static func isPromotionalCardEmail(_ email: String) -> Bool {
        email.range(
            of: Self.promotionalCardEmailPattern,
            options: .regularExpression
        ) != nil
    }

    private func shouldIncludeCollectionPayloadValue(_ value: Any) -> Bool {
        if let text = value as? String {
            return !text.isEmpty
        }
        return true
    }

    private func collectionInfoPayload(payload: SalesmartlyPayload, collectionType: String) -> SalesmartlyPayload {
        var nextPayload = payload
        nextPayload["type"] = collectionType
        return nextPayload
    }

    private func isDemoMode() -> Bool {
        config?.setting.mode == .demo
    }

    private func messageText(from value: Any) -> String {
        if let value = value as? String {
            return value
        }
        return jsonString(from: value)
    }

    private func pushJoinSessionSystemMessage(pushTime: Int64?, chatUserId: String?, nickname: String?) {
        guard let pushTime, let chatUserId, let nickname else {
            return
        }

        let messageId = String(pushTime)
        guard !state.messages.contains(where: { $0.id == messageId }) else {
            return
        }

        state.messages.append(
            ChatMessage(
                id: messageId,
                msgType: "8",
                message: joinSessionMessage(nickname: nickname),
                sendType: "2",
                createdAt: Date(timeIntervalSince1970: TimeInterval(transformSendTime(pushTime)) / 1000),
                mid: messageId,
                createdTime: transformSendTime(pushTime),
                chatUserId: chatUserId
            )
        )
    }

    private func joinSessionMessage(nickname: String) -> String {
        let data = try! JSONSerialization.data(withJSONObject: [nickname])
        let nicknameList = String(data: data, encoding: .utf8)!
        let escapedNickname = nicknameList.dropFirst().dropLast()
        return #"{"type":"join_session","nickname":\#(escapedNickname)}"#
    }

    private func setAssignUserInfo(sysUserId: String, nickname: String, avatar: String?, sysUserAvatar: String?) {
        var resolvedAvatar = ""
        if let avatar {
            resolvedAvatar = avatar
        } else if let sysUserAvatar {
            resolvedAvatar = sysUserAvatar
        }
        state.assignUserInfo = [
            "avatar": resolvedAvatar,
            "nickname": nickname,
            "sys_user_id": sysUserId,
        ]
    }

    private func resetAssignUserInfo() {
        state.assignUserInfo = [
            "avatar": "",
            "nickname": "",
            "sys_user_id": "",
        ]
    }

    private func emptyStringWhenMissing(_ value: String?) -> String {
        if let value {
            return value
        }
        return ""
    }

    private func makeQuestionContext(for message: ChatMessage) -> QuestionContext? {
        guard message.msgType != "5",
              let messageIndex = state.messages.firstIndex(where: { item in
                  item.id == message.id && item.tempId == message.tempId && item.cMId == message.cMId
              }),
              messageIndex > 0 else {
            return nil
        }

        let previousMessage = state.messages[messageIndex - 1]
        guard previousMessage.msgType == "3",
              let data = previousMessage.message.data(using: .utf8),
              let msgData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let payload = msgData["payload"] as? [String: Any],
              let rawBranches = payload["branches"] as? [[String: Any]],
              let questionId = payload["question_id"] as? String else {
            return nil
        }

        let branches = rawBranches.compactMap { branch -> [String: String]? in
            guard let title = branch["title"] as? String,
                  let postback = branch["postback"] as? String else {
                return nil
            }
            return [
                "title": title,
                "postback": postback,
            ]
        }

        guard !branches.isEmpty, branches.count == rawBranches.count else {
            return nil
        }

        return QuestionContext(branches: branches, questionId: questionId)
    }

    private func normalizeUserId(_ userId: String) -> String? {
        if userId.utf16.count > 300 {
            return nil
        }
        if userId.unicodeScalars.allSatisfy({ $0.value < 128 }) {
            return userId
        }
        return userId.addingPercentEncoding(withAllowedCharacters: Self.encodeURIComponentAllowedCharacters)!
    }

    private func transformSendTime(_ sendTime: Int64) -> Int64 {
        if String(abs(sendTime)).count == 11 {
            return sendTime * 1000
        }
        return sendTime
    }

    private func currentTimestamp() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}

public enum SalesmartlyChat {
    nonisolated(unsafe) private static var sharedRuntime = SalesmartlyRuntime()

    public static func runtime() -> SalesmartlyRuntime {
        sharedRuntime
    }

    public static func reset(runtime: SalesmartlyRuntime = SalesmartlyRuntime()) {
        sharedRuntime = runtime
    }

    public static func initialize(config: SalesmartlyConfig) {
        initialize(
            config: config,
            environment: SalesmartlyEnvironment.androidEndpointEnvironment(
                requestOriginURL: config.setting.requestOriginURL,
                widgetHost: config.setting.widgetHost
            ),
            nativeBootstrapContext: nil
        )
    }

    /// 对齐 Android `SalesmartlyChat.initialize(context, scriptUrl)`，iOS SDK 拉取外层脚本解析 license 和 install path 后启动原生 runtime，不执行 Web widget bundle。
    public static func initialize(
        scriptURL: URL
    ) async throws {
        try await initialize(
            scriptURL: scriptURL,
            scriptFetcher: SalesmartlyURLSessionProjectScriptFetcher()
        )
    }

    /// 对齐 Android `SalesmartlyChat.initialize(context, scriptUrl)` 的字符串地址入口。
    public static func initialize(
        scriptURL: String
    ) async throws {
        try await initialize(
            scriptURL: scriptURL,
            scriptFetcher: SalesmartlyURLSessionProjectScriptFetcher()
        )
    }

    /// 对齐线上 project_*.js 脚本接入语义，允许测试或宿主显式注入运行环境。
    public static func initialize(
        scriptURL: URL,
        environment: SalesmartlyEnvironment
    ) async throws {
        try await initialize(
            scriptURL: scriptURL,
            environment: environment,
            scriptFetcher: SalesmartlyURLSessionProjectScriptFetcher()
        )
    }

    /// 对齐线上 project_*.js 脚本接入和 widget main:src/utils/env.ts 的页面上下文语义，宿主传入 iOS 原生 create-user 所需上下文。
    public static func initialize(
        scriptURL: URL,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext
    ) async throws {
        try await initialize(
            scriptURL: scriptURL,
            scriptFetcher: SalesmartlyURLSessionProjectScriptFetcher(),
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐 Android 字符串脚本地址入口和 widget main:src/utils/env.ts 的页面上下文语义。
    public static func initialize(
        scriptURL: String,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext
    ) async throws {
        try await initialize(
            scriptURL: scriptURL,
            scriptFetcher: SalesmartlyURLSessionProjectScriptFetcher(),
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐线上 project_*.js 脚本接入和 widget main:src/utils/env.ts 的页面上下文语义，显式环境由测试或宿主传入。
    public static func initialize(
        scriptURL: URL,
        environment: SalesmartlyEnvironment,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext
    ) async throws {
        try await initialize(
            scriptURL: scriptURL,
            environment: environment,
            scriptFetcher: SalesmartlyURLSessionProjectScriptFetcher(),
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐线上 project_*.js 脚本接入语义的测试入口，允许注入脚本 fixture 以避免真实网络请求。
    static func initialize(
        scriptURL: URL,
        scriptFetcher: SalesmartlyProjectScriptFetching,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext? = nil
    ) async throws {
        let script = try await scriptFetcher.fetchProjectScript(from: scriptURL)
        let bootstrap = try SalesmartlyProjectScriptParser.parse(script, scriptURL: scriptURL)
        try initialize(
            bootstrap: bootstrap,
            environment: SalesmartlyEnvironment.projectScriptEnvironment(installPath: bootstrap.installPath),
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐 Android 字符串脚本地址测试入口，URL 无效时按网络地址错误抛出。
    static func initialize(
        scriptURL: String,
        scriptFetcher: SalesmartlyProjectScriptFetching,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext? = nil
    ) async throws {
        guard let url = URL(string: scriptURL) else {
            throw URLError(.badURL)
        }
        try await initialize(
            scriptURL: url,
            scriptFetcher: scriptFetcher,
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐线上 project_*.js 脚本接入语义的显式环境测试入口。
    static func initialize(
        scriptURL: URL,
        environment: SalesmartlyEnvironment,
        scriptFetcher: SalesmartlyProjectScriptFetching,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext? = nil
    ) async throws {
        let script = try await scriptFetcher.fetchProjectScript(from: scriptURL)
        let bootstrap = try SalesmartlyProjectScriptParser.parse(script, scriptURL: scriptURL)
        try initialize(
            bootstrap: bootstrap,
            environment: environment,
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐 Android `ProjectScriptInitializer` 加载成功后调用既有 initialize(config) 的共享落地逻辑。
    private static func initialize(
        bootstrap: SalesmartlyProjectScriptBootstrap,
        environment: SalesmartlyEnvironment,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext?
    ) throws {
        initialize(
            config: SalesmartlyConfig(license: bootstrap.license),
            environment: environment,
            nativeBootstrapContext: nativeBootstrapContext
        )
    }

    /// 对齐 Android config 初始化与 project script 初始化的共同落地：构造环境、安装 HTTP/Socket/upload transport，并立即请求 plugin/info。
    private static func initialize(
        config: SalesmartlyConfig,
        environment: SalesmartlyEnvironment,
        nativeBootstrapContext: SalesmartlyNativeBootstrapContext?
    ) {
        let context = SalesmartlyPluginRequestContext(
            pluginId: config.license,
            mode: config.setting.mode.rawValue
        )
        let runtime = sharedRuntime
        let httpTransport = SalesmartlyURLSessionTransport(
            environment: environment,
            contextProvider: {
                // 对齐 widget main:src/api/axios.ts 的请求时读取 localToken/projectId，脚本初始化后的 create-user 与 plugin/info reducer 会更新 runtime state。
                SalesmartlyPluginRequestContext(
                    pluginId: context.pluginId,
                    mode: context.mode,
                    overTime: context.overTime,
                    localToken: runtime.state.userToken,
                    uid: context.uid,
                    projectId: runtime.state.pluginProjectId
                )
            }
        )
        if sharedRuntime.shouldInstallDefaultUploadExecutor() {
            sharedRuntime.installDefaultUploadExecutor(
                SalesmartlyURLSessionUploadExecutor(
                    environment: environment,
                    contextProvider: {
                        // 对齐 widget main:src/api/axios.ts 的请求上下文，OSS config 获取同样需要运行时最新 token 与 projectId。
                        SalesmartlyPluginRequestContext(
                            pluginId: context.pluginId,
                            mode: context.mode,
                            overTime: context.overTime,
                            localToken: runtime.state.userToken,
                            uid: context.uid,
                            projectId: runtime.state.pluginProjectId
                        )
                    }
                )
            )
        }
        if sharedRuntime.shouldInstallDefaultTransport() {
            #if canImport(SocketIO)
            let socketTransport = SalesmartlySocketIOTransport(socketURL: environment.webSocketURL)
            sharedRuntime.installDefaultTransport(
                SalesmartlyCompositeTransport(
                    httpTransport: httpTransport,
                    socketTransport: socketTransport
                )
            )
            #else
            sharedRuntime.installDefaultTransport(httpTransport)
            #endif
        }
        if let nativeBootstrapContext {
            sharedRuntime.setNativeBootstrapContext(nativeBootstrapContext)
        }
        sharedRuntime.setRealtimeCentrifugoURL(environment.centrifugoURL)
        sharedRuntime.state.widgetHost = environment.widgetURL.absoluteString
        sharedRuntime.initialize(config: config)
        sharedRuntime.sendPluginInfoTransportRequest()
    }

    public static func openChat() {
        sharedRuntime.openChatEntry()
    }

    public static func closeChat() {
        sharedRuntime.closeChat()
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 visibilitychange 监听，供 iOS 宿主向全局 runtime 同步窗口可见性。
    @discardableResult
    public static func setWindowVisible(_ isVisible: Bool) -> SalesmartlyPayload? {
        sharedRuntime.setWindowVisible(isVisible)
    }

    public static func setLoginInfo(_ loginInfo: LoginInfo) {
        sharedRuntime.setLoginInfo(loginInfo)
    }

    public static func setUserInfo(_ userInfo: [String: String]) {
        sharedRuntime.setUserInfo(userInfo)
    }

    /// 对齐 widget main:src/utils/SsmEvent.ts 的 ssq.push("setUserInfo", data:any)，允许全局 API 传入 JSON 对象 payload。
    public static func setUserInfo(_ userInfo: SalesmartlyPayload) {
        sharedRuntime.setUserInfo(userInfo)
    }

    public static func clearUser() {
        sharedRuntime.clearUser()
    }

    public static func sendTextMessage(_ text: String) {
        sharedRuntime.sendTextMessage(text)
    }

    public static func showCollection() {
        sharedRuntime.showCollection()
    }

    /// 对齐 Android sample `SalesmartlyChat.showCollection(true)` 的宿主入口，允许示例和宿主显式打开或关闭留资弹窗。
    public static func showCollection(_ visible: Bool) {
        sharedRuntime.showCollection(visible)
    }

    public static func showOffline() {
        sharedRuntime.showOffline()
    }

    /// 对齐 Android sample `SalesmartlyChat.showOffline(true/false)` 的宿主入口，允许显式打开或关闭离线留资弹窗。
    public static func showOffline(_ visible: Bool) {
        sharedRuntime.showOffline(visible)
    }

    public static func setNotificationStatus(_ enabled: Bool) {
        sharedRuntime.setNotificationStatus(enabled)
    }

    /// 对齐 widget main:src/helper/types.ts 的 flashTitle/soundNotice 插件配置，向全局 runtime 同步未读标题闪烁与声音提醒开关。
    public static func setNotificationConfiguration(flashTitle: Bool, soundNotice: Bool) {
        sharedRuntime.setNotificationConfiguration(flashTitle: flashTitle, soundNotice: soundNotice)
    }

    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 Launcher 高度测量，供全局 runtime 记录折叠侧边栏高度。
    public static func setCollapsedSidebarHeight(_ height: Int) {
        sharedRuntime.setCollapsedSidebarHeight(height)
    }

    /// 对齐 widget main:src/components/ColumnChannel.vue、src/components/SideBar/index.vue 与 src/components/Launcher/index.vue 的 data-ssc-launcher-height-target，向全局 runtime 记录可见 Launcher 高度目标。
    public static func setLauncherHeightTargetFrames(_ frames: [SalesmartlyLauncherHeightTargetFrame]) {
        sharedRuntime.setLauncherHeightTargetFrames(frames)
    }

    /// 对齐 widget main:src/utils/sidebarHeight.ts 的 getCollapsedSidebarHeight，读取全局 runtime 当前聚合后的 Launcher 高度。
    public static func getSidebarHeight() -> Int? {
        sharedRuntime.getSidebarHeight()
    }

    /// 对齐 widget main:src/App.vue 的 getSidebarHeight 命令，读取全局 runtime 的折叠侧边栏高度并回调。
    public static func getSidebarHeight(callback: SalesmartlySidebarHeightCallback) {
        sharedRuntime.getSidebarHeight(callback: callback)
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 originTitle 与 title.newMsg，向全局 runtime 同步宿主标题闪烁配置。
    public static func setNotificationTitleConfiguration(originTitle: String, newMessageTitle: String) {
        sharedRuntime.setNotificationTitleConfiguration(originTitle: originTitle, newMessageTitle: newMessageTitle)
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 parentDoc.title，宿主标题变化时同步到全局 runtime。
    public static func setNotificationCurrentTitle(_ title: String) {
        sharedRuntime.setNotificationCurrentTitle(title)
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 flashTitle 800ms 定时切换，由宿主定时器或生命周期回调推进标题状态。
    @discardableResult
    public static func advanceNotificationFlashTitle(nowMilliseconds: Int64) -> Bool {
        sharedRuntime.advanceNotificationFlashTitle(nowMilliseconds: nowMilliseconds)
    }

    /// 对齐 widget main:src/helper/useSocket.ts 的 timerHide/typingTimer，供全局 runtime 推进 typing 自动隐藏状态。
    @discardableResult
    public static func advanceTypingTimers(nowMilliseconds: Int64) -> Bool {
        sharedRuntime.advanceTypingTimers(nowMilliseconds: nowMilliseconds)
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 Notification/sound/click 处理，向全局 runtime 注入宿主通知处理器。
    public static func setNotificationHandler(_ handler: SalesmartlyNotificationHandling?) {
        sharedRuntime.setNotificationHandler(handler)
    }

    /// 对齐 widget main:src/helper/useNotification.ts 的 msg.onclick，通知点击后触发聚焦和关闭动作。
    public static func handleUnreadNotificationClick() {
        sharedRuntime.handleUnreadNotificationClick()
    }

    public static func hideUpload(_ types: [String]) {
        sharedRuntime.hideUpload(types)
    }

    public static func hideCloseIcon(_ hidden: Bool = true) {
        sharedRuntime.hideCloseIcon(hidden)
    }

    public static func openCustomEntry(_ entryId: String) {
        sharedRuntime.openCustomEntry(entryId)
    }

    public static func trackUrl(_ url: String) {
        sharedRuntime.trackUrl(url)
    }

    public static func setDemo(_ payload: [String: String]) {
        sharedRuntime.setDemo(payload)
    }

    /// 对齐 Android `setDemo(SalesmartlyPayload)`，允许 demo 数据携带布尔、数字或嵌套对象。
    public static func setDemo(_ payload: SalesmartlyPayload) {
        sharedRuntime.setDemo(payload)
    }

    public static func push(command: String, payload: Any? = nil) {
        sharedRuntime.push(command: command, payload: payload)
    }

    public static func push(_ command: String, _ payload: Any? = nil) {
        sharedRuntime.push(command: command, payload: payload)
    }

    public static func push(_ eventName: String, callback: @escaping SalesmartlyCallback) {
        sharedRuntime.registerCallback(eventName, callback: callback)
    }
}
