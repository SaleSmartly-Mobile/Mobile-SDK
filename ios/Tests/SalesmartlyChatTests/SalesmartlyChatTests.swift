#if canImport(XCTest)
import XCTest
@testable import SalesmartlyChat

final class SalesmartlyTransportSpy: SalesmartlyTransporting {
    var requests: [SalesmartlyTransportRequest] = []
    var responseHandler: SalesmartlyTransportResponseHandler?
    var socketInboundEventHandler: SalesmartlySocketInboundEventHandler?
    var sseInboundPayloadHandler: SalesmartlySSEInboundPayloadHandler?
    var socketConnections: [SalesmartlySocketConnectionRequest] = []
    var sseConnections: [SalesmartlySSEConnectionRequest] = []
    var socketDisconnectCount = 0
    var sseDisconnectCount = 0
    var removedBufferedSocketEvents: [String] = []
    var removedSocketEventHandlerBatches: [[String]] = []
    var addedSocketEventHandlerBatches: [[String]] = []
    var reconnectDelays: [Int] = []
    var addedPongHandlerCount = 0
    var removedPongHandlerCount = 0

    func send(_ request: SalesmartlyTransportRequest) {
        requests.append(request)
    }

    func setResponseHandler(_ handler: @escaping SalesmartlyTransportResponseHandler) {
        responseHandler = handler
    }

    func respond(_ response: SalesmartlyPayload, requestIndex: Int) {
        responseHandler?(response, requests[requestIndex])
    }

    func setSocketInboundEventHandler(_ handler: @escaping SalesmartlySocketInboundEventHandler) {
        socketInboundEventHandler = handler
    }

    func setSSEInboundPayloadHandler(_ handler: @escaping SalesmartlySSEInboundPayloadHandler) {
        sseInboundPayloadHandler = handler
    }

    func emitSocketEvent(_ eventName: String, payload: SalesmartlyPayload) {
        socketInboundEventHandler?(eventName, payload)
    }

    func emitSSEPayload(_ payload: SalesmartlyPayload) {
        sseInboundPayloadHandler?(payload)
    }

    func connectSocket(_ request: SalesmartlySocketConnectionRequest) {
        socketConnections.append(request)
    }

    func connectSSE(_ request: SalesmartlySSEConnectionRequest) {
        sseConnections.append(request)
    }

    func disconnectSocket() {
        socketDisconnectCount += 1
    }

    func disconnectSSE() {
        sseDisconnectCount += 1
    }

    func removeBufferedSocketEvent(_ eventName: String) {
        removedBufferedSocketEvents.append(eventName)
    }

    func removeSocketEventHandlers(_ eventNames: [String]) {
        removedSocketEventHandlerBatches.append(eventNames)
    }

    func addSocketEventHandlers(_ eventNames: [String]) {
        addedSocketEventHandlerBatches.append(eventNames)
    }

    func addSocketPongHandler() {
        addedPongHandlerCount += 1
    }

    func removeSocketPongHandler() {
        removedPongHandlerCount += 1
    }

    func reconnectSocketAfterHeartbeatTimeout(delayMilliseconds: Int) {
        reconnectDelays.append(delayMilliseconds)
    }
}

final class SalesmartlyUploadExecutorSpy: SalesmartlyUploadExecuting {
    var requests: [SalesmartlyUploadExecutionRequest] = []
    var nextFileURL: String
    var shouldFail: Bool

    init(nextFileURL: String, shouldFail: Bool = false) {
        self.nextFileURL = nextFileURL
        self.shouldFail = shouldFail
    }

    func upload(_ request: SalesmartlyUploadExecutionRequest) async throws -> String {
        requests.append(request)
        if shouldFail {
            throw URLError(.cannotConnectToHost)
        }
        return nextFileURL
    }
}

final class SalesmartlyNotificationSpy: SalesmartlyNotificationHandling {
    var requestedStatuses: [String] = []
    var permissionStatus = "granted"
    var showCount = 0
    var soundCount = 0
    var focusCount = 0
    var closeCount = 0

    func requestUnreadNotificationPermission(currentStatus: String) -> String {
        requestedStatuses.append(currentStatus)
        return permissionStatus
    }

    func showUnreadNotification() {
        showCount += 1
    }

    func playUnreadSound() {
        soundCount += 1
    }

    func focusNotificationTarget() {
        focusCount += 1
    }

    func closeUnreadNotification() {
        closeCount += 1
    }
}

final class SalesmartlyProjectScriptFixtureFetcher: SalesmartlyProjectScriptFetching {
    var requestedURLs: [URL] = []
    var script: String

    init(script: String) {
        self.script = script
    }

    func fetchProjectScript(from url: URL) async throws -> String {
        requestedURLs.append(url)
        return script
    }
}

final class SalesmartlySSEStreamSpy: SalesmartlySSEStreaming {
    var startCount = 0
    var stopCount = 0
    let onOpen: () -> Void
    let onPayload: (SalesmartlyPayload) -> Void

    init(
        url: URL,
        onOpen: @escaping () -> Void,
        onPayload: @escaping (SalesmartlyPayload) -> Void
    ) {
        self.onOpen = onOpen
        self.onPayload = onPayload
    }

    func start() {
        startCount += 1
    }

    func stop() {
        stopCount += 1
    }

    func emitOpen() {
        onOpen()
    }

    func emitPayload(_ payload: SalesmartlyPayload) {
        onPayload(payload)
    }
}

final class SalesmartlyURLProtocolSpy: URLProtocol {
    nonisolated(unsafe) static var requests: [URLRequest] = []
    nonisolated(unsafe) static var bodies: [Data] = []
    nonisolated(unsafe) static var responseBody = #"{"code":0,"data":{"ok":true}}"#.data(using: .utf8)!
    nonisolated(unsafe) static var responseBodies: [Data] = []
    nonisolated(unsafe) static var heldPaths: Set<String> = []
    nonisolated(unsafe) static var heldLoaders: [String: [() -> Void]] = [:]

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.requests.append(request)
        Self.bodies.append(Self.bodyData(from: request))
        let load = {
            let response = HTTPURLResponse(
                url: self.request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            let responseBody = Self.responseBodies.isEmpty ? Self.responseBody : Self.responseBodies.removeFirst()
            self.client?.urlProtocol(self, didLoad: responseBody)
            self.client?.urlProtocolDidFinishLoading(self)
        }
        if let path = request.url?.path, Self.heldPaths.contains(path) {
            var loaders = Self.heldLoaders[path] ?? []
            loaders.append(load)
            Self.heldLoaders[path] = loaders
            return
        }
        load()
    }

    override func stopLoading() {}

    static func releaseHeldPath(_ path: String) {
        let loaders = heldLoaders.removeValue(forKey: path) ?? []
        loaders.forEach { $0() }
    }

    private static func bodyData(from request: URLRequest) -> Data {
        if let body = request.httpBody {
            return body
        }
        guard let stream = request.httpBodyStream else {
            return Data()
        }
        stream.open()
        defer {
            stream.close()
        }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while stream.hasBytesAvailable {
            let count = stream.read(buffer, maxLength: bufferSize)
            if count <= 0 {
                break
            }
            data.append(buffer, count: count)
        }
        return data
    }
}

final class SalesmartlySocketIOClientSpy: SalesmartlySocketIOClienting {
    var connectedQueries: [[String: Any]] = []
    var connectedTransports: [[String]] = []
    var connectedReconnectionAttempts: [Int] = []
    var connectedSocketIOProtocolVersions: [Int] = []
    /// 对齐 widget main:src/helper/socket.ts 的 connect 事件，用于单测触发 Swift 侧发送缓冲 flush。
    var connectHandler: (() -> Void)?
    var emittedEvents: [(eventName: String, jsonPayload: String)] = []
    var inboundHandlers: [String: (SalesmartlyPayload) -> Void] = [:]
    var disconnectedCount = 0
    var removedBufferedEvents: [String] = []
    var offEvents: [String] = []
    var pongHandler: (() -> Void)?
    var reconnectDelays: [Int] = []

    func connect(
        query: [String: Any],
        transports: [String],
        reconnectionAttempts: Int,
        socketIOProtocolVersion: SalesmartlySocketIOProtocolVersion,
        onConnect: @escaping () -> Void
    ) {
        connectedQueries.append(query)
        connectedTransports.append(transports)
        connectedReconnectionAttempts.append(reconnectionAttempts)
        connectedSocketIOProtocolVersions.append(socketIOProtocolVersion.rawValue)
        connectHandler = onConnect
    }

    func disconnect() {
        disconnectedCount += 1
    }

    func emit(eventName: String, jsonPayload: String, ack: @escaping (SalesmartlyPayload) -> Void) {
        emittedEvents.append((eventName: eventName, jsonPayload: jsonPayload))
        _ = ack
    }

    func on(eventName: String, callback: @escaping (SalesmartlyPayload) -> Void) {
        inboundHandlers[eventName] = callback
    }

    func off(eventName: String) {
        offEvents.append(eventName)
        inboundHandlers.removeValue(forKey: eventName)
    }

    func removeBufferedEvent(_ eventName: String) {
        removedBufferedEvents.append(eventName)
    }

    func addPongHandler(_ callback: @escaping () -> Void) {
        pongHandler = callback
    }

    func removePongHandler() {
        pongHandler = nil
    }

    func reconnectAfterHeartbeatTimeout(delayMilliseconds: Int) {
        reconnectDelays.append(delayMilliseconds)
    }

    func emitInbound(eventName: String, payload: SalesmartlyPayload) {
        inboundHandlers[eventName]?(payload)
    }

    /// 模拟 Socket.IO client connect 事件，验证 join-room 等事件在连接后补发。
    func emitConnect() {
        connectHandler?()
    }
}

/// 对齐 widget main:src/utils/storage.ts 的 localRead/localSave/localRemove，用于单测观察本地缓存读写和删除行为。
final class SalesmartlyLocalStoreSpy: SalesmartlyLocalStoring {
    var values: [String: String] = [:]
    var savedValues: [(key: String, value: String)] = []
    var removedKeys: [String] = []

    func read(_ key: String) -> String {
        values[key] ?? ""
    }

    @discardableResult
    func save(_ key: String, value: String) -> Bool {
        values[key] = value
        savedValues.append((key: key, value: value))
        return true
    }

    func remove(_ key: String) {
        values.removeValue(forKey: key)
        removedKeys.append(key)
    }
}

actor SalesmartlyRemoteResourceLoadCounter {
    private var value = 0

    func increment() {
        value += 1
    }

    func count() -> Int {
        value
    }
}

final class SalesmartlyChatTests: XCTestCase {
    private func waitForURLProtocolRequestCount(_ count: Int, timeout: TimeInterval = 2) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while SalesmartlyURLProtocolSpy.requests.count < count, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    private func chatMsgEventData(
        from request: SalesmartlyTransportRequest,
        event: String,
        loginToken: String = "token_1",
        chatUserId: String = "chat_user_1"
    ) throws -> SalesmartlyPayload {
        XCTAssertEqual(request.kind, .http)
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.path, "/chat/chat-msg/event")
        XCTAssertEqual(request.bodyEncoding, .json)
        XCTAssertEqual(request.externalSign, true)
        XCTAssertEqual(request.payload["login_token"] as? String, loginToken)
        XCTAssertEqual(request.payload["chat_user_id"] as? String, chatUserId)
        XCTAssertEqual(request.payload["event"] as? String, event)

        let dataString = try XCTUnwrap(request.payload["data"] as? String)
        let data = try XCTUnwrap(dataString.data(using: .utf8))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload)
    }

    func testInitializeStoresConfigAndDispatchesQueuedReadyCallback() async throws {
        let runtime = SalesmartlyRuntime()
        var readyPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onReady") { payload in
            readyPayload = payload
        }

        let config = SalesmartlyConfig(
            license: "YOUR_LICENSE",
            setting: SalesmartlySetting(mode: .chat, showNotification: true)
        )

        SalesmartlyChat.initialize(config: config)

        XCTAssertEqual(runtime.config?.license, "YOUR_LICENSE")
        XCTAssertTrue(runtime.state.isReady)
        XCTAssertEqual(readyPayload["mode"] as? String, "chat")
    }

    /// 对齐 Android `EndpointResolver`：config 初始化时从 `requestOriginURL` 与 `widgetHost` 推导 API、msg、socket 和 widget host。
    func testConfigEndpointEnvironmentMatchesAndroidEndpointResolver() async throws {
        let environment = SalesmartlyEnvironment.androidEndpointEnvironment(
            requestOriginURL: "aHR0cHM6Ly9hcHAtZGV2LnNhbGVzbWFydGx5LmNvbQ==",
            widgetHost: "https://widget-dev.salesmartly.com"
        )

        XCTAssertEqual(environment.baseAPIURL.absoluteString, "https://api-dev.salesmartly.com/")
        XCTAssertEqual(environment.webSocketHTTPURL.absoluteString, "https://msg-dev.salesmartly.com/")
        XCTAssertEqual(environment.webSocketURL.absoluteString, "wss://msg-ws-dev.salesmartly.com/")
        XCTAssertEqual(environment.widgetURL.absoluteString, "https://widget-dev.salesmartly.com/")
    }

    /// 对齐 Android `SalesmartlyChat.initialize(config)`：原生 config 入口应安装 HTTP/Socket/upload transport，并立即请求 plugin/info。
    func testInitializeConfigInstallsTransportAndRequestsPluginInfo() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBody = #"{"code":0,"data":{}}"#.data(using: .utf8)!

        URLProtocol.registerClass(SalesmartlyURLProtocolSpy.self)
        defer { URLProtocol.unregisterClass(SalesmartlyURLProtocolSpy.self) }
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_config_1",
                setting: SalesmartlySetting(
                    mode: .chat,
                    requestOriginURL: "aHR0cHM6Ly9hcHAtZGV2LnNhbGVzbWFydGx5LmNvbQ==",
                    widgetHost: "https://widget-dev.salesmartly.com"
                )
            )
        )
        try await waitForURLProtocolRequestCount(1)

        XCTAssertEqual(runtime.config?.license, "plugin_config_1")
        XCTAssertEqual(runtime.state.widgetHost, "https://widget-dev.salesmartly.com/")
        let request = try XCTUnwrap(SalesmartlyURLProtocolSpy.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.host, "widget-dev.salesmartly.com")
        XCTAssertEqual(request.url?.path, "/plugin/info")
        XCTAssertEqual(
            URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)?
                .queryItems?
                .first { $0.name == "plugin_id" }?
                .value,
            "plugin_config_1"
        )
        XCTAssertNotNil(request.value(forHTTPHeaderField: "external-sign"))
    }

    func testRemoteResourceCacheReturnsCachedResourceWithoutSecondLoad() async throws {
        let cache = SalesmartlyRemoteResourceCache<String>(maxEntries: 2)
        let counter = SalesmartlyRemoteResourceLoadCounter()

        let first = await cache.getOrLoad(key: "https://cdn.example.com/a.png") {
            await counter.increment()
            return "bitmap-a"
        }
        let second = await cache.getOrLoad(key: "https://cdn.example.com/a.png") {
            await counter.increment()
            return "bitmap-b"
        }

        XCTAssertEqual(first, "bitmap-a")
        XCTAssertEqual(second, "bitmap-a")
        let loadCount = await counter.count()
        XCTAssertEqual(loadCount, 1)
    }

    func testRemoteResourceCacheSharesConcurrentLoadForSameURL() async throws {
        let cache = SalesmartlyRemoteResourceCache<String>(maxEntries: 2)
        let counter = SalesmartlyRemoteResourceLoadCounter()

        async let first = cache.getOrLoad(key: "https://cdn.example.com/a.png") {
            await counter.increment()
            try? await Task.sleep(nanoseconds: 50_000_000)
            return "bitmap-a"
        }
        async let second = cache.getOrLoad(key: "https://cdn.example.com/a.png") {
            await counter.increment()
            return "bitmap-b"
        }
        let results = await (first, second)

        XCTAssertEqual(results.0, results.1)
        let loadCount = await counter.count()
        XCTAssertEqual(loadCount, 1)
    }

    func testPushRoutesCommandsToRuntimeState() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        SalesmartlyChat.push("chatOpen")
        SalesmartlyChat.push("sendTextMessage", "Hello")
        SalesmartlyChat.push("hideUpload", ["img", "video"])
        runtime.state.channelOpenConfigs["custom_1"] = ["type": "1", "input_value": "Custom content"]
        SalesmartlyChat.push("openCustomEntry", "custom_1")

        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertEqual(runtime.state.currentView, .chat)
        XCTAssertEqual(runtime.state.messages.last?.message, "Hello")
        XCTAssertEqual(runtime.state.hideUploadTypes, ["img", "video"])
        XCTAssertEqual(runtime.state.openCustomEntryId, "custom_1")
        XCTAssertEqual(runtime.state.customEntryPopup?.inputValue, "Custom content")
    }

    func testWindowCloseButtonVisibilityMatchesWidgetHeaderRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        XCTAssertTrue(runtime.shouldShowWindowCloseButton())

        SalesmartlyChat.push("hideCloseIcon", true)

        XCTAssertFalse(runtime.shouldShowWindowCloseButton())

        SalesmartlyChat.push("hideCloseIcon", false)

        XCTAssertTrue(runtime.shouldShowWindowCloseButton())

        let fullScreenRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: fullScreenRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, initMobileScreen: "full")
            )
        )

        XCTAssertFalse(fullScreenRuntime.shouldShowWindowCloseButton())
        XCTAssertEqual(fullScreenRuntime.state.mobileScreen, "full")

        let exclusiveRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: exclusiveRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .exclusiveLink)
            )
        )

        XCTAssertFalse(exclusiveRuntime.shouldShowWindowCloseButton())
    }

    #if canImport(SwiftUI)
    func testHostWrapFrameEdgeMatchesWidgetSidePositionRules() async throws {
        XCTAssertEqual(SalesmartlyChatHost.widgetWrapFrameEdge(position: "right"), .bottomTrailing)
        XCTAssertEqual(SalesmartlyChatHost.widgetWrapFrameEdge(position: "left"), .bottomLeading)
    }

    func testMediaPreviewVideoLayoutMatchesWidgetPopupRules() async throws {
        let portrait = SalesmartlyChatHost.mediaPreviewVideoLayoutState(
            availableSize: CGSize(width: 368, height: 800),
            aspectRatio: 16 / 9
        )
        XCTAssertEqual(portrait.coverOpacity, 0.35)
        XCTAssertEqual(portrait.width, 331.2, accuracy: 0.1)
        XCTAssertEqual(portrait.height, 186.3, accuracy: 0.1)

        let landscape = SalesmartlyChatHost.mediaPreviewVideoLayoutState(
            availableSize: CGSize(width: 1200, height: 500),
            aspectRatio: 16 / 9
        )
        XCTAssertEqual(landscape.width, 755.6, accuracy: 0.1)
        XCTAssertEqual(landscape.height, 425, accuracy: 0.1)
    }

    func testOpenedChatWindowLayoutMatchesWidgetMobileOpenRules() async throws {
        let fullScreenLayout = SalesmartlyChatHost.openedChatWindowLayoutState(
            availableSize: CGSize(width: 393, height: 852),
            configuredBottomInset: 30,
            isMobileHost: true,
            position: "right",
            initMobileScreen: "full",
            mobileScreen: "",
            shouldShowWindowCloseButton: true
        )

        XCTAssertEqual(fullScreenLayout.width, 393)
        XCTAssertEqual(fullScreenLayout.height, 852)
        XCTAssertEqual(fullScreenLayout.leadingInset, 0)
        XCTAssertEqual(fullScreenLayout.trailingInset, 0)
        XCTAssertEqual(fullScreenLayout.bottomInset, 0)
        XCTAssertEqual(fullScreenLayout.cornerRadius, 0)
        XCTAssertEqual(fullScreenLayout.shadowRadius, 0)
        XCTAssertFalse(fullScreenLayout.showsBottomCloseButton)

        let mobileLayout = SalesmartlyChatHost.openedChatWindowLayoutState(
            availableSize: CGSize(width: 393, height: 852),
            configuredBottomInset: 30,
            isMobileHost: true,
            position: "left",
            initMobileScreen: nil,
            mobileScreen: "",
            shouldShowWindowCloseButton: true
        )

        XCTAssertEqual(mobileLayout.width, 393)
        XCTAssertEqual(mobileLayout.height, 724.2, accuracy: 0.001)
        XCTAssertEqual(mobileLayout.leadingInset, 0)
        XCTAssertEqual(mobileLayout.trailingInset, 0)
        XCTAssertEqual(mobileLayout.bottomInset, 0)
        XCTAssertEqual(mobileLayout.cornerRadius, 12)
        XCTAssertEqual(mobileLayout.shadowRadius, 40)
        XCTAssertFalse(mobileLayout.showsBottomCloseButton)

        let desktopLayout = SalesmartlyChatHost.openedChatWindowLayoutState(
            availableSize: CGSize(width: 820, height: 900),
            configuredBottomInset: 30,
            isMobileHost: false,
            position: "right",
            initMobileScreen: nil,
            mobileScreen: "",
            shouldShowWindowCloseButton: true
        )

        XCTAssertEqual(desktopLayout.width, 400)
        XCTAssertEqual(desktopLayout.height, 700)
        XCTAssertEqual(desktopLayout.leadingInset, 0)
        XCTAssertEqual(desktopLayout.trailingInset, 15)
        XCTAssertEqual(desktopLayout.bottomInset, 30)
        XCTAssertEqual(desktopLayout.cornerRadius, 12)
        XCTAssertEqual(desktopLayout.shadowRadius, 40)
        XCTAssertTrue(desktopLayout.showsBottomCloseButton)

        let leftDesktopLayout = SalesmartlyChatHost.openedChatWindowLayoutState(
            availableSize: CGSize(width: 820, height: 900),
            configuredBottomInset: 30,
            isMobileHost: false,
            position: "left",
            initMobileScreen: nil,
            mobileScreen: "",
            shouldShowWindowCloseButton: true
        )

        XCTAssertEqual(leftDesktopLayout.leadingInset, 15)
        XCTAssertEqual(leftDesktopLayout.trailingInset, 0)
    }

    func testComposerLayoutKeepsStableInputIdentityAcrossDraftChanges() async throws {
        let emptyLayout = SalesmartlyChatHost.composerLayoutState(hasDraftText: false)
        let contentLayout = SalesmartlyChatHost.composerLayoutState(hasDraftText: true)

        XCTAssertEqual(emptyLayout.textFieldIdentity, contentLayout.textFieldIdentity)
        XCTAssertEqual(emptyLayout.cornerRadius, 100)
        XCTAssertEqual(contentLayout.cornerRadius, 10)
        XCTAssertFalse(emptyLayout.textFieldOwnsFirstRow)
        XCTAssertTrue(contentLayout.textFieldOwnsFirstRow)
    }

    func testComposerUploadMenuItemsRespectHiddenUploadTypes() async throws {
        XCTAssertEqual(
            SalesmartlyChatHost.composerUploadMenuItems(hideUploadTypes: []),
            [.searchSame, .image, .video, .attachment]
        )
        XCTAssertEqual(
            SalesmartlyChatHost.composerUploadMenuItems(hideUploadTypes: ["img", "video"]),
            [.attachment]
        )
        XCTAssertEqual(
            SalesmartlyChatHost.composerUploadMenuItems(hideUploadTypes: ["document"]),
            [.searchSame, .image, .video]
        )
    }

    func testHostHomepageDefaultTextUsesCurrentLanguage() async throws {
        XCTAssertEqual(
            SalesmartlyChatHost.localizedHomePageWelcomeText(homePageTitle: "", language: "en-US"),
            salesmartlyText("tips.contactUs", language: "en-US")
        )
        XCTAssertEqual(
            SalesmartlyChatHost.localizedHomePageWelcomeText(homePageTitle: "", language: "fr"),
            salesmartlyText("tips.contactUs", language: "fr")
        )
        XCTAssertEqual(
            SalesmartlyChatHost.localizedHomePageWelcomeText(homePageTitle: "欢迎联系我们", language: "en-US"),
            "欢迎联系我们"
        )
    }
    #endif

    func testChatHeaderTitleAndAvatarFollowWidgetReceptionInfoRules() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.iconPopupWindowName = "SaleSmartly"
        runtime.state.pluginAvatarURL = "https://avatar.example/brand.png"
        runtime.state.iconPopupShowReceptionInfo = true
        runtime.state.assignUserInfo = [
            "avatar": "https://avatar.example/agent.png",
            "nickname": "Agent",
            "sys_user_id": "123",
        ]

        XCTAssertTrue(runtime.chatHeaderHasAssignUserInfo())
        XCTAssertEqual(runtime.chatHeaderTitle(), "Agent")
        XCTAssertEqual(runtime.chatHeaderAvatarURL(), "https://avatar.example/agent.png")

        runtime.state.showServiceTyping = true
        runtime.state.lang = "zh-CN"

        XCTAssertEqual(runtime.chatHeaderTitle(), "正在输入")
    }

    func testChatHeaderFallsBackToWindowInfoWithoutPositiveAssignUserId() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.iconPopupWindowName = "SaleSmartly"
        runtime.state.pluginAvatarURL = "https://avatar.example/brand.png"
        runtime.state.iconPopupShowReceptionInfo = true
        runtime.state.assignUserInfo = [
            "avatar": "https://avatar.example/agent.png",
            "nickname": "Agent",
            "sys_user_id": "0",
        ]

        XCTAssertFalse(runtime.chatHeaderHasAssignUserInfo())
        XCTAssertEqual(runtime.chatHeaderTitle(), "SaleSmartly")
        XCTAssertEqual(runtime.chatHeaderAvatarURL(), "https://avatar.example/brand.png")
    }

    func testChatHeaderSubtitleActionsAndPresentationMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.welcome = "欢迎联系我们"
        runtime.state.windowSubheadSwitch = "1"
        runtime.state.homePageEnabled = false
        runtime.state.helpdeskSwitch = "1"
        runtime.state.channels = ["chat", "whatsapp", "telegram"]
        runtime.state.channelSort = ["telegram", "whatsapp"]
        runtime.state.integrationType = "chat"

        XCTAssertEqual(runtime.chatHeaderSubtitle(), "欢迎联系我们")
        XCTAssertEqual(runtime.chatHeaderLeftAction(), .close)
        XCTAssertEqual(runtime.chatHeaderRightAction(), .helpdesk)
        XCTAssertTrue(runtime.chatHeaderShowsChannelRow())
        XCTAssertEqual(runtime.chatHeaderChannels(), ["telegram", "whatsapp"])

        runtime.state.homePageEnabled = true

        XCTAssertEqual(runtime.chatHeaderLeftAction(), .back)
        XCTAssertEqual(runtime.chatHeaderRightAction(), .close)
        XCTAssertFalse(runtime.chatHeaderShowsChannelRow())

        runtime.state.homePageEnabled = false
        runtime.state.windowSubheadSwitch = "0"

        XCTAssertNil(runtime.chatHeaderSubtitle())

        runtime.state.windowSubheadSwitch = "1"
        runtime.state.isOnline = false
        runtime.state.offlineSurvey = SalesmartlyCollectionConfig(collect_switch: true, guidance: "", status_text: "  当前没有客服在线  ")

        XCTAssertEqual(runtime.chatHeaderSubtitle(), "当前没有客服在线")

        let expanded = runtime.chatHeaderInfoCardAfterTopRowClick(.collapsed)
        let detailOpen = runtime.chatHeaderInfoCardAfterTopRowClick(expanded)

        XCTAssertEqual(expanded, .expanded)
        XCTAssertEqual(detailOpen, .detailOpen)
        XCTAssertEqual(runtime.chatHeaderInfoCardAfterOutsideClick(.expanded, isMobile: true), .collapsed)
        XCTAssertEqual(runtime.chatHeaderInfoCardAfterOutsideClick(.expanded, isMobile: false), .expanded)
        XCTAssertEqual(runtime.chatHeaderInfoCardAfterPointerEnter(.collapsed, isMobile: false), .expanded)
        XCTAssertEqual(runtime.chatHeaderInfoCardAfterPointerExit(.expanded, isMobile: false), .collapsed)
        XCTAssertEqual(SalesmartlyChatHost.chatHeaderInfoCardAfterChatContentTap(.expanded, runtime: runtime), .collapsed)
        XCTAssertEqual(SalesmartlyChatHost.chatHeaderInfoCardAfterChatContentTap(.detailOpen, runtime: runtime), .collapsed)
        XCTAssertEqual(SalesmartlyChatHost.chatHeaderInfoCardAfterChatContentTap(.collapsed, runtime: runtime), .collapsed)

        let collapsedPresentation = runtime.chatHeaderInfoCardPresentation(.collapsed, showHeaderChannelRow: true)
        let expandedPresentation = runtime.chatHeaderInfoCardPresentation(.expanded, showHeaderChannelRow: true)
        let detailPresentation = runtime.chatHeaderInfoCardPresentation(.detailOpen, showHeaderChannelRow: true)

        XCTAssertEqual(collapsedPresentation.cardWidth, 260)
        XCTAssertEqual(collapsedPresentation.channelRowHeight, 20)
        XCTAssertEqual(collapsedPresentation.topRowMaxHeight, 52)
        XCTAssertEqual(collapsedPresentation.titleFontSize, 12)
        XCTAssertTrue(collapsedPresentation.showChannelRow)
        XCTAssertEqual(expandedPresentation.cardWidth, 368)
        XCTAssertEqual(expandedPresentation.channelRowHeight, 52)
        XCTAssertEqual(expandedPresentation.topRowCornerRadius, 100)
        XCTAssertEqual(detailPresentation.cardWidth, 368)
        XCTAssertEqual(detailPresentation.topRowCornerRadius, 20)
        XCTAssertEqual(detailPresentation.topRowMaxHeight, 300)
        XCTAssertEqual(detailPresentation.titleFontSize, 14)
        XCTAssertFalse(detailPresentation.showChannelRow)
        XCTAssertEqual(runtime.chatHeaderInfoCardWidth(.expanded, availableWidth: 380), 368)
        XCTAssertEqual(runtime.chatHeaderInfoCardWidth(.expanded, availableWidth: 320), 320)
        XCTAssertEqual(runtime.chatHeaderContainerHeight(.collapsed, showHeaderChannelRow: false), 72)
        XCTAssertEqual(runtime.chatHeaderContainerHeight(.collapsed, showHeaderChannelRow: true), 86)
        XCTAssertEqual(runtime.chatHeaderContainerHeight(.expanded, showHeaderChannelRow: true), 132)
        XCTAssertEqual(runtime.chatHeaderContainerHeight(.detailOpen, showHeaderChannelRow: true), 114)
    }

    func testChatHeaderIconStatesMatchWidgetHeaderRules() async throws {
        let runtime = SalesmartlyRuntime()
        let leftClose = runtime.chatHeaderActionIconState(.close, isRightAction: false)
        let rightClose = runtime.chatHeaderActionIconState(.close, isRightAction: true)
        let back = runtime.chatHeaderActionIconState(.back, isRightAction: false)
        let helpdesk = runtime.chatHeaderActionIconState(.helpdesk, isRightAction: true)
        let collapsedChannel = runtime.chatHeaderChannelIconSpec(compact: true)
        let expandedChannel = runtime.chatHeaderChannelIconSpec(compact: false)

        XCTAssertEqual(leftClose.webIconName, "icon-closure-circle")
        XCTAssertEqual(leftClose.size, 24)
        XCTAssertEqual(rightClose.size, 20)
        XCTAssertEqual(back.webIconName, "icon-return-circle")
        XCTAssertEqual(back.size, 24)
        XCTAssertEqual(helpdesk.webIconName, "icon-help-center-fill")
        XCTAssertEqual(helpdesk.size, 20)
        XCTAssertEqual(runtime.chatHeaderDefaultLogoIconState().webIconName, "icon-default-logo-fill")
        XCTAssertEqual(runtime.chatHeaderDefaultLogoIconState().size, 28)
        XCTAssertEqual(collapsedChannel.containerSize, 12)
        XCTAssertEqual(collapsedChannel.iconSize, 8)
        XCTAssertEqual(expandedChannel.containerSize, 24)
        XCTAssertEqual(expandedChannel.iconSize, 14)
    }

    func testHomeChannelDisplayStateMatchesWidgetHomeRules() async throws {
        let runtime = SalesmartlyRuntime()

        runtime.state.channels = ["whatsapp", "chat", "email"]
        runtime.state.channelSort = ["email", "whatsapp"]
        runtime.state.integrationType = "column"

        let chatMainState = runtime.homeChannelDisplayState()
        XCTAssertEqual(chatMainState.mainChannel, "chat")
        XCTAssertTrue(chatMainState.showMainCard)
        XCTAssertTrue(chatMainState.showReceptionChatCard)
        XCTAssertEqual(chatMainState.gridChannels, [])

        runtime.state.channels = ["whatsapp", "email", "telegram"]
        runtime.state.channelSort = ["email", "whatsapp", "telegram"]
        runtime.state.integrationType = "chat"
        runtime.state.sidebarShow = false

        let externalMainState = runtime.homeChannelDisplayState()
        XCTAssertEqual(externalMainState.mainChannel, "email")
        XCTAssertTrue(externalMainState.showMainCard)
        XCTAssertFalse(externalMainState.showReceptionChatCard)
        XCTAssertEqual(externalMainState.gridChannels, ["whatsapp", "telegram"])

        runtime.state.channels = ["chat", "whatsapp", "telegram"]
        runtime.state.channelSort = ["whatsapp", "telegram"]
        runtime.state.integrationType = "chat"
        runtime.state.sidebarShow = true
        runtime.state.sidebarShrinkMode = "sidebar"

        let dedupedState = runtime.homeChannelDisplayState()
        XCTAssertEqual(dedupedState.mainChannel, "chat")
        XCTAssertTrue(dedupedState.showMainCard)
        XCTAssertEqual(dedupedState.gridChannels, [])
    }

    func testFileAttachmentCardStyleMatchesWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        let style = runtime.fileAttachmentCardStyleState()

        XCTAssertEqual(style.width, 280)
        XCTAssertEqual(style.height, 54)
        XCTAssertEqual(style.cornerRadius, 6)
        XCTAssertEqual(style.padding, 12)
        XCTAssertEqual(style.gap, 8)
    }

    /// 对齐 Android sample `SalesmartlyChat.showCollection(true)` 入口，公开 API 可显式打开和关闭留资弹窗。
    func testGlobalShowCollectionVisibleEntryTogglesCollectionOverlay() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.showCollection(true)
        XCTAssertTrue(runtime.state.showCollection)

        SalesmartlyChat.showCollection(false)
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertFalse(runtime.state.showOffline)
    }

    /// 对齐 Android `showCollection(show)` / `showOffline(show)` 与命令桥布尔 payload，普通留资和离线留资保持互斥。
    func testShowCollectionAndOfflineBoolCommandsMatchAndroidSwitchSemantics() async throws {
        let runtime = SalesmartlyRuntime()
        var collectionPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        runtime.registerCallback("onOpenCollection") { payload in
            collectionPayload = payload
        }

        SalesmartlyChat.push("showCollection", true)
        XCTAssertTrue(runtime.state.showCollection)
        XCTAssertFalse(runtime.state.showOffline)
        XCTAssertEqual(collectionPayload["show"] as? Bool, true)

        SalesmartlyChat.push("showCollection", false)
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertFalse(runtime.state.showOffline)

        SalesmartlyChat.push("showOffline", true)
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertTrue(runtime.state.showOffline)

        SalesmartlyChat.push("showOffline", false)
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertFalse(runtime.state.showOffline)

        SalesmartlyChat.showCollection(true)
        SalesmartlyChat.showOffline(true)
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertTrue(runtime.state.showOffline)

        SalesmartlyChat.showOffline(false)
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertFalse(runtime.state.showOffline)
    }

    /// 对齐 Android `setDemo(SalesmartlyPayload)`：demo 模式下保留原始 payload 语义并触发 onSetDemo。
    func testSetDemoPayloadDispatchesOnSetDemoInDemoMode() async throws {
        let runtime = SalesmartlyRuntime()
        var callbackPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "demo_plugin_1",
                setting: SalesmartlySetting(mode: .demo)
            )
        )
        runtime.registerCallback("onSetDemo") { payload in
            callbackPayload = payload
        }

        let demoPayload: SalesmartlyPayload = [
            "enabled": true,
            "count": 2,
            "scenario": ["id": "demo_1"],
        ]
        SalesmartlyChat.setDemo(demoPayload)

        XCTAssertEqual(callbackPayload["enabled"] as? Bool, true)
        XCTAssertEqual(callbackPayload["count"] as? Int, 2)
        XCTAssertEqual((callbackPayload["scenario"] as? SalesmartlyPayload)?["id"] as? String, "demo_1")
        XCTAssertEqual(runtime.state.demoPayload["enabled"], "true")
        XCTAssertEqual(runtime.state.demoPayload["count"], "2")
    }

    func testOpenLauncherEntryUsesHomePageWhenEnabled() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.homePageEnabled = true

        runtime.openLauncherEntry()

        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertEqual(runtime.state.currentView, .home)

        let chatRuntime = SalesmartlyRuntime()
        chatRuntime.state.homePageEnabled = false

        chatRuntime.openLauncherEntry()

        XCTAssertTrue(chatRuntime.state.showWrapper)
        XCTAssertEqual(chatRuntime.state.currentView, .chat)
    }

    /// 对齐 widget main:src/stores/app.ts 的 toggleChat(true) resetView，外部打开入口在 Home 开启时先展示主页。
    func testGlobalOpenChatEntryResetsToHomePageWhenEnabled() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.homePageEnabled = true
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.openChat()

        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertEqual(runtime.state.currentView, .home)

        runtime.closeChat()
        SalesmartlyChat.push("chatOpen")

        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertEqual(runtime.state.currentView, .home)
    }

    func testHostCloseInteractionStateResetsLocalPresentationFlags() async throws {
        let closeState = SalesmartlyChatHost.closeInteractionState(
            launcherExpanded: true,
            showEmojiPanel: true,
            isComposerFocused: true
        )

        XCTAssertFalse(closeState.launcherExpanded)
        XCTAssertFalse(closeState.showEmojiPanel)
        XCTAssertFalse(closeState.isComposerFocused)
    }

    func testGetSidebarHeightCommandMatchesWidgetLauncherHeightRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.setLauncherHeightTargetFrames([
            SalesmartlyLauncherHeightTargetFrame(top: 30.2, bottom: 40.2, height: 10),
            SalesmartlyLauncherHeightTargetFrame(top: 10.1, bottom: 20.1, height: 10),
            SalesmartlyLauncherHeightTargetFrame(top: 100, bottom: 100, height: 0),
        ])

        XCTAssertEqual(runtime.getSidebarHeight(), 31)

        var callbackHeight: Int?
        let callback: SalesmartlySidebarHeightCallback = { height in
            callbackHeight = height
        }
        SalesmartlyChat.push("getSidebarHeight", callback)
        XCTAssertEqual(callbackHeight, 31)

        runtime.setLauncherHeightTargetFrames([])
        callbackHeight = nil
        SalesmartlyChat.push("getSidebarHeight", callback)
        XCTAssertNil(callbackHeight)
    }

    func testSendTextMessageCreatesWidgetPendingMessagePayload() async throws {
        let runtime = SalesmartlyRuntime()
        var sendPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onSendMessage") { payload in
            sendPayload = payload
        }

        SalesmartlyChat.sendTextMessage("Hello")

        let message = try XCTUnwrap(runtime.state.messages.last)
        XCTAssertEqual(message.msgType, "1")
        XCTAssertEqual(message.sendType, "1")
        XCTAssertTrue(message.id.hasPrefix("temp_"))
        XCTAssertEqual(message.mid, message.id)
        XCTAssertEqual(message.tempId, message.id)
        XCTAssertNil(message.status)
        XCTAssertGreaterThan(message.createdTime, 0)
        XCTAssertFalse(try XCTUnwrap(message.cMId).isEmpty)
        XCTAssertEqual(runtime.sendMessageMap[try XCTUnwrap(message.cMId)]?.tempId, message.tempId)
        XCTAssertEqual(sendPayload["mid"] as? String, message.mid)
        XCTAssertEqual(sendPayload["msg_type"] as? String, "1")
        XCTAssertEqual(sendPayload["message"] as? String, "Hello")
    }

    func testSendTextMessageBuildsWidgetSocketPayload() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.sendTextMessage("Hello")

        let message = try XCTUnwrap(runtime.state.messages.last)
        let payload = runtime.makeSocketSendMessagePayload(for: message)
        let clientExpandInfo = try XCTUnwrap(payload["client_expand_info"] as? [String: String])

        XCTAssertEqual(payload["room_type"] as? Int, 6)
        XCTAssertEqual(payload["msg_type"] as? String, "1")
        XCTAssertEqual(payload["message"] as? String, "Hello")
        XCTAssertEqual(clientExpandInfo["c_m_id"], message.cMId)
    }

    func testSendTextMessageBuildsWidgetHttpPayload() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.sendTextMessage("Hello")

        let message = try XCTUnwrap(runtime.state.messages.last)
        let payload = runtime.makeHTTPSendMessagePayload(
            for: message,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )
        let clientExpandInfoString = try XCTUnwrap(payload["client_expand_info"] as? String)
        let clientExpandInfoData = try XCTUnwrap(clientExpandInfoString.data(using: .utf8))
        let clientExpandInfo = try XCTUnwrap(
            JSONSerialization.jsonObject(with: clientExpandInfoData) as? [String: String]
        )

        XCTAssertEqual(payload["ref"] as? String, "chat-plugin")
        XCTAssertEqual(payload["msg_type"] as? String, "1")
        XCTAssertEqual(payload["message"] as? String, "Hello")
        XCTAssertEqual(payload["login_token"] as? String, "token_1")
        XCTAssertEqual(payload["chat_user_id"] as? String, "chat_user_1")
        XCTAssertEqual(clientExpandInfo["c_m_id"], message.cMId)
    }

    func testSseHttpPluginInfoKeepsCachedGuestTokenOnHttpModeWithoutSocketConnection() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        runtime.setTransport(spy)
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.state.userType = "guest"
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"

        XCTAssertTrue(
            runtime.handlePluginInfoTransportResponse([
                "data": [
                    "project_id": "project_1",
                    "sse_switch": "1",
                    "support_retry": "1",
                ] as SalesmartlyPayload,
            ])
        )

        XCTAssertEqual(runtime.state.sseSwitch, "1")
        XCTAssertEqual(runtime.state.realtimeMode, "sse-http")
        XCTAssertEqual(runtime.state.sendMode, "http")
        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertTrue(spy.socketConnections.isEmpty)
        XCTAssertTrue(spy.requests.isEmpty)
    }

    func testSseHttpSendTextMessageBuildsWidgetChatMsgEventRequestAndAck() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.sendMode = "http"

        SalesmartlyChat.sendTextMessage("Hello")
        let message = try XCTUnwrap(runtime.state.messages.last)
        let request = try XCTUnwrap(
            runtime.makeSendMessageTransportRequest(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertEqual(request.kind, .http)
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.path, "/chat/chat-msg/event")
        XCTAssertEqual(request.bodyEncoding, .json)
        XCTAssertEqual(request.externalSign, true)
        XCTAssertEqual(request.payload["login_token"] as? String, "token_1")
        XCTAssertEqual(request.payload["chat_user_id"] as? String, "chat_user_1")
        XCTAssertEqual(request.payload["event"] as? String, "send-message")

        let dataString = try XCTUnwrap(request.payload["data"] as? String)
        let data = try XCTUnwrap(dataString.data(using: .utf8))
        let eventData = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload)
        let clientExpandInfo = try XCTUnwrap(eventData["client_expand_info"] as? [String: String])
        XCTAssertEqual(eventData["room_type"] as? Int, 6)
        XCTAssertEqual(eventData["msg_type"] as? String, "1")
        XCTAssertEqual(eventData["message"] as? String, "Hello")
        XCTAssertEqual(clientExpandInfo["c_m_id"], message.cMId)

        XCTAssertTrue(
            runtime.handleTransportResponse(
                [
                    "data": [
                        "message": [
                            "sequence_id": "server_event_1",
                            "send_time": 1_779_860_001_003,
                            "content": [
                                "msg": "Hello",
                            ],
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ],
                for: request,
                currentChatUserId: "chat_user_1"
            ).isEmpty
        )
        XCTAssertEqual(runtime.state.messages.last?.id, "server_event_1")
        XCTAssertNil(runtime.sendMessageMap[try XCTUnwrap(message.cMId)])
    }

    func testSseHttpRoomLifecycleReadAndPendingOpenFrameUseWidgetChatMsgEventRequests() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        runtime.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(flowId: "flow_1")
            )
        )
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.sendMode = "http"
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"

        let pendingOpenFrame = runtime.makeOpenFrameTransportRequest()
        XCTAssertNil(pendingOpenFrame)
        XCTAssertEqual(runtime.state.pendingSocketEvents, ["open-frame"])

        let joinRequest = try XCTUnwrap(runtime.makeJoinRoomTransportRequest())
        let joinData = try chatMsgEventData(from: joinRequest, event: "join-room")
        XCTAssertEqual(joinData["room_type"] as? Int, 6)
        XCTAssertEqual(joinData["flow_id"] as? String, "flow_1")
        XCTAssertEqual(joinData["room_id"] as? String, "chat_user_1")
        XCTAssertTrue(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")

        let pendingRequests = runtime.flushPendingSocketTransportRequests()
        XCTAssertEqual(pendingRequests.count, 1)
        let queuedOpenFrameData = try chatMsgEventData(from: try XCTUnwrap(pendingRequests.first), event: "open-frame")
        XCTAssertEqual(queuedOpenFrameData["room_type"] as? Int, 6)
        XCTAssertEqual(queuedOpenFrameData["flow_id"] as? String, "flow_1")

        let openFrameRequest = try XCTUnwrap(runtime.makeOpenFrameTransportRequest())
        let openFrameData = try chatMsgEventData(from: openFrameRequest, event: "open-frame")
        XCTAssertEqual(openFrameData["room_type"] as? Int, 6)
        XCTAssertEqual(openFrameData["flow_id"] as? String, "flow_1")

        let readRequest = runtime.makeReadMessageTransportRequest(sequenceId: "server_1")
        let readData = try chatMsgEventData(from: readRequest, event: "read-message")
        XCTAssertEqual(readData["room_type"] as? Int, 6)
        XCTAssertEqual(readData["flow_id"] as? String, "flow_1")
        XCTAssertEqual(readData["sequence_id"] as? String, "server_1")

        let leaveRequest = try XCTUnwrap(runtime.makeLeaveRoomTransportRequest())
        let leaveData = try chatMsgEventData(from: leaveRequest, event: "leave-room")
        XCTAssertEqual(leaveData["room_type"] as? Int, 6)
        XCTAssertEqual(leaveData["flow_id"] as? String, "flow_1")
        XCTAssertEqual(leaveData["room_id"] as? String, "chat_user_1")
        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")
    }

    func testSseHttpActionEventsUseWidgetChatMsgEventRequests() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setTransport(spy)
        runtime.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(flowId: "flow_1")
            )
        )
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.sendMode = "http"
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"

        let humanServiceData = try chatMsgEventData(from: runtime.makeHumanServiceTransportRequest(), event: "human-service")
        XCTAssertEqual(humanServiceData["room_type"] as? Int, 6)

        let streamStopData = try chatMsgEventData(
            from: runtime.makeStreamStopTransportRequest(mid: "stream_1", chatUserId: "chat_user_1"),
            event: "stream-stop"
        )
        XCTAssertEqual(streamStopData["sequence_id"] as? String, "stream_1")
        XCTAssertEqual(streamStopData["chat_user_id"] as? String, "chat_user_1")

        let likePayload = runtime.makeLikePayload(
            sequenceId: "like_template_1",
            flowId: "flow_1",
            likeResult: "like",
            postback: "postback_like",
            clientExpandInfo: ["c_m_id": "client_like_1"]
        )
        let likeData = try chatMsgEventData(from: runtime.makeLikeTransportRequest(payload: likePayload), event: "like")
        XCTAssertEqual(likeData["room_type"] as? Int, 6)
        XCTAssertEqual(likeData["sequence_id"] as? String, "like_template_1")
        XCTAssertEqual(likeData["flow_id"] as? String, "flow_1")
        XCTAssertEqual(likeData["like_result"] as? String, "like")
        XCTAssertEqual(likeData["postback"] as? String, "postback_like")
        XCTAssertEqual((likeData["client_expand_info"] as? [String: String])?["c_m_id"], "client_like_1")

        runtime.receiveMessage(
            sequenceId: "invite_evalution_1",
            senderType: "2",
            msgType: "3",
            message: #"{"type":"invite_evalution","payload":{"session_id":"session_1","flow_id":"flow_1","step_log_id":"step_1","invite_evaluation_id":"invite_1","invite_evaluation_order_id":"order_1"}}"#,
            sendTime: 1_779_860_001_211,
            chatUserId: "chat_user_1"
        )
        let message = try XCTUnwrap(runtime.state.messages.first)
        XCTAssertNil(runtime.submitEvalutionMessage(message: message, score: 5, comment: "good"))

        let evalutionRequest = try XCTUnwrap(spy.requests.last)
        let evalutionData = try chatMsgEventData(from: evalutionRequest, event: "evalution")
        XCTAssertEqual(evalutionData["room_type"] as? Int, 6)
        XCTAssertEqual(evalutionData["session_id"] as? String, "session_1")
        XCTAssertEqual(evalutionData["sequence_id"] as? String, "invite_evalution_1")
        XCTAssertEqual(evalutionData["flow_id"] as? String, "flow_1")
        XCTAssertEqual(evalutionData["step_log_id"] as? String, "step_1")
        XCTAssertEqual(evalutionData["score"] as? String, "5")
        XCTAssertEqual(evalutionData["comment"] as? String, "good")
        XCTAssertEqual(evalutionData["invite_evaluation_id"] as? String, "invite_1")
        XCTAssertEqual(evalutionData["invite_evaluation_order_id"] as? String, "order_1")
        XCTAssertNotNil((evalutionData["client_expand_info"] as? [String: String])?["c_m_id"])
    }

    func testSseEnvelopeRoutesWidgetDownstreamEventsAndReadFollowUp() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        runtime.state.hasJoinRoom = true
        runtime.openChat()
        runtime.setWindowVisible(true)

        let followUps = runtime.handleSseRealtimePayload([
            "channel": "chat_channel_1",
            "pub": [
                "data": [
                    "event": "receive-message",
                    "data": [
                        "chat_user_id": "chat_user_1",
                        "sequence_id": "sse_receive_1",
                        "sender_type": "2",
                        "sender_name": "Ada",
                        "sender_avatar": "",
                        "send_time": "1779860001000",
                        "msg_type": "1",
                        "content": [
                            "msg": "SSE receive",
                        ] as SalesmartlyPayload,
                        "read_time": "0",
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ] as SalesmartlyPayload,
        ])

        XCTAssertEqual(runtime.state.messages.last?.id, "sse_receive_1")
        XCTAssertEqual(runtime.state.messages.last?.message, "SSE receive")
        XCTAssertEqual(followUps.count, 1)
        let readData = try chatMsgEventData(from: try XCTUnwrap(followUps.first), event: "read-message")
        XCTAssertEqual(readData["sequence_id"] as? String, "sse_receive_1")

        XCTAssertTrue(
            runtime.handleSseRealtimePayload([
                "channel": "chat_channel_1",
                "pub": [
                    "data": [
                        "event": "receive-notice",
                        "data": [
                            "notice_type": 19,
                            "notice": [:] as SalesmartlyPayload,
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ]).isEmpty
        )
        XCTAssertTrue(runtime.state.showRobotTyping)
        XCTAssertTrue(runtime.handleSseRealtimePayload(["connect": [:] as SalesmartlyPayload]).isEmpty)
    }

    func testSseRealtimeRequestsAndCentrifugoURLMatchWidgetFactory() async throws {
        let runtime = SalesmartlyRuntime()

        XCTAssertEqual(SalesmartlyEnvironment.production().centrifugoURL.absoluteString, "https://events.salesmartly.com/")
        XCTAssertEqual(SalesmartlyEnvironment.pre().centrifugoURL.absoluteString, "https://events-pre.salesmartly.com/")
        XCTAssertEqual(SalesmartlyEnvironment.dev().centrifugoURL.absoluteString, "https://ss-centrifugo-dev.xmp.one")

        let tokenRequest = runtime.makeCentrifugoTokenTransportRequest(
            loginToken: "token_1",
            chatUserId: "chat_1"
        )
        XCTAssertEqual(tokenRequest.method, .get)
        XCTAssertEqual(tokenRequest.path, "/chat/chat-msg/centrifugo-token")
        XCTAssertEqual(tokenRequest.query["login_token"], "token_1")
        XCTAssertEqual(tokenRequest.query["chat_user_id"], "chat_1")
        XCTAssertEqual(tokenRequest.payload.isEmpty, true)
        XCTAssertEqual(tokenRequest.externalSign, true)

        let connectRequest = runtime.makeSseConnectTransportRequest(
            loginToken: "token_1",
            chatUserId: "chat_1"
        )
        let disconnectRequest = runtime.makeSseDisconnectTransportRequest(
            loginToken: "token_1",
            chatUserId: "chat_1"
        )
        XCTAssertEqual(connectRequest.method, .post)
        XCTAssertEqual(connectRequest.path, "/chat/chat-msg/sse-connect")
        XCTAssertEqual(connectRequest.bodyEncoding, .json)
        XCTAssertEqual(connectRequest.payload["login_token"] as? String, "token_1")
        XCTAssertEqual(connectRequest.payload["chat_user_id"] as? String, "chat_1")
        XCTAssertEqual(connectRequest.externalSign, true)
        XCTAssertEqual(disconnectRequest.method, .post)
        XCTAssertEqual(disconnectRequest.path, "/chat/chat-msg/sse-disconnect")
        XCTAssertEqual(disconnectRequest.payload["login_token"] as? String, "token_1")
        XCTAssertEqual(disconnectRequest.payload["chat_user_id"] as? String, "chat_1")
        XCTAssertEqual(disconnectRequest.bodyEncoding, .json)
        XCTAssertEqual(disconnectRequest.externalSign, true)

        let eventSourceURL = try XCTUnwrap(
            runtime.makeCentrifugoEventSourceURL(
                baseURL: URL(string: "https://ss-centrifugo-dev.xmp.one/")!,
                token: "jwt_1",
                channels: ["project#1", "user#2"]
            )
        )
        XCTAssertEqual(
            eventSourceURL.absoluteString,
            "https://ss-centrifugo-dev.xmp.one/connection/uni_sse?cf_connect=%7B%22token%22%3A%22jwt_1%22%2C%22name%22%3A%22js%22%2C%22subs%22%3A%7B%22project%231%22%3A%7B%7D%2C%22user%232%22%3A%7B%7D%7D%7D"
        )
    }

    func testSseHttpTokenPreflightStartsEventSourceAndOpenJoinRoomRequests() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        runtime.setTransport(spy)
        runtime.setRealtimeCentrifugoURL(URL(string: "https://ss-centrifugo-dev.xmp.one")!)
        runtime.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(flowId: "flow_1")
            )
        )
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        runtime.state.pluginProjectId = "project_1"
        XCTAssertNil(runtime.makeOpenFrameTransportRequest())

        let tokenRequest = try XCTUnwrap(
            runtime.connectSocketTransport(
                loginToken: "token_1",
                chatUserId: "chat_user_1",
                pluginId: "plugin_1",
                projectId: "project_1"
            )
        )
        XCTAssertEqual(tokenRequest.path, "/chat/chat-msg/centrifugo-token")
        XCTAssertEqual(spy.requests.count, 1)

        spy.respond(
            [
                "data": [
                    "token": "jwt_1",
                    "channels": ["project#1", "user#2"],
                ] as SalesmartlyPayload,
            ],
            requestIndex: 0
        )

        let connection = try XCTUnwrap(spy.sseConnections.first)
        XCTAssertEqual(
            connection.eventSourceURL.absoluteString,
            "https://ss-centrifugo-dev.xmp.one/connection/uni_sse?cf_connect=%7B%22token%22%3A%22jwt_1%22%2C%22name%22%3A%22js%22%2C%22subs%22%3A%7B%22project%231%22%3A%7B%7D%2C%22user%232%22%3A%7B%7D%7D%7D"
        )
        XCTAssertEqual(connection.connectRequest.path, "/chat/chat-msg/sse-connect")
        XCTAssertEqual(connection.disconnectRequest.path, "/chat/chat-msg/sse-disconnect")
        XCTAssertEqual(connection.openRequests.count, 1)
        let joinData = try chatMsgEventData(from: try XCTUnwrap(connection.openRequests.first), event: "join-room")
        XCTAssertEqual(joinData["room_id"] as? String, "chat_user_1")

        _ = runtime.handleTransportResponse(
            ["data": ["data": [:] as SalesmartlyPayload] as SalesmartlyPayload],
            for: try XCTUnwrap(connection.openRequests.first),
            currentChatUserId: "chat_user_1"
        )
        let openFrameRequest = try XCTUnwrap(spy.requests.last)
        XCTAssertEqual(openFrameRequest.payload["event"] as? String, "open-frame")
    }

    func testSseTransportInboundPayloadRoutesEnvelopeAndReadFollowUp() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        runtime.setTransport(spy)
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        runtime.state.hasJoinRoom = true
        runtime.openChat()
        runtime.setWindowVisible(true)

        spy.emitSSEPayload([
            "channel": "chat_channel_1",
            "pub": [
                "data": [
                    "event": "receive-message",
                    "data": [
                        "chat_user_id": "chat_user_1",
                        "sequence_id": "sse_receive_transport_1",
                        "sender_type": "2",
                        "sender_name": "Ada",
                        "sender_avatar": "",
                        "send_time": "1779860001000",
                        "msg_type": "1",
                        "content": [
                            "msg": "SSE transport receive",
                        ] as SalesmartlyPayload,
                        "read_time": "0",
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ] as SalesmartlyPayload,
        ])

        XCTAssertEqual(runtime.state.messages.last?.id, "sse_receive_transport_1")
        let readRequest = try XCTUnwrap(spy.requests.last)
        let readData = try chatMsgEventData(from: readRequest, event: "read-message")
        XCTAssertEqual(readData["sequence_id"] as? String, "sse_receive_transport_1")
    }

    func testSseEventSourceParserReadsWidgetDataBlocksAcrossChunks() async throws {
        let parser = SalesmartlyEventSourceParser()
        XCTAssertTrue(parser.append(Data(#"data: {"channel":"chat_channel_1","#.utf8)).isEmpty)
        let payloads = parser.append(
            Data((#""pub":{"data":{"event":"receive-notice","data":{"notice_type":19,"notice":{}}}}}"# + "\n\n").utf8)
        )

        XCTAssertEqual(payloads.count, 1)
        XCTAssertEqual(payloads.first?["channel"] as? String, "chat_channel_1")
    }

    func testSendPayloadIncludesQuestionBranchesFromPreviousTemplateMessage() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "template_1",
            senderType: "2",
            msgType: "3",
            message: #"{"payload":{"branches":[{"title":"Yes","postback":"yes"}],"question_id":"question_1"}}"#,
            sendTime: 1_779_860_000_000,
            chatUserId: "chat_user_1"
        )
        SalesmartlyChat.sendTextMessage("Yes")

        let message = try XCTUnwrap(runtime.state.messages.last)
        let socketPayload = runtime.makeSocketSendMessagePayload(for: message)
        let socketBranches = try XCTUnwrap(socketPayload["branches"] as? [[String: String]])
        let httpPayload = runtime.makeHTTPSendMessagePayload(
            for: message,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )
        let httpBranchesString = try XCTUnwrap(httpPayload["branches"] as? String)
        let httpBranchesData = try XCTUnwrap(httpBranchesString.data(using: .utf8))
        let httpBranches = try XCTUnwrap(JSONSerialization.jsonObject(with: httpBranchesData) as? [[String: String]])

        XCTAssertEqual(socketBranches.first?["title"], "Yes")
        XCTAssertEqual(socketBranches.first?["postback"], "yes")
        XCTAssertEqual(socketPayload["question_id"] as? String, "question_1")
        XCTAssertEqual(httpBranches.first?["title"], "Yes")
        XCTAssertEqual(httpBranches.first?["postback"], "yes")
        XCTAssertEqual(httpPayload["question_id"] as? String, "question_1")
    }

    func testReadMessagePayloadMatchesWidgetRoomType() async throws {
        let runtime = SalesmartlyRuntime()

        let allPayload = runtime.makeReadMessagePayload()
        let singlePayload = runtime.makeReadMessagePayload(sequenceId: "server_1")

        XCTAssertEqual(allPayload["room_type"] as? Int, 6)
        XCTAssertNil(allPayload["sequence_id"])
        XCTAssertEqual(singlePayload["room_type"] as? Int, 6)
        XCTAssertEqual(singlePayload["sequence_id"] as? String, "server_1")
    }

    func testHandleSendMessageSuccessMergesLocalMessageByClientMessageId() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.sendTextMessage("Hello")

        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let tempId = try XCTUnwrap(localMessage.tempId)
        let clientMessageId = try XCTUnwrap(localMessage.cMId)

        runtime.handleSendMessageSuccess(
            sequenceId: "server_1",
            message: "Hello",
            sendTime: 1_779_860_000_123,
            tempId: tempId,
            clientMessageId: clientMessageId
        )

        XCTAssertEqual(runtime.state.messages.count, 1)
        let message = try XCTUnwrap(runtime.state.messages.last)
        XCTAssertEqual(message.id, "server_1")
        XCTAssertEqual(message.mid, "server_1")
        XCTAssertEqual(message.tempId, tempId)
        XCTAssertEqual(message.cMId, clientMessageId)
        XCTAssertEqual(message.createdTime, 1_779_860_000_123)
        XCTAssertNil(runtime.sendMessageMap[clientMessageId])
    }

    func testReceiveMessageMergesOwnEchoByClientMessageId() async throws {
        let runtime = SalesmartlyRuntime()
        var receivePayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onReceiveMessage") { payload in
            receivePayload = payload
        }

        SalesmartlyChat.sendTextMessage("Hello")

        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let clientMessageId = try XCTUnwrap(localMessage.cMId)

        runtime.receiveMessage(
            sequenceId: "server_2",
            senderType: "1",
            msgType: "1",
            message: "Hello",
            sendTime: 1_779_860_000_456,
            chatUserId: "chat_user_1",
            clientMessageId: clientMessageId
        )

        XCTAssertEqual(runtime.state.messages.count, 1)
        let message = try XCTUnwrap(runtime.state.messages.last)
        XCTAssertEqual(message.id, "server_2")
        XCTAssertEqual(message.mid, "server_2")
        XCTAssertEqual(message.cMId, clientMessageId)
        XCTAssertEqual(message.chatUserId, "chat_user_1")
        XCTAssertEqual(receivePayload["mid"] as? String, "server_2")
        XCTAssertEqual(receivePayload["msg_type"] as? String, "1")
        XCTAssertEqual(receivePayload["message"] as? String, "Hello")
    }

    func testSocketSendAckDispatchesSendEventAndReturnsReadPayloadForPreviousServiceMessage() async throws {
        let runtime = SalesmartlyRuntime()
        var sendPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onSendMessage") { payload in
            sendPayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "Agent message",
            sendTime: 1_779_860_000_100,
            chatUserId: "chat_user_1"
        )
        SalesmartlyChat.sendTextMessage("Hello")

        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let tempId = try XCTUnwrap(localMessage.tempId)
        let clientMessageId = try XCTUnwrap(localMessage.cMId)
        let readPayload = try XCTUnwrap(
            runtime.handleSocketSendMessageAck(
                sequenceId: "101",
                message: "Hello",
                sendTime: 1_779_860_000_101,
                tempId: tempId,
                clientMessageId: clientMessageId
            )
        )

        XCTAssertEqual(runtime.state.messages.last?.id, "101")
        XCTAssertEqual(runtime.state.messages.last?.mid, "101")
        XCTAssertEqual(sendPayload["mid"] as? String, "101")
        XCTAssertEqual(sendPayload["msg_type"] as? String, "1")
        XCTAssertEqual(sendPayload["message"] as? String, "Hello")
        XCTAssertEqual(readPayload["room_type"] as? Int, 6)
        XCTAssertEqual(readPayload["sequence_id"] as? String, "101")
        XCTAssertEqual(runtime.state.messages.first?.isRead, "1")
        XCTAssertEqual(runtime.state.unReadNum, 0)
    }

    func testHttpSendAckDispatchesSendEventWithoutReadPayload() async throws {
        let runtime = SalesmartlyRuntime()
        var sendPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onSendMessage") { payload in
            sendPayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "Agent message",
            sendTime: 1_779_860_000_100,
            chatUserId: "chat_user_1"
        )
        SalesmartlyChat.sendTextMessage("Hello")

        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let tempId = try XCTUnwrap(localMessage.tempId)
        let clientMessageId = try XCTUnwrap(localMessage.cMId)

        XCTAssertTrue(
            runtime.handleHTTPSendMessageAck(
                sequenceId: "101",
                message: "Hello",
                sendTime: 1_779_860_000_101,
                tempId: tempId,
                clientMessageId: clientMessageId
            )
        )
        XCTAssertEqual(runtime.state.messages.last?.id, "101")
        XCTAssertEqual(sendPayload["mid"] as? String, "101")
        XCTAssertEqual(sendPayload["msg_type"] as? String, "1")
        XCTAssertEqual(sendPayload["message"] as? String, "Hello")
        XCTAssertEqual(runtime.state.messages.first?.isRead, "0")
        XCTAssertEqual(runtime.state.unReadNum, 1)
    }

    func testTransportSendAckParsesWidgetSocketAndHttpResponseShapes() async throws {
        let runtime = SalesmartlyRuntime()
        var sendPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onSendMessage") { payload in
            sendPayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "Agent message",
            sendTime: 1_779_860_000_100,
            chatUserId: "chat_user_1"
        )
        SalesmartlyChat.sendTextMessage("Socket hello")

        let socketLocalMessage = try XCTUnwrap(runtime.state.messages.last)
        let socketTempId = try XCTUnwrap(socketLocalMessage.tempId)
        let socketClientMessageId = try XCTUnwrap(socketLocalMessage.cMId)
        let readPayload = try XCTUnwrap(
            runtime.handleSocketSendMessageTransportAck(
                [
                    "code": 0,
                    "data": [
                        "message": [
                            "sequence_id": "101",
                            "send_time": Int64(1_779_860_000_101),
                            "content": [
                                "msg": "Socket hello",
                            ],
                        ],
                    ],
                ],
                tempId: socketTempId,
                clientMessageId: socketClientMessageId
            )
        )

        XCTAssertEqual(runtime.state.messages.last?.id, "101")
        XCTAssertEqual(runtime.state.messages.last?.message, "Socket hello")
        XCTAssertEqual(sendPayload["mid"] as? String, "101")
        XCTAssertEqual(readPayload["sequence_id"] as? String, "101")

        _ = runtime.leaveRoom()
        SalesmartlyChat.sendTextMessage("HTTP hello")

        let httpLocalMessage = try XCTUnwrap(runtime.state.messages.last)
        let httpTempId = try XCTUnwrap(httpLocalMessage.tempId)
        let httpClientMessageId = try XCTUnwrap(httpLocalMessage.cMId)

        XCTAssertTrue(
            runtime.handleHTTPSendMessageTransportResponse(
                [
                    "data": [
                        "data": [
                            "message": [
                                "sequence_id": "102",
                                "send_time": Int64(1_779_860_000_102),
                                "content": [
                                    "msg": "HTTP hello",
                                ],
                            ],
                        ],
                    ],
                ],
                tempId: httpTempId,
                clientMessageId: httpClientMessageId
            )
        )
        XCTAssertEqual(runtime.state.messages.last?.id, "102")
        XCTAssertEqual(runtime.state.messages.last?.message, "HTTP hello")
        XCTAssertEqual(sendPayload["mid"] as? String, "102")
    }

    func testPostbackAckKeepsWidgetJSONStringPayloadReadable() async throws {
        let runtime = SalesmartlyRuntime()
        var sendPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onSendMessage") { payload in
            sendPayload = payload
        }

        runtime.postMessage(
            msgType: "5",
            message: [
                "text": "Yes",
                "postback": "yes",
            ],
            chatUserId: "chat_user_1"
        )

        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let tempId = try XCTUnwrap(localMessage.tempId)
        let clientMessageId = try XCTUnwrap(localMessage.cMId)

        XCTAssertTrue(
            runtime.handleHTTPSendMessageTransportResponse(
                [
                    "data": [
                        "data": [
                            "message": [
                                "sequence_id": "postback_ack_1",
                                "send_time": Int64(1_779_860_000_103),
                                "content": [
                                    "msg": #""{\"postback\":\"yes\",\"text\":\"Yes\"}""#,
                                ],
                            ],
                        ],
                    ],
                ],
                tempId: tempId,
                clientMessageId: clientMessageId
            )
        )

        let acknowledgedMessage = try XCTUnwrap(runtime.state.messages.last)
        let component = SalesmartlyNativeMessagePresentation.component(for: acknowledgedMessage)
        XCTAssertEqual(acknowledgedMessage.msgType, "5")
        XCTAssertEqual(acknowledgedMessage.message, #"{"postback":"yes","text":"Yes"}"#)
        XCTAssertEqual(component.summary, "Yes")
        XCTAssertEqual(sendPayload["message"] as? String, #"{"postback":"yes","text":"Yes"}"#)
    }

    func testReceiveUnreadMessageDispatchesWidgetUnreadPayload() async throws {
        let runtime = SalesmartlyRuntime()
        var unreadPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onUnRead") { payload in
            unreadPayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "Agent message",
            sendTime: 1_779_860_000_789,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.unReadNum, 1)
        XCTAssertEqual(runtime.state.messages.last?.isRead, "0")
        XCTAssertEqual(unreadPayload["num"] as? Int, 1)
        let list = try XCTUnwrap(unreadPayload["list"] as? [ChatMessage])
        XCTAssertEqual(list.last?.id, "100")
    }

    func testReceiveQuoteChatPassesThroughAndBuildsWidgetQuotePreview() async throws {
        let runtime = SalesmartlyRuntime()
        var receivePayload: SalesmartlyPayload = [:]
        let quoteChat = #"{"chat_user_id":"chat_user_1","msg_type":"1","content":{"msg":"Quoted\n   text"}}"#

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onReceiveMessage") { payload in
            receivePayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "quote_1",
            senderType: "2",
            msgType: "1",
            message: "Reply",
            sendTime: 1_779_860_000_789,
            chatUserId: "chat_user_1",
            quoteChat: quoteChat
        )

        let message = try XCTUnwrap(runtime.state.messages.last)
        let component = SalesmartlyNativeMessagePresentation.component(for: message, showReceptionInfo: true)

        XCTAssertEqual(message.quoteChat, quoteChat)
        XCTAssertEqual(receivePayload["quote_chat"] as? String, quoteChat)
        XCTAssertEqual(component.quote_preview?.text, "Quoted text")
        XCTAssertEqual(component.quote_preview?.tag, "")
    }

    func testMessageRenderNodesMatchWidgetTimeDividerAndWithdrawRules() async throws {
        let messages = [
            ChatMessage(id: "m1", msgType: "1", message: "First", sendType: "2", createdTime: 1_000_000),
            ChatMessage(id: "sys1", msgType: "8", message: "System", sendType: "2", createdTime: 1_100_000),
            ChatMessage(id: "w1", msgType: "1", message: "Withdraw", sendType: "2", createdTime: 1_200_000, isWithdraw: "1"),
            ChatMessage(id: "m2", msgType: "1", message: "Second", sendType: "2", createdTime: 1_400_000),
        ]

        let hiddenWithdrawNodes = salesmartlyMessageRenderNodes(messages: messages, withdrawRecord: false)
        let visibleWithdrawNodes = salesmartlyMessageRenderNodes(messages: messages, withdrawRecord: true)

        XCTAssertEqual(hiddenWithdrawNodes.map(\.key), ["time_1000000_m1", "msg_m1", "msg_sys1", "time_1400000_m2", "msg_m2"])
        XCTAssertEqual(visibleWithdrawNodes.map(\.key), ["time_1000000_m1", "msg_m1", "msg_sys1", "msg_w1", "time_1400000_m2", "msg_m2"])
    }

    func testMessageAvatarVisibilityMatchesWidgetBubbleRules() async throws {
        XCTAssertTrue(salesmartlyShouldShowMessageAvatar(ChatMessage(id: "service", msgType: "1", message: "Hello", sendType: "2")))
        XCTAssertTrue(salesmartlyShouldShowMessageAvatar(ChatMessage(id: "robot", msgType: "1", message: "Hello", sendType: "3")))
        XCTAssertFalse(salesmartlyShouldShowMessageAvatar(ChatMessage(id: "visitor", msgType: "1", message: "Hello", sendType: "1")))
        XCTAssertFalse(salesmartlyShouldShowMessageAvatar(ChatMessage(id: "intro", msgType: "0", message: "Intro", sendType: "2")))
        XCTAssertFalse(salesmartlyShouldShowMessageAvatar(ChatMessage(id: "survey", msgType: "19", message: "Survey", sendType: "2")))
    }

    func testOpenChatMarksUnreadMessagesReadLikeWidgetEnterChat() async throws {
        let runtime = SalesmartlyRuntime()
        var unreadPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onUnRead") { payload in
            unreadPayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "Agent message",
            sendTime: 1_779_860_000_789,
            chatUserId: "chat_user_1"
        )

        runtime.openChat()

        XCTAssertEqual(runtime.state.unReadNum, 0)
        XCTAssertEqual(runtime.state.messages.last?.isRead, "1")
        XCTAssertEqual(unreadPayload["num"] as? Int, 0)
        XCTAssertTrue((unreadPayload["list"] as? [ChatMessage])?.isEmpty == true)
    }

    func testReadMessageMarksMessagesUpToSequenceIdRead() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "First",
            sendTime: 1_779_860_000_100,
            chatUserId: "chat_user_1"
        )
        runtime.receiveMessage(
            sequenceId: "101",
            senderType: "2",
            msgType: "1",
            message: "Second",
            sendTime: 1_779_860_000_101,
            chatUserId: "chat_user_1"
        )
        runtime.receiveMessage(
            sequenceId: "102",
            senderType: "2",
            msgType: "1",
            message: "Third",
            sendTime: 1_779_860_000_102,
            chatUserId: "chat_user_1"
        )

        let payload = runtime.readMessage(sequenceId: "101")

        XCTAssertEqual(payload["room_type"] as? Int, 6)
        XCTAssertEqual(payload["sequence_id"] as? String, "101")
        XCTAssertEqual(runtime.state.messages[0].isRead, "1")
        XCTAssertEqual(runtime.state.messages[1].isRead, "1")
        XCTAssertEqual(runtime.state.messages[2].isRead, "0")
        XCTAssertEqual(runtime.state.unReadNum, 1)
    }

    func testFailedAndRetryPrefixesMatchWidgetPendingMessageRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.sendTextMessage("Hello")

        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let tempId = try XCTUnwrap(localMessage.tempId)
        let clientMessageId = try XCTUnwrap(localMessage.cMId)

        runtime.markPendingMessagesFailed()

        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.id).hasPrefix("temp_"))
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.mid).hasPrefix("fail_"))

        XCTAssertTrue(runtime.retrySendMessage(tempId: tempId))
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.mid).hasPrefix("retry_"))
        XCTAssertEqual(runtime.retryingMap[clientMessageId]?.tempId, tempId)
    }

    func testRetryPostMessageBuildsHttpRetryPayloadsForPendingMessages() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.state.supportRetry = true

        SalesmartlyChat.sendTextMessage("First")
        let firstMessage = try XCTUnwrap(runtime.state.messages.last)
        let firstClientMessageId = try XCTUnwrap(firstMessage.cMId)
        try await Task.sleep(nanoseconds: 2_000_000)

        SalesmartlyChat.sendTextMessage("Second")
        let secondMessage = try XCTUnwrap(runtime.state.messages.last)
        let secondClientMessageId = try XCTUnwrap(secondMessage.cMId)
        XCTAssertTrue(runtime.retrySendMessage(tempId: try XCTUnwrap(secondMessage.tempId)))

        let payloads = runtime.retryPostMessage(loginToken: "token_1", chatUserId: "chat_user_1")

        XCTAssertEqual(payloads.count, 1)
        XCTAssertEqual(payloads.first?["ref"] as? String, "chat-plugin")
        XCTAssertEqual(payloads.first?["message"] as? String, "First")
        XCTAssertEqual(payloads.first?["login_token"] as? String, "token_1")
        XCTAssertEqual(payloads.first?["chat_user_id"] as? String, "chat_user_1")
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.cMId == firstClientMessageId }?.mid).hasPrefix("retry_"))
        XCTAssertNotNil(runtime.retryingMap[firstClientMessageId])
        XCTAssertNotNil(runtime.retryingMap[secondClientMessageId])
    }

    func testLikeMessagePayloadAndStateMatchWidgetSocketRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "like_template_1",
            senderType: "2",
            msgType: "3",
            message: #"{"payload":{"likes":{"like":"Like","unlike":"Unlike"}}}"#,
            sendTime: 1_779_860_000_900,
            chatUserId: "chat_user_1"
        )

        let payload = runtime.makeLikePayload(
            sequenceId: "like_template_1",
            flowId: nil,
            likeResult: "like",
            postback: "postback_like",
            clientExpandInfo: ["c_m_id": "client_like_1"]
        )

        XCTAssertEqual(payload["room_type"] as? Int, 6)
        XCTAssertEqual(payload["sequence_id"] as? String, "like_template_1")
        XCTAssertEqual(payload["flow_id"] as? String, "")
        XCTAssertEqual(payload["like_result"] as? String, "like")
        XCTAssertEqual(payload["postback"] as? String, "postback_like")
        XCTAssertEqual((payload["client_expand_info"] as? [String: String])?["c_m_id"], "client_like_1")
        XCTAssertEqual(runtime.state.messages.last?.likeResult?["like"], "")

        XCTAssertTrue(runtime.handleLikeMessageSuccess(sequenceId: "like_template_1", likeResult: "like"))
        XCTAssertEqual(runtime.state.messages.last?.likeResult?["like"], "like")
    }

    func testEvalutionAndStreamStopPayloadsMatchWidgetSocketRules() async throws {
        let runtime = SalesmartlyRuntime()

        let evalutionPayload = runtime.makeEvalutionPayload(
            sessionId: "session_1",
            sequenceId: "message_1",
            flowId: nil,
            stepLogId: nil,
            score: "5",
            comment: "good",
            inviteEvaluationId: "invite_1",
            inviteEvaluationOrderId: "order_1",
            clientExpandInfo: ["c_m_id": "client_evalution_1"]
        )
        let streamStopPayload = runtime.makeStreamStopPayload(
            mid: "stream_message_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(evalutionPayload["room_type"] as? Int, 6)
        XCTAssertEqual(evalutionPayload["session_id"] as? String, "session_1")
        XCTAssertEqual(evalutionPayload["sequence_id"] as? String, "message_1")
        XCTAssertEqual(evalutionPayload["flow_id"] as? String, "")
        XCTAssertEqual(evalutionPayload["step_log_id"] as? String, "")
        XCTAssertEqual(evalutionPayload["score"] as? String, "5")
        XCTAssertEqual(evalutionPayload["comment"] as? String, "good")
        XCTAssertEqual(evalutionPayload["invite_evaluation_id"] as? String, "invite_1")
        XCTAssertEqual(evalutionPayload["invite_evaluation_order_id"] as? String, "order_1")
        XCTAssertEqual((evalutionPayload["client_expand_info"] as? [String: String])?["c_m_id"], "client_evalution_1")
        XCTAssertEqual(streamStopPayload["sequence_id"] as? String, "stream_message_1")
        XCTAssertEqual(streamStopPayload["chat_user_id"] as? String, "chat_user_1")
    }

    /// 对齐 Android 评价错误提示：140001 表示已评价，140002 表示评价已过期，均展示 toast 且不标记消息成功。
    func testEvalutionErrorCodesAppendAndroidToastMessages() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.state.lang = "en-US"
        runtime.receiveMessage(
            sequenceId: "invite_evalution_1",
            senderType: "2",
            msgType: "3",
            message: #"{"type":"invite_evalution","payload":{"session_id":"session_1"}}"#,
            sendTime: 1_779_860_000_100,
            chatUserId: "chat_user_1"
        )
        let request = SalesmartlyTransportRequest(
            kind: .socketEvent,
            eventName: "evalution",
            path: nil,
            method: nil,
            query: [:],
            payload: ["sequence_id": "invite_evalution_1"],
            externalSign: false
        )

        XCTAssertFalse(
            runtime.handleEvalutionTransportResponse(
                ["data": ["error_code": 140001]],
                request: request
            )
        )
        XCTAssertEqual(
            runtime.state.toasts.last?.message,
            "The current session has been evaluated and cannot be re-evaluated"
        )
        XCTAssertEqual(runtime.state.messages.last?.status, 0)

        XCTAssertFalse(
            runtime.handleEvalutionTransportResponse(
                ["data": ["error_code": 140002]],
                request: request
            )
        )
        XCTAssertEqual(runtime.state.toasts.last?.message, "This review link has expired")
    }

    func testSubmitInviteEvalutionMessageMatchesWidgetScoreTplFlow() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setTransport(spy)
        runtime.receiveMessage(
            sequenceId: "invite_evalution_1",
            senderType: "2",
            msgType: "3",
            message: #"{"type":"invite_evalution","payload":{"session_id":"session_1","flow_id":"flow_1","step_log_id":"step_1","invite_evaluation_id":"invite_1","invite_evaluation_order_id":"order_1"}}"#,
            sendTime: 1_779_860_001_211,
            chatUserId: "chat_user_1"
        )
        let message = try XCTUnwrap(runtime.state.messages.first)

        let zeroScoreError = runtime.submitEvalutionMessage(
            message: message,
            score: 0,
            comment: ""
        )
        XCTAssertEqual(zeroScoreError, "请选择评分")
        XCTAssertTrue(spy.requests.isEmpty)

        let error = runtime.submitEvalutionMessage(
            message: message,
            score: 5,
            comment: "good"
        )

        XCTAssertNil(error)
        XCTAssertEqual(spy.requests.count, 1)
        XCTAssertEqual(spy.requests[0].eventName, "evalution")
        XCTAssertEqual(spy.requests[0].payload["room_type"] as? Int, 6)
        XCTAssertEqual(spy.requests[0].payload["session_id"] as? String, "session_1")
        XCTAssertEqual(spy.requests[0].payload["sequence_id"] as? String, "invite_evalution_1")
        XCTAssertEqual(spy.requests[0].payload["flow_id"] as? String, "flow_1")
        XCTAssertEqual(spy.requests[0].payload["step_log_id"] as? String, "step_1")
        XCTAssertEqual(spy.requests[0].payload["score"] as? String, "5")
        XCTAssertEqual(spy.requests[0].payload["comment"] as? String, "good")
        XCTAssertEqual(spy.requests[0].payload["invite_evaluation_id"] as? String, "invite_1")
        XCTAssertEqual(spy.requests[0].payload["invite_evaluation_order_id"] as? String, "order_1")
        XCTAssertNotNil((spy.requests[0].payload["client_expand_info"] as? [String: String])?["c_m_id"])
    }

    func testStreamMessageStateBlocksSendingAndStopsLikeWidget() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "stream_message_1",
            senderType: "3",
            msgType: "1",
            message: "Streaming response",
            sendTime: 1_779_860_000_980,
            chatUserId: "chat_user_1",
            streamInfo: SalesmartlyStreamInfo(count: 12, current: 4, size: 2, process: "running")
        )

        XCTAssertEqual(runtime.state.currentStreamInfo.mid, "stream_message_1")
        XCTAssertEqual(runtime.state.currentStreamInfo.msg, "Streaming response")
        XCTAssertEqual(runtime.state.currentStreamInfo.current, 4)
        XCTAssertEqual(runtime.state.messages.last?.isStream, "1")
        XCTAssertFalse(runtime.state.isStopStream)

        runtime.setStreamSending(true)
        let messageCount = runtime.state.messages.count

        runtime.postMessage(
            msgType: "1",
            message: "Blocked while streaming",
            tempId: "temp_blocked_stream_message_1",
            chatUserId: "chat_user_1"
        )
        SalesmartlyChat.sendTextMessage("Blocked command while streaming")

        XCTAssertEqual(runtime.state.messages.count, messageCount)
        XCTAssertTrue(runtime.sendMessageMap.isEmpty)

        let stopPayload = try XCTUnwrap(
            runtime.stopStreamMessage(
                mid: "stream_message_1",
                message: "Streaming",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertFalse(runtime.state.isStreamSending)
        XCTAssertTrue(runtime.state.isStopStream)
        XCTAssertEqual(runtime.state.messages.last?.message, "Streaming")
        XCTAssertEqual(runtime.state.messages.last?.isStop, "1")
        XCTAssertEqual(stopPayload["sequence_id"] as? String, "stream_message_1")
        XCTAssertEqual(stopPayload["chat_user_id"] as? String, "chat_user_1")

        runtime.resetStreamInfo()

        XCTAssertEqual(runtime.state.currentStreamInfo.mid, "")
        XCTAssertEqual(runtime.state.currentStreamInfo.msg, "")
        XCTAssertEqual(runtime.state.currentStreamInfo.current, 0)
    }

    func testStreamMessageRenderingAdvancesCompletesAndStopsWithRenderedTextLikeWidget() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "stream_render_1",
            senderType: "3",
            msgType: "1",
            message: "abcdef",
            sendTime: 1_779_860_001_000,
            chatUserId: "chat_user_1",
            streamInfo: SalesmartlyStreamInfo(count: 6, current: 0, size: 1, process: "running")
        )

        XCTAssertTrue(runtime.startStreamMessageRendering(mid: "stream_render_1"))
        XCTAssertTrue(runtime.state.isStreamSending)
        XCTAssertTrue(runtime.state.isStreamAnimating)
        XCTAssertEqual(runtime.state.streamMsg, "a")
        XCTAssertEqual(runtime.state.streamCurrentIndex, 1)

        XCTAssertTrue(runtime.advanceStreamMessageRendering())
        XCTAssertEqual(runtime.state.streamMsg, "ab")
        XCTAssertEqual(runtime.state.streamCurrentIndex, 2)

        let stopPayload = try XCTUnwrap(runtime.stopCurrentStreamMessage())

        XCTAssertFalse(runtime.state.isStreamSending)
        XCTAssertTrue(runtime.state.isStopStream)
        XCTAssertFalse(runtime.state.isStreamAnimating)
        XCTAssertEqual(runtime.state.messages.last?.message, "ab")
        XCTAssertEqual(runtime.state.messages.last?.isStop, "1")
        XCTAssertEqual(stopPayload["sequence_id"] as? String, "stream_render_1")
        XCTAssertEqual(stopPayload["chat_user_id"] as? String, "chat_user_1")

        let completedRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: completedRuntime)

        completedRuntime.receiveMessage(
            sequenceId: "stream_render_2",
            senderType: "3",
            msgType: "1",
            message: "xyz",
            sendTime: 1_779_860_001_010,
            chatUserId: "chat_user_2",
            streamInfo: SalesmartlyStreamInfo(count: 3, current: 0, size: 1, process: "running")
        )

        XCTAssertTrue(completedRuntime.startStreamMessageRendering(mid: "stream_render_2"))
        while completedRuntime.advanceStreamMessageRendering() {}

        XCTAssertFalse(completedRuntime.state.isStreamSending)
        XCTAssertFalse(completedRuntime.state.isStreamAnimating)
        XCTAssertEqual(completedRuntime.state.streamMsg, "")
        XCTAssertEqual(completedRuntime.state.streamCurrentIndex, 0)
        XCTAssertEqual(completedRuntime.state.currentStreamInfo.mid, "")
    }

    func testComposerDraftSubmitAndStopMatchWidgetTextBoxRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.setDraftText("  Hello  ")

        XCTAssertNil(runtime.handleComposerSubmit())
        XCTAssertEqual(runtime.state.messages.last?.message, "  Hello  ")
        XCTAssertEqual(runtime.state.draftText, "")
        XCTAssertEqual(runtime.sendMessageMap.count, 1)

        let messageCount = runtime.state.messages.count
        runtime.setDraftText("   ")

        XCTAssertNil(runtime.handleComposerSubmit())
        XCTAssertEqual(runtime.state.messages.count, messageCount)
        XCTAssertEqual(runtime.state.draftText, "   ")

        runtime.receiveMessage(
            sequenceId: "stream_message_2",
            senderType: "3",
            msgType: "1",
            message: "Streaming response",
            sendTime: 1_779_860_001_100,
            chatUserId: "chat_user_2",
            streamInfo: SalesmartlyStreamInfo(count: 12, current: 4, size: 2, process: "running")
        )
        runtime.setStreamSending(true)
        runtime.setDraftText("draft kept while stopping stream")

        let streamMessageCount = runtime.state.messages.count
        let stopPayload = try XCTUnwrap(runtime.handleComposerSubmit())

        XCTAssertEqual(runtime.state.messages.count, streamMessageCount)
        XCTAssertFalse(runtime.state.isStreamSending)
        XCTAssertTrue(runtime.state.isStopStream)
        XCTAssertEqual(runtime.state.messages.last?.isStop, "1")
        XCTAssertEqual(runtime.state.draftText, "draft kept while stopping stream")
        XCTAssertEqual(stopPayload["sequence_id"] as? String, "stream_message_2")
        XCTAssertEqual(stopPayload["chat_user_id"] as? String, "chat_user_2")
    }

    func testComposerEmojiLabelsAndAppendMatchWidgetTextBoxRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertEqual(SalesmartlyChatHost.chatInputEmojiLabels.count, 143)
        XCTAssertEqual(Array(SalesmartlyChatHost.chatInputEmojiLabels.prefix(4)), ["😀", "😃", "😄", "😁"])
        XCTAssertEqual(Array(SalesmartlyChatHost.chatInputEmojiLabels.suffix(4)), ["👐", "🤲", "🤝", "🙏"])

        runtime.setDraftText("hello")
        runtime.appendComposerEmoji("😀")

        XCTAssertEqual(runtime.state.draftText, "hello😀")
    }

    func testReceiveWithdrawNoticeMarksExistingMessageWithdrawn() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "withdraw_1",
            senderType: "2",
            msgType: "1",
            message: "Agent message",
            sendTime: 1_779_860_000_950,
            chatUserId: "chat_user_1"
        )

        XCTAssertTrue(runtime.receiveNotice(noticeType: 20, sequenceId: "withdraw_1"))
        XCTAssertEqual(runtime.state.messages.last?.message, "{}")
        XCTAssertEqual(runtime.state.messages.last?.isWithdraw, "1")
    }

    func testWithdrawUnreadMessageNoLongerCountsAsUnreadLikeWidget() async throws {
        let runtime = SalesmartlyRuntime()
        var unreadPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onUnRead") { payload in
            unreadPayload = payload
        }

        runtime.receiveMessage(
            sequenceId: "withdraw_unread_1",
            senderType: "2",
            msgType: "1",
            message: "Unread agent message",
            sendTime: 1_779_860_000_950,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.unReadNum, 1)
        XCTAssertTrue(runtime.receiveNotice(noticeType: 20, sequenceId: "withdraw_unread_1"))
        XCTAssertEqual(runtime.state.messages.last?.isWithdraw, "1")
        XCTAssertEqual(runtime.state.unReadNum, 0)
        XCTAssertEqual(unreadPayload["num"] as? Int, 0)
    }

    func testReceiveInteractiveMessagesKeepWidgetPendingStatus() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "invite_evalution_1",
            senderType: "2",
            msgType: "3",
            message: #"{"type":"invite_evalution","payload":{"session_id":"session_1"}}"#,
            sendTime: 1_779_860_000_990,
            chatUserId: "chat_user_1"
        )
        try await Task.sleep(nanoseconds: 2_000_000)
        runtime.receiveMessage(
            sequenceId: "promotional_card_1",
            senderType: "2",
            msgType: "3",
            message: ##"{"payload":{"text":"Save","attachments":[],"buttons":[{"type":"postback","text":"Claim","payload":"claim"}],"promotional_card":{"type":"discount","text":"Save now","text_color":"#111111","btn_color":"#222222","image":"https://cdn.example.com/card.png","discount":80,"countdown":10}}}"##,
            sendTime: 1_779_860_000_991,
            chatUserId: "chat_user_1"
        )
        runtime.receiveMessage(
            sequenceId: "ai_guide_1",
            senderType: "2",
            msgType: "11",
            message: #"{"type":"guide","data":[]}"#,
            sendTime: 1_779_860_001_000,
            chatUserId: "chat_user_1"
        )
        runtime.receiveMessage(
            sequenceId: "quick_reply_1",
            senderType: "2",
            msgType: "21",
            message: #"{"payload":{"buttons":[{"type":"postback","text":"Yes","payload":"yes"}]}}"#,
            sendTime: 1_779_860_001_001,
            chatUserId: "chat_user_1"
        )

        XCTAssertTrue(try XCTUnwrap(runtime.state.messages[0].tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages[0].status, 0)
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages[1].tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages[1].status, 0)
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages[2].tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages[2].status, 0)
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages[3].tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages[3].status, 0)

        let inviteTempId = try XCTUnwrap(runtime.state.messages[0].tempId)
        XCTAssertTrue(runtime.handleEvalutionMessageSuccess(tempId: inviteTempId))
        XCTAssertEqual(runtime.state.messages[0].status, 1)

        runtime.receiveMessage(
            sequenceId: "own_reply_1",
            senderType: "1",
            msgType: "1",
            message: "Yes",
            sendTime: 1_779_860_001_002,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[3].status, 1)

        let promotionalTempId = try XCTUnwrap(runtime.state.messages[1].tempId)
        runtime.postMessage(
            msgType: "5",
            message: [
                "text": "Claim",
                "postback": "claim",
            ],
            tempId: promotionalTempId,
            type: "promotionalCard",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[1].status, 1)
        XCTAssertEqual(runtime.state.messages.last?.msgType, "5")
        XCTAssertEqual(runtime.state.messages.last?.message, #"{"postback":"claim","text":"Claim"}"#)
    }

    func testSubmitPromotionalCardEmailMatchesWidgetPostbackFlow() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        let store = SalesmartlyLocalStoreSpy()
        runtime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "promo_plugin_1",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        let keys = runtime.makeLocalStorageKeys()
        store.values[keys.userInfoKey] = #"{"chat_user_id":"chat_user_1","info":{"name":"Ada"}}"#
        runtime.receiveMessage(
            sequenceId: "promotional_card_1",
            senderType: "2",
            msgType: "3",
            message: ##"{"payload":{"buttons":[{"type":"postback","text":"Claim","payload":"claim"}],"promotional_card":{"type":"discount","text":"Save now","text_color":"#111111","btn_color":"#222222","image":"https://cdn.example.com/card.png","discount":80,"countdown":10}}}"##,
            sendTime: 1_779_860_001_111,
            chatUserId: "chat_user_1"
        )
        let tempId = try XCTUnwrap(runtime.state.messages.first?.tempId)

        let error = runtime.submitPromotionalCardEmail(
            email: "ada@example.com",
            button: SalesmartlyNativeTemplateButton(
                type: "postback",
                text: "Claim",
                label: nil,
                payload: "claim",
                url: nil
            ),
            tempId: tempId
        )

        XCTAssertNil(error)
        XCTAssertEqual(spy.requests.count, 2)
        XCTAssertEqual(spy.requests[0].path, "chat/msg-user/update-user")
        XCTAssertEqual(spy.requests[0].payload["token"] as? String, "token_1")
        XCTAssertEqual(spy.requests[0].payload["email"] as? String, "ada@example.com")
        XCTAssertEqual(spy.requests[0].payload["chat_user_id"] as? String, "chat_user_1")
        XCTAssertNil(spy.requests[0].payload["source"])
        XCTAssertEqual(spy.requests[1].path, "chat/chat-auto/trigger")
        XCTAssertEqual(spy.requests[1].query["login_token"], "token_1")
        XCTAssertEqual(spy.requests[1].query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(spy.requests[1].payload["trigger_type"] as? String, "16")
        XCTAssertEqual(spy.requests[1].payload["source"] as? String, "3")
        XCTAssertEqual(spy.requests[1].payload["flow_id"] as? String, "flow_1")
        let triggerDataString = try XCTUnwrap(spy.requests[1].payload["data"] as? String)
        let triggerData = try XCTUnwrap(triggerDataString.data(using: .utf8))
        let triggerParams = try XCTUnwrap(JSONSerialization.jsonObject(with: triggerData) as? [String: String])
        XCTAssertEqual(triggerParams["chat_user_id"], "chat_user_1")
        XCTAssertEqual(triggerParams["email"], "ada@example.com")

        let recordData = try XCTUnwrap(store.values[keys.userInfoKey]?.data(using: .utf8))
        let record = try XCTUnwrap(JSONSerialization.jsonObject(with: recordData) as? [String: Any])
        let info = try XCTUnwrap(record["info"] as? [String: String])
        XCTAssertEqual(info["name"], "Ada")
        XCTAssertEqual(info["email"], "ada@example.com")
        XCTAssertEqual(runtime.state.messages.first?.status, 1)
        XCTAssertEqual(runtime.state.messages.last?.msgType, "5")
        XCTAssertEqual(runtime.state.messages.last?.message, #"{"postback":"claim","text":"Claim"}"#)
    }

    func testReceiveOwnMessageCompletesPreviousInteractiveMessageStatus() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "ai_guide_1",
            senderType: "2",
            msgType: "11",
            message: #"{"type":"guide","data":[]}"#,
            sendTime: 1_779_860_001_000,
            chatUserId: "chat_user_1"
        )
        runtime.receiveMessage(
            sequenceId: "own_reply_1",
            senderType: "1",
            msgType: "1",
            message: "Question answer",
            sendTime: 1_779_860_001_002,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[0].status, 1)

        runtime.receiveMessage(
            sequenceId: "quick_reply_1",
            senderType: "2",
            msgType: "21",
            message: #"{"payload":{"buttons":[{"type":"postback","text":"Yes","payload":"yes"}]}}"#,
            sendTime: 1_779_860_001_003,
            chatUserId: "chat_user_1"
        )
        runtime.receiveMessage(
            sequenceId: "own_reply_2",
            senderType: "1",
            msgType: "1",
            message: "Yes",
            sendTime: 1_779_860_001_004,
            chatUserId: "chat_user_1"
        )

        let quickReply = try XCTUnwrap(runtime.state.messages.first { $0.id == "quick_reply_1" })
        XCTAssertEqual(quickReply.status, 1)
    }

    func testReceiveNoticeUpdatesWidgetTypingAndAssignUserState() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveNotice(
            noticeType: 3,
            pushTime: 1_779_860_001_100,
            chatUserId: "chat_user_1",
            sysUserId: "sys_user_1",
            nickname: "Ada",
            avatar: "avatar.png",
            sysUserAvatar: "sys-avatar.png"
        )

        XCTAssertEqual(runtime.state.messages.last?.msgType, "8")
        XCTAssertEqual(runtime.state.messages.last?.message, #"{"type":"join_session","nickname":"Ada"}"#)
        XCTAssertEqual(runtime.state.assignUserInfo["avatar"], "avatar.png")
        XCTAssertEqual(runtime.state.assignUserInfo["nickname"], "Ada")
        XCTAssertEqual(runtime.state.assignUserInfo["sys_user_id"], "sys_user_1")

        XCTAssertTrue(runtime.receiveNotice(noticeType: 19))
        XCTAssertTrue(runtime.state.showRobotTyping)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 24, nowMilliseconds: 10_000))
        XCTAssertTrue(runtime.state.showRobotTyping)
        XCTAssertGreaterThanOrEqual(runtime.state.robotTypingHideAtMilliseconds, 12_000)
        XCTAssertLessThanOrEqual(runtime.state.robotTypingHideAtMilliseconds, 13_000)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 33))
        XCTAssertTrue(runtime.state.showServiceTyping)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 4))
        XCTAssertEqual(runtime.state.assignUserInfo["sys_user_id"], "")
    }

    func testTypingNoticeTimersMatchWidgetUseSocketRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 19, nowMilliseconds: 1_000))
        XCTAssertTrue(runtime.state.showRobotTyping)
        XCTAssertEqual(runtime.state.robotTypingHideAtMilliseconds, 61_000)

        XCTAssertFalse(runtime.advanceTypingTimers(nowMilliseconds: 60_999))
        XCTAssertTrue(runtime.state.showRobotTyping)
        XCTAssertTrue(runtime.advanceTypingTimers(nowMilliseconds: 61_000))
        XCTAssertFalse(runtime.state.showRobotTyping)
        XCTAssertEqual(runtime.state.robotTypingHideAtMilliseconds, 0)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 19, nowMilliseconds: 70_000))
        XCTAssertTrue(runtime.receiveNotice(noticeType: 24, nowMilliseconds: 71_000))
        XCTAssertTrue(runtime.state.showRobotTyping)
        let helplookHideAtMilliseconds = runtime.state.robotTypingHideAtMilliseconds
        XCTAssertGreaterThanOrEqual(helplookHideAtMilliseconds, 73_000)
        XCTAssertLessThanOrEqual(helplookHideAtMilliseconds, 74_000)
        XCTAssertFalse(runtime.advanceTypingTimers(nowMilliseconds: helplookHideAtMilliseconds - 1))
        XCTAssertTrue(runtime.state.showRobotTyping)
        XCTAssertTrue(runtime.advanceTypingTimers(nowMilliseconds: helplookHideAtMilliseconds))
        XCTAssertFalse(runtime.state.showRobotTyping)
        XCTAssertEqual(runtime.state.robotTypingHideAtMilliseconds, 0)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 33, nowMilliseconds: 2_000))
        XCTAssertTrue(runtime.state.showServiceTyping)
        XCTAssertEqual(runtime.state.serviceTypingHideAtMilliseconds, 12_000)

        XCTAssertTrue(runtime.receiveNotice(noticeType: 33, nowMilliseconds: 5_000))
        XCTAssertEqual(runtime.state.serviceTypingHideAtMilliseconds, 15_000)
        XCTAssertFalse(runtime.advanceTypingTimers(nowMilliseconds: 14_999))
        XCTAssertTrue(runtime.state.showServiceTyping)
        XCTAssertTrue(runtime.advanceTypingTimers(nowMilliseconds: 15_000))
        XCTAssertFalse(runtime.state.showServiceTyping)
        XCTAssertEqual(runtime.state.serviceTypingHideAtMilliseconds, 0)
    }

    func testPostMessageInsertsWidgetLocalMessagesAndSendCandidates() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "ai_guide_post_1",
            senderType: "2",
            msgType: "11",
            message: #"{"type":"guide","data":[]}"#,
            sendTime: 1_779_860_001_200,
            chatUserId: "chat_user_1"
        )
        runtime.postMessage(
            msgType: "11",
            message: [
                "type": "postback",
                "data": [
                    "id": "question_1",
                    "question": "Where is my order?",
                ],
            ],
            tempId: "temp_post_ai_1",
            status: 1,
            mid: "ai_guide_post_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[0].status, 1)
        XCTAssertEqual(runtime.state.messages[1].msgType, "11")
        XCTAssertEqual(
            runtime.state.messages[1].message,
            #"{"data":{"id":"question_1","question":"Where is my order?"},"type":"postback"}"#
        )
        XCTAssertEqual(runtime.state.messages[1].sendType, "1")
        XCTAssertEqual(runtime.state.messages[1].chatUserId, "chat_user_1")
        XCTAssertTrue(runtime.state.messages[1].mid.hasPrefix("temp_"))
        XCTAssertEqual(
            runtime.sendMessageMap[try XCTUnwrap(runtime.state.messages[1].cMId)]?.tempId,
            runtime.state.messages[1].tempId
        )

        runtime.postMessage(
            msgType: "5",
            message: [
                "text": "Yes",
                "postback": "yes",
            ],
            tempId: "temp_postback_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[2].msgType, "5")
        XCTAssertEqual(runtime.state.messages[2].message, #"{"postback":"yes","text":"Yes"}"#)
        XCTAssertEqual(
            runtime.sendMessageMap[try XCTUnwrap(runtime.state.messages[2].cMId)]?.tempId,
            runtime.state.messages[2].tempId
        )

        runtime.postMessage(
            msgType: "19",
            message: #"{"fields":[]}"#,
            tempId: "temp_collection_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[3].msgType, "19")
        XCTAssertEqual(
            runtime.sendMessageMap[try XCTUnwrap(runtime.state.messages[3].cMId)]?.tempId,
            runtime.state.messages[3].tempId
        )

        runtime.postMessage(
            msgType: "2",
            message: "blob:local-image",
            tempId: "temp_blob_image_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[4].msgType, "2")
        XCTAssertNil(runtime.sendMessageMap[try XCTUnwrap(runtime.state.messages[4].cMId)])

        runtime.postMessage(
            msgType: "2",
            message: "https://cdn.example.com/image.png",
            tempId: "temp_https_image_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages[5].msgType, "2")
        XCTAssertEqual(
            runtime.sendMessageMap[try XCTUnwrap(runtime.state.messages[5].cMId)]?.tempId,
            runtime.state.messages[5].tempId
        )
    }

    func testQuickReplyPostbackMarksOriginalMessageAndKeepsWidgetPayloadShape() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "quick_reply_postback_1",
            senderType: "2",
            msgType: "21",
            message: #"{"payload":{"text":"Choose","buttons":[{"type":"postback","text":"Yes","payload":"yes"}]}}"#,
            sendTime: 1_779_860_001_300,
            chatUserId: "chat_user_1"
        )
        try await Task.sleep(nanoseconds: 2_000_000)
        runtime.postMessage(
            msgType: "5",
            message: [
                "text": "Yes",
                "postback": "yes",
            ],
            status: 1,
            mid: "quick_reply_postback_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages.count, 2)
        let originalMessage = try XCTUnwrap(runtime.state.messages.first { $0.id == "quick_reply_postback_1" })
        let postbackMessage = try XCTUnwrap(runtime.state.messages.last)
        XCTAssertEqual(originalMessage.status, 1)
        XCTAssertEqual(postbackMessage.msgType, "5")
        XCTAssertEqual(postbackMessage.message, #"{"postback":"yes","text":"Yes"}"#)
    }

    func testQuickReplyAlwaysShowPostbackKeepsOriginalMessageVisible() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "quick_reply_always_show_1",
            senderType: "2",
            msgType: "21",
            message: #"{"payload":{"text":"Choose","always_show":true,"buttons":[{"type":"postback","text":"Yes","payload":"yes"}]}}"#,
            sendTime: 1_779_860_001_301,
            chatUserId: "chat_user_1"
        )
        try await Task.sleep(nanoseconds: 2_000_000)
        runtime.postMessage(
            msgType: "5",
            message: [
                "text": "Yes",
                "postback": "yes",
            ],
            status: 0,
            mid: "quick_reply_always_show_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages.count, 2)
        let originalMessage = try XCTUnwrap(runtime.state.messages.first { $0.id == "quick_reply_always_show_1" })
        let postbackMessage = try XCTUnwrap(runtime.state.messages.last)
        XCTAssertEqual(originalMessage.status, 0)
        XCTAssertEqual(postbackMessage.msgType, "5")
        XCTAssertEqual(postbackMessage.message, #"{"postback":"yes","text":"Yes"}"#)
    }

    func testSocketRoomFrameAndHumanPayloadsMatchWidgetCommonParams() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        XCTAssertNil(runtime.openFrame())
        XCTAssertEqual(runtime.state.pendingSocketEvents, ["open-frame"])

        let joinPayload = try XCTUnwrap(runtime.joinRoom())
        XCTAssertEqual(joinPayload["room_type"] as? Int, 6)
        XCTAssertEqual(joinPayload["flow_id"] as? String, "flow_1")
        XCTAssertTrue(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "ws")

        let queuedEvents = runtime.flushPendingSocketEvents()
        let queuedEvent = try XCTUnwrap(queuedEvents.first)
        let queuedPayload = try XCTUnwrap(queuedEvent["payload"] as? SalesmartlyPayload)
        XCTAssertEqual(queuedEvent["event"] as? String, "open-frame")
        XCTAssertEqual(queuedPayload["room_type"] as? Int, 6)
        XCTAssertEqual(queuedPayload["flow_id"] as? String, "flow_1")
        XCTAssertTrue(runtime.state.pendingSocketEvents.isEmpty)

        let openFramePayload = try XCTUnwrap(runtime.openFrame())
        XCTAssertEqual(openFramePayload["room_type"] as? Int, 6)
        XCTAssertEqual(openFramePayload["flow_id"] as? String, "flow_1")

        let humanServicePayload = runtime.makeHumanServicePayload()
        XCTAssertEqual(humanServicePayload["room_type"] as? Int, 6)
        XCTAssertNil(humanServicePayload["flow_id"])

        let leavePayload = try XCTUnwrap(runtime.leaveRoom())
        XCTAssertEqual(leavePayload["room_type"] as? Int, 6)
        XCTAssertEqual(leavePayload["flow_id"] as? String, "flow_1")
        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")
    }

    func testSendMessageByModeMatchesWidgetWsHttpRetryAndDemoRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        SalesmartlyChat.sendTextMessage("Hello")
        let message = try XCTUnwrap(runtime.state.messages.last)

        let socketPayload = try XCTUnwrap(
            runtime.makeSendMessagePayloadByMode(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        XCTAssertEqual(socketPayload["room_type"] as? Int, 6)
        XCTAssertEqual(socketPayload["flow_id"] as? String, "flow_1")
        XCTAssertNil(socketPayload["ref"])

        runtime.leaveRoom()
        let socketPayloadWithoutRetrySupport = try XCTUnwrap(
            runtime.makeSendMessagePayloadByMode(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        XCTAssertEqual(socketPayloadWithoutRetrySupport["room_type"] as? Int, 6)
        XCTAssertNil(socketPayloadWithoutRetrySupport["ref"])

        runtime.state.supportRetry = true
        let httpPayload = try XCTUnwrap(
            runtime.makeSendMessagePayloadByMode(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        XCTAssertEqual(httpPayload["ref"] as? String, "chat-plugin")
        XCTAssertEqual(httpPayload["login_token"] as? String, "token_1")
        XCTAssertEqual(httpPayload["chat_user_id"] as? String, "chat_user_1")

        runtime.joinRoom()
        runtime.state.supportRetry = false
        let retrySocketPayload = try XCTUnwrap(
            runtime.makeSendMessagePayloadByMode(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1",
                type: "retry"
            )
        )
        XCTAssertEqual(retrySocketPayload["room_type"] as? Int, 6)
        XCTAssertNil(retrySocketPayload["ref"])

        runtime.state.supportRetry = true
        let retryPayload = try XCTUnwrap(
            runtime.makeSendMessagePayloadByMode(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1",
                type: "retry"
            )
        )
        XCTAssertEqual(retryPayload["ref"] as? String, "chat-plugin")

        let demoRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: demoRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .demo)
            )
        )
        SalesmartlyChat.sendTextMessage("Demo")
        let demoMessage = try XCTUnwrap(demoRuntime.state.messages.last)
        XCTAssertNil(
            demoRuntime.makeSendMessagePayloadByMode(
                for: demoMessage,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
    }

    func testSendTextMessageAutomaticallyDispatchesSocketRequestWhenJoined() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"

        XCTAssertNotNil(
            runtime.connectSocketTransport(
                loginToken: "token_1",
                chatUserId: "chat_user_1",
                pluginId: "YOUR_LICENSE",
                projectId: "project_1"
            )
        )

        SalesmartlyChat.sendTextMessage("Auto socket text")

        XCTAssertEqual(spy.requests.last?.eventName, "send-message")
        XCTAssertEqual(spy.requests.last?.payload["message"] as? String, "Auto socket text")
        XCTAssertEqual(spy.requests.last?.payload["room_type"] as? Int, 6)
        XCTAssertEqual(spy.requests.last?.payload["flow_id"] as? String, "flow_1")
    }

    func testTransportRequestsMatchWidgetSocketAndHttpBoundaries() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        let socketConnection = runtime.makeSocketConnectionRequest(
            loginToken: "token_1",
            chatUserId: "chat_user_1",
            pluginId: "plugin_1",
            projectId: "project_1"
        )

        XCTAssertEqual(socketConnection.query["ref"], "chat-plugin")
        XCTAssertEqual(socketConnection.query["login_token"], "token_1")
        XCTAssertEqual(socketConnection.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(socketConnection.query["plugin_id"], "plugin_1")
        XCTAssertEqual(socketConnection.query["_xma_"], "project_1")
        XCTAssertEqual(socketConnection.transports, ["websocket"])
        XCTAssertEqual(socketConnection.reconnectionAttempts, 30)

        XCTAssertNil(runtime.makeOpenFrameTransportRequest())
        XCTAssertEqual(runtime.state.pendingSocketEvents, ["open-frame"])

        let joinRequest = try XCTUnwrap(runtime.makeJoinRoomTransportRequest())
        XCTAssertEqual(joinRequest.kind, .socketEvent)
        XCTAssertEqual(joinRequest.eventName, "join-room")
        XCTAssertEqual(joinRequest.payload["room_type"] as? Int, 6)
        XCTAssertEqual(joinRequest.payload["flow_id"] as? String, "flow_1")
        XCTAssertTrue(joinRequest.payloadJSONString().contains(#""room_type":6"#))

        let queuedRequests = runtime.flushPendingSocketTransportRequests()
        XCTAssertEqual(queuedRequests.count, 1)
        XCTAssertEqual(queuedRequests.first?.eventName, "open-frame")
        XCTAssertEqual(queuedRequests.first?.payload["flow_id"] as? String, "flow_1")

        SalesmartlyChat.sendTextMessage("Hello")
        let message = try XCTUnwrap(runtime.state.messages.last)
        let socketSend = try XCTUnwrap(
            runtime.makeSendMessageTransportRequest(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertEqual(socketSend.kind, .socketEvent)
        XCTAssertEqual(socketSend.eventName, "send-message")
        XCTAssertEqual(socketSend.payload["message"] as? String, "Hello")

        runtime.state.supportRetry = true
        _ = runtime.leaveRoom()

        let httpSend = try XCTUnwrap(
            runtime.makeSendMessageTransportRequest(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertEqual(httpSend.kind, .http)
        XCTAssertEqual(httpSend.method, .post)
        XCTAssertEqual(httpSend.path, "/chat/chat-msg/send-message")
        XCTAssertEqual(httpSend.payload["ref"] as? String, "chat-plugin")
        XCTAssertEqual(httpSend.externalSign, true)

        let readRequest = runtime.makeReadMessageTransportRequest(sequenceId: "server_1")
        XCTAssertEqual(readRequest.kind, .socketEvent)
        XCTAssertEqual(readRequest.eventName, "read-message")
        XCTAssertEqual(readRequest.payload["sequence_id"] as? String, "server_1")

        let queueRequest = runtime.makeQueueStatusTransportRequest(chatUserId: "chat_user_1")
        XCTAssertEqual(queueRequest.kind, .http)
        XCTAssertEqual(queueRequest.method, .get)
        XCTAssertEqual(queueRequest.path, "user/plugin-queue-status")
        XCTAssertEqual(queueRequest.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(queueRequest.externalSign, true)

        let humanRequest = runtime.makeHumanServiceTransportRequest()
        XCTAssertEqual(humanRequest.kind, .socketEvent)
        XCTAssertEqual(humanRequest.eventName, "human-service")
        XCTAssertEqual(humanRequest.payload["room_type"] as? Int, 6)

        let streamStopRequest = runtime.makeStreamStopTransportRequest(mid: "server_1", chatUserId: "chat_user_1")
        XCTAssertEqual(streamStopRequest.kind, .socketEvent)
        XCTAssertEqual(streamStopRequest.eventName, "stream-stop")
        XCTAssertEqual(streamStopRequest.payload["sequence_id"] as? String, "server_1")
        XCTAssertEqual(streamStopRequest.payload["chat_user_id"] as? String, "chat_user_1")

        let recentRequest = runtime.makeRecentMsgListTransportRequest(loginToken: "token_1", chatUserId: "chat_user_1")
        XCTAssertEqual(recentRequest.path, "/chat/chat-msg/recent-msg-list-v2")
        XCTAssertEqual(recentRequest.query["login_token"], "token_1")
        XCTAssertEqual(recentRequest.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(recentRequest.query["sender_type"], "2")
        XCTAssertEqual(recentRequest.query["limit"], "10")

        let triggerPayload = runtime.makeTriggerUrlPayload(
            sourceURL: "https://example.com/products",
            uniqueId: "page_token_1",
            scrollNum: 120,
            delayNum: 2
        )
        let triggerRequest = runtime.makeTriggerTransportRequest(
            token: "token_1",
            chatUserId: "chat_user_1",
            payload: triggerPayload
        )
        XCTAssertEqual(triggerRequest.path, "chat/chat-auto/trigger")
        XCTAssertEqual(triggerRequest.query["login_token"], "token_1")
        XCTAssertEqual(triggerRequest.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(triggerRequest.payload["trigger_type"] as? String, "11")

        let triggerUserRequest = runtime.makeTriggerUserTransportRequest(
            token: "token_1",
            chatUserId: "chat_user_1",
            payload: ["is_new_user": "1"]
        )
        XCTAssertEqual(triggerUserRequest.path, "chat/chat-auto/user/trigger")
        XCTAssertEqual(triggerUserRequest.payload["is_new_user"] as? String, "1")

        let updateRequests = runtime.makeUpdateUserInfoTransportRequests(
            token: "token_1",
            userName: "Ada",
            chatUserId: "chat_user_1",
            source: "2"
        )
        XCTAssertEqual(updateRequests.updateUser.path, "chat/msg-user/update-user")
        XCTAssertEqual(updateRequests.updateUser.payload["token"] as? String, "token_1")
        XCTAssertEqual(updateRequests.updateUser.payload["user_name"] as? String, "Ada")
        XCTAssertEqual(updateRequests.trigger.path, "chat/chat-auto/trigger")

        let spy = SalesmartlyTransportSpy()
        runtime.setTransport(spy)
        runtime.sendTransportRequest(readRequest)

        XCTAssertEqual(spy.requests.count, 1)
        XCTAssertEqual(spy.requests.first?.eventName, "read-message")
    }

    func testTransportDispatchWrappersSendWidgetRequestsThroughInjectedTransport() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        runtime.setTransport(spy)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        XCTAssertNil(runtime.sendOpenFrameTransportRequest())
        XCTAssertEqual(runtime.state.pendingSocketEvents, ["open-frame"])

        let joinRequest = try XCTUnwrap(runtime.sendJoinRoomTransportRequest())
        XCTAssertEqual(joinRequest.eventName, "join-room")
        XCTAssertEqual(spy.requests.last?.eventName, "join-room")

        let pendingRequests = runtime.sendPendingSocketTransportRequests()
        XCTAssertEqual(pendingRequests.count, 1)
        XCTAssertEqual(spy.requests.last?.eventName, "open-frame")

        SalesmartlyChat.sendTextMessage("Hello")
        let message = try XCTUnwrap(runtime.state.messages.last)
        let socketSend = try XCTUnwrap(
            runtime.sendMessageTransportRequest(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        XCTAssertEqual(socketSend.eventName, "send-message")
        XCTAssertEqual(spy.requests.last?.eventName, "send-message")

        let readRequest = runtime.sendReadMessageTransportRequest(sequenceId: "server_1")
        XCTAssertEqual(readRequest.eventName, "read-message")
        XCTAssertEqual(spy.requests.last?.eventName, "read-message")

        let humanRequest = runtime.sendHumanServiceTransportRequest()
        XCTAssertEqual(humanRequest.eventName, "human-service")
        XCTAssertEqual(spy.requests.last?.eventName, "human-service")

        let streamStopRequest = runtime.sendStreamStopTransportRequest(mid: "server_1", chatUserId: "chat_user_1")
        XCTAssertEqual(streamStopRequest.eventName, "stream-stop")
        XCTAssertEqual(spy.requests.last?.eventName, "stream-stop")

        let queueRequest = runtime.sendQueueStatusTransportRequest(chatUserId: "chat_user_1")
        XCTAssertEqual(queueRequest.path, "user/plugin-queue-status")
        XCTAssertEqual(spy.requests.last?.path, "user/plugin-queue-status")

        let triggerRequest = runtime.sendTriggerTransportRequest(
            token: "token_1",
            chatUserId: "chat_user_1",
            payload: ["trigger_type": "11"]
        )
        XCTAssertEqual(triggerRequest.path, "chat/chat-auto/trigger")
        XCTAssertEqual(spy.requests.last?.path, "chat/chat-auto/trigger")

        let updateRequests = runtime.sendUpdateUserInfoTransportRequests(
            token: "token_1",
            userName: "Ada",
            chatUserId: "chat_user_1",
            source: "2"
        )
        XCTAssertEqual(updateRequests.updateUser.path, "chat/msg-user/update-user")
        XCTAssertEqual(updateRequests.trigger.path, "chat/chat-auto/trigger")
        XCTAssertEqual(spy.requests.suffix(2).map { $0.path }, ["chat/msg-user/update-user", "chat/chat-auto/trigger"])

        let leaveRequest = try XCTUnwrap(runtime.sendLeaveRoomTransportRequest())
        XCTAssertEqual(leaveRequest.eventName, "leave-room")
        XCTAssertEqual(spy.requests.last?.eventName, "leave-room")

        runtime.state.supportRetry = true
        let httpSend = try XCTUnwrap(
            runtime.sendMessageTransportRequest(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        XCTAssertEqual(httpSend.path, "/chat/chat-msg/send-message")
        XCTAssertEqual(spy.requests.last?.path, "/chat/chat-msg/send-message")
    }

    func testPendingSendMessageTransportRequestsFlushWidgetSendMapByMode() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)
        runtime.joinRoom()

        SalesmartlyChat.sendTextMessage("Queued text")
        runtime.postMessage(
            msgType: "2",
            message: "blob:local-image",
            tempId: "temp_local_image_1",
            chatUserId: "chat_user_1"
        )
        runtime.postMessage(
            msgType: "2",
            message: "https://cdn.example.com/photo.png",
            tempId: "temp_sent_image_1",
            chatUserId: "chat_user_1"
        )

        let socketRequests = runtime.sendPendingMessageTransportRequests(
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(socketRequests.count, 2)
        XCTAssertEqual(spy.requests.map(\.eventName), ["send-message", "send-message"])
        XCTAssertEqual(spy.requests.map { $0.payload["message"] as? String }, ["Queued text", "https://cdn.example.com/photo.png"])
        XCTAssertEqual(runtime.sendMessageMap.count, 2)

        runtime.state.supportRetry = true
        _ = runtime.leaveRoom()

        let httpRequests = runtime.sendPendingMessageTransportRequests(
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(httpRequests.count, 2)
        XCTAssertEqual(spy.requests.suffix(2).map(\.path), ["/chat/chat-msg/send-message", "/chat/chat-msg/send-message"])
        XCTAssertEqual(spy.requests.suffix(2).map { $0.payload["ref"] as? String }, ["chat-plugin", "chat-plugin"])
    }

    func testTransportResponsesApplyWidgetReceiveNoticePollingTriggerAndQueueShapes() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        var receivePayload: SalesmartlyPayload = [:]
        SalesmartlyChat.push("onReceiveMessage") { payload in
            receivePayload = payload
        }

        XCTAssertTrue(
            runtime.handleReceiveMessageTransportPayload([
                "code": 0,
                "data": [
                    "chat_user_id": "chat_user_1",
                    "sequence_id": "server_receive_1",
                    "sender_type": "2",
                    "sender": "sys_user_1",
                    "sender_name": "Ada",
                    "sender_avatar": "",
                    "sys_user_avatar": "",
                    "send_time": "1779860001000",
                    "msg_type": "1",
                    "content": [
                        "msg": "Transport receive",
                    ],
                    "read_time": "0",
                    "client_expand_info": [
                        "c_m_id": "cm_receive_1",
                    ],
                ] as SalesmartlyPayload,
            ])
        )
        XCTAssertEqual(runtime.state.messages.last?.id, "server_receive_1")
        XCTAssertEqual(runtime.state.messages.last?.message, "Transport receive")
        XCTAssertEqual(runtime.state.messages.last?.cMId, "cm_receive_1")
        XCTAssertEqual(runtime.state.unReadNum, 1)
        XCTAssertEqual(receivePayload["mid"] as? String, "server_receive_1")

        XCTAssertTrue(
            runtime.handleReceiveNoticeTransportPayload([
                "code": 0,
                "data": [
                    "notice_type": 20,
                    "push_time": 1_779_860_002_000,
                    "notice": [
                        "chat_user_id": "chat_user_1",
                        "sequence_id": "server_receive_1",
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ])
        )
        XCTAssertEqual(runtime.state.messages.last?.message, "{}")
        XCTAssertEqual(runtime.state.messages.last?.isWithdraw, "1")

        XCTAssertEqual(
            runtime.handleRecentMsgListTransportResponse(
                [
                    "data": [
                        "messages": [
                            [
                                "chat_user_id": "chat_user_1",
                                "sequence_id": "server_recent_1",
                                "sender_type": "2",
                                "sender": "sys_user_1",
                                "sender_name": "Ada",
                                "sender_avatar": "",
                                "sys_user_avatar": "",
                                "send_time": "1779860003000",
                                "msg_type": "1",
                                "content": [
                                    "msg": "Recent transport",
                                ],
                                "read_time": "0",
                            ] as SalesmartlyPayload,
                        ],
                    ] as SalesmartlyPayload,
                ],
                currentChatUserId: "chat_user_1"
            ),
            1
        )
        XCTAssertNotNil(runtime.state.messages.first { $0.id == "server_recent_1" })

        XCTAssertEqual(
            runtime.handleUnreadMsgListTransportResponse(
                [
                    "data": [
                        "messages": [
                            [
                                "chat_user_id": "chat_user_1",
                                "sequence_id": "server_unread_1",
                                "sender_type": "2",
                                "sender": "sys_user_1",
                                "sender_name": "Ada",
                                "sender_avatar": "",
                                "sys_user_avatar": "",
                                "send_time": "1779860003500",
                                "msg_type": "1",
                                "content": [
                                    "msg": "Unread transport",
                                ],
                                "read_time": "0",
                            ] as SalesmartlyPayload,
                        ],
                    ] as SalesmartlyPayload,
                ],
                currentChatUserId: "chat_user_1"
            ),
            1
        )
        XCTAssertNotNil(runtime.state.messages.first { $0.id == "server_unread_1" })

        XCTAssertEqual(
            runtime.handleTriggerTransportResponse([
                "data": [
                    "messages": [
                        [
                            "chat_user_id": "chat_user_1",
                            "sequence_id": "server_trigger_1",
                            "sender_type": "2",
                            "sender": "sys_user_1",
                            "sender_name": "Ada",
                            "sender_avatar": "",
                            "sys_user_avatar": "",
                            "send_time": "1779860004000",
                            "msg_type": "1",
                            "content": [
                                "msg": "Triggered transport",
                            ],
                            "read_time": "0",
                        ] as SalesmartlyPayload,
                    ],
                ] as SalesmartlyPayload,
            ]),
            1
        )
        XCTAssertNotNil(runtime.state.messages.first { $0.id == "server_trigger_1" })

        XCTAssertTrue(
            runtime.handleQueueStatusTransportResponse([
                "data": [
                    "data": [
                        "status": "waiting",
                        "queue_count": 5,
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ])
        )
        XCTAssertEqual(runtime.state.queueStatus, "waiting")
        XCTAssertEqual(runtime.state.queueCount, 5)
    }

    func testVisibleSocketReceiveMessageDispatchesReadFollowUpLikeWidgetShowSession() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setTransport(spy)
        runtime.joinRoom()
        runtime.openChat()

        spy.emitSocketEvent(
            "receive-message",
            payload: [
                "data": [
                    "chat_user_id": "chat_user_1",
                    "sequence_id": "visible_receive_1",
                    "sender_type": "2",
                    "sender_name": "Ada",
                    "sender_avatar": "",
                    "send_time": "1779860001000",
                    "msg_type": "1",
                    "content": [
                        "msg": "Visible receive",
                    ],
                    "read_time": "0",
                ] as SalesmartlyPayload,
            ]
        )

        XCTAssertEqual(spy.requests.count, 2)
        XCTAssertEqual(spy.requests.first?.eventName, "open-frame")
        XCTAssertEqual(spy.requests.last?.eventName, "read-message")
        XCTAssertEqual(spy.requests.last?.payload["room_type"] as? Int, 6)
        XCTAssertEqual(spy.requests.last?.payload["sequence_id"] as? String, "visible_receive_1")
        XCTAssertEqual(runtime.state.messages.last?.isRead, "1")
        XCTAssertEqual(runtime.state.unReadNum, 0)
    }

    func testReceiveMessageTransportKeepsWidgetObjectMediaTextMessage() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(
            runtime.handleReceiveMessageTransportPayload([
                "code": 0,
                "data": [
                    "chat_user_id": "chat_user_1",
                    "sequence_id": "server_receive_media_text_1",
                    "sender_type": "2",
                    "sender": "sys_user_1",
                    "sender_name": "Ada",
                    "sender_avatar": "",
                    "sys_user_avatar": "",
                    "send_time": "1779860001001",
                    "msg_type": "40",
                    "content": [
                        "msg": [
                            "caption": "Photo guide",
                            "file_type": "image",
                            "file_url": "https://cdn.example.com/photo.png",
                        ] as SalesmartlyPayload,
                    ],
                    "read_time": "0",
                ] as SalesmartlyPayload,
            ])
        )
        let mediaTextMessage = try XCTUnwrap(runtime.state.messages.last)
        let mediaTextComponent = SalesmartlyNativeMessagePresentation.component(for: mediaTextMessage)
        XCTAssertEqual(mediaTextMessage.id, "server_receive_media_text_1")
        XCTAssertEqual(mediaTextComponent.kind, .mediaText)
        XCTAssertEqual(mediaTextComponent.summary, "Photo guide")
        XCTAssertEqual(mediaTextComponent.media_text?.file_type, "image")
        XCTAssertEqual(mediaTextComponent.media_text?.file_url, "https://cdn.example.com/photo.png")
    }

    func testTransportResponseDispatcherAppliesWidgetSocketAndHttpCallbacks() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        let joinRequest = try XCTUnwrap(runtime.makeJoinRoomTransportRequest())
        let joinFollowUps = runtime.handleTransportResponse(
            [
                "data": [
                    "messages": [
                        [
                            "chat_user_id": "chat_user_1",
                            "sequence_id": "join_message_1",
                            "sender_type": "2",
                            "send_time": "1779860001000",
                            "msg_type": "1",
                            "content": [
                                "msg": "Joined from socket callback",
                            ],
                            "read_time": "0",
                        ] as SalesmartlyPayload,
                    ],
                ] as SalesmartlyPayload,
            ],
            for: joinRequest,
            currentChatUserId: "chat_user_1"
        )

        XCTAssertTrue(joinFollowUps.isEmpty)
        XCTAssertEqual(runtime.state.messages.last?.id, "join_message_1")
        XCTAssertEqual(runtime.state.unReadNum, 1)

        SalesmartlyChat.sendTextMessage("Hello")
        let localMessage = try XCTUnwrap(runtime.state.messages.last)
        let sendRequest = try XCTUnwrap(
            runtime.makeSendMessageTransportRequest(
                for: localMessage,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        let sendFollowUps = runtime.handleTransportResponse(
            [
                "code": 0,
                "data": [
                    "message": [
                        "sequence_id": "server_send_1",
                        "send_time": 1_779_860_001_001,
                        "content": [
                            "msg": "Hello",
                        ],
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ],
            for: sendRequest,
            currentChatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages.last?.id, "server_send_1")
        XCTAssertNil(runtime.sendMessageMap[try XCTUnwrap(localMessage.cMId)])
        XCTAssertEqual(sendFollowUps.first?.eventName, "read-message")
        XCTAssertEqual(sendFollowUps.first?.payload["sequence_id"] as? String, "server_send_1")

        runtime.state.supportRetry = true
        _ = runtime.leaveRoom()
        SalesmartlyChat.sendTextMessage("HTTP message")
        let httpMessage = try XCTUnwrap(runtime.state.messages.last)
        let httpRequest = try XCTUnwrap(
            runtime.makeSendMessageTransportRequest(
                for: httpMessage,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertTrue(
            runtime.handleTransportResponse(
                [
                    "data": [
                        "data": [
                            "sequence_id": "server_http_1",
                            "send_time": 1_779_860_001_002,
                            "content": [
                                "msg": "HTTP message",
                            ],
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ],
                for: httpRequest,
                currentChatUserId: "chat_user_1"
            ).isEmpty
        )
        XCTAssertEqual(runtime.state.messages.last?.id, "server_http_1")

        let triggerRequest = runtime.makeTriggerTransportRequest(
            token: "token_1",
            chatUserId: "chat_user_1",
            payload: ["trigger_type": "11"]
        )

        XCTAssertTrue(
            runtime.handleTransportResponse(
                [
                    "data": [
                        "messages": [
                            [
                                "chat_user_id": "chat_user_1",
                                "sequence_id": "trigger_message_1",
                                "sender_type": "2",
                                "send_time": "1779860002000",
                                "msg_type": "1",
                                "content": [
                                    "msg": "Triggered from dispatcher",
                                ],
                                "read_time": "0",
                            ] as SalesmartlyPayload,
                        ],
                    ] as SalesmartlyPayload,
                ],
                for: triggerRequest,
                currentChatUserId: "chat_user_1"
            ).isEmpty
        )
        XCTAssertEqual(runtime.state.messages.last?.id, "trigger_message_1")
    }

    func testPluginInfoTransportResponseAppliesWidgetConfiguration() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        let request = runtime.makePluginInfoTransportRequest()
        let followUps = runtime.handleTransportResponse(
            [
                "data": [
                    "show_line_app_config": ["switch": "1"] as SalesmartlyPayload,
                    "show_line": "1",
                    "show_plugin": "1",
                    "show_messenger": "1",
                    "show_whatsapp": "1",
                    "show_email_config": ["switch": "1"] as SalesmartlyPayload,
                    "show_whatsapp_config": [
                        "redirect_url": "https://wa.me/123",
                        "send_page_link": "1",
                        "type": "3",
                        "prolusion": "Hello",
                    ] as SalesmartlyPayload,
                    "show_telegram_config": [
                        "switch": "1",
                        "redirect_url": "https://t.me/bot",
                        "link_params": "start_1",
                    ] as SalesmartlyPayload,
                    "show_instagram_config": ["switch": "1"] as SalesmartlyPayload,
                    "show_tiktok_config": [
                        "switch": "1",
                        "redirect_url": "https://tiktok.com/@brand",
                    ] as SalesmartlyPayload,
                    "show_zalo_config": [
                        "switch": "1",
                        "redirect_url": "https://zalo.me/brand",
                    ] as SalesmartlyPayload,
                    "show_vkontakte_config": ["switch": "1"] as SalesmartlyPayload,
                    "show_work_weixin_config": ["switch": "1"] as SalesmartlyPayload,
                    "show_custom_config": #"[{"id":"custom_1","switch":"0"},{"id":"custom_2","switch":"1"}]"#,
                    "auto_frame": [
                        "icon_popup": "1",
                        "icon_popup_type": "1",
                    ],
                    "sdk_message_notice": #"{"browser_tab_tips":"1","sound_notice":"1"}"#,
                    "plugin_name": "Plugin Name",
                    "background_color": "#D9AED6",
                    "position": "left",
                    "margin_bottom": "18",
                    "margin_bottom_pc": "32",
                    "mobile_display": [
                        "cover_the_screen": "1",
                    ] as SalesmartlyPayload,
                    "location_config_divisive": "1",
                    "plugin_iconv_url": "https://cdn.example.com/chat-out.png",
                    "plugin_iconv_active_url": "https://cdn.example.com/chat-in.png",
                    "avatar_url": "https://cdn.example.com/avatar.png",
                    "window_name": "Sales Team",
                    "project_id": "project_1",
                    "channel_sort": #"["email","chat","whatsapp","telegram"]"#,
                    "home_page": [
                        "enabled": "1",
                        "title": "Welcome\\nBack",
                    ] as SalesmartlyPayload,
                    "show_effect": #"{"type":"2"}"#,
                    "show_side_config": #"{"switch":"1","type":"2","shrinkMode":"1","text":"Side"}"#,
                    "report_switch": "1",
                    "show_reception_info": "0",
                    "turn_to_manual_button": ["type": "0"] as SalesmartlyPayload,
                    "withdraw_notice": ["type": "0"] as SalesmartlyPayload,
                    "show_customer_service_name": ["type": "1"] as SalesmartlyPayload,
                    "is_limit": "1",
                    "support_retry": "1",
                    "is_polling": "1",
                    "polling_gap": "12",
                    "queue_switch": "1",
                    "queue_polling_interval": "7",
                ] as SalesmartlyPayload,
            ],
            for: request,
            currentChatUserId: ""
        )

        XCTAssertTrue(followUps.isEmpty)
        XCTAssertEqual(runtime.state.channels, [
            "lineApp",
            "line",
            "chat",
            "messenger",
            "whatsapp",
            "email",
            "telegram",
            "instagram",
            "tiktok",
            "zalo",
            "vkontakte",
            "weixin",
            "custom_2",
        ])
        XCTAssertTrue(runtime.state.iconPopupEnabled)
        XCTAssertEqual(runtime.state.iconPopupType, "1")
        XCTAssertTrue(runtime.state.isLimit)
        XCTAssertEqual(runtime.state.pluginName, "Plugin Name")
        XCTAssertEqual(runtime.state.backgroundColor, "#D9AED6")
        XCTAssertTrue(runtime.state.chatIconDefine)
        XCTAssertEqual(runtime.state.chatIconOutURL, "https://cdn.example.com/chat-out.png")
        XCTAssertEqual(runtime.state.chatIconInURL, "https://cdn.example.com/chat-in.png")
        XCTAssertEqual(runtime.state.position, "left")
        XCTAssertEqual(runtime.state.marginBottom, 18)
        XCTAssertEqual(runtime.state.marginBottomPC, 32)
        XCTAssertEqual(runtime.state.mobileScreen, "full")
        XCTAssertTrue(runtime.state.locationConfigDivisive)
        XCTAssertEqual(runtime.state.pluginAvatarURL, "https://cdn.example.com/avatar.png")
        XCTAssertEqual(runtime.state.pluginProjectId, "project_1")
        XCTAssertEqual(runtime.state.channelSort, ["email", "whatsapp", "telegram"])
        XCTAssertEqual(runtime.state.channelOpenConfigs["whatsapp"]?["redirect_url"], "https://wa.me/123")
        XCTAssertEqual(runtime.state.channelOpenConfigs["telegram"]?["link_params"], "start_1")
        XCTAssertEqual(runtime.state.channelOpenConfigs["tiktok"]?["redirect_url"], "https://tiktok.com/@brand")
        XCTAssertEqual(runtime.state.channelOpenConfigs["zalo"]?["redirect_url"], "https://zalo.me/brand")
        XCTAssertTrue(runtime.state.homePageEnabled)
        XCTAssertEqual(runtime.state.homePageTitle, "Welcome\nBack")
        XCTAssertEqual(runtime.state.integrationType, "chat")
        XCTAssertTrue(runtime.state.sidebarShow)
        XCTAssertEqual(runtime.state.sidebarShrinkMode, "sidebar")
        XCTAssertEqual(runtime.state.iconPopupWindowName, "Sales Team")
        XCTAssertFalse(runtime.state.iconPopupShowReceptionInfo)
        XCTAssertFalse(runtime.state.humanServiceEnabled)
        XCTAssertFalse(runtime.state.withdrawRecord)
        XCTAssertTrue(runtime.state.showSenderName)
        XCTAssertTrue(runtime.state.reportSwitch)
        XCTAssertTrue(runtime.state.flashTitle)
        XCTAssertTrue(runtime.state.soundNotice)
        XCTAssertTrue(runtime.state.supportRetry)
        XCTAssertTrue(runtime.state.isPollingEnabled)
        XCTAssertEqual(runtime.state.pollingGapSeconds, 12)
        XCTAssertEqual(runtime.state.queueSwitch, "1")
        XCTAssertEqual(runtime.state.queuePollingIntervalSeconds, 7)

        runtime.state.localChatUserId = "chat user 1"
        runtime.state.trackedURL = "https://shop.example.com/a b?x=1&y=2"
        runtime.state.widgetHost = "https://widget-dev.salesmartly.com/"

        let reportURL = try XCTUnwrap(runtime.bottomBarReportURL()?.absoluteString)
        XCTAssertTrue(reportURL.hasPrefix("https://cellus-test.salesmartly.com/report?"))
        XCTAssertTrue(reportURL.contains("plugin_id=YOUR_LICENSE"))
        XCTAssertTrue(reportURL.contains("plugin_name=Plugin%20Name"))
        XCTAssertTrue(reportURL.contains("window_name=Sales%20Team"))
        XCTAssertTrue(reportURL.contains("project_id=project_1"))
        XCTAssertTrue(reportURL.contains("chat_user_id=chat%20user%201"))
        XCTAssertTrue(reportURL.contains("exclusive_link=https%3A%2F%2Fshop.example.com%2Fa%20b%3Fx%3D1%26y%3D2"))
    }

    func testPluginInfoTransportResponseConnectsCachedGuestTokenLikeWidgetAppLoad() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.setTransport(spy)
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"

        runtime.sendPluginInfoTransportRequest()
        spy.respond(
            [
                "data": [
                    "project_id": "project_1",
                    "show_plugin": "1",
                ] as SalesmartlyPayload,
            ],
            requestIndex: 0
        )

        XCTAssertEqual(runtime.state.pluginProjectId, "project_1")
        XCTAssertEqual(spy.socketConnections.first?.query["login_token"], "token_1")
        XCTAssertEqual(spy.socketConnections.first?.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(spy.socketConnections.first?.query["plugin_id"], "plugin_1")
        XCTAssertEqual(spy.socketConnections.first?.query["_xma_"], "project_1")
        XCTAssertEqual(spy.requests.last?.eventName, "join-room")
        XCTAssertTrue(runtime.state.hasJoinRoom)
    }

    func testPluginInfoTransportResponseRequestsCreateUserWithNativeBootstrapContext() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.setNativeBootstrapContext(
            SalesmartlyNativeBootstrapContext(
                sourceURL: "salesmartly-ios://host/products",
                userAgent: "Salesmartly iOS Host",
                navigatorLanguage: "en-US",
                beforeSourceURL: "salesmartly-ios://referrer",
                guestUserId: "guest_uuid_1"
            )
        )
        runtime.setTransport(spy)

        runtime.sendPluginInfoTransportRequest()
        spy.respond(
            [
                "data": [
                    "project_id": "project_1",
                    "show_plugin": "1",
                ] as SalesmartlyPayload,
            ],
            requestIndex: 0
        )

        XCTAssertEqual(spy.requests.count, 2)
        XCTAssertEqual(spy.requests[1].path, "chat/msg-user/create-user")
        XCTAssertEqual(spy.requests[1].payload["source_url"] as? String, "salesmartly-ios://host/products")
        XCTAssertEqual(spy.requests[1].payload["ua"] as? String, "Salesmartly iOS Host")
        XCTAssertEqual(spy.requests[1].payload["language"] as? String, "en-US")
        XCTAssertEqual(spy.requests[1].payload["before_source_url"] as? String, "salesmartly-ios://referrer")
        XCTAssertEqual(spy.requests[1].payload["user_id"] as? String, "guest_uuid_1")
        XCTAssertTrue(runtime.state.isCreateUserTokenRequestActive)
    }

    func testCreateUserTransportResponseConnectsAfterNativeBootstrapRequest() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.setNativeBootstrapContext(
            SalesmartlyNativeBootstrapContext(
                sourceURL: "salesmartly-ios://host/products",
                userAgent: "Salesmartly iOS Host",
                navigatorLanguage: "en-US",
                beforeSourceURL: "salesmartly-ios://referrer",
                guestUserId: "guest_uuid_1"
            )
        )
        runtime.setTransport(spy)

        runtime.sendPluginInfoTransportRequest()
        spy.respond(
            [
                "data": [
                    "project_id": "project_1",
                    "show_plugin": "1",
                ] as SalesmartlyPayload,
            ],
            requestIndex: 0
        )
        spy.respond(
            [
                "data": [
                    "data": [
                        "token": "token_1",
                        "chat_user_id": "chat_user_1",
                        "is_new_user": "1",
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ],
            requestIndex: 1
        )

        XCTAssertEqual(runtime.state.userToken, "token_1")
        XCTAssertEqual(runtime.state.localChatUserId, "chat_user_1")
        XCTAssertEqual(spy.socketConnections.first?.query["login_token"], "token_1")
        XCTAssertEqual(spy.socketConnections.first?.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(spy.socketConnections.first?.query["plugin_id"], "plugin_1")
        XCTAssertEqual(spy.socketConnections.first?.query["_xma_"], "project_1")
        XCTAssertEqual(spy.requests.last?.eventName, "join-room")
        XCTAssertTrue(runtime.state.hasJoinRoom)
    }

    func testPendingTextMessageFlushesAfterCreateUserConnectsNativeBootstrap() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.setNativeBootstrapContext(
            SalesmartlyNativeBootstrapContext(
                sourceURL: "salesmartly-ios://host/products",
                userAgent: "Salesmartly iOS Host",
                navigatorLanguage: "en-US",
                beforeSourceURL: "salesmartly-ios://referrer",
                guestUserId: "guest_uuid_1"
            )
        )
        runtime.setTransport(spy)

        SalesmartlyChat.sendTextMessage("Queued before token")
        runtime.sendPluginInfoTransportRequest()
        spy.respond(
            [
                "data": [
                    "project_id": "project_1",
                    "show_plugin": "1",
                ] as SalesmartlyPayload,
            ],
            requestIndex: 0
        )
        spy.respond(
            [
                "data": [
                    "data": [
                        "token": "token_1",
                        "chat_user_id": "chat_user_1",
                        "is_new_user": "1",
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ],
            requestIndex: 1
        )

        XCTAssertEqual(spy.requests.suffix(2).map(\.eventName), ["join-room", "send-message"])
        XCTAssertEqual(spy.requests.last?.payload["message"] as? String, "Queued before token")
        XCTAssertEqual(spy.requests.last?.payload["room_type"] as? Int, 6)
    }

    func testTransportResponseHandlerFeedsDispatcherAndSendsFollowUps() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)

        XCTAssertNotNil(runtime.sendJoinRoomTransportRequest())
        spy.respond(
            [
                "data": [
                    "messages": [
                        [
                            "chat_user_id": "chat_user_1",
                            "sequence_id": "join_callback_1",
                            "sender_type": "2",
                            "send_time": "1779860001000",
                            "msg_type": "1",
                            "content": [
                                "msg": "Joined from callback",
                            ],
                            "read_time": "0",
                        ] as SalesmartlyPayload,
                    ],
                ] as SalesmartlyPayload,
            ],
            requestIndex: 0
        )

        XCTAssertEqual(runtime.state.messages.last?.id, "join_callback_1")
        XCTAssertEqual(runtime.state.unReadNum, 1)

        SalesmartlyChat.sendTextMessage("Callback hello")
        let localMessage = try XCTUnwrap(runtime.state.messages.last)

        XCTAssertNotNil(
            runtime.sendMessageTransportRequest(
                for: localMessage,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )

        let sendRequestIndex = spy.requests.count - 1

        XCTAssertEqual(spy.requests[sendRequestIndex].eventName, "send-message")

        spy.respond(
            [
                "code": 0,
                "data": [
                    "message": [
                        "sequence_id": "server_callback_1",
                        "send_time": 1_779_860_001_001,
                        "content": [
                            "msg": "Callback hello",
                        ],
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ],
            requestIndex: sendRequestIndex
        )

        XCTAssertEqual(runtime.state.messages.last?.id, "server_callback_1")
        XCTAssertNil(runtime.sendMessageMap[try XCTUnwrap(localMessage.cMId)])
        XCTAssertEqual(spy.requests.last?.eventName, "read-message")
        XCTAssertEqual(spy.requests.last?.payload["sequence_id"] as? String, "server_callback_1")
    }

    func testDisconnectSwitchesHttpModeRetriesAndMarksPendingMessagesFailed() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.state.supportRetry = true

        runtime.joinRoom()
        SalesmartlyChat.sendTextMessage("Offline")

        let message = try XCTUnwrap(runtime.state.messages.last)
        let clientMessageId = try XCTUnwrap(message.cMId)
        let payloads = runtime.onDisconnect(loginToken: "token_1", chatUserId: "chat_user_1")

        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")
        XCTAssertEqual(payloads.count, 1)
        XCTAssertEqual(payloads.first?["ref"] as? String, "chat-plugin")
        XCTAssertEqual(payloads.first?["message"] as? String, "Offline")
        XCTAssertEqual(payloads.first?["login_token"] as? String, "token_1")
        XCTAssertEqual(payloads.first?["chat_user_id"] as? String, "chat_user_1")
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.mid).hasPrefix("fail_"))
        XCTAssertNotNil(runtime.retryingMap[clientMessageId])
    }

    func testDisconnectDoesNotRetryWhenWidgetSupportRetryDisabled() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        runtime.joinRoom()
        SalesmartlyChat.sendTextMessage("Offline")

        let message = try XCTUnwrap(runtime.state.messages.last)
        let clientMessageId = try XCTUnwrap(message.cMId)
        let payloads = runtime.onDisconnect(loginToken: "token_1", chatUserId: "chat_user_1")

        XCTAssertTrue(payloads.isEmpty)
        XCTAssertNil(runtime.retryingMap[clientMessageId])
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.mid).hasPrefix("fail_"))
    }

    func testSocketInboundEventHandlerRoutesWidgetEventsToReducersAndFollowUps() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)

        spy.emitSocketEvent(
            "receive-message",
            payload: [
                "data": [
                    "chat_user_id": "chat_user_1",
                    "sequence_id": "inbound_message_1",
                    "sender_type": "2",
                    "send_time": "1779860001000",
                    "msg_type": "1",
                    "content": [
                        "msg": "Inbound service message",
                    ],
                    "read_time": "0",
                ] as SalesmartlyPayload,
            ]
        )

        XCTAssertEqual(runtime.state.messages.last?.id, "inbound_message_1")
        XCTAssertEqual(runtime.state.unReadNum, 1)

        spy.emitSocketEvent(
            "sdk-receive-notice",
            payload: [
                "data": [
                    "notice_type": "20",
                    "push_time": "1779860002000",
                    "notice": [
                        "sequence_id": "inbound_message_1",
                    ] as SalesmartlyPayload,
                ] as SalesmartlyPayload,
            ]
        )

        XCTAssertEqual(runtime.state.messages.last?.message, "{}")
        XCTAssertEqual(runtime.state.messages.last?.isWithdraw, "1")

        runtime.state.supportRetry = true
        SalesmartlyChat.sendTextMessage("Retry after disconnect")
        runtime.openFrame()

        spy.emitSocketEvent(
            "reconnect_attempt",
            payload: [
                "attempt": 3,
            ]
        )

        XCTAssertTrue(runtime.state.pendingSocketEvents.isEmpty)

        spy.emitSocketEvent(
            "disconnect",
            payload: [
                "login_token": "token_1",
                "chat_user_id": "chat_user_1",
            ]
        )

        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")
        XCTAssertEqual(spy.requests.last?.path, "/chat/chat-msg/send-message")

        spy.emitSocketEvent("reconnect", payload: [:])

        XCTAssertEqual(spy.requests.last?.eventName, "join-room")
        XCTAssertTrue(runtime.state.hasJoinRoom)

        spy.emitSocketEvent("reconnect_error", payload: [:])
        XCTAssertFalse(runtime.state.hasJoinRoom)
    }

    func testSocketTransportLifecycleMatchesWidgetJoinAndReleaseRules() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)

        let joinRequest = try XCTUnwrap(
            runtime.connectSocketTransport(
                loginToken: "token_1",
                chatUserId: "chat_user_1",
                pluginId: "plugin_1",
                projectId: "project_1"
            )
        )

        XCTAssertEqual(spy.removedSocketEventHandlerBatches.first, [
            "reconnect",
            "disconnect",
            "receive-message",
            "sdk-receive-notice",
            "error",
            "reconnect_error",
            "reconnect_failed",
            "reconnect_attempt",
            "test-to-message",
            "ssevl",
        ])
        XCTAssertEqual(spy.socketConnections.first?.query["login_token"], "token_1")
        XCTAssertEqual(spy.addedPongHandlerCount, 1)
        XCTAssertEqual(spy.removedBufferedSocketEvents, ["join-room"])
        XCTAssertEqual(joinRequest.eventName, "join-room")
        XCTAssertEqual(spy.requests.last?.eventName, "join-room")
        XCTAssertEqual(spy.addedSocketEventHandlerBatches.last, [
            "reconnect",
            "disconnect",
            "receive-message",
            "sdk-receive-notice",
            "error",
            "reconnect_error",
            "reconnect_failed",
            "reconnect_attempt",
            "test-to-message",
            "ssevl",
        ])
        XCTAssertTrue(runtime.state.hasJoinRoom)

        let leaveRequest = try XCTUnwrap(runtime.releaseSocketTransport())

        XCTAssertEqual(spy.removedSocketEventHandlerBatches.suffix(2).first, ["receive-message"])
        XCTAssertEqual(leaveRequest.eventName, "leave-room")
        XCTAssertEqual(spy.requests.last?.eventName, "leave-room")
        XCTAssertEqual(spy.removedSocketEventHandlerBatches.last, [
            "reconnect",
            "error",
            "reconnect_error",
            "reconnect_failed",
            "reconnect_attempt",
            "test-to-message",
            "ssevl",
        ])
        XCTAssertEqual(spy.socketDisconnectCount, 1)
        XCTAssertEqual(spy.removedPongHandlerCount, 1)
        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")

        let idleRuntime = SalesmartlyRuntime()
        let idleSpy = SalesmartlyTransportSpy()
        idleRuntime.setTransport(idleSpy)

        XCTAssertNil(idleRuntime.releaseSocketTransport())
        XCTAssertEqual(idleSpy.socketDisconnectCount, 1)
        XCTAssertEqual(idleSpy.removedPongHandlerCount, 1)
    }

    func testOpenChatSendsOpenFrameAfterSocketJoinLikeWidgetHandleShowChat() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setTransport(spy)

        XCTAssertNotNil(
            runtime.connectSocketTransport(
                loginToken: "token_1",
                chatUserId: "chat_user_1",
                pluginId: "plugin_1",
                projectId: "project_1"
            )
        )

        runtime.openChat()

        XCTAssertEqual(spy.requests.last?.eventName, "open-frame")
        XCTAssertEqual(spy.requests.last?.payload["room_type"] as? Int, 6)
    }

    func testSocketPongTimeoutMatchesWidgetHeartbeatReconnectRule() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()
        runtime.setTransport(spy)

        let firstReconnect = runtime.handleSocketPong(
            nowMilliseconds: 1_000,
            pingIntervalMilliseconds: 25_000,
            pingTimeoutMilliseconds: 20_000
        )

        XCTAssertFalse(firstReconnect)
        XCTAssertEqual(runtime.socketLastPongTime, 1_000)
        XCTAssertTrue(spy.reconnectDelays.isEmpty)

        let normalReconnect = runtime.handleSocketPong(
            nowMilliseconds: 74_999,
            pingIntervalMilliseconds: 25_000,
            pingTimeoutMilliseconds: 20_000
        )

        XCTAssertFalse(normalReconnect)
        XCTAssertTrue(spy.reconnectDelays.isEmpty)

        let timeoutReconnect = runtime.handleSocketPong(
            nowMilliseconds: 149_999,
            pingIntervalMilliseconds: 25_000,
            pingTimeoutMilliseconds: 20_000
        )

        XCTAssertTrue(timeoutReconnect)
        XCTAssertEqual(runtime.socketLastPongTime, 149_999)
        XCTAssertEqual(spy.reconnectDelays, [100])
    }

    func testJoinRoomTimeoutRollsBackWhenSocketAckDoesNotArrive() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )
        runtime.setTransport(spy)

        let firstJoinRequest = try XCTUnwrap(runtime.sendJoinRoomTransportRequest())

        XCTAssertEqual(firstJoinRequest.eventName, "join-room")
        XCTAssertTrue(runtime.state.hasJoinRoom)
        XCTAssertFalse(runtime.handleJoinRoomTransportTimeout())
        XCTAssertFalse(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "http")

        let secondJoinRequest = try XCTUnwrap(runtime.sendJoinRoomTransportRequest())

        XCTAssertTrue(runtime.state.hasJoinRoom)
        XCTAssertEqual(secondJoinRequest.eventName, "join-room")

        XCTAssertTrue(
            runtime.handleTransportResponse(
                [:],
                for: secondJoinRequest,
                currentChatUserId: "chat_user_1"
            ).isEmpty
        )
        XCTAssertTrue(runtime.handleJoinRoomTransportTimeout())
        XCTAssertTrue(runtime.state.hasJoinRoom)
        XCTAssertEqual(runtime.state.sendMode, "ws")
    }

    func testVisibilityReadAndPollingStateMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        XCTAssertTrue(runtime.checkPolling(isPollingEnabled: true))

        runtime.setWindowVisible(false)
        XCTAssertFalse(runtime.checkPolling(isPollingEnabled: true))

        XCTAssertNotNil(runtime.joinRoom())
        runtime.receiveMessage(
            sequenceId: "visibility_1",
            senderType: "2",
            msgType: "1",
            message: "Hidden unread",
            sendTime: 1_779_860_000_001,
            chatUserId: "chat_user_1"
        )
        XCTAssertEqual(runtime.state.unReadNum, 1)

        runtime.openChat()

        XCTAssertEqual(runtime.state.unReadNum, 1)
        XCTAssertEqual(runtime.state.messages.last?.isRead, "0")

        let readPayload = try XCTUnwrap(runtime.setWindowVisible(true))

        XCTAssertEqual(readPayload["room_type"] as? Int, 6)
        XCTAssertEqual(runtime.state.unReadNum, 0)
        XCTAssertEqual(runtime.state.messages.last?.isRead, "1")

        let demoRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: demoRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .demo)
            )
        )

        XCTAssertFalse(demoRuntime.checkPolling(isPollingEnabled: true))
    }

    func testPollingPayloadsAndReducersMatchWidgetHttpRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.receiveMessage(
            sequenceId: "100",
            senderType: "2",
            msgType: "1",
            message: "Read service message",
            sendTime: 1_779_860_000_100,
            chatUserId: "chat_user_1",
            readTime: 1
        )
        runtime.receiveMessage(
            sequenceId: "101",
            senderType: "2",
            msgType: "1",
            message: "Unread service message",
            sendTime: 1_779_860_000_101,
            chatUserId: "chat_user_1"
        )

        let unreadPayload = runtime.makeUnreadMsgListPayload(
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )
        XCTAssertEqual(unreadPayload["login_token"] as? String, "token_1")
        XCTAssertEqual(unreadPayload["chat_user_id"] as? String, "chat_user_1")
        XCTAssertEqual(unreadPayload["direction_type"] as? String, "1")
        XCTAssertEqual(unreadPayload["sequence_id"] as? String, "101")

        let recentPayload = runtime.makeRecentMsgListPayload(
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )
        XCTAssertEqual(recentPayload["login_token"] as? String, "token_1")
        XCTAssertEqual(recentPayload["chat_user_id"] as? String, "chat_user_1")
        XCTAssertEqual(recentPayload["direction_type"] as? String, "1")
        XCTAssertEqual(recentPayload["sender_type"] as? Int, 2)
        XCTAssertEqual(recentPayload["limit"] as? Int, 10)
        XCTAssertEqual(recentPayload["sequence_id"] as? String, "100")

        let historyPayload = runtime.makeHistoryMsgListPayload(
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )
        XCTAssertEqual(historyPayload["login_token"] as? String, "token_1")
        XCTAssertEqual(historyPayload["chat_user_id"] as? String, "chat_user_1")
        XCTAssertEqual(historyPayload["direction_type"] as? String, "1")
        XCTAssertEqual(historyPayload["sender_type"] as? Int, 0)
        XCTAssertEqual(historyPayload["limit"] as? Int, 20)
        XCTAssertEqual(historyPayload["sequence_id"] as? String, "100")

        let historyRequest = runtime.makeHistoryMsgListTransportRequest(
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )
        XCTAssertEqual(historyRequest.kind, .http)
        XCTAssertEqual(historyRequest.path, "/chat/chat-msg/recent-msg-list-v2")
        XCTAssertEqual(historyRequest.method, .get)
        XCTAssertTrue(historyRequest.externalSign)
        XCTAssertEqual(historyRequest.query["sender_type"], "0")
        XCTAssertEqual(historyRequest.query["limit"], "20")

        runtime.applyRecentMessageList(
            [
                ChatMessage(
                    id: "103",
                    msgType: "1",
                    message: "Later",
                    sendType: "2",
                    createdTime: 1_779_860_000_103,
                    chatUserId: "chat_user_1",
                    isRead: "0"
                ),
                ChatMessage(
                    id: "102",
                    msgType: "1",
                    message: "Earlier",
                    sendType: "2",
                    createdTime: 1_779_860_000_102,
                    chatUserId: "chat_user_1",
                    isRead: "0"
                ),
                ChatMessage(
                    id: "101",
                    msgType: "1",
                    message: "Unread service message updated",
                    sendType: "2",
                    createdTime: 1_779_860_000_101,
                    chatUserId: "chat_user_1",
                    isRead: "1"
                ),
            ],
            currentChatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages.map(\.id), ["100", "101", "102", "103"])
        XCTAssertEqual(runtime.state.messages[1].message, "Unread service message")
        XCTAssertEqual(runtime.state.messages[1].isRead, "1")
        XCTAssertEqual(runtime.state.messages[2].isRead, "0")
        XCTAssertEqual(runtime.state.unReadNum, 2)

        runtime.applyUnreadMessageList(
            [
                ChatMessage(
                    id: "102",
                    msgType: "1",
                    message: "Withdrawn",
                    sendType: "2",
                    createdTime: 1_779_860_000_102,
                    chatUserId: "chat_user_1",
                    isRead: "1",
                    isWithdraw: "1"
                ),
                ChatMessage(
                    id: "104",
                    msgType: "8",
                    message: "Filtered system",
                    sendType: "2",
                    createdTime: 1_779_860_000_104,
                    chatUserId: "chat_user_1",
                    isRead: "0"
                ),
            ],
            currentChatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.messages.map(\.id), ["100", "101", "102", "103"])
        XCTAssertEqual(runtime.state.messages[2].message, "{}")
        XCTAssertEqual(runtime.state.messages[2].isWithdraw, "1")
        XCTAssertEqual(runtime.state.messages[2].isRead, "1")
        XCTAssertEqual(runtime.state.unReadNum, 1)
    }

    func testQueueStatusPollingScheduleMatchesWidgetUseQueueStatusRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        XCTAssertNil(
            runtime.applyQueueStatusPolling(
                showWrapper: true,
                queueSwitch: "0",
                chatUserId: "chat_user_1",
                queuePollingIntervalSeconds: 5,
                nowMilliseconds: 1_000
            )
        )
        XCTAssertEqual(runtime.state.queueStatusPollingRequestId, 1)
        XCTAssertEqual(runtime.state.queueStatusPollingNextFetchMilliseconds, 0)

        let request = try XCTUnwrap(
            runtime.applyQueueStatusPolling(
                showWrapper: true,
                queueSwitch: "1",
                chatUserId: "chat_user_1",
                queuePollingIntervalSeconds: 5,
                nowMilliseconds: 2_000
            )
        )

        XCTAssertEqual(request.path, "user/plugin-queue-status")
        XCTAssertEqual(request.query["chat_user_id"], "chat_user_1")
        XCTAssertEqual(runtime.state.queueStatusPollingRequestId, 3)

        XCTAssertTrue(
            runtime.handleQueueStatusTransportResponse(
                [
                    "data": [
                        "data": [
                            "status": "waiting",
                            "queue_count": 3,
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ],
                requestId: 3,
                queuePollingIntervalSeconds: 5,
                nowMilliseconds: 3_000
            )
        )
        XCTAssertEqual(runtime.state.queueStatus, "waiting")
        XCTAssertEqual(runtime.state.queueCount, 3)
        XCTAssertEqual(runtime.state.queueStatusPollingNextFetchMilliseconds, 8_000)

        XCTAssertFalse(
            runtime.handleQueueStatusTransportResponse(
                [
                    "data": [
                        "data": [
                            "status": "assigned",
                            "queue_count": 0,
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ],
                requestId: 2,
                queuePollingIntervalSeconds: 5,
                nowMilliseconds: 4_000
            )
        )
        XCTAssertEqual(runtime.state.queueStatus, "waiting")
        XCTAssertEqual(runtime.state.queueCount, 3)

        XCTAssertFalse(
            runtime.handleQueueStatusTransportResponse(
                [
                    "data": [
                        "data": [
                            "status": "assigned",
                            "queue_count": 0,
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ],
                requestId: 3,
                queuePollingIntervalSeconds: 5,
                nowMilliseconds: 5_000
            )
        )
        XCTAssertEqual(runtime.state.queueStatus, "")
        XCTAssertEqual(runtime.state.queueCount, 0)
        XCTAssertEqual(runtime.state.queueStatusPollingNextFetchMilliseconds, 0)
    }

    func testHistoryPollingRequestMatchesWidgetGetHistoryRules() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setTransport(spy)

        XCTAssertTrue(
            runtime.shouldRefreshHistoryMessages(
                isNewUser: false,
                isPollingEnabled: true,
                lastRecentTimeMilliseconds: nil,
                nowMilliseconds: 1_779_860_000_000
            )
        )
        XCTAssertFalse(
            runtime.shouldRefreshHistoryMessages(
                isNewUser: false,
                isPollingEnabled: true,
                lastRecentTimeMilliseconds: 1_779_859_500_000,
                nowMilliseconds: 1_779_860_000_000
            )
        )
        XCTAssertTrue(
            runtime.shouldRefreshHistoryMessages(
                isNewUser: false,
                isPollingEnabled: true,
                lastRecentTimeMilliseconds: 1_779_859_399_999,
                nowMilliseconds: 1_779_860_000_000
            )
        )
        XCTAssertFalse(
            runtime.shouldRefreshHistoryMessages(
                isNewUser: true,
                isPollingEnabled: true,
                lastRecentTimeMilliseconds: nil,
                nowMilliseconds: 1_779_860_000_000
            )
        )

        let request = runtime.sendHistoryMsgListTransportRequest(loginToken: "token_1", chatUserId: "chat_user_1")

        XCTAssertEqual(spy.requests.count, 1)
        XCTAssertEqual(spy.requests.first?.path, "/chat/chat-msg/recent-msg-list-v2")
        XCTAssertEqual(request.query["sender_type"], "0")

        let sandboxRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: sandboxRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .sandbox)
            )
        )

        XCTAssertFalse(
            sandboxRuntime.shouldRefreshHistoryMessages(
                isNewUser: false,
                isPollingEnabled: true,
                lastRecentTimeMilliseconds: nil,
                nowMilliseconds: 1_779_860_000_000
            )
        )
    }

    func testVisibilityWatcherSchedulesWidgetPollingAndReadRequests() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setTransport(spy)
        runtime.receiveMessage(
            sequenceId: "polling_1",
            senderType: "2",
            msgType: "1",
            message: "Unread",
            sendTime: 1_779_860_000_001,
            chatUserId: "chat_user_1"
        )

        let hiddenSchedule = runtime.applyVisibilityPollingSchedule(
            isWindowVisible: true,
            showWrapper: false,
            currentView: .home,
            isPollingEnabled: true,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertTrue(hiddenSchedule.startUnreadPolling)
        XCTAssertFalse(hiddenSchedule.startRecentPolling)
        XCTAssertTrue(runtime.state.isUnreadPollingActive)
        XCTAssertFalse(runtime.state.isRecentPollingActive)
        XCTAssertEqual(spy.requests.count, 1)
        XCTAssertEqual(spy.requests[0].path, "/chat/chat-msg/unread-msg-list-v2")

        runtime.joinRoom()
        let openedSchedule = runtime.applyVisibilityPollingSchedule(
            isWindowVisible: true,
            showWrapper: true,
            currentView: .chat,
            isPollingEnabled: true,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertFalse(openedSchedule.startUnreadPolling)
        XCTAssertTrue(openedSchedule.startRecentPolling)
        XCTAssertFalse(runtime.state.isUnreadPollingActive)
        XCTAssertTrue(runtime.state.isRecentPollingActive)
        XCTAssertEqual(spy.requests.count, 3)
        XCTAssertEqual(spy.requests[1].path, "/chat/chat-msg/recent-msg-list-v2")
        XCTAssertEqual(spy.requests[1].query["sender_type"], "2")
        XCTAssertEqual(spy.requests[2].eventName, "read-message")
        XCTAssertEqual(runtime.state.unReadNum, 0)

        let hiddenWindowSchedule = runtime.applyVisibilityPollingSchedule(
            isWindowVisible: false,
            showWrapper: true,
            currentView: .chat,
            isPollingEnabled: true,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertFalse(hiddenWindowSchedule.startUnreadPolling)
        XCTAssertFalse(hiddenWindowSchedule.startRecentPolling)
        XCTAssertFalse(runtime.state.isUnreadPollingActive)
        XCTAssertFalse(runtime.state.isRecentPollingActive)
    }

    func testOpenChatRequestsRecentMessagesWhenWidgetPollingReady() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))
        runtime.setTransport(spy)
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        runtime.state.isPollingEnabled = true
        runtime.state.isWindowVisible = true

        runtime.openChat()

        XCTAssertTrue(spy.requests.contains { $0.path == "/chat/chat-msg/recent-msg-list-v2" })
    }

    func testOpenChatRequestsHistoryMessagesWhenWidgetPollingReadyForExistingUser() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))
        runtime.setTransport(spy)
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        runtime.state.isNewUser = false
        runtime.state.isPollingEnabled = true
        runtime.state.isWindowVisible = true
        runtime.state.messages = [
            ChatMessage(
                id: "latest_service_1",
                msgType: "1",
                message: "Latest service",
                sendType: "2",
                createdTime: 1_779_860_000_100,
                chatUserId: "chat_user_1",
                isRead: "1"
            ),
        ]

        runtime.openChat()

        let historyRequest = try XCTUnwrap(
            spy.requests.first { request in
                request.path == "/chat/chat-msg/recent-msg-list-v2" &&
                    request.query["sender_type"] == "0"
            }
        )
        XCTAssertNil(historyRequest.query["sequence_id"])
    }

    func testVisibilityPollingScheduleUsesWidgetPluginInfoState() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setTransport(spy)

        runtime.state.isPollingEnabled = true
        let activeSchedule = runtime.applyVisibilityPollingSchedule(
            isWindowVisible: true,
            showWrapper: false,
            currentView: .home,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertTrue(activeSchedule.startUnreadPolling)
        XCTAssertEqual(spy.requests.first?.path, "/chat/chat-msg/unread-msg-list-v2")

        runtime.state.isPollingEnabled = false
        let inactiveSchedule = runtime.applyVisibilityPollingSchedule(
            isWindowVisible: true,
            showWrapper: false,
            currentView: .home,
            loginToken: "token_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertFalse(inactiveSchedule.startUnreadPolling)
    }

    func testMessagePollingIntervalUsesWidgetPollingGapMinimum() async throws {
        let runtime = SalesmartlyRuntime()

        runtime.state.pollingGapSeconds = 6
        XCTAssertEqual(runtime.messagePollingIntervalMilliseconds(), 10_000)

        runtime.state.pollingGapSeconds = 12
        XCTAssertEqual(runtime.messagePollingIntervalMilliseconds(), 12_000)
    }

    func testQueueStatusPollingUsesWidgetPluginInfoState() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyTransportSpy()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setTransport(spy)
        runtime.state.queueSwitch = "1"
        runtime.state.queuePollingIntervalSeconds = 7

        let request = try XCTUnwrap(
            runtime.applyQueueStatusPolling(
                showWrapper: true,
                chatUserId: "chat_user_1",
                nowMilliseconds: 1_000
            )
        )

        XCTAssertEqual(request.path, "user/plugin-queue-status")
        XCTAssertTrue(
            runtime.handleQueueStatusTransportResponse(
                [
                    "data": [
                        "data": [
                            "status": "waiting",
                            "queue_count": 3,
                        ] as SalesmartlyPayload,
                    ] as SalesmartlyPayload,
                ],
                requestId: runtime.state.queueStatusPollingRequestId,
                nowMilliseconds: 2_000
            )
        )
        XCTAssertEqual(runtime.state.queueStatusPollingNextFetchMilliseconds, 9_000)
    }

    func testApplyLocalConversationListMatchesWidgetRecoveryRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        let recoveredMessages = runtime.applyLocalConversationList([
            ChatMessage(
                id: "temp_text_1",
                msgType: "1",
                message: "Pending text",
                sendType: "1",
                mid: "temp_text_1",
                tempId: "temp_text_1",
                createdTime: 1_779_860_001_001
            ),
            ChatMessage(
                id: "temp_image_1",
                msgType: "2",
                message: "blob:local-image",
                sendType: "1",
                mid: "temp_image_1",
                tempId: "temp_image_1",
                createdTime: 1_779_860_001_002
            ),
            ChatMessage(
                id: "system_1",
                msgType: "8",
                message: #"{"type":"plain"}"#,
                sendType: "2",
                createdTime: 1_779_860_001_003
            ),
            ChatMessage(
                id: "join_1",
                msgType: "8",
                message: #"{"type":"join_session","nickname":"Ada"}"#,
                sendType: "2",
                createdTime: 1_779_860_001_004
            ),
            ChatMessage(
                id: "invite_1",
                msgType: "3",
                message: #"{"type":"invite_evalution","payload":{"session_id":"session_1"}}"#,
                sendType: "2",
                createdTime: 1_779_860_001_005
            ),
            ChatMessage(
                id: "promo_1",
                msgType: "3",
                message: ##"{"payload":{"promotional_card":{"type":"discount","text":"Save","text_color":"#111111","btn_color":"#222222","image":"https://cdn.example.com/card.png","discount":80,"countdown":10}}}"##,
                sendType: "2",
                createdTime: 1_779_860_001_006
            ),
            ChatMessage(
                id: "likes_1",
                msgType: "3",
                message: #"{"payload":{"likes":{"like":"Like","unlike":"Unlike"}}}"#,
                sendType: "2",
                createdTime: 1_779_860_001_007
            ),
            ChatMessage(
                id: "guide_1",
                msgType: "11",
                message: #"{"type":"guide","data":[]}"#,
                sendType: "2",
                createdTime: 1_779_860_001_008
            ),
        ])

        XCTAssertEqual(recoveredMessages.map(\.id), ["temp_text_1", "temp_image_1", "join_1", "invite_1", "promo_1", "likes_1", "guide_1"])
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.id == "temp_text_1" }?.mid).hasPrefix("fail_"))
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.id == "temp_image_1" }?.mid).hasPrefix("fail_"))
        XCTAssertNil(runtime.state.messages.first { $0.id == "system_1" })
        XCTAssertNotNil(runtime.state.messages.first { $0.id == "join_1" })
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.id == "invite_1" }?.tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages.first { $0.id == "invite_1" }?.status, 0)
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.id == "promo_1" }?.tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages.first { $0.id == "promo_1" }?.status, 0)
        XCTAssertEqual(runtime.state.messages.first { $0.id == "likes_1" }?.likeResult?["like"], "")
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.id == "guide_1" }?.tempId).hasPrefix("temp_"))
        XCTAssertEqual(runtime.state.messages.first { $0.id == "guide_1" }?.status, 0)
    }

    func testTriggerPayloadsAndResponseReducerMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        let triggerUserPayload = try XCTUnwrap(
            runtime.makeTriggerUserPayload(
                newUserKey: "new_user_key_1",
                chatUserId: "chat_user_1",
                isNewUser: true,
                isInvalidRefresh: false,
                hasLocalRecord: false,
                isSandbox: false
            )
        )
        XCTAssertEqual(triggerUserPayload["is_new_user"] as? String, "1")
        XCTAssertEqual(triggerUserPayload["flow_id"] as? String, "flow_1")
        XCTAssertNil(
            runtime.makeTriggerUserPayload(
                newUserKey: "new_user_key_1",
                chatUserId: "chat_user_1",
                isNewUser: true,
                isInvalidRefresh: false,
                hasLocalRecord: false,
                isSandbox: false
            )
        )
        XCTAssertNil(
            runtime.makeTriggerUserPayload(
                newUserKey: "new_user_key_2",
                chatUserId: "",
                isNewUser: false,
                isInvalidRefresh: false,
                hasLocalRecord: false,
                isSandbox: false
            )
        )

        let triggerUrlPayload = runtime.makeTriggerUrlPayload(
            sourceURL: "https://example.com/products",
            uniqueId: "page_token_1",
            scrollNum: 120,
            delayNum: 2
        )
        let triggerUrlDataString = try XCTUnwrap(triggerUrlPayload["data"] as? String)
        let triggerUrlData = try XCTUnwrap(triggerUrlDataString.data(using: .utf8))
        let triggerUrlParams = try XCTUnwrap(JSONSerialization.jsonObject(with: triggerUrlData) as? [String: Any])

        XCTAssertEqual(triggerUrlPayload["trigger_type"] as? String, "11")
        XCTAssertEqual(triggerUrlPayload["flow_id"] as? String, "flow_1")
        XCTAssertEqual(triggerUrlParams["url"] as? String, "https://example.com/products")
        XCTAssertEqual(triggerUrlParams["unique_id"] as? String, "page_token_1")
        XCTAssertEqual(triggerUrlParams["scroll_num"] as? Int, 120)
        XCTAssertEqual(triggerUrlParams["delay_num"] as? Int, 2)

        var receivePayload: SalesmartlyPayload = [:]
        SalesmartlyChat.push("onReceiveMessage") { payload in
            receivePayload = payload
        }

        let appliedCount = runtime.applyTriggeredMessageList([
            ChatMessage(
                id: "trigger_msg_1",
                msgType: "1",
                message: "Triggered message",
                sendType: "2",
                createdTime: 1_779_860_001_300,
                chatUserId: "chat_user_1",
                isRead: "0"
            ),
        ])

        XCTAssertEqual(appliedCount, 1)
        XCTAssertEqual(runtime.state.messages.last?.id, "trigger_msg_1")
        XCTAssertEqual(runtime.state.unReadNum, 1)
        XCTAssertEqual(receivePayload["mid"] as? String, "trigger_msg_1")

        runtime.joinRoom()

        XCTAssertEqual(
            runtime.applyTriggeredMessageList([
                ChatMessage(
                    id: "trigger_msg_2",
                    msgType: "1",
                    message: "Joined room message",
                    sendType: "2",
                    createdTime: 1_779_860_001_301,
                    chatUserId: "chat_user_1",
                    isRead: "0"
                ),
            ]),
            0
        )
        XCTAssertNil(runtime.state.messages.first { $0.id == "trigger_msg_2" })
    }

    func testUpdateUserInfoPayloadsMatchWidgetUnionRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat, flowId: "flow_1")
            )
        )

        let payloads = runtime.makeUpdateUserInfoPayloads(
            token: "token_1",
            userName: "Ada",
            phone: "10086",
            email: "ada@example.com",
            language: "en-US",
            data: #"{"plan":"pro"}"#,
            company: "Acme",
            chatUserId: "chat_user_1",
            source: "2"
        )
        let triggerDataString = try XCTUnwrap(payloads.trigger["data"] as? String)
        let triggerData = try XCTUnwrap(triggerDataString.data(using: .utf8))
        let triggerParams = try XCTUnwrap(JSONSerialization.jsonObject(with: triggerData) as? [String: String])

        XCTAssertEqual(payloads.updateUser["token"] as? String, "token_1")
        XCTAssertEqual(payloads.updateUser["user_name"] as? String, "Ada")
        XCTAssertEqual(payloads.updateUser["phone"] as? String, "10086")
        XCTAssertEqual(payloads.updateUser["email"] as? String, "ada@example.com")
        XCTAssertEqual(payloads.updateUser["language"] as? String, "en-US")
        XCTAssertEqual(payloads.updateUser["data"] as? String, #"{"plan":"pro"}"#)
        XCTAssertEqual(payloads.updateUser["company"] as? String, "Acme")
        XCTAssertEqual(payloads.updateUser["chat_user_id"] as? String, "chat_user_1")
        XCTAssertNil(payloads.updateUser["source"])

        XCTAssertEqual(payloads.trigger["trigger_type"] as? String, "16")
        XCTAssertEqual(payloads.trigger["source"] as? String, "2")
        XCTAssertEqual(payloads.trigger["flow_id"] as? String, "flow_1")
        XCTAssertEqual(triggerParams["user_name"], "Ada")
        XCTAssertEqual(triggerParams["phone"], "10086")
        XCTAssertEqual(triggerParams["email"], "ada@example.com")
        XCTAssertEqual(triggerParams["language"], "en-US")
        XCTAssertEqual(triggerParams["data"], #"{"plan":"pro"}"#)
        XCTAssertEqual(triggerParams["company"], "Acme")
        XCTAssertEqual(triggerParams["chat_user_id"], "chat_user_1")
        XCTAssertNil(triggerParams["token"])
        XCTAssertNil(triggerParams["source"])
    }

    func testAfterCollectionBuildsWidgetCollectionMessageAndDispatchesInfo() async throws {
        let runtime = SalesmartlyRuntime()
        var collectionInfoPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onCollectionInfo") { payload in
            collectionInfoPayload = payload
        }
        runtime.showCollection()

        XCTAssertTrue(
            runtime.afterCollection(
                title: "Leave info",
                payload: [
                    "name": "Ada",
                    "email": "ada@example.com",
                    "empty": "",
                    "custom_a": ["", "VIP"],
                    "ignored": "skip",
                ],
                customFieldTitle: [
                    "custom_a": "Tier",
                ],
                currentFieldOptionKeys: ["name", "email", "empty", "custom_a"],
                collectionType: "survey",
                chatUserId: "chat_user_1"
            )
        )

        let message = try XCTUnwrap(runtime.state.messages.last)
        let messageData = try XCTUnwrap(message.message.data(using: .utf8))
        let params = try XCTUnwrap(JSONSerialization.jsonObject(with: messageData) as? [String: Any])
        let payload = try XCTUnwrap(params["payload"] as? [String: Any])
        let customFieldTitle = try XCTUnwrap(params["custom_field_title"] as? [String: String])

        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertEqual(message.msgType, "19")
        XCTAssertEqual(message.sendType, "1")
        XCTAssertEqual(message.chatUserId, "chat_user_1")
        XCTAssertEqual(runtime.sendMessageMap[try XCTUnwrap(message.cMId)]?.tempId, message.tempId)
        XCTAssertEqual(params["source"] as? String, "survey")
        XCTAssertEqual(params["title"] as? String, "Leave info")
        XCTAssertEqual(payload["name"] as? String, "Ada")
        XCTAssertEqual(payload["email"] as? String, "ada@example.com")
        XCTAssertNil(payload["empty"])
        XCTAssertNil(payload["ignored"])
        XCTAssertEqual(payload["custom_a"] as? [String], ["VIP"])
        XCTAssertEqual(customFieldTitle["custom_a"], "Tier")
        XCTAssertEqual(collectionInfoPayload["name"] as? String, "Ada")
        XCTAssertEqual(collectionInfoPayload["type"] as? String, "survey")
    }

    func testAfterCollectionClosesWithoutMessageWhenPayloadEmpty() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.showCollection()

        XCTAssertFalse(
            runtime.afterCollection(
                title: "Leave info",
                payload: [
                    "name": "",
                    "ignored": "skip",
                ],
                customFieldTitle: [:],
                currentFieldOptionKeys: ["name"],
                collectionType: "offline",
                chatUserId: "chat_user_1"
            )
        )
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertTrue(runtime.state.messages.isEmpty)
        XCTAssertTrue(runtime.sendMessageMap.isEmpty)
    }

    func testPluginInfoTransportResponseAppliesWidgetCollectionConfigs() async throws {
        let runtime = SalesmartlyRuntime()
        let collectFields: [SalesmartlyPayload] = [
            [
                "id": "email",
                "name": "Email",
                "field_type": "0",
                "required": "1",
                "key": "email",
                "field_name": "",
                "select_type": "0",
                "select_content": [],
            ],
            [
                "id": "tier",
                "name": "客户等级",
                "field_type": "1",
                "required": "1",
                "key": "tier",
                "field_name": "客户等级",
                "select_type": "1",
                "select_content": [
                    [
                        "id": "vip",
                        "value": "VIP",
                    ],
                ] as [SalesmartlyPayload],
            ],
        ]
        let info: SalesmartlyPayload = [
            "collect_information": [
                "collect_switch": "1",
                "collect_required": "1",
                "collect_btn_switch": "0",
                "guidance": "Before chat",
                "status_text": "Leave info",
                "field_options": collectFields,
            ] as SalesmartlyPayload,
            "offline_survey": [
                "collect_switch": "1",
                "collect_required": "0",
                "collect_btn_switch": "1",
                "guidance": "Offline",
                "status_text": "Offline status",
            ] as SalesmartlyPayload,
            "welcome": "欢迎联系我们",
            "window_subhead_switch": "1",
            "show_helpdesk_config": [
                "switch": "1",
                "id": "help_1",
                "title": "帮助中心",
                "url": "\"https://help.example/docs\"",
            ] as SalesmartlyPayload,
            "bulletin_board": [
                "enabled": "1",
                "content": "公告内容",
                "background_color": "#F3C141",
                "link": "example.com/news",
                "enable_link": "0",
                "board_mode": "2",
            ] as SalesmartlyPayload,
        ]

        XCTAssertTrue(
            runtime.handlePluginInfoTransportResponse([
                "data": info,
            ])
        )

        XCTAssertTrue(runtime.state.collectInformation.collect_switch)
        XCTAssertTrue(runtime.state.collectInformation.collect_required)
        XCTAssertFalse(runtime.state.collectInformation.collect_btn_switch)
        XCTAssertEqual(runtime.state.collectInformation.guidance, "Before chat")
        XCTAssertEqual(runtime.state.collectInformation.status_text, "Leave info")
        XCTAssertEqual(runtime.state.collectInformation.field_options.count, 2)
        XCTAssertEqual(runtime.state.collectInformation.field_options[1].key, "tier")
        XCTAssertEqual(runtime.state.collectInformation.field_options[1].select_content.first?.value, "VIP")
        XCTAssertTrue(runtime.state.offlineSurvey.collect_switch)
        XCTAssertFalse(runtime.state.offlineSurvey.collect_required)
        XCTAssertTrue(runtime.state.offlineSurvey.collect_btn_switch)
        XCTAssertEqual(runtime.state.offlineSurvey.guidance, "Offline")
        XCTAssertEqual(runtime.state.offlineSurvey.field_options, SalesmartlyCollectionConfig.defaultFieldOptions)
        XCTAssertEqual(runtime.state.welcome, "欢迎联系我们")
        XCTAssertEqual(runtime.state.windowSubheadSwitch, "1")
        XCTAssertEqual(runtime.state.helpdeskSwitch, "1")
        XCTAssertEqual(runtime.state.helpdeskId, "help_1")
        XCTAssertEqual(runtime.state.helpdeskTitle, "帮助中心")
        XCTAssertEqual(runtime.state.helpdeskURL, "\"https://help.example/docs\"")
        XCTAssertTrue(runtime.chatHeaderIsHelpdeskEnabled())
        XCTAssertEqual(runtime.chatHeaderHelpdeskURLString(), "https://help.example/docs")
        XCTAssertTrue(runtime.state.bulletinBoard.enabled)
        XCTAssertEqual(runtime.state.bulletinBoard.content, "公告内容")
        XCTAssertEqual(runtime.state.bulletinBoard.background_color, "#F3C141")
        XCTAssertEqual(runtime.state.bulletinBoard.link, "example.com/news")
        XCTAssertFalse(runtime.state.bulletinBoard.enable_link)
        XCTAssertEqual(runtime.state.bulletinBoard.board_mode, "2")
    }

    /// 对齐 Android `bulletinBoardStateFollowsWidgetVisibilityAndDismissedFlag` 与 Web 公告栏关闭/点击规则。
    func testBulletinBoardStateFollowsWidgetVisibilityAndClickRules() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.lang = "zh-CN"
        runtime.state.bulletinBoard = SalesmartlyBulletinBoardConfig(
            enabled: true,
            content: "公告内容",
            background_color: "#F3C141"
        )

        var boardState = runtime.bulletinBoardState()

        XCTAssertTrue(boardState.visible)
        XCTAssertEqual(boardState.content, "公告内容")
        XCTAssertEqual(boardState.backgroundColor, "#F3C141")
        XCTAssertEqual(boardState.link, "")
        XCTAssertFalse(boardState.isMarquee)
        XCTAssertTrue(boardState.canOpenModal)
        XCTAssertFalse(boardState.canJumpOnBoardClick)
        XCTAssertFalse(boardState.canGotoLink)
        XCTAssertTrue(boardState.isBoardClickable)
        XCTAssertEqual(boardState.marqueeDurationSeconds, 1)
        XCTAssertEqual(boardState.modalTitle, "公告")
        XCTAssertEqual(boardState.gotoText, "前往")
        XCTAssertEqual(runtime.bulletinBoardClickAction(), .openModal)

        runtime.dismissBulletinBoard()

        XCTAssertFalse(runtime.bulletinBoardState().visible)
        XCTAssertEqual(runtime.bulletinBoardClickAction(), .none)

        runtime.state.bulletinBoardDismissed = false
        runtime.state.bulletinBoard = SalesmartlyBulletinBoardConfig(
            enabled: true,
            content: "公告内容",
            link: "example.com/news",
            enable_link: true,
            board_mode: "2"
        )
        boardState = runtime.bulletinBoardState()

        XCTAssertTrue(boardState.isMarquee)
        XCTAssertEqual(boardState.link, "//example.com/news")
        XCTAssertTrue(boardState.canJumpOnBoardClick)
        XCTAssertFalse(boardState.canGotoLink)
        XCTAssertFalse(boardState.canOpenModal)
        XCTAssertEqual(runtime.bulletinBoardClickAction(), .openLink("//example.com/news"))

        runtime.state.bulletinBoard = SalesmartlyBulletinBoardConfig(
            enabled: true,
            content: "公告内容",
            link: "https://example.com/news",
            enable_link: true,
            board_mode: "1"
        )
        boardState = runtime.bulletinBoardState()

        XCTAssertEqual(boardState.link, "https://example.com/news")
        XCTAssertTrue(boardState.canGotoLink)
        XCTAssertFalse(boardState.canJumpOnBoardClick)
        XCTAssertEqual(runtime.bulletinBoardClickAction(), .openModal)

        runtime.state.bulletinBoard = SalesmartlyBulletinBoardConfig(
            enabled: true,
            content: "",
            link: "",
            enable_link: true,
            board_mode: "1"
        )

        XCTAssertEqual(runtime.bulletinBoardClickAction(), .none)
    }

    /// 对齐 Android `bulletinBoardMarqueeDurationFollowsWebContentLengthRule` 和弹窗多语言文案规则。
    func testBulletinBoardMarqueeDurationAndLanguageMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.state.lang = "en-US"
        runtime.state.bulletinBoard = SalesmartlyBulletinBoardConfig(
            enabled: true,
            content: "1234567",
            board_mode: "2"
        )

        let boardState = runtime.bulletinBoardState()

        XCTAssertEqual(boardState.marqueeDurationSeconds, 2)
        XCTAssertEqual(boardState.modalTitle, "announcement")
        XCTAssertEqual(boardState.gotoText, "Go to")
    }

    func testCollectionConfigValidationAndSubmitStateMatchAndroidRules() async throws {
        let config = SalesmartlyCollectionConfig(
            field_options: [
                SalesmartlyCollectionFieldOption(name: "Email", field_type: "0", required: "1", key: "email"),
                SalesmartlyCollectionFieldOption(name: "Phone", field_type: "0", required: "1", key: "phone"),
                SalesmartlyCollectionFieldOption(
                    id: "tier",
                    name: "客户等级",
                    field_type: "1",
                    required: "1",
                    key: "tier",
                    select_type: "1",
                    select_content: [
                        SalesmartlyCollectionSelectOption(id: "vip", value: "VIP"),
                        SalesmartlyCollectionSelectOption(id: "trial", value: "试用"),
                    ]
                ),
                SalesmartlyCollectionFieldOption(name: "预约日期", field_type: "2", required: "1", key: "date"),
                SalesmartlyCollectionFieldOption(name: "人数", field_type: "3", required: "1", key: "count"),
                SalesmartlyCollectionFieldOption(name: "备注", field_type: "0", required: "1", key: "note"),
            ]
        )

        let errors = config.collectionFieldErrorTexts(
            values: [
                "email": "",
                "phone": "123",
                "tier": [String](),
                "date": "2024-02-30",
                "count": "123456789012",
                "note": "",
            ],
            area: "",
            language: "zh-CN"
        )

        XCTAssertEqual(errors["email"], "请输入邮箱")
        XCTAssertEqual(errors["phone"], "请选择区号")
        XCTAssertEqual(errors["tier"], "请选择")
        XCTAssertEqual(errors["date"], "请输入日期: 2050-10-01")
        XCTAssertEqual(errors["count"], "请输入数字")
        XCTAssertEqual(errors["note"], "请输入")

        let optionalEmailConfig = SalesmartlyCollectionConfig(
            field_options: [
                SalesmartlyCollectionFieldOption(name: "Email", field_type: "0", required: "0", key: "email"),
            ]
        )
        XCTAssertEqual(
            optionalEmailConfig.collectionFieldErrorTexts(values: ["email": "bad"], area: "", language: "zh-CN")["email"],
            "邮箱格式错误"
        )

        let submitState = config.collectionSubmitState(
            title: "信息提交成功",
            type: "offline",
            values: [
                "email": "ada@example.com",
                "phone": "13800138000",
                "tier": ["vip", "trial"],
                "date": "2024-02-29",
                "count": "11",
                "note": "备注",
            ],
            area: "+86"
        )

        XCTAssertEqual(submitState.payload["email"] as? String, "ada@example.com")
        XCTAssertEqual(submitState.payload["phone"] as? String, "8613800138000")
        XCTAssertEqual(submitState.payload["tier"] as? [String], ["VIP", "试用"])
        XCTAssertEqual(submitState.payload["date"] as? String, "2024-02-29")
        XCTAssertEqual(submitState.payload["count"] as? String, "11")
        XCTAssertEqual(submitState.payload["note"] as? String, "备注")
        XCTAssertNil(submitState.custom_field_title["email"])
        XCTAssertNil(submitState.custom_field_title["phone"])
        XCTAssertEqual(submitState.custom_field_title["tier"], "客户等级")
        XCTAssertEqual(submitState.custom_field_title["date"], "预约日期")
        XCTAssertEqual(submitState.callbackPayload["type"] as? String, "offline")
        XCTAssertEqual(submitState.messagePayload["source"] as? String, "offline")
    }

    func testSubmitCollectionPostsIntroductionMessageAndClosesOverlay() async throws {
        let runtime = SalesmartlyRuntime()
        var collectionInfoPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onCollectionInfo") { payload in
            collectionInfoPayload = payload
        }
        runtime.state.lang = "zh-CN"
        runtime.state.offlineSurvey = SalesmartlyCollectionConfig(
            field_options: [
                SalesmartlyCollectionFieldOption(name: "Email", field_type: "0", required: "1", key: "email"),
            ]
        )
        runtime.showOffline()

        XCTAssertTrue(runtime.submitCollection(type: "offline", values: ["email": "ada@example.com"], area: ""))

        let message = try XCTUnwrap(runtime.state.messages.last)
        let messageData = try XCTUnwrap(message.message.data(using: .utf8))
        let params = try XCTUnwrap(JSONSerialization.jsonObject(with: messageData) as? [String: Any])
        let payload = try XCTUnwrap(params["payload"] as? [String: Any])

        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertFalse(runtime.state.showOffline)
        XCTAssertEqual(message.msgType, "19")
        XCTAssertEqual(params["source"] as? String, "offline")
        XCTAssertEqual(params["title"] as? String, "信息提交成功")
        XCTAssertEqual(payload["email"] as? String, "ada@example.com")
        XCTAssertEqual(collectionInfoPayload["email"] as? String, "ada@example.com")
        XCTAssertEqual(collectionInfoPayload["type"] as? String, "offline")
    }

    func testBeforePostMessageCollectionInterceptionMatchesWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertFalse(
            runtime.beforePostMessage(
                msgType: "1",
                message: "Pending text",
                tempId: "temp_pending_text_1",
                chatUserId: "chat_user_1",
                enabledCollect: true,
                requiredCollect: false
            )
        )
        XCTAssertTrue(runtime.state.showCollection)
        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertTrue(runtime.state.messages.isEmpty)
        XCTAssertTrue(runtime.sendMessageMap.isEmpty)

        runtime.closeCollection()

        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertEqual(runtime.state.draftText, "Pending text")

        XCTAssertTrue(
            runtime.beforePostMessage(
                msgType: "5",
                message: [
                    "text": "Yes",
                    "postback": "yes",
                ],
                tempId: "temp_postback_collect_1",
                chatUserId: "chat_user_1",
                enabledCollect: true,
                requiredCollect: false
            )
        )
        XCTAssertEqual(runtime.state.messages.last?.msgType, "5")
        XCTAssertFalse(runtime.state.showCollection)

        let requiredRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: requiredRuntime)

        XCTAssertFalse(
            requiredRuntime.beforePostMessage(
                msgType: "5",
                message: [
                    "text": "Required",
                    "postback": "required",
                ],
                tempId: "temp_postback_required_1",
                chatUserId: "chat_user_1",
                enabledCollect: true,
                requiredCollect: true
            )
        )
        XCTAssertTrue(requiredRuntime.state.showCollection)
        XCTAssertTrue(requiredRuntime.state.messages.isEmpty)
    }

    func testAfterCollectionContinuesPendingPostAndRetry() async throws {
        let runtime = SalesmartlyRuntime()
        var collectionInfoPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onCollectionInfo") { payload in
            collectionInfoPayload = payload
        }

        XCTAssertFalse(
            runtime.beforePostMessage(
                msgType: "1",
                message: "Pending after collection",
                tempId: "temp_pending_after_collection_1",
                chatUserId: "chat_user_1",
                enabledCollect: true,
                requiredCollect: false
            )
        )
        XCTAssertTrue(
            runtime.afterCollection(
                title: "Leave info",
                payload: [
                    "name": "Ada",
                ],
                customFieldTitle: [:],
                currentFieldOptionKeys: ["name"],
                collectionType: "survey",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertEqual(runtime.state.messages.map(\.msgType), ["19", "1"])
        XCTAssertEqual(runtime.state.messages.last?.message, "Pending after collection")
        XCTAssertEqual(runtime.state.messages.last?.tempId, "temp_pending_after_collection_1")
        XCTAssertEqual(collectionInfoPayload["type"] as? String, "survey")

        let retryRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: retryRuntime)
        retryRuntime.postMessage(
            msgType: "1",
            message: "Retry after collection",
            tempId: "temp_retry_after_collection_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertFalse(
            retryRuntime.beforeRetrySendMessage(
                tempId: "temp_retry_after_collection_1",
                enabledCollect: true,
                requiredCollect: false
            )
        )
        XCTAssertTrue(retryRuntime.state.showCollection)
        XCTAssertTrue(
            retryRuntime.afterCollection(
                title: "Leave info",
                payload: [
                    "name": "Ada",
                ],
                customFieldTitle: [:],
                currentFieldOptionKeys: ["name"],
                collectionType: "survey",
                chatUserId: "chat_user_1"
            )
        )

        let retryMessage = try XCTUnwrap(retryRuntime.state.messages.first { $0.tempId == "temp_retry_after_collection_1" })
        let retryClientMessageId = try XCTUnwrap(retryMessage.cMId)

        XCTAssertTrue(retryMessage.mid.hasPrefix("retry_"))
        XCTAssertNotNil(retryRuntime.retryingMap[retryClientMessageId])
    }

    func testBeforeRetrySendMessageSkipsUploadStageAttachmentCollection() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.postMessage(
            msgType: "2",
            message: "blob:local-image",
            tempId: "temp_blob_retry_collection_1",
            chatUserId: "chat_user_1"
        )

        XCTAssertFalse(
            runtime.beforeRetrySendMessage(
                tempId: "temp_blob_retry_collection_1",
                enabledCollect: true,
                requiredCollect: false
            )
        )
        XCTAssertFalse(runtime.state.showCollection)
        XCTAssertTrue(runtime.retryingMap.isEmpty)
    }

    func testUploadLifecycleMatchesWidgetLocalPlaceholderAndRetryRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        let uploadFile = SalesmartlyUploadFile(
            name: "photo.png",
            size: 4096,
            isImage: true,
            isVideo: false,
            localURL: "blob:local-photo"
        )

        XCTAssertTrue(
            runtime.onUpload(
                uploadFile,
                tempId: "temp_upload_photo_1",
                clientExpandInfo: ["c_m_id": "upload_client_1"]
            )
        )

        let placeholder = try XCTUnwrap(runtime.state.messages.last)

        XCTAssertEqual(placeholder.msgType, "2")
        XCTAssertEqual(placeholder.message, "blob:local-photo")
        XCTAssertEqual(placeholder.tempId, "temp_upload_photo_1")
        XCTAssertEqual(placeholder.cMId, "upload_client_1")
        XCTAssertNil(runtime.sendMessageMap["upload_client_1"])
        XCTAssertEqual(runtime.uploadTaskMap["temp_upload_photo_1"]?.type, "2")

        XCTAssertTrue(
            runtime.handleUploadSuccess(
                tempId: "temp_upload_photo_1",
                fileURL: "https://assets.example.com/photo.png",
                sendURL: "https://send.example.com/photo.png",
                assetURL: "https://view.example.com/photo.png"
            )
        )

        XCTAssertNil(runtime.uploadTaskMap["temp_upload_photo_1"])
        XCTAssertEqual(runtime.sendMessageMap["upload_client_1"]?.message, "https://send.example.com/photo.png")
        XCTAssertEqual(runtime.sendAssetsList.last?["c_m_id"], "upload_client_1")
        XCTAssertEqual(runtime.sendAssetsList.last?["url"], "https://view.example.com/photo.png")

        let failedUploadRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: failedUploadRuntime)
        XCTAssertTrue(
            failedUploadRuntime.onUpload(
                uploadFile,
                tempId: "temp_upload_photo_2",
                clientExpandInfo: ["c_m_id": "upload_client_2"]
            )
        )

        XCTAssertEqual(failedUploadRuntime.handleOfflineUploadTasks(), 1)
        XCTAssertTrue(try XCTUnwrap(failedUploadRuntime.state.messages.last?.mid).hasPrefix("fail_"))

        XCTAssertTrue(failedUploadRuntime.retryUploadByTempId("temp_upload_photo_2"))
        XCTAssertTrue(try XCTUnwrap(failedUploadRuntime.state.messages.last?.mid).hasPrefix("retry_"))

        let emptyVideo = SalesmartlyUploadFile(
            name: "empty.mov",
            size: 0,
            isImage: false,
            isVideo: true,
            localURL: nil
        )

        XCTAssertFalse(runtime.onUpload(emptyVideo, tempId: "temp_empty_video_1"))
    }

    func testUploadTransportPayloadsMatchWidgetOSSAndSwapObjectRules() async throws {
        let runtime = SalesmartlyRuntime()

        let uploadConfigPayload = runtime.makeUploadOSSConfigPayload(
            pluginId: "plugin_1",
            env: "chat",
            msgType: "2"
        )

        XCTAssertEqual(uploadConfigPayload["module"] as? String, "chat")
        XCTAssertEqual(uploadConfigPayload["module_path"] as? String, "plugin/plugin_1/2")
        XCTAssertEqual(uploadConfigPayload["plugin_id"] as? String, "plugin_1")
        XCTAssertEqual(uploadConfigPayload["env"] as? String, "chat")
        XCTAssertEqual(uploadConfigPayload["platform"] as? String, "pc0")
        XCTAssertEqual(uploadConfigPayload["btype"] as? String, "mix_ads")
        XCTAssertEqual(runtime.uploadTimeoutMilliseconds(), 150_000)

        XCTAssertEqual(
            runtime.normalizedUploadFileURL("http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png"),
            "https://assets.salesmartly.com/media/a.png"
        )

        let swapPayload = runtime.makeSwapObjectPayload(
            tempId: "temp_upload_photo_1",
            fileURL: "http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png"
        )

        XCTAssertEqual(
            swapPayload["object"] as? String,
            "nSph1nohMhH4rna8NSX8P3z+ruz813z4PaFjyh8hsGXA19X4yAKhtAOhBdHWsQEVsSohMhHwrncEsCz+BGY/rqHzNo=="
        )
    }

    func testUploadFileTypeCompressionAndReplaceNameMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()

        XCTAssertEqual(runtime.makeUploadMsgType(fileName: "photo.JPG"), "2")
        XCTAssertEqual(runtime.makeUploadMsgType(fileName: "clip.mov"), "6")
        XCTAssertEqual(runtime.makeUploadMsgType(fileName: "animation.gif"), "4")
        XCTAssertEqual(runtime.makeUploadMsgType(fileName: "photo.png", requestedMsgType: "45"), "45")

        let largeImagePlan = runtime.makeUploadCompressionPlan(
            for: SalesmartlyUploadFile(
                name: "large-photo.jpg",
                size: 1_048_576,
                isImage: true,
                isVideo: false,
                localURL: "blob:large-photo"
            )
        )
        XCTAssertTrue(largeImagePlan.shouldCompress)
        XCTAssertEqual(largeImagePlan.quality, 0.85)
        XCTAssertTrue(largeImagePlan.fallbackToOriginalOnFailure)

        let smallImagePlan = runtime.makeUploadCompressionPlan(
            for: SalesmartlyUploadFile(
                name: "small-photo.jpg",
                size: 1_048_575,
                isImage: true,
                isVideo: false,
                localURL: "blob:small-photo"
            )
        )
        XCTAssertFalse(smallImagePlan.shouldCompress)
        XCTAssertFalse(smallImagePlan.fallbackToOriginalOnFailure)

        let gifPlan = runtime.makeUploadCompressionPlan(
            for: SalesmartlyUploadFile(
                name: "animation.gif",
                size: 2_097_152,
                isImage: true,
                isVideo: false,
                localURL: "blob:animation"
            )
        )
        XCTAssertFalse(gifPlan.shouldCompress)
        XCTAssertTrue(runtime.shouldLogCompressedUpload(originalSize: 4_194_304, compressedSize: 2_097_151))
        XCTAssertFalse(runtime.shouldLogCompressedUpload(originalSize: 4_194_304, compressedSize: 2_097_152))

        XCTAssertEqual(
            runtime.makeUploadReplaceName(
                fileName: "客户 photo.png",
                msgType: "2",
                pluginId: "plugin_1",
                random: 12_345,
                nowMilliseconds: 1_779_900_123_456
            ),
            "fa0f9df9c046ee0d989dbbbbb6cd67e5.png"
        )
        XCTAssertEqual(
            runtime.makeUploadReplaceName(
                fileName: "report.pdf",
                msgType: "4",
                pluginId: "plugin_1",
                random: 12_345,
                nowMilliseconds: 1_779_900_123_456
            ),
            ""
        )

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "animation.gif",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:animation"
                ),
                tempId: "temp_upload_gif_1",
                clientExpandInfo: ["c_m_id": "upload_gif_1"]
            )
        )
        XCTAssertEqual(runtime.state.messages.last?.msgType, "4")
        XCTAssertEqual(runtime.state.messages.last?.message, "animation.gif")
    }

    func testResizeOssMediaUrlsMatchWidgetBubbleRules() async throws {
        let runtime = SalesmartlyRuntime()

        XCTAssertEqual(
            runtime.resizeOssImgUrl(
                "https://salesmartly.oss-accelerate.aliyuncs.com/media/photo.jpg?token=1",
                height: 120,
                width: 280
            ),
            "https://static.salesmartly.com/media/photo.jpg?token=1&x-oss-process=image/resize,h_120,w_280"
        )
        XCTAssertEqual(
            runtime.resizeOssImgUrl("https://assets.salesmartly.com/media/animation.gif"),
            "https://assets-cdn.salesmartly.com/media/animation.gif"
        )
        XCTAssertEqual(
            runtime.resizeOssImgUrl("blob:local-photo", height: 120, width: 280),
            "blob:local-photo"
        )
        XCTAssertEqual(
            runtime.resizeOssImgUrl(
                "https://salesmartly.oss-accelerate.aliyuncs.com/media/photo.jpg",
                width: 720
            ),
            "https://static.salesmartly.com/media/photo.jpg?x-oss-process=image/resize,w_720"
        )
        XCTAssertEqual(
            runtime.resizeOssVideoUrl("http://salesmartly.oss-accelerate.aliyuncs.com/media/clip.mp4"),
            "http://static.salesmartly.com/media/clip.mp4"
        )
    }

    func testUploadOSSConfigCacheAndDirectFormMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        let stsConfig = SalesmartlyOSSSTSConfig(
            accessKeyId: "access_key_1",
            accessKeySecret: "secret_1",
            expiration: "2026-06-01T00:00:00Z",
            securityToken: "security_token_1"
        )
        let cache = runtime.saveUploadOSSConfig(
            module: "chat",
            modulePath: "plugin/plugin_1/2",
            stsConfig: stsConfig,
            path: "test3/project/d1c7rxe/chat/plugin/img/egt3nf/20260529/",
            dewsCode: "3",
            nowMilliseconds: 1_779_900_000_000
        )

        XCTAssertEqual(cache.effectiveTime, 1_779_900_600_000)
        XCTAssertEqual(cache.dews, "public-read")
        XCTAssertEqual(
            runtime.cachedUploadOSSConfig(
                module: "chat",
                modulePath: "plugin/plugin_1/2",
                nowMilliseconds: 1_779_900_300_000
            ),
            cache
        )
        XCTAssertNil(
            runtime.cachedUploadOSSConfig(
                module: "chat",
                modulePath: "plugin/plugin_1/2",
                nowMilliseconds: 1_779_900_700_000
            )
        )

        let form = runtime.makeUploadOSSDirectForm(
            config: cache,
            fileName: "客户 photo.png",
            replaceName: "safe-photo.png",
            nowMilliseconds: 1_779_900_123_456
        )

        XCTAssertEqual(form.url, "https://mix-ads.oss-accelerate.aliyuncs.com")
        XCTAssertEqual(form.headers["Content-Type"], "multipart/form-data")
        XCTAssertEqual(form.timeoutMilliseconds, 120_000)
        XCTAssertEqual(form.fileFieldName, "file")
        XCTAssertEqual(
            form.objectURL,
            "https://assets-cdn.salesmartly.com/test3/project/d1c7rxe/chat/plugin/img/egt3nf/20260529/1779900123456/safe-photo.png"
        )
        XCTAssertEqual(form.fields["ossAccessKeyId"], "access_key_1")
        XCTAssertEqual(form.fields["x-oss-security-token"], "security_token_1")
        XCTAssertEqual(form.fields["x-oss-object-acl"], "public-read")
        XCTAssertEqual(
            form.fields["key"],
            "test3/project/d1c7rxe/chat/plugin/img/egt3nf/20260529/1779900123456/safe-photo.png"
        )
        XCTAssertEqual(
            form.fields["policy"],
            "eyJleHBpcmF0aW9uIjoiMjAyNi0wNi0wMVQwMDowMDowMFoiLCJjb25kaXRpb25zIjpbWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsMCwxMDczNzQxODI0XV19"
        )
        XCTAssertEqual(form.fields["signature"], "G9F2cgylsqiILmlbXOvg3FMvn3g=")
    }

    func testUploadSwapObjectResultCompletesUploadWithSendUrlAndAssetUrl() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "photo.png",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:photo"
                ),
                tempId: "temp_upload_photo_3",
                clientExpandInfo: ["c_m_id": "upload_client_3"]
            )
        )

        let result = #"[{"id":"temp_upload_photo_3","object":"media/a.png","url":"https://assets.example.com/preview.png","process":"","send_url":"https://send.example.com/a.png"}]"#
            .data(using: .utf8)!
            .base64EncodedString()

        XCTAssertTrue(
            runtime.handleUploadSwapObjectResult(
                tempId: "temp_upload_photo_3",
                fileURL: "http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png",
                result: result
            )
        )
        XCTAssertNil(runtime.uploadTaskMap["temp_upload_photo_3"])
        XCTAssertEqual(runtime.sendMessageMap["upload_client_3"]?.message, "https://send.example.com/a.png")
        XCTAssertEqual(runtime.sendAssetsList.last?["c_m_id"], "upload_client_3")
        XCTAssertEqual(runtime.sendAssetsList.last?["url"], "https://assets.example.com/preview.png")
    }

    func testUploadFailureNotificationDedupesByTempIdAndIntervalLikeWidget() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "photo-a.png",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:photo-a"
                ),
                tempId: "temp_upload_photo_4",
                clientExpandInfo: ["c_m_id": "upload_client_4"]
            )
        )

        XCTAssertTrue(runtime.handleUploadFailure(tempId: "temp_upload_photo_4", nowMilliseconds: 10_000))
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.mid).hasPrefix("fail_"))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 1)
        XCTAssertEqual(runtime.state.toasts.last?.message, "File upload failed, please check the network and try again")
        XCTAssertFalse(runtime.handleUploadFailure(tempId: "temp_upload_photo_4", nowMilliseconds: 12_000))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 1)
        XCTAssertEqual(runtime.state.toasts.count, 1)

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "photo-b.png",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:photo-b"
                ),
                tempId: "temp_upload_photo_5",
                clientExpandInfo: ["c_m_id": "upload_client_5"]
            )
        )

        XCTAssertFalse(runtime.handleUploadFailure(tempId: "temp_upload_photo_5", nowMilliseconds: 10_500))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 1)
        XCTAssertFalse(runtime.handleUploadFailure(tempId: "temp_upload_photo_5", nowMilliseconds: 12_000))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 1)

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "photo-c.png",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:photo-c"
                ),
                tempId: "temp_upload_photo_6",
                clientExpandInfo: ["c_m_id": "upload_client_6"]
            )
        )

        XCTAssertTrue(runtime.handleUploadFailure(tempId: "temp_upload_photo_6", nowMilliseconds: 12_000))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 2)
        XCTAssertEqual(runtime.state.toasts.count, 2)
        XCTAssertTrue(runtime.retryUploadByTempId("temp_upload_photo_4"))
        XCTAssertTrue(runtime.handleUploadFailure(tempId: "temp_upload_photo_4", nowMilliseconds: 14_000))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 3)
        XCTAssertEqual(runtime.state.toasts.count, 3)
    }

    func testOfflineUploadFailureMarksTasksNotifiedBeforeRetryLikeWidget() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "offline-a.png",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:offline-a"
                ),
                tempId: "temp_upload_offline_1",
                clientExpandInfo: ["c_m_id": "upload_offline_1"]
            )
        )
        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "offline-b.png",
                    size: 4096,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:offline-b"
                ),
                tempId: "temp_upload_offline_2",
                clientExpandInfo: ["c_m_id": "upload_offline_2"]
            )
        )

        XCTAssertEqual(runtime.handleOfflineUploadTasks(nowMilliseconds: 20_000), 2)
        XCTAssertEqual(runtime.uploadFailNotificationCount, 1)
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.tempId == "temp_upload_offline_1" }?.mid).hasPrefix("fail_"))
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.first { $0.tempId == "temp_upload_offline_2" }?.mid).hasPrefix("fail_"))

        XCTAssertTrue(runtime.retryUploadByTempId("temp_upload_offline_1", isOnline: false, nowMilliseconds: 22_000))
        XCTAssertEqual(runtime.uploadFailNotificationCount, 1)
    }

    func testPasteFilePreviewCollectionAndUploadButtonFlowMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        let pasteFile = SalesmartlyUploadFile(
            name: "paste.png",
            size: 4096,
            isImage: true,
            isVideo: false,
            localURL: "blob:paste-photo"
        )

        XCTAssertTrue(runtime.onPaste(pasteFile))
        XCTAssertTrue(runtime.state.showModal)
        XCTAssertEqual(runtime.state.pasteMsgType, "2")
        XCTAssertEqual(runtime.state.tempImgUrl, "blob:paste-photo")
        XCTAssertEqual(runtime.state.fileName, "paste.png")

        XCTAssertFalse(runtime.beforeSendPasteFile(enabledCollect: true))
        XCTAssertTrue(runtime.state.showCollection)
        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertTrue(runtime.state.showModal)

        XCTAssertTrue(
            runtime.afterCollection(
                title: "Leave info",
                payload: [
                    "name": "Ada",
                ],
                customFieldTitle: [:],
                currentFieldOptionKeys: ["name"],
                collectionType: "survey",
                chatUserId: "chat_user_1"
            )
        )

        XCTAssertFalse(runtime.state.showModal)
        XCTAssertEqual(runtime.state.messages.map(\.msgType), ["19", "2"])
        let uploadedPlaceholder = try XCTUnwrap(runtime.state.messages.last)
        XCTAssertEqual(uploadedPlaceholder.message, "blob:paste-photo")
        XCTAssertNil(runtime.sendMessageMap[try XCTUnwrap(uploadedPlaceholder.cMId)])
        XCTAssertEqual(runtime.uploadTaskMap[try XCTUnwrap(uploadedPlaceholder.tempId)]?.type, "2")

        let directRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: directRuntime)
        let videoPasteFile = SalesmartlyUploadFile(
            name: "clip.mov",
            size: 4096,
            isImage: false,
            isVideo: true,
            localURL: "blob:clip-preview"
        )

        XCTAssertTrue(directRuntime.onPaste(videoPasteFile))
        XCTAssertTrue(directRuntime.beforeSendPasteFile(enabledCollect: false))
        XCTAssertFalse(directRuntime.state.showModal)
        XCTAssertEqual(directRuntime.state.messages.last?.msgType, "6")
        XCTAssertEqual(directRuntime.state.messages.last?.message, "blob:clip.mov")

        let hiddenRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: hiddenRuntime)
        hiddenRuntime.hideUpload(["document"])

        XCTAssertFalse(
            hiddenRuntime.onPaste(
                SalesmartlyUploadFile(
                    name: "terms.pdf",
                    size: 1024,
                    isImage: false,
                    isVideo: false
                )
            )
        )
        XCTAssertFalse(hiddenRuntime.state.showModal)

        let buttonRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: buttonRuntime)
        buttonRuntime.openChat()

        XCTAssertTrue(buttonRuntime.handleClickUploadBtn(enabledCollect: true))
        XCTAssertTrue(buttonRuntime.state.showCollection)

        let collectionRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: collectionRuntime)

        collectionRuntime.collectionFromBtn()

        XCTAssertTrue(collectionRuntime.state.showWrapper)
        XCTAssertTrue(collectionRuntime.state.showCollection)
    }

    @MainActor
    func testPickedUploadFileExecutesDirectUploadAndSendsSwapObjectRequest() async throws {
        let runtime = SalesmartlyRuntime()
        let transport = SalesmartlyTransportSpy()
        let uploadExecutor = SalesmartlyUploadExecutorSpy(
            nextFileURL: "http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png"
        )
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.setTransport(transport)
        runtime.setUploadExecutor(uploadExecutor)
        runtime.state.userToken = "token_1"
        runtime.state.localChatUserId = "chat_user_1"
        runtime.state.hasJoinRoom = true

        let pickedFile = SalesmartlyPickedUploadFile(
            name: "photo.png",
            data: Data([1, 2, 3]),
            isImage: true,
            isVideo: false,
            localURL: "file:///tmp/photo.png"
        )

        let didUpload = await runtime.uploadPickedFile(pickedFile)

        XCTAssertTrue(didUpload)
        XCTAssertEqual(uploadExecutor.requests.count, 1)
        XCTAssertEqual(uploadExecutor.requests.first?.file.name, "photo.png")
        XCTAssertEqual(uploadExecutor.requests.first?.fileData, Data([1, 2, 3]))
        XCTAssertEqual(runtime.state.messages.last?.message, "file:///tmp/photo.png")
        XCTAssertEqual(transport.requests.last?.path, "sys/project/project/swap-object-v2")

        let result = #"[{"id":"\#(try XCTUnwrap(runtime.state.messages.last?.tempId))","object":"media/a.png","url":"https://assets.example.com/preview.png","process":"","send_url":"https://send.example.com/a.png"}]"#
            .data(using: .utf8)!
            .base64EncodedString()
        transport.respond(
            [
                "data": [
                    "result": result,
                ],
            ],
            requestIndex: transport.requests.count - 1
        )

        XCTAssertEqual(runtime.sendMessageMap[try XCTUnwrap(runtime.state.messages.last?.cMId)]?.message, "https://send.example.com/a.png")
        XCTAssertEqual(runtime.sendAssetsList.last?["url"], "https://assets.example.com/preview.png")
        XCTAssertEqual(transport.requests.last?.eventName, "send-message")
        XCTAssertEqual(transport.requests.last?.payload["message"] as? String, "https://send.example.com/a.png")
    }

    @MainActor
    func testPickedUploadFileFailureMarksPlaceholderFailed() async throws {
        let runtime = SalesmartlyRuntime()
        let uploadExecutor = SalesmartlyUploadExecutorSpy(
            nextFileURL: "http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png",
            shouldFail: true
        )
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.setUploadExecutor(uploadExecutor)

        let pickedFile = SalesmartlyPickedUploadFile(
            name: "photo.png",
            data: Data([1, 2, 3]),
            isImage: true,
            isVideo: false,
            localURL: "file:///tmp/photo.png"
        )

        let didUpload = await runtime.uploadPickedFile(pickedFile)

        XCTAssertFalse(didUpload)
        XCTAssertEqual(uploadExecutor.requests.count, 1)
        XCTAssertTrue(try XCTUnwrap(runtime.state.messages.last?.mid).hasPrefix("fail_"))
    }

    func testUploadExecutionRequestAndDirectSuccessFollowWidgetUploadFlow() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(
            runtime.onUpload(
                SalesmartlyUploadFile(
                    name: "客户 photo.png",
                    size: 1_048_576,
                    isImage: true,
                    isVideo: false,
                    localURL: "blob:large-photo"
                ),
                tempId: "temp_upload_execute_1",
                clientExpandInfo: ["c_m_id": "upload_execute_client_1"]
            )
        )

        let request = try XCTUnwrap(
            runtime.makeUploadExecutionRequest(
                tempId: "temp_upload_execute_1",
                pluginId: "plugin_1",
                env: "chat",
                random: 12_345,
                nowMilliseconds: 1_779_900_123_456
            )
        )

        XCTAssertEqual(request.file.name, "客户 photo.png")
        XCTAssertEqual(request.type, "2")
        XCTAssertEqual(request.clientExpandInfo["c_m_id"], "upload_execute_client_1")
        XCTAssertTrue(request.compressionPlan.shouldCompress)
        XCTAssertEqual(request.compressionPlan.quality, 0.85)
        XCTAssertEqual(request.replaceName, "fa0f9df9c046ee0d989dbbbbb6cd67e5.png")
        XCTAssertEqual(request.uploadTimeoutMilliseconds, 150_000)
        XCTAssertEqual(request.uploadConfigPayload["module"], "chat")
        XCTAssertEqual(request.uploadConfigPayload["module_path"], "plugin/plugin_1/2")
        XCTAssertEqual(request.uploadConfigPayload["plugin_id"], "plugin_1")
        XCTAssertEqual(request.uploadConfigPayload["env"], "chat")
        XCTAssertEqual(request.uploadConfigPayload["platform"], "pc0")
        XCTAssertEqual(request.uploadConfigPayload["btype"], "mix_ads")

        let swapPayload = try XCTUnwrap(
            runtime.handleUploadDirectSuccess(
                tempId: "temp_upload_execute_1",
                fileURL: "http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png"
            )
        )
        XCTAssertEqual(
            swapPayload["object"] as? String,
            "nSph1nohMhH4rna8NSX8P3z+ruzV03XAtNcVN5OhBdHhtnIZrNohMhH9lCypyQzh1QXAtdyiyQaVr3V+B9O/f3mGyGat"
        )

        let result = #"[{"id":"temp_upload_execute_1","object":"media/a.png","url":"https://assets.example.com/preview.png","process":"","send_url":"https://send.example.com/a.png"}]"#
            .data(using: .utf8)!
            .base64EncodedString()

        XCTAssertTrue(
            runtime.handleUploadSwapObjectResult(
                tempId: "temp_upload_execute_1",
                fileURL: "http://mix-ads.oss-accelerate.aliyuncs.com/media/a.png",
                result: result
            )
        )
        XCTAssertNil(runtime.uploadTaskMap["temp_upload_execute_1"])
        XCTAssertEqual(runtime.sendMessageMap["upload_execute_client_1"]?.message, "https://send.example.com/a.png")
        XCTAssertEqual(runtime.sendAssetsList.last?["url"], "https://assets.example.com/preview.png")
    }

    func testQueueStatusPayloadAndReducersMatchWidgetPollingRules() async throws {
        let runtime = SalesmartlyRuntime()
        var queueAssignedCount = 0

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.push("onQueueAssigned") { _ in
            queueAssignedCount += 1
        }

        let payload = runtime.makeQueueStatusPayload(chatUserId: "chat_user_1")

        XCTAssertEqual(payload["chat_user_id"] as? String, "chat_user_1")

        XCTAssertTrue(runtime.applyQueueStatus(status: "waiting", queueCount: 3))
        XCTAssertEqual(runtime.state.queueStatus, "waiting")
        XCTAssertEqual(runtime.state.queueCount, 3)

        XCTAssertFalse(runtime.applyQueueStatus(status: "assigned", queueCount: 0))
        XCTAssertEqual(runtime.state.queueStatus, "")
        XCTAssertEqual(runtime.state.queueCount, 0)

        XCTAssertTrue(runtime.applyQueueStatus(status: "no_online_staff", queueCount: 0))
        XCTAssertEqual(runtime.state.queueStatus, "")
        XCTAssertEqual(runtime.state.queueCount, 0)

        runtime.setQueueWaiting(4)
        XCTAssertTrue(runtime.receiveNotice(noticeType: 3, pushTime: 1_779_860_002_000, chatUserId: "chat_user_1", nickname: "Ada"))
        XCTAssertEqual(runtime.state.queueStatus, "")
        XCTAssertEqual(runtime.state.queueCount, 0)
        XCTAssertEqual(queueAssignedCount, 1)
    }

    func testHumanServiceStateAndPayloadMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertTrue(runtime.handleSendMessageRequiresHumanService(sysUserId: "-1", humanServiceEnabled: true))
        XCTAssertTrue(runtime.state.showHumanService)
        XCTAssertFalse(runtime.state.showHumanMsg)
        XCTAssertFalse(runtime.state.showHumanTips)

        let payload = runtime.requestHumanService()

        XCTAssertEqual(payload["room_type"] as? Int, 6)

        runtime.closeHumanService()

        XCTAssertTrue(runtime.state.showHumanService)
        XCTAssertTrue(runtime.state.showHumanMsg)
        XCTAssertFalse(runtime.state.showHumanTips)

        runtime.hideJoinSessionTips()

        XCTAssertTrue(runtime.state.showHumanService)
        XCTAssertFalse(runtime.state.showHumanMsg)
        XCTAssertTrue(runtime.state.showHumanTips)

        runtime.hideHumanComponent()

        XCTAssertFalse(runtime.state.showHumanService)
        XCTAssertFalse(runtime.state.showHumanMsg)
        XCTAssertFalse(runtime.state.showHumanTips)

        XCTAssertFalse(runtime.handleSendMessageRequiresHumanService(sysUserId: "-1", humanServiceEnabled: false))
        XCTAssertFalse(runtime.state.showHumanService)
    }

    func testConversationNewMessageFlagMatchesWidgetScrollState() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        runtime.openChat()
        runtime.setConversationAtBottom(false)

        runtime.receiveMessage(
            sequenceId: "scroll_1",
            senderType: "2",
            msgType: "1",
            message: "Agent message while reading history",
            sendTime: 1_779_860_003_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertFalse(runtime.state.conversationAtBottom)
        XCTAssertTrue(runtime.state.conversationHasNewMessage)
        XCTAssertEqual(runtime.state.messages.last?.isRead, "1")
        XCTAssertEqual(runtime.state.unReadNum, 0)

        runtime.setConversationAtBottom(true)

        XCTAssertTrue(runtime.state.conversationAtBottom)
        XCTAssertFalse(runtime.state.conversationHasNewMessage)

        runtime.markConversationHasNewMessage()

        XCTAssertFalse(runtime.state.conversationHasNewMessage)

        runtime.setConversationAtBottom(false)
        runtime.markConversationHasNewMessage()

        XCTAssertTrue(runtime.state.conversationHasNewMessage)

        runtime.clearConversationNewMessage()

        XCTAssertFalse(runtime.state.conversationHasNewMessage)
    }

    func testLauncherUnreadPreviewPopupStateMatchesWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "0",
            channels: ["chat"],
            isLimit: false
        )

        runtime.receiveMessage(
            sequenceId: "notice_1",
            senderType: "2",
            msgType: "1",
            message: "First unread preview",
            sendTime: 1_779_860_010_000,
            chatUserId: "chat_user_1",
            senderName: "Ada",
            senderAvatar: "https://assets.example/avatar.png"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_1")
        XCTAssertEqual(runtime.state.lastNoticeMsg?.senderName, "Ada")
        XCTAssertEqual(runtime.state.lastNoticeMsg?.senderAvatar, "https://assets.example/avatar.png")
        XCTAssertTrue(runtime.showIconPopup())

        runtime.receiveMessage(
            sequenceId: "notice_2",
            senderType: "2",
            msgType: "1",
            message: "Second unread preview",
            sendTime: 1_779_860_011_000,
            chatUserId: "chat_user_1",
            senderName: "Grace",
            senderAvatar: "https://assets.example/grace.png"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_1")

        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "1",
            channels: ["chat"],
            isLimit: false
        )
        runtime.receiveMessage(
            sequenceId: "notice_3",
            senderType: "2",
            msgType: "11",
            message: #"{"type":"other"}"#,
            sendTime: 1_779_860_012_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_1")

        runtime.receiveMessage(
            sequenceId: "notice_4",
            senderType: "2",
            msgType: "11",
            message: #"{"type":"guide"}"#,
            sendTime: 1_779_860_013_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_4")

        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "0",
            channels: ["chat"],
            isLimit: false
        )
        runtime.receiveMessage(
            sequenceId: "notice_5",
            senderType: "2",
            msgType: "3",
            message: #"{"type":"default","payload":{"promotional_card":{"title":"Deal"}}}"#,
            sendTime: 1_779_860_014_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_5")

        runtime.receiveMessage(
            sequenceId: "notice_6",
            senderType: "2",
            msgType: "1",
            message: "Text after card",
            sendTime: 1_779_860_015_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_5")

        runtime.clearLastNoticeMsg()

        XCTAssertNil(runtime.state.lastNoticeMsg)
        XCTAssertFalse(runtime.showIconPopup())

        runtime.receiveMessage(
            sequenceId: "notice_7",
            senderType: "2",
            msgType: "1",
            message: "Open from popup",
            sendTime: 1_779_860_016_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertTrue(runtime.showIconPopup())

        runtime.openChatFromIconPopup()

        XCTAssertNil(runtime.state.lastNoticeMsg)
        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertFalse(runtime.showIconPopup())

        runtime.closeChat()
        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "1",
            channels: ["line"],
            isLimit: false
        )
        runtime.receiveMessage(
            sequenceId: "notice_8",
            senderType: "2",
            msgType: "1",
            message: "No chat channel",
            sendTime: 1_779_860_017_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.state.lastNoticeMsg?.id, "notice_8")
        XCTAssertFalse(runtime.showIconPopup())
    }

    func testLauncherUnreadPreviewDisplayTextMatchesWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "1",
            channels: ["chat"],
            isLimit: false
        )
        runtime.setIconPopupDisplayConfiguration(
            windowName: "Sales Team",
            showReceptionInfo: false
        )

        runtime.receiveMessage(
            sequenceId: "notice_display_1",
            senderType: "2",
            msgType: "1",
            message: "Hello\n   there",
            sendTime: 1_779_860_018_000,
            chatUserId: "chat_user_1",
            senderName: "Ada"
        )

        XCTAssertEqual(runtime.iconPopupPreviewTitle(), "Sales Team")
        XCTAssertEqual(runtime.iconPopupPreviewText(), "Hello there")

        runtime.setIconPopupDisplayConfiguration(
            windowName: "Sales Team",
            showReceptionInfo: true
        )

        XCTAssertEqual(runtime.iconPopupPreviewTitle(), "Ada")
    }

    func testLauncherUnreadPreviewComponentMappingMatchesWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "1",
            channels: ["chat"],
            isLimit: false
        )

        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .unknown)
        XCTAssertFalse(runtime.iconPopupPreviewNeedsPadding())
        XCTAssertFalse(runtime.iconPopupPreviewIsPromotionalCard())

        runtime.receiveMessage(
            sequenceId: "preview_image_1",
            senderType: "2",
            msgType: "2",
            message: "https://assets.example.com/a.png",
            sendTime: 1_779_860_020_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .image)
        XCTAssertTrue(runtime.iconPopupPreviewNeedsPadding())
        XCTAssertFalse(runtime.iconPopupPreviewIsPromotionalCard())

        runtime.clearLastNoticeMsg()
        runtime.receiveMessage(
            sequenceId: "preview_quick_1",
            senderType: "2",
            msgType: "21",
            message: #"{"payload":{"text":"Choose one","buttons":[{"text":"A","payload":"a"}]}}"#,
            sendTime: 1_779_860_021_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .quickReply)
        XCTAssertFalse(runtime.iconPopupPreviewNeedsPadding())

        runtime.clearLastNoticeMsg()
        runtime.receiveMessage(
            sequenceId: "preview_promo_1",
            senderType: "2",
            msgType: "3",
            message: #"{"payload":{"promotional_card":{"title":"Deal"}}}"#,
            sendTime: 1_779_860_022_000,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .template)
        XCTAssertTrue(runtime.iconPopupPreviewIsPromotionalCard())
    }

    func testLauncherUnreadPreviewNonTextSummaryMatchesWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.setIconPopupConfiguration(
            iconPopupEnabled: true,
            iconPopupType: "1",
            channels: ["chat"],
            isLimit: false
        )

        func receivePreview(_ sequenceId: String, msgType: String, message: String) {
            runtime.clearLastNoticeMsg()
            runtime.receiveMessage(
                sequenceId: sequenceId,
                senderType: "2",
                msgType: msgType,
                message: message,
                sendTime: 1_779_860_030_000,
                chatUserId: "chat_user_1"
            )
        }

        receivePreview("preview_file_1", msgType: "4", message: "https://cdn.example.com/files/report%20final.pdf?token=1")
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .file)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "report final.pdf")

        receivePreview("preview_email_1", msgType: "7", message: "{}")
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .email)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "您有一封邮件，请查收")

        receivePreview("preview_audio_1", msgType: "12", message: "https://cdn.example.com/voice.mp3")
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .unknown)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "")

        receivePreview(
            "preview_template_1",
            msgType: "3",
            message: #"{"type":"default","payload":{"text":"Template\n  text","attachments":[],"buttons":[]}}"#
        )
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .template)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "Template text")

        receivePreview("preview_score_1", msgType: "3", message: #"{"type":"invite_evalution","payload":{}}"#)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "您对本次服务满意吗？")

        receivePreview("preview_coupon_1", msgType: "3", message: #"{"payload":{"promotional_card":{"title":"Deal"}}}"#)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "收到1张优惠券")

        receivePreview("preview_ai_1", msgType: "11", message: #"{"type":"guide","data":[{"id":"q1","question":"Order"}]}"#)
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .ai)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "请选择以下您想咨询的内容")

        receivePreview(
            "preview_ai_2",
            msgType: "11",
            message: #"{"type":"reply","data":[{"context_type":"text","context":"AI\n reply"}]}"#
        )
        XCTAssertEqual(runtime.iconPopupPreviewText(), "AI reply")

        receivePreview("preview_quick_2", msgType: "21", message: #"{"payload":{"text":"Choose\n  one","buttons":[]}}"#)
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .quickReply)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "Choose one")

        receivePreview(
            "preview_product_1",
            msgType: "14",
            message: #"{"product_info":{"product_name":"Travel Bag","price":"12","currency_code":"USD"}}"#
        )
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .product)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "Travel Bag")

        receivePreview(
            "preview_media_text_1",
            msgType: "40",
            message: #"{"file_type":"image","file_url":"https://cdn.example.com/a.png","caption":"Look\n here"}"#
        )
        XCTAssertEqual(runtime.iconPopupPreviewComponent(), .mediaText)
        XCTAssertEqual(runtime.iconPopupPreviewText(), "Look here")

        receivePreview(
            "preview_media_text_2",
            msgType: "40",
            message: #"{"file_type":"document","file_url":"https://cdn.example.com/docs/catalog.pdf"}"#
        )
        XCTAssertEqual(runtime.iconPopupPreviewText(), "catalog.pdf")
    }

    func testChannelOrderingComponentsAndOpenCallbacksMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        var whatsappPayload: SalesmartlyPayload = [:]
        var messengerPayload: SalesmartlyPayload = [:]
        var telegramPayload: SalesmartlyPayload = [:]
        var emailPayload: SalesmartlyPayload = [:]
        var customPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.registerCallback("onOpenWhatsapp") { payload in
            whatsappPayload = payload
        }
        runtime.registerCallback("onOpenMessenger") { payload in
            messengerPayload = payload
        }
        runtime.registerCallback("onOpenTelegram") { payload in
            telegramPayload = payload
        }
        runtime.registerCallback("onOpenEmail") { payload in
            emailPayload = payload
        }
        runtime.registerCallback("onOpenCustom") { payload in
            customPayload = payload
        }

        XCTAssertEqual(
            runtime.makeChannelList(
                channels: ["line", "custom_2", "whatsapp", "telegram"],
                channelSort: []
            ),
            ["custom_2", "telegram", "whatsapp", "line"]
        )
        XCTAssertEqual(
            runtime.makeReverseChannelList(
                channels: ["line", "custom_2", "whatsapp", "telegram"],
                channelSort: []
            ),
            ["custom_2", "telegram", "whatsapp", "line"]
        )
        XCTAssertEqual(
            runtime.makeChannelList(
                channels: ["line", "custom_1", "telegram"],
                channelSort: ["telegram", "custom_1"]
            ),
            ["telegram", "custom_1"]
        )
        XCTAssertEqual(
            runtime.makeReverseChannelList(
                channels: ["line", "custom_1", "telegram"],
                channelSort: ["telegram", "custom_1"]
            ),
            ["custom_1", "telegram"]
        )
        XCTAssertEqual(runtime.channelComponentName(for: "lineApp"), "ChannelLineApp")
        XCTAssertEqual(runtime.channelComponentName(for: "custom_3"), "CustomEntry")
        XCTAssertEqual(runtime.channelComponentName(for: "unknown"), "")
        XCTAssertEqual(runtime.channelIconSize(for: "small"), 22)
        XCTAssertEqual(runtime.channelIconSize(for: "side"), 16)
        XCTAssertEqual(runtime.channelIconSize(for: "large"), 36)

        let whatsappURL = runtime.openWhatsappChannel(
            redirectURL: "https://wa.me/100",
            sendPageLink: "0",
            type: "3",
            prolusion: "Hello",
            sourceURL: "https://shop.example/products?a=1",
            whatsappLinkText: "Link:"
        )
        XCTAssertEqual(whatsappURL, "https://wa.me/100?text=Hello")
        XCTAssertEqual(whatsappPayload["linkUrl"] as? String, whatsappURL)

        let messengerURL = runtime.openMessengerChannel(
            redirectURL: "https://www.facebook.com/messages/t/page_1",
            isMobile: true
        )
        XCTAssertEqual(messengerURL, "https://m.me/page_1")
        XCTAssertEqual(messengerPayload["linkUrl"] as? String, messengerURL)

        let telegramURL = runtime.openTelegramChannel(
            redirectURL: "https://t.me/bot_1",
            linkParams: "start_1"
        )
        XCTAssertEqual(telegramURL, "https://t.me/bot_1?start=start_1")
        XCTAssertEqual(telegramPayload["linkUrl"] as? String, telegramURL)

        let mailtoURL = runtime.openEmailChannel(email: "support@example.com")
        XCTAssertEqual(mailtoURL, "mailto:support@example.com")
        XCTAssertEqual(emailPayload["email"] as? String, "support@example.com")

        let customURL = runtime.openCustomEntryChannel(
            id: "custom_1",
            type: "3",
            inputValue: "https://example.com/custom",
            open: true
        )
        XCTAssertEqual(customURL, "https://example.com/custom")
        XCTAssertEqual(customPayload["id"] as? String, "custom_1")
        XCTAssertEqual(customPayload["content"] as? String, "https://example.com/custom")

        let demoRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: demoRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .demo)
            )
        )

        XCTAssertNil(demoRuntime.openTelegramChannel(redirectURL: "https://t.me/bot_1", linkParams: "start_1"))
    }

    func testWhatsappGreetingCallbackMatchesWidgetCreateWhatsappGreetingRules() async throws {
        let runtime = SalesmartlyRuntime()
        var whatsappPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.registerCallback("onOpenWhatsapp") { payload in
            whatsappPayload = payload
        }

        let callback: SalesmartlyWhatsappGreetingCallback = { text in
            "\(text) from callback"
        }
        runtime.push(command: "createWhatsappGreeting", payload: callback)

        let callbackURL = runtime.openWhatsappChannel(
            redirectURL: "https://wa.me/100",
            sendPageLink: "1",
            type: "3",
            prolusion: "Hello",
            sourceURL: "https://shop.example/products?a=1",
            whatsappLinkText: "Link:"
        )

        XCTAssertEqual(
            callbackURL,
            "https://wa.me/100?text=Link: https%3A%2F%2Fshop.example%2Fproducts%3Fa%3D1 from callback"
        )
        XCTAssertEqual(whatsappPayload["linkUrl"] as? String, callbackURL)

        let emptyCallback: SalesmartlyWhatsappGreetingCallback = { _ in "" }
        runtime.push(command: "createWhatsappGreeting", payload: emptyCallback)

        let fallbackURL = runtime.openWhatsappChannel(
            redirectURL: "https://wa.me/100",
            sendPageLink: "0",
            type: "3",
            prolusion: "Hello",
            sourceURL: "https://shop.example/products?a=1",
            whatsappLinkText: "Link:"
        )

        XCTAssertEqual(fallbackURL, "https://wa.me/100?text=Hello")
    }

    func testRemainingChannelOpenCallbacksMatchWidgetRules() async throws {
        let runtime = SalesmartlyRuntime()
        var linePayload: SalesmartlyPayload = [:]
        var lineAppPayload: SalesmartlyPayload = [:]
        var instagramPayload: SalesmartlyPayload = [:]
        var tikTokPayload: SalesmartlyPayload = [:]
        var weixinPayload: SalesmartlyPayload = [:]
        var vkontaktePayload: SalesmartlyPayload = [:]
        var zaloPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.registerCallback("onOpenLine") { payload in
            linePayload = payload
        }
        runtime.registerCallback("onOpenLineApp") { payload in
            lineAppPayload = payload
        }
        runtime.registerCallback("onOpenInstagram") { payload in
            instagramPayload = payload
        }
        runtime.registerCallback("onOpenTikTok") { payload in
            tikTokPayload = payload
        }
        runtime.registerCallback("onOpenWeixin") { payload in
            weixinPayload = payload
        }
        runtime.registerCallback("onOpenVKontakte") { payload in
            vkontaktePayload = payload
        }
        runtime.registerCallback("onOpenZalo") { payload in
            zaloPayload = payload
        }

        let mobileLineURL = runtime.openLineChannel(
            redirectURL: "https://line.me/R/ti/p/@account",
            botURL: "https://line.me/R/ti/p/@bot",
            type: "1",
            enableBrowseURL: "1",
            liffURL: "https://liff.line.me/abc123",
            pluginId: "plugin_1",
            sourceURL: "https://shop.example/products?a=1",
            uid: "uid_1",
            isInLineApp: false,
            isMobile: true
        )
        XCTAssertEqual(
            mobileLineURL,
            "https://line.me/R/app/abc123?plugin_id=plugin_1&current_url=https%3A%2F%2Fshop.example%2Fproducts%3Fa%3D1&uid=uid_1"
        )
        XCTAssertEqual(linePayload["linkUrl"] as? String, "https://line.me/R/ti/p/@bot")

        let inLineAppURL = runtime.openLineChannel(
            redirectURL: "https://line.me/R/ti/p/@account",
            botURL: "https://line.me/R/ti/p/@bot",
            type: "1",
            enableBrowseURL: "1",
            liffURL: "https://liff.line.me/abc123",
            pluginId: "plugin_1",
            sourceURL: "https://shop.example/products?a=1",
            uid: "uid_1",
            isInLineApp: true,
            isMobile: true
        )
        XCTAssertEqual(
            inLineAppURL,
            "https://liff.line.me/abc123?plugin_id=plugin_1&current_url=https%3A%2F%2Fshop.example%2Fproducts%3Fa%3D1&uid=uid_1"
        )

        XCTAssertEqual(runtime.openLineAppChannel(redirectURL: "https://line.example/app"), "https://line.example/app")
        XCTAssertEqual(runtime.openInstagramChannel(redirectURL: "https://instagram.com/acct"), "https://instagram.com/acct")
        XCTAssertEqual(runtime.openTikTokChannel(redirectURL: "https://tiktok.com/@acct"), "https://tiktok.com/@acct")
        XCTAssertEqual(runtime.openWeixinChannel(kfURL: "https://work.weixin.qq.com/kf"), "https://work.weixin.qq.com/kf")
        XCTAssertEqual(runtime.openVKontakteChannel(redirectURL: "https://vk.com/acct"), "https://vk.com/acct")
        XCTAssertEqual(runtime.openZaloChannel(redirectURL: "https://zalo.me/acct"), "https://zalo.me/acct")
        XCTAssertEqual(lineAppPayload["linkUrl"] as? String, "https://line.example/app")
        XCTAssertEqual(instagramPayload["linkUrl"] as? String, "https://instagram.com/acct")
        XCTAssertEqual(tikTokPayload["linkUrl"] as? String, "https://tiktok.com/@acct")
        XCTAssertEqual(weixinPayload["linkUrl"] as? String, "https://work.weixin.qq.com/kf")
        XCTAssertEqual(vkontaktePayload["linkUrl"] as? String, "https://vk.com/acct")
        XCTAssertEqual(zaloPayload["linkUrl"] as? String, "https://zalo.me/acct")

        let demoRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: demoRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(mode: .demo)
            )
        )

        XCTAssertNil(demoRuntime.openInstagramChannel(redirectURL: "https://instagram.com/acct"))
    }

    /// 对齐 Android `handleChannelClick`：统一入口覆盖 chat、Launcher Line 页、外部 URL 和回调分发。
    func testUnifiedChannelClickDispatchesAndroidChannelSemantics() async throws {
        let runtime = SalesmartlyRuntime()
        var emailPayload: SalesmartlyPayload = [:]
        var messengerPayload: SalesmartlyPayload = [:]
        var lineAppPayload: SalesmartlyPayload = [:]
        var weixinPayload: SalesmartlyPayload = [:]
        var vkontaktePayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        runtime.state.integrationType = "column"
        runtime.setLauncherContext(showSideBar: false, showIcon: true)
        runtime.state.channelOpenConfigs = [
            "line": [
                "redirect_url": "https://line.me/R/ti/p/@account",
                "bot_url": "https://line.me/R/ti/p/@bot",
                "type": "1",
                "enable_browse_url": "1",
                "liff_url": "https://liff.line.me/abc123",
                "qr_code": "https://qr.example/line.png",
            ],
            "email": ["email": "support@example.com"],
            "messenger": ["redirect_url": "https://www.facebook.com/messages/t/page_1"],
            "lineApp": ["redirect_url": "https://line.example/app"],
            "weixin": ["kf_url": "https://work.weixin.qq.com/kf"],
            "vkontakte": ["redirect_url": "https://vk.com/acct"],
        ]
        runtime.registerCallback("onOpenEmail") { payload in
            emailPayload = payload
        }
        runtime.registerCallback("onOpenMessenger") { payload in
            messengerPayload = payload
        }
        runtime.registerCallback("onOpenLineApp") { payload in
            lineAppPayload = payload
        }
        runtime.registerCallback("onOpenWeixin") { payload in
            weixinPayload = payload
        }
        runtime.registerCallback("onOpenVKontakte") { payload in
            vkontaktePayload = payload
        }

        XCTAssertNil(runtime.handleChannelClick("line", sourceURL: "https://shop.example/products?a=1"))
        XCTAssertTrue(runtime.state.showLinePage)

        XCTAssertNil(runtime.handleChannelClick("chat"))
        XCTAssertTrue(runtime.state.showWrapper)
        XCTAssertEqual(runtime.state.currentView, .chat)

        runtime.closeChat()
        XCTAssertEqual(runtime.handleChannelClick("email"), "mailto:support@example.com")
        XCTAssertEqual(emailPayload["email"] as? String, "support@example.com")
        XCTAssertEqual(runtime.handleChannelClick("messenger", isMobile: true), "https://m.me/page_1")
        XCTAssertEqual(messengerPayload["linkUrl"] as? String, "https://m.me/page_1")
        XCTAssertEqual(runtime.handleChannelClick("lineApp"), "https://line.example/app")
        XCTAssertEqual(lineAppPayload["linkUrl"] as? String, "https://line.example/app")
        XCTAssertEqual(runtime.handleChannelClick("weixin"), "https://work.weixin.qq.com/kf")
        XCTAssertEqual(weixinPayload["linkUrl"] as? String, "https://work.weixin.qq.com/kf")
        XCTAssertEqual(runtime.handleChannelClick("vkontakte"), "https://vk.com/acct")
        XCTAssertEqual(vkontaktePayload["linkUrl"] as? String, "https://vk.com/acct")
    }

    /// 对齐 Android `customEntryPopup`：自定义入口仅在非 demo、聊天窗已打开且配置存在时展示文字/图片弹层。
    func testCustomEntryPopupShowsTextImagePreviewAndClosesLikeAndroid() async throws {
        let runtime = SalesmartlyRuntime()
        var customPayload: SalesmartlyPayload = [:]

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.registerCallback("onOpenCustom") { payload in
            customPayload = payload
        }
        runtime.state.channelOpenConfigs = [
            "custom_1": ["type": "1", "input_value": "Text entry"],
            "custom_2": ["type": "2", "input_value": "https://cdn.example.com/entry.png"],
        ]

        XCTAssertFalse(runtime.openCustomEntry("custom_1"))
        XCTAssertNil(runtime.state.customEntryPopup)

        runtime.openChat()
        XCTAssertTrue(runtime.openCustomEntry("custom_1"))
        XCTAssertEqual(runtime.state.customEntryPopup?.id, "custom_1")
        XCTAssertEqual(runtime.state.customEntryPopup?.type, "1")
        XCTAssertEqual(runtime.state.customEntryPopup?.inputValue, "Text entry")
        XCTAssertEqual(customPayload["id"] as? String, "custom_1")
        XCTAssertEqual(customPayload["content"] as? String, "Text entry")

        runtime.closeCustomEntryPopup()
        XCTAssertNil(runtime.state.customEntryPopup)
        XCTAssertNil(runtime.state.openCustomEntryId)

        XCTAssertTrue(runtime.openCustomEntry("custom_2"))
        XCTAssertEqual(runtime.state.customEntryPopup?.type, "2")
        XCTAssertTrue(runtime.previewCustomEntryPopupImage())
        XCTAssertEqual(runtime.state.customEntryPreviewImageURL, "https://cdn.example.com/entry.png")
        runtime.closeCustomEntryPopupImagePreview()
        XCTAssertNil(runtime.state.customEntryPreviewImageURL)

        let demoRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: demoRuntime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(mode: .demo)
            )
        )
        demoRuntime.state.showWrapper = true
        demoRuntime.state.channelOpenConfigs = ["custom_1": ["type": "1", "input_value": "Text entry"]]

        XCTAssertFalse(demoRuntime.openCustomEntry("custom_1"))
        XCTAssertNil(demoRuntime.state.customEntryPopup)
    }

    func testLinePageLauncherStateMatchesWidgetLineClickRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        runtime.setLauncherContext(showSideBar: false, showIcon: true)

        XCTAssertFalse(
            runtime.handleLineChannelClick(
                hasQRCode: true,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertTrue(runtime.state.showLinePage)

        XCTAssertFalse(
            runtime.handleLineChannelClick(
                hasQRCode: true,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertFalse(runtime.state.showLinePage)

        runtime.openLinePage()

        XCTAssertTrue(
            runtime.handleLineChannelClick(
                hasQRCode: false,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertFalse(runtime.state.showLinePage)

        runtime.openLinePage()
        runtime.setLauncherContext(showSideBar: true, showIcon: true)

        XCTAssertTrue(
            runtime.handleLineChannelClick(
                hasQRCode: true,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertFalse(runtime.state.showLinePage)

        runtime.setLauncherContext(showSideBar: false, showIcon: true)
        runtime.openLinePage()
        runtime.openChat()
        XCTAssertTrue(
            runtime.applyLinePageVisibilityRules(
                hasQRCode: true,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertFalse(runtime.state.showLinePage)

        runtime.openLinePage()
        XCTAssertTrue(
            runtime.applyLinePageVisibilityRules(
                hasQRCode: false,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertFalse(runtime.state.showLinePage)
    }

    func testDemoModeLineClickKeepsLinePageClosedLikeWidget() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "plugin_1",
                setting: SalesmartlySetting(mode: .demo)
            )
        )

        runtime.setLauncherContext(showSideBar: false, showIcon: true)

        XCTAssertFalse(
            runtime.handleLineChannelClick(
                hasQRCode: true,
                sidebarShow: false,
                isColumnIntegration: true
            )
        )
        XCTAssertFalse(runtime.state.showLinePage)
    }

    func testUserCommandsUpdateSession() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )

        SalesmartlyChat.setLoginInfo(
            LoginInfo(
                userId: "user-1",
                userName: "Ada",
                language: "en-US",
                phone: "10086",
                email: "ada@example.com",
                description: "VIP",
                labelNames: ["paid"],
                customFieldsExt: ["level": "gold"]
            )
        )
        SalesmartlyChat.setUserInfo(["plan": "pro"])

        XCTAssertEqual(runtime.state.loginInfo?.userId, "user-1")
        XCTAssertEqual(runtime.state.userInfo["plan"], "pro")
        XCTAssertEqual(runtime.state.userInfoJSONString, #"{"plan":"pro"}"#)

        SalesmartlyChat.clearUser()

        XCTAssertNil(runtime.state.loginInfo)
        XCTAssertTrue(runtime.state.userInfo.isEmpty)
        XCTAssertEqual(runtime.state.userInfoJSONString, "")
    }

    func testSetUserInfoSerializesWidgetUserInfoPayload() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        let payload: SalesmartlyPayload = [
            "age": 3,
            "plan": "pro",
            "tags": ["vip", "paid"],
        ]
        SalesmartlyChat.setUserInfo(payload)

        XCTAssertEqual(runtime.state.userInfo["plan"], "pro")
        XCTAssertNil(runtime.state.userInfo["age"])

        let data = try XCTUnwrap(runtime.state.userInfoJSONString.data(using: .utf8))
        let userInfo = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(userInfo["age"] as? Int, 3)
        XCTAssertEqual(userInfo["plan"] as? String, "pro")
        XCTAssertEqual(userInfo["tags"] as? [String], ["vip", "paid"])

        SalesmartlyChat.push(command: "setUserInfo", payload: ["tier": "gold"] as SalesmartlyPayload)
        XCTAssertEqual(runtime.state.userInfoJSONString, #"{"tier":"gold"}"#)
    }

    func testSetUserDataPayloadAggregatesWidgetLoginAndUserInfoFields() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.setLoginInfo(
            LoginInfo(
                userId: "user-1",
                userName: "Ada",
                language: "en-US",
                phone: "10086",
                email: "ada@example.com",
                description: "VIP buyer",
                labelNames: ["paid", "vip"],
                customFieldsExt: ["level": "gold"]
            )
        )
        SalesmartlyChat.setUserInfo(["plan": "pro", "tier": "gold"] as SalesmartlyPayload)

        let payload = runtime.makeSetUserDataPayload()

        XCTAssertEqual(payload["user_id"] as? String, "user-1")
        XCTAssertEqual(payload["user_name"] as? String, "Ada")
        XCTAssertEqual(payload["language"] as? String, "en-US")
        XCTAssertEqual(payload["phone"] as? String, "10086")
        XCTAssertEqual(payload["email"] as? String, "ada@example.com")
        XCTAssertEqual(payload["description"] as? String, "VIP buyer")
        XCTAssertEqual(payload["user_info"] as? String, #"{"plan":"pro","tier":"gold"}"#)
        XCTAssertEqual(payload["label_names"] as? String, #"["paid","vip"]"#)
        XCTAssertEqual(payload["custom_fields_ext"] as? String, #"{"level":"gold"}"#)
    }

    func testCreateUserPayloadMatchesWidgetGuestTokenParams() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .preview, flowId: "flow_1")
            )
        )
        SalesmartlyChat.setLoginInfo(
            LoginInfo(
                phone: "10086",
                email: "ada@example.com",
                description: "VIP buyer",
                labelNames: ["paid", "vip"],
                customFieldsExt: ["level": "gold"]
            )
        )

        let payload = runtime.makeCreateUserPayload(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1"
        )
        let dataString = try XCTUnwrap(payload["data"] as? String)
        let data = try XCTUnwrap(Data(base64Encoded: dataString))
        let paramsData = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(payload["source_url"] as? String, "https://shop.example/products")
        XCTAssertEqual(payload["ua"] as? String, "Safari")
        XCTAssertEqual(payload["language"] as? String, "en-US")
        XCTAssertEqual(payload["user_id"] as? String, "guest_1")
        XCTAssertEqual(payload["is_sandbox"] as? Int, 1)
        XCTAssertEqual(payload["before_source_url"] as? String, "https://google.example/search")
        XCTAssertEqual(payload["label_names"] as? String, #"["paid","vip"]"#)
        XCTAssertEqual(payload["custom_fields_ext"] as? String, #"{"level":"gold"}"#)
        XCTAssertEqual(payload["from"] as? String, #"{"key":"flow_test","value":"flow_1"}"#)
        XCTAssertEqual(paramsData["phone"], "10086")
        XCTAssertEqual(paramsData["email"], "ada@example.com")
        XCTAssertEqual(paramsData["description"], "VIP buyer")
    }

    func testCreateUserPayloadMatchesWidgetKnownUserTokenParams() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(
            config: SalesmartlyConfig(
                license: "YOUR_LICENSE",
                setting: SalesmartlySetting(mode: .chat)
            )
        )
        SalesmartlyChat.setLoginInfo(
            LoginInfo(
                userId: "user-1",
                userName: "Ada",
                language: "fr",
                phone: "10086",
                email: "ada@example.com",
                description: "VIP buyer",
                labelNames: ["paid", "vip"],
                customFieldsExt: ["level": "gold"]
            )
        )

        let payload = runtime.makeCreateUserPayload(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1"
        )
        let dataString = try XCTUnwrap(payload["data"] as? String)
        let data = try XCTUnwrap(Data(base64Encoded: dataString))
        let paramsData = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(payload["source_url"] as? String, "https://shop.example/products")
        XCTAssertEqual(payload["ua"] as? String, "Safari")
        XCTAssertEqual(payload["user_id"] as? String, "user-1")
        XCTAssertEqual(payload["user_name"] as? String, "Ada")
        XCTAssertEqual(payload["language"] as? String, "fr")
        XCTAssertEqual(payload["phone"] as? String, "10086")
        XCTAssertEqual(payload["email"] as? String, "ada@example.com")
        XCTAssertNil(payload["is_sandbox"])
        XCTAssertNil(payload["before_source_url"])
        XCTAssertNil(payload["label_names"])
        XCTAssertNil(payload["custom_fields_ext"])
        XCTAssertNil(payload["from"])
        XCTAssertEqual(paramsData["phone"], "10086")
        XCTAssertEqual(paramsData["email"], "ada@example.com")
        XCTAssertEqual(paramsData["description"], "VIP buyer")
    }

    func testCreateUserTransportRequestUsesWidgetCreateUserEndpoint() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))

        let request = runtime.makeCreateUserTransportRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1"
        )

        XCTAssertEqual(request.kind, .http)
        XCTAssertEqual(request.path, "chat/msg-user/create-user")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.payload["user_id"] as? String, "guest_1")
    }

    func testLocalStorageKeysMatchWidgetGetLocalKeyRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))

        let guestKeys = runtime.makeLocalStorageKeys()
        XCTAssertEqual(guestKeys.tokenKey, "salesmartly_p_plugin_1_token")
        XCTAssertEqual(guestKeys.tokenDateKey, "salesmartly_p_plugin_1_token_date")
        XCTAssertEqual(guestKeys.conversationKey, "salesmartly_p_plugin_1_list")
        XCTAssertEqual(guestKeys.newUserKey, "salesmartly_p_plugin_1_n_u")
        XCTAssertEqual(guestKeys.userInfoKey, "salesmartly_p_plugin_1_u_i")
        XCTAssertEqual(guestKeys.guestUUIDKey, "salesmartly_p_plugin_1_g_uid")
        XCTAssertEqual(guestKeys.autoOpenKey, "salesmartly_p_plugin_1_a_o")
        XCTAssertEqual(guestKeys.autoOpenLastKey, "salesmartly_p_plugin_1_a_o_last")
        XCTAssertEqual(guestKeys.customFieldsLocalMapKey, "salesmartly_p_plugin_1_custom_fields_local_map")

        let explicitUserKeys = runtime.makeLocalStorageKeys(userId: "user_1")
        XCTAssertEqual(explicitUserKeys.tokenKey, "salesmartly_p_plugin_1_user_1_token")
        XCTAssertEqual(explicitUserKeys.tokenDateKey, "salesmartly_p_plugin_1_user_1_token_date")
        XCTAssertEqual(explicitUserKeys.conversationKey, "salesmartly_p_plugin_1_user_1_list")
        XCTAssertEqual(explicitUserKeys.newUserKey, "salesmartly_p_plugin_1_user_1_n_u")
        XCTAssertEqual(explicitUserKeys.userInfoKey, "salesmartly_p_plugin_1_user_1_u_i")
        XCTAssertEqual(explicitUserKeys.customFieldsLocalMapKey, "salesmartly_p_plugin_1_user_1_custom_fields_local_map")

        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "user_2"))
        let currentUserKeys = runtime.makeLocalStorageKeys()
        XCTAssertEqual(currentUserKeys.tokenKey, "salesmartly_p_plugin_1_user_2_token")
        XCTAssertEqual(currentUserKeys.userInfoKey, "salesmartly_p_plugin_1_user_2_u_i")

        SalesmartlyChat.clearUser()
        let clearedKeys = runtime.makeLocalStorageKeys()
        XCTAssertEqual(clearedKeys.tokenKey, "salesmartly_p_plugin_1_token")
        XCTAssertEqual(clearedKeys.userInfoKey, "salesmartly_p_plugin_1_u_i")
    }

    func testLocalUserStateLoadsWidgetTokenAndChatUserRecord() async throws {
        let runtime = SalesmartlyRuntime()
        let store = SalesmartlyLocalStoreSpy()
        store.values["salesmartly_p_local_plugin_1_token"] = "token_1"
        store.values["salesmartly_p_local_plugin_1_u_i"] = #"{"chat_user_id":"chat_user_1","info":{"name":"Ada"}}"#

        runtime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "local_plugin_1"))

        XCTAssertEqual(runtime.state.userToken, "token_1")
        XCTAssertFalse(runtime.state.isNewUser)
        XCTAssertEqual(runtime.state.localChatUserId, "chat_user_1")
    }

    func testConversationPersistsAndRestoresWidgetLocalList() async throws {
        let runtime = SalesmartlyRuntime()
        let store = SalesmartlyLocalStoreSpy()
        runtime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "local_plugin_conversation"))
        let keys = runtime.makeLocalStorageKeys()

        runtime.receiveMessage(
            sequenceId: "server_1",
            senderType: "2",
            msgType: "1",
            message: "Persisted",
            sendTime: 1_779_860_000_000,
            chatUserId: "chat_user_1",
            senderName: "Ada"
        )

        let storedData = try XCTUnwrap(store.values[keys.conversationKey]?.data(using: .utf8))
        let storedList = try XCTUnwrap(JSONSerialization.jsonObject(with: storedData) as? [SalesmartlyPayload])
        XCTAssertEqual(storedList.first?["id"] as? String, "server_1")
        XCTAssertEqual(storedList.first?["message"] as? String, "Persisted")

        let nextRuntime = SalesmartlyRuntime()
        nextRuntime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: nextRuntime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "local_plugin_conversation"))

        XCTAssertEqual(nextRuntime.state.messages.map(\.id), ["server_1"])
        XCTAssertEqual(nextRuntime.state.messages.first?.message, "Persisted")
        XCTAssertEqual(nextRuntime.state.messages.first?.senderName, "Ada")
    }

    func testCreateUserResponsePersistsWidgetLocalRecordAndNewUserMarker() async throws {
        let runtime = SalesmartlyRuntime()
        let store = SalesmartlyLocalStoreSpy()
        runtime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "local_plugin_2"))
        let keys = runtime.makeLocalStorageKeys()
        store.values[keys.userInfoKey] = #"{"info":{"phone":"10086"}}"#
        store.values[keys.newUserKey] = "1"

        _ = runtime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 20_000
        )
        let token = runtime.handleCreateUserTransportResponse(
            [
                "data": [
                    "data": [
                        "token": "token_1",
                        "chat_user_id": "chat_user_1",
                        "is_new_user": "1",
                    ],
                ],
            ],
            nowMilliseconds: 21_000
        )

        XCTAssertEqual(token, "token_1")
        XCTAssertEqual(store.values[keys.tokenKey], "token_1")
        XCTAssertEqual(store.values[keys.tokenDateKey], "21000")
        XCTAssertTrue(store.removedKeys.contains(keys.newUserKey))
        let recordData = try XCTUnwrap(store.values[keys.userInfoKey]?.data(using: .utf8))
        let record = try XCTUnwrap(JSONSerialization.jsonObject(with: recordData) as? [String: Any])
        XCTAssertEqual(record["chat_user_id"] as? String, "chat_user_1")
        XCTAssertEqual(record["create_user_last_time"] as? String, "21000")
        let info = try XCTUnwrap(record["info"] as? [String: String])
        XCTAssertEqual(info["phone"], "10086")
    }

    func testCreateUserResponseAcceptsWidgetTopLevelDataShape() async throws {
        let runtime = SalesmartlyRuntime()
        let store = SalesmartlyLocalStoreSpy()
        runtime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "local_plugin_top_level"))
        let keys = runtime.makeLocalStorageKeys()

        let token = runtime.handleCreateUserTransportResponse(
            [
                "data": [
                    "token": "token_top_level",
                    "chat_user_id": "chat_user_top_level",
                    "is_new_user": "0",
                ] as SalesmartlyPayload,
            ],
            nowMilliseconds: 22_000
        )

        XCTAssertEqual(token, "token_top_level")
        XCTAssertEqual(runtime.state.userToken, "token_top_level")
        XCTAssertEqual(runtime.state.localChatUserId, "chat_user_top_level")
        XCTAssertFalse(runtime.state.isNewUser)
        XCTAssertEqual(store.values[keys.tokenKey], "token_top_level")
    }

    func testClearUserDataMatchesWidgetGuestLocalCleanupRules() async throws {
        let runtime = SalesmartlyRuntime()
        let store = SalesmartlyLocalStoreSpy()
        runtime.setLocalStore(store)
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "local_plugin_3"))
        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "user_1"))
        runtime.state.userToken = "guest_token_1"
        let guestKeys = runtime.makeLocalStorageKeys(userId: "")
        store.values[guestKeys.tokenKey] = "guest_token_1"
        store.values[guestKeys.conversationKey] = "conversation"
        store.values[guestKeys.userInfoKey] = #"{"chat_user_id":"chat_user_1"}"#
        store.values[guestKeys.guestUUIDKey] = "guest_uuid_1"
        store.values[guestKeys.autoOpenLastKey] = "1"
        store.values[guestKeys.newUserKey] = "1"

        SalesmartlyChat.clearUser()

        XCTAssertNil(runtime.state.loginInfo)
        XCTAssertEqual(runtime.state.userToken, "")
        XCTAssertTrue(runtime.state.isNewUser)
        XCTAssertTrue(store.removedKeys.contains(guestKeys.conversationKey))
        XCTAssertTrue(store.removedKeys.contains(guestKeys.userInfoKey))
        XCTAssertTrue(store.removedKeys.contains(guestKeys.guestUUIDKey))
        XCTAssertTrue(store.removedKeys.contains(guestKeys.autoOpenLastKey))
        XCTAssertTrue(store.removedKeys.contains(guestKeys.newUserKey))
        XCTAssertEqual(runtime.makeLocalStorageKeys().tokenKey, guestKeys.tokenKey)
    }

    func testCreateUserTokenRequestDecisionMatchesWidgetUseLocalCacheAndDelayRules() async throws {
        let runtime = SalesmartlyRuntime(state: ChatRuntimeState(userToken: "guest_token_1"))
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))

        let cachedGuestDecision = runtime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 10_000
        )
        XCTAssertEqual(cachedGuestDecision.cachedToken, "guest_token_1")
        XCTAssertNil(cachedGuestDecision.request)

        let knownUserRuntime = SalesmartlyRuntime(
            state: ChatRuntimeState(createUserTokenSavedDateMilliseconds: 10_000)
        )
        SalesmartlyChat.reset(runtime: knownUserRuntime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))
        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "user-1", userName: "Ada", language: "en-US"))
        let requestDecision = knownUserRuntime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 11_500
        )
        let request = try XCTUnwrap(requestDecision.request)
        XCTAssertNil(requestDecision.cachedToken)
        XCTAssertEqual(requestDecision.delayMilliseconds, 1_500)
        XCTAssertEqual(request.path, "chat/msg-user/create-user")
        XCTAssertTrue(knownUserRuntime.state.isCreateUserTokenRequestActive)
        XCTAssertEqual(knownUserRuntime.state.createUserTokenPadParams, request.payloadJSONString())
        XCTAssertEqual(knownUserRuntime.state.createUserTokenRequestDateMilliseconds, 11_500)

        let duplicateDecision = knownUserRuntime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 12_000
        )
        XCTAssertNil(duplicateDecision.cachedToken)
        XCTAssertNil(duplicateDecision.request)
        XCTAssertEqual(duplicateDecision.delayMilliseconds, 0)
    }

    func testCreateUserTransportResponseUpdatesWidgetTokenStateAndFailureResetsPad() async throws {
        let runtime = SalesmartlyRuntime()
        runtime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))

        let requestDecision = runtime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 20_000
        )
        XCTAssertNotNil(requestDecision.request)

        let token = runtime.handleCreateUserTransportResponse(
            [
                "data": [
                    "data": [
                        "token": "token_1",
                        "chat_user_id": "chat_user_1",
                        "is_new_user": "1",
                    ],
                ],
            ],
            nowMilliseconds: 21_000
        )

        XCTAssertEqual(token, "token_1")
        XCTAssertEqual(runtime.state.userToken, "token_1")
        XCTAssertEqual(runtime.state.createUserTokenPadToken, "token_1")
        XCTAssertFalse(runtime.state.isCreateUserTokenRequestActive)
        XCTAssertEqual(runtime.state.createUserTokenSavedDateMilliseconds, 21_000)
        XCTAssertEqual(runtime.state.localChatUserId, "chat_user_1")
        XCTAssertTrue(runtime.state.isNewUser)
        XCTAssertEqual(runtime.state.createUserLastTimeMilliseconds, 21_000)

        let cachedDecision = runtime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 22_000
        )
        XCTAssertEqual(cachedDecision.cachedToken, "token_1")
        XCTAssertNil(cachedDecision.request)

        let dispatchRuntime = SalesmartlyRuntime()
        dispatchRuntime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: dispatchRuntime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))
        let spy = SalesmartlyTransportSpy()
        dispatchRuntime.setTransport(spy)
        _ = dispatchRuntime.sendCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 23_000
        )
        XCTAssertEqual(spy.requests.count, 1)
        spy.respond(
            [
                "data": [
                    "data": [
                        "token": "token_2",
                        "chat_user_id": "chat_user_2",
                        "is_new_user": "0",
                    ],
                ],
            ],
            requestIndex: 0
        )
        XCTAssertEqual(dispatchRuntime.state.userToken, "token_2")
        XCTAssertEqual(dispatchRuntime.state.localChatUserId, "chat_user_2")
        XCTAssertFalse(dispatchRuntime.state.isNewUser)

        let failedRuntime = SalesmartlyRuntime()
        failedRuntime.setLocalStore(SalesmartlyLocalStoreSpy())
        SalesmartlyChat.reset(runtime: failedRuntime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "YOUR_LICENSE"))
        _ = failedRuntime.prepareCreateUserTokenRequest(
            sourceURL: "https://shop.example/products",
            userAgent: "Safari",
            navigatorLanguage: "en-US",
            beforeSourceURL: "https://google.example/search",
            guestUserId: "guest_1",
            nowMilliseconds: 30_000
        )

        XCTAssertEqual(failedRuntime.handleCreateUserTransportFailure(), "")
        XCTAssertFalse(failedRuntime.state.isCreateUserTokenRequestActive)
        XCTAssertEqual(failedRuntime.state.createUserTokenPadParams, "")
        XCTAssertEqual(failedRuntime.state.createUserTokenPadToken, "")
    }

    func testUserLocalKeysMatchWidgetGetLocalKeyRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))

        let guestKeys = runtime.makeUserLocalKeys()

        XCTAssertEqual(guestKeys.tokenKey, "salesmartly_p_plugin_1_token")
        XCTAssertEqual(guestKeys.tokenDateKey, "salesmartly_p_plugin_1_token_date")
        XCTAssertEqual(guestKeys.conversationKey, "salesmartly_p_plugin_1_list")
        XCTAssertEqual(guestKeys.newUserKey, "salesmartly_p_plugin_1_n_u")
        XCTAssertEqual(guestKeys.userInfoKey, "salesmartly_p_plugin_1_u_i")
        XCTAssertEqual(guestKeys.guestUUIDKey, "salesmartly_p_plugin_1_g_uid")
        XCTAssertEqual(guestKeys.autoOpenLastKey, "salesmartly_p_plugin_1_a_o_last")
        XCTAssertEqual(runtime.state.tokenKey, guestKeys.tokenKey)

        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "user-1"))

        XCTAssertEqual(runtime.state.userType, "user")
        XCTAssertEqual(runtime.state.localUserId, "user-1")
        XCTAssertEqual(runtime.state.tokenKey, "salesmartly_p_plugin_1_user-1_token")
        XCTAssertEqual(runtime.state.tokenDateKey, "salesmartly_p_plugin_1_user-1_token_date")
        XCTAssertEqual(runtime.state.conversationKey, "salesmartly_p_plugin_1_user-1_list")
        XCTAssertEqual(runtime.state.newUserKey, "salesmartly_p_plugin_1_user-1_n_u")
        XCTAssertEqual(runtime.state.userInfoKey, "salesmartly_p_plugin_1_user-1_u_i")
    }

    func testClearUserDataMatchesWidgetStoreTokenAndLocalRemoveRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "user-1", userName: "Ada"))
        runtime.state.userToken = "guest_token_1"

        let removedKeys = runtime.clearUserData(localGuestToken: "guest_token_1")

        XCTAssertEqual(runtime.state.userType, "guest")
        XCTAssertEqual(runtime.state.localUserId, "")
        XCTAssertEqual(runtime.state.userToken, "")
        XCTAssertTrue(runtime.state.isNewUser)
        XCTAssertNil(runtime.state.loginInfo)
        XCTAssertEqual(
            removedKeys,
            [
                "salesmartly_p_plugin_1_list",
                "salesmartly_p_plugin_1_u_i",
                "salesmartly_p_plugin_1_g_uid",
                "salesmartly_p_plugin_1_a_o_last",
                "salesmartly_p_plugin_1_n_u",
            ]
        )
        XCTAssertEqual(runtime.state.pendingLocalRemoveKeys, removedKeys)
        XCTAssertEqual(runtime.state.tokenKey, "salesmartly_p_plugin_1_token")

        let runtimeWithGuestToken = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtimeWithGuestToken)
        SalesmartlyChat.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "user-1"))
        runtimeWithGuestToken.state.userToken = "user_token_1"

        let preservedKeys = runtimeWithGuestToken.clearUserData(localGuestToken: "guest_token_2")

        XCTAssertTrue(preservedKeys.isEmpty)
        XCTAssertEqual(runtimeWithGuestToken.state.userType, "guest")
        XCTAssertEqual(runtimeWithGuestToken.state.userToken, "guest_token_2")
        XCTAssertFalse(runtimeWithGuestToken.state.isNewUser)
        XCTAssertEqual(runtimeWithGuestToken.state.pendingLocalRemoveKeys, [])
    }

    func testSetLoginInfoNormalizesUserIdLikeWidgetSsmEvent() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        SalesmartlyChat.setLoginInfo(LoginInfo(userId: "客户-1"))

        XCTAssertEqual(runtime.state.loginInfo?.userId, "%E5%AE%A2%E6%88%B7-1")

        SalesmartlyChat.setLoginInfo(LoginInfo(userId: String(repeating: "a", count: 301)))

        XCTAssertEqual(runtime.state.loginInfo?.userId, "%E5%AE%A2%E6%88%B7-1")
    }

    func testLanguageMappingMatchesWidgetLocalesRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)

        XCTAssertEqual(runtime.dealLanguageMap("zh-TW"), "zh-HK")
        XCTAssertEqual(runtime.dealLanguageMap("ru"), "ru-RU")
        XCTAssertEqual(runtime.dealLanguageMap("zh"), "zh-CN")
        XCTAssertEqual(runtime.dealLanguageMap("ja"), "ja-JP")
        XCTAssertEqual(runtime.dealLanguageMap("ind"), "id")
        XCTAssertEqual(runtime.dealLanguageMap("ko-KR"), "ko")
        XCTAssertEqual(runtime.dealLanguageMap("nl-BE"), "nl")
        XCTAssertEqual(runtime.dealLanguageMap("pt-BR"), "pt")
        XCTAssertEqual(runtime.dealLanguageMap("th-any"), "th-TH")

        XCTAssertEqual(runtime.getLang(), "en-US")
        XCTAssertEqual(runtime.setLang("zh-TW", navigatorLanguage: "fr-FR"), "zh-HK")
        XCTAssertEqual(runtime.getLang(), "zh-HK")
        XCTAssertTrue(runtime.checkZh())
        XCTAssertEqual(runtime.setLang("unsupported", navigatorLanguage: "zh-CN"), "en-US")
        XCTAssertEqual(runtime.setLang("auto", navigatorLanguage: "nl-NL"), "nl")
        XCTAssertEqual(runtime.setLang("auto", navigatorLanguage: "unsupported"), "en-US")

        SalesmartlyChat.setLoginInfo(LoginInfo(language: "ja"))

        XCTAssertEqual(runtime.state.loginInfo?.language, "ja-JP")
        XCTAssertEqual(runtime.getLang(), "ja-JP")
    }

    func testI18nReadsBundledWebLocaleResources() async throws {
        XCTAssertEqual(
            SalesmartlyI18n.resolveLanguage(userLanguage: "zh-TW", widgetLanguage: "fr", systemLanguage: "nl-NL"),
            "zh-HK"
        )
        XCTAssertEqual(
            SalesmartlyI18n.resolveLanguage(userLanguage: "", widgetLanguage: "auto", systemLanguage: "pt-BR"),
            "pt"
        )
        XCTAssertEqual(salesmartlyText("btn.human", language: "fr-FR"), "Passer au manuel")
        XCTAssertEqual(
            salesmartlyText("msg.queueWaiting", language: "pt-BR", replacements: ["count": "2"]),
            "Há 2 visitantes à sua frente na fila, por favor, aguarde."
        )
        XCTAssertEqual(salesmartlyText("verifyLangInfo.report", language: "zh-TW"), "檢舉")
        XCTAssertEqual(salesmartlyText("msg.newMsg", language: "zh-CN"), "新消息")
        XCTAssertEqual(salesmartlyText("msg.newMsg", language: "en-US"), "Breaking news")
        XCTAssertEqual(salesmartlyText("tips.guessQuestion", language: "fr"), "Je suppose que vous voulez demander")
        XCTAssertEqual(salesmartlyText("btn.searchSame", language: "fr"), "Rechercher des articles similaires")
        XCTAssertEqual(salesmartlyText("searchProduct.productTips", language: "fr"), "Je vous recommande les produits suivants")
        XCTAssertEqual(salesmartlyText("btn.detail", language: "fr"), "Détails")
        XCTAssertEqual(salesmartlyText("btn.checkoutNow", language: "fr"), "Achetez-le maintenant")
        XCTAssertEqual(salesmartlyText("tips.welcomeScore", language: "fr"), "Êtes-vous satisfait de ce service ?")
        XCTAssertEqual(salesmartlyText("btn.human", language: "zh-CN"), "转人工")
        XCTAssertEqual(salesmartlyText("missing.key", language: "fr"), "missing.key")
    }

    func testUnreadNotificationStateMatchesWidgetUseNotificationRules() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.setNotificationConfiguration(flashTitle: true, soundNotice: false)
        runtime.setNotificationStatus(true)
        _ = runtime.setWindowVisible(false)

        XCTAssertTrue(runtime.updateUnreadNotificationState(unreadMsgNum: 2, nowMilliseconds: 20_000))
        XCTAssertEqual(runtime.state.unreadRecord, 2)
        XCTAssertTrue(runtime.state.shouldFlashTitle)
        XCTAssertEqual(runtime.state.notificationShowCount, 1)
        XCTAssertEqual(runtime.state.notificationLastTimeMilliseconds, 20_000)

        XCTAssertFalse(runtime.updateUnreadNotificationState(unreadMsgNum: 3, nowMilliseconds: 25_000))
        XCTAssertEqual(runtime.state.notificationShowCount, 1)

        XCTAssertTrue(runtime.updateUnreadNotificationState(unreadMsgNum: 4, nowMilliseconds: 31_000))
        XCTAssertEqual(runtime.state.notificationShowCount, 2)

        XCTAssertFalse(runtime.updateUnreadNotificationState(unreadMsgNum: 0, nowMilliseconds: 32_000))
        XCTAssertEqual(runtime.state.unreadRecord, 0)
        XCTAssertFalse(runtime.state.shouldFlashTitle)

        let soundRuntime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: soundRuntime)
        soundRuntime.setNotificationConfiguration(flashTitle: true, soundNotice: true)
        soundRuntime.setNotificationStatus(true)
        _ = soundRuntime.setWindowVisible(false)

        XCTAssertFalse(soundRuntime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 40_000))
        XCTAssertEqual(soundRuntime.state.soundNoticePlayCount, 1)
        XCTAssertEqual(soundRuntime.state.notificationShowCount, 0)
        XCTAssertEqual(soundRuntime.state.notificationLastTimeMilliseconds, 40_000)
    }

    func testGlobalNotificationConfigurationWrapperMatchesRuntimeUseNotificationRules() async throws {
        let runtime = SalesmartlyRuntime()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.setNotificationConfiguration(flashTitle: true, soundNotice: true)

        XCTAssertTrue(runtime.state.flashTitle)
        XCTAssertTrue(runtime.state.soundNotice)
    }

    func testNotificationTitleFlashFollowsWidgetTimerRules() async throws {
        let runtime = SalesmartlyRuntime()

        SalesmartlyChat.reset(runtime: runtime)
        runtime.setNotificationConfiguration(flashTitle: true, soundNotice: false)
        runtime.setNotificationTitleConfiguration(originTitle: "Inbox", newMessageTitle: "【新消息】")
        runtime.setNotificationStatus(false)

        XCTAssertFalse(runtime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 1_000))
        XCTAssertTrue(runtime.state.shouldFlashTitle)
        XCTAssertEqual(runtime.state.notificationOriginTitle, "Inbox")
        XCTAssertEqual(runtime.state.notificationCurrentTitle, "【新消息】Inbox")
        XCTAssertEqual(runtime.state.notificationFlashNextTitle, "\u{200E}")
        XCTAssertEqual(runtime.state.notificationFlashNextTickMilliseconds, 1_800)

        XCTAssertFalse(runtime.advanceNotificationFlashTitle(nowMilliseconds: 1_799))
        XCTAssertTrue(runtime.advanceNotificationFlashTitle(nowMilliseconds: 1_800))
        XCTAssertEqual(runtime.state.notificationCurrentTitle, "\u{200E}")
        XCTAssertEqual(runtime.state.notificationFlashNextTitle, "【新消息】Inbox")
        XCTAssertEqual(runtime.state.notificationFlashNextTickMilliseconds, 2_600)

        XCTAssertTrue(runtime.advanceNotificationFlashTitle(nowMilliseconds: 2_600))
        XCTAssertEqual(runtime.state.notificationCurrentTitle, "【新消息】Inbox")
        XCTAssertEqual(runtime.state.notificationFlashNextTitle, "\u{200E}")

        runtime.setNotificationCurrentTitle("【新消息】Checkout")
        XCTAssertFalse(runtime.updateUnreadNotificationState(unreadMsgNum: 0, nowMilliseconds: 3_000))
        XCTAssertFalse(runtime.state.shouldFlashTitle)
        XCTAssertEqual(runtime.state.notificationCurrentTitle, "Checkout")
        XCTAssertEqual(runtime.state.notificationOriginTitle, "Checkout")
        XCTAssertTrue(runtime.state.notificationFlashNextTitle.isEmpty)
        XCTAssertEqual(runtime.state.notificationFlashNextTickMilliseconds, 0)

        runtime.setNotificationTitleConfiguration(originTitle: "Inbox", newMessageTitle: "【新消息】")
        XCTAssertFalse(runtime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 4_000))
        runtime.setNotificationCurrentTitle("\u{200E}")
        runtime.clearUser()
        XCTAssertEqual(runtime.state.notificationCurrentTitle, "Inbox")
        XCTAssertEqual(runtime.state.notificationOriginTitle, "Inbox")
        XCTAssertFalse(runtime.state.shouldFlashTitle)
    }

    func testGlobalWindowVisibilityEntryMatchesWidgetVisibilityChangeRules() async throws {
        let runtime = SalesmartlyRuntime()

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.setWindowVisible(false)
        runtime.setNotificationConfiguration(flashTitle: false, soundNotice: false)
        runtime.setNotificationStatus(true)

        XCTAssertFalse(runtime.state.isWindowVisible)
        XCTAssertTrue(runtime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 20_000))

        SalesmartlyChat.setWindowVisible(true)

        XCTAssertTrue(runtime.state.isWindowVisible)
        XCTAssertFalse(runtime.updateUnreadNotificationState(unreadMsgNum: 2, nowMilliseconds: 31_000))
    }

    func testNotificationHandlerMatchesWidgetPermissionSoundAndClickRules() async throws {
        let runtime = SalesmartlyRuntime()
        let spy = SalesmartlyNotificationSpy()

        SalesmartlyChat.reset(runtime: runtime)
        runtime.setNotificationHandler(spy)
        runtime.setNotificationConfiguration(flashTitle: true, soundNotice: false)
        runtime.setNotificationStatus(true)
        _ = runtime.setWindowVisible(false)

        XCTAssertTrue(runtime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 20_000))
        XCTAssertEqual(spy.requestedStatuses, [""])
        XCTAssertEqual(runtime.state.notificationPermissionStatus, "granted")
        XCTAssertEqual(spy.soundCount, 0)
        XCTAssertEqual(spy.showCount, 1)
        XCTAssertEqual(runtime.state.notificationShowCount, 1)

        runtime.handleUnreadNotificationClick()

        XCTAssertEqual(spy.focusCount, 1)
        XCTAssertEqual(spy.closeCount, 1)
        XCTAssertEqual(runtime.state.notificationClickCount, 1)

        let soundRuntime = SalesmartlyRuntime()
        let soundSpy = SalesmartlyNotificationSpy()

        SalesmartlyChat.reset(runtime: soundRuntime)
        soundRuntime.setNotificationHandler(soundSpy)
        soundRuntime.setNotificationConfiguration(flashTitle: true, soundNotice: true)
        soundRuntime.setNotificationStatus(true)
        _ = soundRuntime.setWindowVisible(false)

        XCTAssertFalse(soundRuntime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 40_000))
        XCTAssertEqual(soundSpy.soundCount, 1)
        XCTAssertEqual(soundSpy.showCount, 0)
        XCTAssertEqual(soundRuntime.state.notificationLastTimeMilliseconds, 40_000)

        let unsupportedRuntime = SalesmartlyRuntime()
        let unsupportedSpy = SalesmartlyNotificationSpy()
        unsupportedSpy.permissionStatus = "noSupport"

        SalesmartlyChat.reset(runtime: unsupportedRuntime)
        unsupportedRuntime.setNotificationHandler(unsupportedSpy)
        unsupportedRuntime.setNotificationConfiguration(flashTitle: false, soundNotice: false)
        unsupportedRuntime.setNotificationStatus(true)
        _ = unsupportedRuntime.setWindowVisible(false)

        XCTAssertFalse(unsupportedRuntime.updateUnreadNotificationState(unreadMsgNum: 1, nowMilliseconds: 20_000))
        XCTAssertEqual(unsupportedSpy.requestedStatuses, [""])
        XCTAssertEqual(unsupportedRuntime.state.notificationPermissionStatus, "noSupport")
        XCTAssertEqual(unsupportedSpy.showCount, 0)
        XCTAssertEqual(unsupportedRuntime.state.notificationShowCount, 0)
    }

    func testProjectScriptParserExtractsWidgetBootstrapFields() async throws {
        let script = """
        (function(d, s, id, w, n) {
            w.__ssc = w.__ssc || {};
            w.__ssc.license = 'g1omil8';
            var deUrl = atob('aHR0cHM6Ly9wbHVnaW4tY29kZS5zYWxlc21hcnRseS5jb20='), path = '/chat/widget-v2/code/install.js';
            var cs = d.currentScript, csUrl = deUrl;
            if (cs && cs.src) {var scriptURL = new URL(cs.src); csUrl = scriptURL.origin;}
            js.src = csUrl + path;
        }(document, 'script', 'ss-chat', window));
        """

        let bootstrap = try SalesmartlyProjectScriptParser.parse(
            script,
            scriptURL: URL(string: "https://plugin-code.salesmartly.com/js/project_290_727666_1778315072.js")!
        )

        XCTAssertEqual(bootstrap.license, "g1omil8")
        XCTAssertEqual(bootstrap.installPath, "/chat/widget-v2/code/install.js")
        XCTAssertEqual(bootstrap.defaultInstallOrigin, "https://plugin-code.salesmartly.com")
        XCTAssertEqual(bootstrap.resolvedInstallURL.absoluteString, "https://plugin-code.salesmartly.com/chat/widget-v2/code/install.js")
    }

    func testInitializeWithProjectScriptURLFetchesScriptAndInitializesRuntime() async throws {
        let runtime = SalesmartlyRuntime()
        let fetcher = SalesmartlyProjectScriptFixtureFetcher(
            script: "w.__ssc.license = 'g1omil8'; var deUrl = atob('aHR0cHM6Ly9wbHVnaW4tY29kZS5zYWxlc21hcnRseS5jb20='), path = '/chat/widget-v2/code/install.js';"
        )
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBody = #"{"code":0,"data":{}}"#.data(using: .utf8)!

        URLProtocol.registerClass(SalesmartlyURLProtocolSpy.self)
        defer { URLProtocol.unregisterClass(SalesmartlyURLProtocolSpy.self) }
        SalesmartlyChat.reset(runtime: runtime)
        try await SalesmartlyChat.initialize(
            scriptURL: URL(string: "https://plugin-code.salesmartly.com/js/project_290_727666_1778315072.js")!,
            environment: SalesmartlyEnvironment(
                baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
                webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
                webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
                centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
                logURL: URL(string: "https://log.salesmartly.test/")!,
                widgetURL: URL(string: "https://widget.salesmartly.test/")!,
                pluginSigningSecret: "plugin-secret",
                pollingRequestSecret: "polling-secret"
            ),
            scriptFetcher: fetcher
        )
        let deadline = Date().addingTimeInterval(2)
        while SalesmartlyURLProtocolSpy.requests.isEmpty, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertEqual(fetcher.requestedURLs.map(\.absoluteString), ["https://plugin-code.salesmartly.com/js/project_290_727666_1778315072.js"])
        XCTAssertEqual(runtime.config?.license, "g1omil8")
        XCTAssertTrue(runtime.state.isReady)
        let request = try XCTUnwrap(SalesmartlyURLProtocolSpy.requests.first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.host, "widget.salesmartly.test")
        XCTAssertEqual(request.url?.path, "/plugin/info")
        XCTAssertNil(URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "plugin_sign" })
        XCTAssertNotNil(request.value(forHTTPHeaderField: "external-sign"))
    }

    /// 对齐 Android `ProjectScriptConfigLoader.parsesDevInstallPathFromConfirmedProjectScript`，字符串脚本地址默认按 install path 推导 dev 端点。
    func testInitializeWithProjectScriptURLStringUsesAndroidDevEnvironment() async throws {
        let runtime = SalesmartlyRuntime()
        let fetcher = SalesmartlyProjectScriptFixtureFetcher(
            script: "w.__ssc.license = 'd2705g6'; var deUrl = atob('aHR0cHM6Ly9wbHVnaW4tY29kZS5zYWxlc21hcnRseS5jb20='), path = '/chat/widget-v2/dev/install.js';"
        )
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBody = #"{"code":0,"data":{}}"#.data(using: .utf8)!

        URLProtocol.registerClass(SalesmartlyURLProtocolSpy.self)
        defer { URLProtocol.unregisterClass(SalesmartlyURLProtocolSpy.self) }
        SalesmartlyChat.reset(runtime: runtime)
        try await SalesmartlyChat.initialize(
            scriptURL: "https://plugin-code.salesmartly.com/js/project_1101_936_1773121438.js",
            scriptFetcher: fetcher
        )
        let deadline = Date().addingTimeInterval(2)
        while SalesmartlyURLProtocolSpy.requests.isEmpty, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertEqual(fetcher.requestedURLs.map(\.absoluteString), ["https://plugin-code.salesmartly.com/js/project_1101_936_1773121438.js"])
        XCTAssertEqual(runtime.config?.license, "d2705g6")
        XCTAssertEqual(runtime.state.widgetHost, "https://widget-dev.salesmartly.com/")
        let request = try XCTUnwrap(SalesmartlyURLProtocolSpy.requests.first)
        XCTAssertEqual(request.url?.host, "widget-dev.salesmartly.com")
        XCTAssertEqual(request.url?.path, "/plugin/info")
    }

    /// 对齐 widget main:.env.testing1 与用户提供的 testing1 install path，字符串脚本地址应推导到 test1 端点。
    func testProjectScriptTesting1InstallPathUsesTest1Environment() throws {
        let environment = SalesmartlyEnvironment.projectScriptEnvironment(
            installPath: "/chat/widget-v2/testing1/install.js"
        )

        XCTAssertEqual(environment.baseAPIURL.absoluteString, "https://api-test1.salesmartly.com/")
        XCTAssertEqual(environment.webSocketURL.absoluteString, "wss://msg-ws-test1.salesmartly.com")
        XCTAssertEqual(environment.webSocketHTTPURL.absoluteString, "https://msg-test1.salesmartly.com")
        XCTAssertEqual(environment.centrifugoURL.absoluteString, "https://ss-centrifugo-test1.xmp.one")
        XCTAssertEqual(environment.logURL.absoluteString, "https://api-test1.salesmartly.com/")
        XCTAssertEqual(environment.widgetURL.absoluteString, "https://widget-test1.salesmartly.com/")
    }

    func testInitializeWithProjectScriptURLAndNativeBootstrapContextRequestsCreateUser() async throws {
        let runtime = SalesmartlyRuntime()
        let fetcher = SalesmartlyProjectScriptFixtureFetcher(
            script: "w.__ssc.license = 'g1omil8'; var deUrl = atob('aHR0cHM6Ly9wbHVnaW4tY29kZS5zYWxlc21hcnRseS5jb20='), path = '/chat/widget-v2/code/install.js';"
        )
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBody = #"{"code":0,"data":{"project_id":"project_1","show_plugin":"1"}}"#.data(using: .utf8)!

        URLProtocol.registerClass(SalesmartlyURLProtocolSpy.self)
        defer { URLProtocol.unregisterClass(SalesmartlyURLProtocolSpy.self) }
        SalesmartlyChat.reset(runtime: runtime)
        try await SalesmartlyChat.initialize(
            scriptURL: URL(string: "https://plugin-code.salesmartly.com/js/project_290_727666_1778315072.js")!,
            environment: SalesmartlyEnvironment(
                baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
                webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
                webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
                centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
                logURL: URL(string: "https://log.salesmartly.test/")!,
                widgetURL: URL(string: "https://widget.salesmartly.test/")!,
                pluginSigningSecret: "plugin-secret",
                pollingRequestSecret: "polling-secret"
            ),
            scriptFetcher: fetcher,
            nativeBootstrapContext: SalesmartlyNativeBootstrapContext(
                sourceURL: "salesmartly-ios://host/products",
                userAgent: "Salesmartly iOS Host",
                navigatorLanguage: "en-US",
                beforeSourceURL: "salesmartly-ios://referrer",
                guestUserId: "guest_uuid_1"
            )
        )
        let deadline = Date().addingTimeInterval(2)
        while SalesmartlyURLProtocolSpy.requests.count < 2, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertEqual(SalesmartlyURLProtocolSpy.requests.first?.url?.path, "/plugin/info")
        XCTAssertEqual(SalesmartlyURLProtocolSpy.requests.last?.url?.path, "/chat/msg-user/create-user")
        let body = try XCTUnwrap(String(data: try XCTUnwrap(SalesmartlyURLProtocolSpy.bodies.last), encoding: .utf8))
        XCTAssertTrue(body.contains("source_url=salesmartly-ios%3A%2F%2Fhost%2Fproducts"))
        XCTAssertTrue(body.contains("ua=Salesmartly%20iOS%20Host"))
        XCTAssertTrue(body.contains("language=en-US"))
        XCTAssertTrue(body.contains("before_source_url=salesmartly-ios%3A%2F%2Freferrer"))
        XCTAssertTrue(body.contains("user_id=guest_uuid_1"))
    }

    func testRequestSignerAndBuilderMatchWidgetAxiosRules() async throws {
        let environment = SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
            webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
            webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
            centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
            logURL: URL(string: "https://log.salesmartly.test/")!,
            widgetURL: URL(string: "https://widget.salesmartly.test/")!,
            pluginSigningSecret: "plugin-secret",
            pollingRequestSecret: "polling-secret"
        )
        let context = SalesmartlyPluginRequestContext(
            pluginId: "g1omil8",
            mode: "chat",
            overTime: "",
            localToken: "token_1",
            uid: "uid_1",
            projectId: "project_1",
            timestampMilliseconds: 1_779_860_001_234
        )
        let request = SalesmartlyTransportRequest(
            kind: .http,
            eventName: nil,
            path: "/chat/chat-msg/unread-msg-list-v2",
            method: .get,
            query: ["chat_user_id": "chat_user_1", "login_token": "token_1"],
            payload: [:],
            externalSign: true
        )

        let urlRequest = try SalesmartlyHTTPRequestBuilder(
            environment: environment,
            context: context
        ).makeURLRequest(for: request)

        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url?.host, "msg.salesmartly.test")
        XCTAssertNil(URLComponents(url: try XCTUnwrap(urlRequest.url), resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "plugin_sign" })
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "external-sign"),
            SalesmartlyRequestSigner.md5Sign(
                payload: [
                    "_": "1779860001234",
                    "_lt": "token_1",
                    "_u": "uid_1",
                    "_xma_": "project_1",
                    "chat_user_id": "chat_user_1",
                    "env": "chat",
                    "login_token": "token_1",
                    "over_time": "",
                    "plugin_id": "g1omil8",
                ],
                secret: "polling-secret"
            )
        )
    }

    func testDefaultExternalSignUsesWidgetPollingSecret() throws {
        let environment = SalesmartlyEnvironment.dev()
        let context = SalesmartlyPluginRequestContext(
            pluginId: "d2705g6",
            mode: "chat",
            timestampMilliseconds: 1_782_117_300_000
        )
        let request = SalesmartlyTransportRequest(
            kind: .http,
            eventName: nil,
            path: "plugin/info",
            method: .get,
            query: [:],
            payload: [:],
            externalSign: true
        )

        let urlRequest = try SalesmartlyHTTPRequestBuilder(
            environment: environment,
            context: context
        ).makeURLRequest(for: request)

        XCTAssertEqual(urlRequest.url?.host, "widget-dev.salesmartly.com")
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "external-sign"),
            SalesmartlyRequestSigner.md5Sign(
                payload: [
                    "_": "1782117300000",
                    "_lt": "",
                    "_u": "",
                    "_xma_": "",
                    "env": "chat",
                    "over_time": "",
                    "plugin_id": "d2705g6",
                ],
                secret: SalesmartlyEnvironment.defaultPollingRequestSecret
            )
        )
    }

    func testDefaultPluginSignUsesAndroidCommonRequestSecret() throws {
        let environment = SalesmartlyEnvironment.dev()
        let context = SalesmartlyPluginRequestContext(
            pluginId: "d2705g6",
            mode: "chat",
            projectId: "1101",
            timestampMilliseconds: 1_782_117_300_000
        )
        let request = SalesmartlyTransportRequest(
            kind: .http,
            eventName: nil,
            path: "chat/msg-user/create-user",
            method: .post,
            query: [:],
            payload: [
                "source_url": "sample-app://home",
                "language": "en-US",
                "ua": "SalesmartlyChatSample iOS",
                "user_id": "guest_uuid_1",
                "data": "e30=",
                "is_sandbox": 0,
                "before_source_url": "",
                "label_names": "[]",
                "custom_fields_ext": "{}",
            ],
            externalSign: false
        )

        let urlRequest = try SalesmartlyHTTPRequestBuilder(
            environment: environment,
            context: context
        ).makeURLRequest(for: request)
        let queryItems = URLComponents(
            url: try XCTUnwrap(urlRequest.url),
            resolvingAgainstBaseURL: false
        )?.queryItems

        XCTAssertEqual(environment.pluginSigningSecret, "9c2210efee9b603e09f8d742917bb538")
        XCTAssertEqual(
            queryItems?.first { $0.name == "plugin_sign" }?.value,
            SalesmartlyRequestSigner.md5Sign(
                payload: [
                    "source_url": "sample-app://home",
                    "language": "en-US",
                    "ua": "SalesmartlyChatSample iOS",
                    "user_id": "guest_uuid_1",
                    "data": "e30=",
                    "is_sandbox": "0",
                    "before_source_url": "",
                    "label_names": "[]",
                    "custom_fields_ext": "{}",
                ],
                secret: "9c2210efee9b603e09f8d742917bb538"
            )
        )
    }

    func testSseHttpChatMsgEventURLRequestUsesWidgetJSONBodyAndExternalSign() async throws {
        let runtime = SalesmartlyRuntime()
        SalesmartlyChat.reset(runtime: runtime)
        runtime.initialize(config: SalesmartlyConfig(license: "plugin_1"))
        runtime.state.sseSwitch = "1"
        runtime.state.realtimeMode = "sse-http"
        runtime.state.sendMode = "http"

        SalesmartlyChat.sendTextMessage("Hello")
        let message = try XCTUnwrap(runtime.state.messages.last)
        let request = try XCTUnwrap(
            runtime.makeSendMessageTransportRequest(
                for: message,
                loginToken: "token_1",
                chatUserId: "chat_user_1"
            )
        )
        let environment = SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
            webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
            webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
            centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
            logURL: URL(string: "https://log.salesmartly.test/")!,
            widgetURL: URL(string: "https://widget.salesmartly.test/")!,
            pluginSigningSecret: "plugin-secret",
            pollingRequestSecret: "polling-secret"
        )
        let context = SalesmartlyPluginRequestContext(
            pluginId: "plugin_1",
            mode: "chat",
            overTime: "",
            localToken: "token_1",
            uid: "",
            projectId: "project_1",
            timestampMilliseconds: 1_779_860_001_234
        )

        let urlRequest = try SalesmartlyHTTPRequestBuilder(
            environment: environment,
            context: context
        ).makeURLRequest(for: request)
        let body = try XCTUnwrap(urlRequest.httpBody)
        let bodyPayload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])

        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.url?.host, "msg.salesmartly.test")
        XCTAssertEqual(urlRequest.url?.path, "/chat/chat-msg/event")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(bodyPayload["login_token"], "token_1")
        XCTAssertEqual(bodyPayload["chat_user_id"], "chat_user_1")
        XCTAssertEqual(bodyPayload["event"], "send-message")
        XCTAssertEqual(bodyPayload["data"], request.payload["data"] as? String)
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "external-sign"),
            SalesmartlyRequestSigner.md5Sign(payload: bodyPayload, secret: "polling-secret")
        )
    }

    func testSwapObjectTransportRequestUsesWidgetJSONBodyAndPluginSign() async throws {
        let runtime = SalesmartlyRuntime()
        let environment = SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api.example.com/")!,
            webSocketURL: URL(string: "wss://msg-ws.example.com")!,
            webSocketHTTPURL: URL(string: "https://msg.example.com/")!,
            centrifugoURL: URL(string: "https://events.example.com/")!,
            logURL: URL(string: "https://log.example.com/")!,
            widgetURL: URL(string: "https://widget.example.com/")!,
            pluginSigningSecret: "plugin-secret",
            pollingRequestSecret: "polling-secret"
        )
        let context = SalesmartlyPluginRequestContext(
            pluginId: "plugin_1",
            mode: "chat",
            overTime: "",
            localToken: "token_1",
            uid: "",
            projectId: "project_1",
            timestampMilliseconds: 1_716_278_400_123
        )
        let expectedEncodedObject = "nSph1nohMhH4rna8N5OhBdHhtnIZrNohMhH9lCypyQzh1QXAtdyiyGYqP9EVsSoWs9++tdz8PTXG1nkWlhzQ1njVBGY/rqHzNo=="
        let request = runtime.makeSwapObjectTransportRequest(
            reportId: "temp_1",
            fileURL: "https://assets-cdn.salesmartly.com/project/chat/plugin/2/file.png"
        )

        XCTAssertEqual(request.path, "sys/project/project/swap-object-v2")
        XCTAssertEqual(request.method, .post)
        XCTAssertFalse(request.externalSign)
        XCTAssertEqual(request.bodyEncoding, .json)
        XCTAssertEqual(request.payload["object"] as? String, expectedEncodedObject)

        let urlRequest = try SalesmartlyHTTPRequestBuilder(
            environment: environment,
            context: context
        ).makeURLRequest(for: request)
        let queryItems = URLComponents(
            url: try XCTUnwrap(urlRequest.url),
            resolvingAgainstBaseURL: false
        )?.queryItems ?? []
        let query = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })

        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.url?.host, "api.example.com")
        XCTAssertEqual(urlRequest.url?.path, "/sys/project/project/swap-object-v2")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(
            String(data: try XCTUnwrap(urlRequest.httpBody), encoding: .utf8),
            #"{"object":"\#(expectedEncodedObject)"}"#
        )
        XCTAssertEqual(
            query["plugin_sign"],
            SalesmartlyRequestSigner.md5Sign(
                payload: ["object": expectedEncodedObject],
                secret: "plugin-secret"
            )
        )
        XCTAssertEqual(query["plugin_id"], "plugin_1")
        XCTAssertEqual(query["over_time"], "")
        XCTAssertEqual(query["env"], "chat")
        XCTAssertEqual(query["_"], "1716278400123")
        XCTAssertEqual(query["_lt"], "token_1")
        XCTAssertEqual(query["_u"], "")
        XCTAssertEqual(query["_xma_"], "project_1")
        XCTAssertNil(urlRequest.value(forHTTPHeaderField: "external-sign"))
    }

    func testFileDownloadStateMatchesWidgetFileMessageRules() async throws {
        let runtime = SalesmartlyRuntime()
        let serverMessage = ChatMessage(
            id: "server_file_1",
            msgType: "4",
            message: "https://cdn.example.com/report.pdf",
            mid: "server_file_1",
            cMId: "cm_file_1"
        )
        let uploadingMessage = ChatMessage(
            id: "server_file_2",
            msgType: "4",
            message: "https://cdn.example.com/uploading.pdf",
            mid: "temp_upload_file_1"
        )

        XCTAssertEqual(runtime.fileDownloadReportId(for: serverMessage), "cm_file_1")
        XCTAssertFalse(runtime.fileMessageIsUploading(serverMessage))
        XCTAssertEqual(runtime.fileDownloadReportId(for: uploadingMessage), "server_file_2")
        XCTAssertTrue(runtime.fileMessageIsUploading(uploadingMessage))
    }

    func testResolveDownloadFileURLUsesSwapObjectResultURL() async throws {
        let runtime = SalesmartlyRuntime()
        let transport = SalesmartlyTransportSpy()
        var resolvedURLs: [String] = []
        var finishedCount = 0

        runtime.setTransport(transport)
        runtime.resolveDownloadFileURL(
            reportId: "cm_file_1",
            fileURL: "https://salesmartly.oss-accelerate.aliyuncs.com/project/chat/plugin/4/report.pdf?time=1716278400",
            onResolved: { resolvedURLs.append($0) },
            onFinished: { finishedCount += 1 }
        )

        let request = try XCTUnwrap(transport.requests.first)
        XCTAssertEqual(request.path, "sys/project/project/swap-object-v2")
        XCTAssertEqual(request.bodyEncoding, .json)
        XCTAssertEqual(
            request.payload["object"] as? String,
            runtime.makeSwapObjectPayload(
                tempId: "cm_file_1",
                fileURL: "https://salesmartly.oss-accelerate.aliyuncs.com/project/chat/plugin/4/report.pdf?time=1716278400"
            )["object"] as? String
        )

        let result = #"[{"id":"cm_file_1","object":"project/chat/plugin/4/report.pdf","url":"http://display.example.com/report.pdf","process":"","send_url":"https://send.example.com/report.pdf"}]"#
            .data(using: .utf8)!
            .base64EncodedString()

        transport.respond(["data": ["result": result]], requestIndex: 0)

        XCTAssertEqual(resolvedURLs, ["https://display.example.com/report.pdf"])
        XCTAssertEqual(finishedCount, 1)
    }

    func testURLSessionTransportSendsWidgetFormRequestAndDispatchesResponse() async throws {
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBodies = []
        SalesmartlyURLProtocolSpy.heldPaths = []
        SalesmartlyURLProtocolSpy.heldLoaders = [:]
        SalesmartlyURLProtocolSpy.responseBody = #"{"code":0,"data":{"ok":true}}"#.data(using: .utf8)!
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SalesmartlyURLProtocolSpy.self]
        let session = URLSession(configuration: configuration)
        let transport = SalesmartlyURLSessionTransport(
            environment: SalesmartlyEnvironment(
                baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
                webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
                webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
                centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
                logURL: URL(string: "https://log.salesmartly.test/")!,
                widgetURL: URL(string: "https://widget.salesmartly.test/")!,
                pluginSigningSecret: "plugin-secret",
                pollingRequestSecret: "polling-secret"
            ),
            context: SalesmartlyPluginRequestContext(pluginId: "g1omil8", timestampMilliseconds: 1),
            session: session
        )
        let expectation = expectation(description: "transport response")
        var responsePayload: SalesmartlyPayload = [:]

        transport.setResponseHandler { payload, _ in
            responsePayload = payload
            expectation.fulfill()
        }
        transport.send(
            SalesmartlyTransportRequest(
                kind: .http,
                eventName: nil,
                path: "chat/msg-user/create-user",
                method: .post,
                query: [:],
                payload: ["source_url": "https://example.com", "language": "en-US"],
                externalSign: false
            )
        )

        await fulfillment(of: [expectation], timeout: 2)

        let request = try XCTUnwrap(SalesmartlyURLProtocolSpy.requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.host, "api.salesmartly.test")
        XCTAssertEqual(String(data: try XCTUnwrap(SalesmartlyURLProtocolSpy.bodies.first), encoding: .utf8), "language=en-US&source_url=https%3A%2F%2Fexample.com")
        XCTAssertEqual((responsePayload["data"] as? [String: Bool])?["ok"], true)
    }

    func testURLSessionTransportWaitsForSseConnectBeforeJoinRoom() async throws {
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBodies = []
        SalesmartlyURLProtocolSpy.responseBody = #"{"code":0,"data":{"ok":true}}"#.data(using: .utf8)!
        SalesmartlyURLProtocolSpy.heldPaths = ["/chat/chat-msg/sse-connect"]
        SalesmartlyURLProtocolSpy.heldLoaders = [:]
        defer {
            SalesmartlyURLProtocolSpy.heldPaths = []
            SalesmartlyURLProtocolSpy.heldLoaders = [:]
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SalesmartlyURLProtocolSpy.self]
        let session = URLSession(configuration: configuration)
        var sseStream: SalesmartlySSEStreamSpy?
        let transport = SalesmartlyURLSessionTransport(
            environment: SalesmartlyEnvironment(
                baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
                webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
                webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
                centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
                logURL: URL(string: "https://log.salesmartly.test/")!,
                widgetURL: URL(string: "https://widget.salesmartly.test/")!,
                pluginSigningSecret: "plugin-secret",
                pollingRequestSecret: "polling-secret"
            ),
            context: SalesmartlyPluginRequestContext(pluginId: "plugin_1", timestampMilliseconds: 1),
            session: session,
            sseStreamFactory: { url, onOpen, onPayload in
                let stream = SalesmartlySSEStreamSpy(url: url, onOpen: onOpen, onPayload: onPayload)
                sseStream = stream
                return stream
            }
        )

        transport.connectSSE(
            SalesmartlySSEConnectionRequest(
                eventSourceURL: URL(string: "https://events.salesmartly.test/connection/uni_sse?cf_connect=%7B%7D")!,
                connectRequest: SalesmartlyTransportRequest(
                    kind: .http,
                    eventName: nil,
                    path: "/chat/chat-msg/sse-connect",
                    method: .post,
                    query: [:],
                    payload: [
                        "login_token": "token_1",
                        "chat_user_id": "chat_user_1",
                    ],
                    externalSign: true,
                    bodyEncoding: .json
                ),
                disconnectRequest: SalesmartlyTransportRequest(
                    kind: .http,
                    eventName: nil,
                    path: "/chat/chat-msg/sse-disconnect",
                    method: .post,
                    query: [:],
                    payload: [:],
                    externalSign: true,
                    bodyEncoding: .json
                ),
                openRequests: [
                    SalesmartlyTransportRequest(
                        kind: .http,
                        eventName: nil,
                        path: "/chat/chat-msg/event",
                        method: .post,
                        query: [:],
                        payload: [
                            "login_token": "token_1",
                            "chat_user_id": "chat_user_1",
                            "event": "join-room",
                            "data": #"{"room_id":"chat_user_1"}"#,
                        ],
                        externalSign: true,
                        bodyEncoding: .json
                    ),
                ]
            )
        )
        sseStream?.emitOpen()

        let connectDeadline = Date().addingTimeInterval(2)
        while !SalesmartlyURLProtocolSpy.requests.contains(where: { $0.url?.path == "/chat/chat-msg/sse-connect" }),
              Date() < connectDeadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(SalesmartlyURLProtocolSpy.requests.contains { $0.url?.path == "/chat/chat-msg/event" })

        SalesmartlyURLProtocolSpy.releaseHeldPath("/chat/chat-msg/sse-connect")

        let joinDeadline = Date().addingTimeInterval(2)
        while !SalesmartlyURLProtocolSpy.requests.contains(where: { $0.url?.path == "/chat/chat-msg/event" }),
              Date() < joinDeadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        let connectIndex = try XCTUnwrap(
            SalesmartlyURLProtocolSpy.requests.firstIndex { $0.url?.path == "/chat/chat-msg/sse-connect" }
        )
        let joinIndex = try XCTUnwrap(
            SalesmartlyURLProtocolSpy.requests.firstIndex { $0.url?.path == "/chat/chat-msg/event" }
        )
        XCTAssertLessThan(connectIndex, joinIndex)
    }

    func testURLSessionTransportReadsLatestWidgetRequestContextForEachSend() async throws {
        SalesmartlyURLProtocolSpy.requests = []
        SalesmartlyURLProtocolSpy.bodies = []
        SalesmartlyURLProtocolSpy.responseBodies = [
            #"{"code":0,"data":{"first":true}}"#.data(using: .utf8)!,
            #"{"code":0,"data":{"second":true}}"#.data(using: .utf8)!,
        ]
        SalesmartlyURLProtocolSpy.heldPaths = []
        SalesmartlyURLProtocolSpy.heldLoaders = [:]
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SalesmartlyURLProtocolSpy.self]
        let session = URLSession(configuration: configuration)
        var context = SalesmartlyPluginRequestContext(
            pluginId: "g1omil8",
            localToken: "token_1",
            projectId: "project_1",
            timestampMilliseconds: 1
        )
        let transport = SalesmartlyURLSessionTransport(
            environment: SalesmartlyEnvironment(
                baseAPIURL: URL(string: "https://api.salesmartly.test/")!,
                webSocketURL: URL(string: "wss://msg-ws.salesmartly.test")!,
                webSocketHTTPURL: URL(string: "https://msg.salesmartly.test/")!,
                centrifugoURL: URL(string: "https://events.salesmartly.test/")!,
                logURL: URL(string: "https://log.salesmartly.test/")!,
                widgetURL: URL(string: "https://widget.salesmartly.test/")!,
                pluginSigningSecret: "plugin-secret",
                pollingRequestSecret: "polling-secret"
            ),
            contextProvider: { context },
            session: session
        )
        let firstExpectation = expectation(description: "first response")
        let secondExpectation = expectation(description: "second response")
        var responseCount = 0
        transport.setResponseHandler { _, _ in
            responseCount += 1
            if responseCount == 1 {
                firstExpectation.fulfill()
            }
            if responseCount == 2 {
                secondExpectation.fulfill()
            }
        }

        transport.send(
            SalesmartlyTransportRequest(
                kind: .http,
                eventName: nil,
                path: "/chat/chat-msg/unread-msg-list-v2",
                method: .get,
                query: ["chat_user_id": "chat_user_1", "login_token": "token_1"],
                payload: [:],
                externalSign: true
            )
        )
        await fulfillment(of: [firstExpectation], timeout: 2)

        context.localToken = "token_2"
        context.projectId = "project_2"
        context.timestampMilliseconds = 2
        transport.send(
            SalesmartlyTransportRequest(
                kind: .http,
                eventName: nil,
                path: "/chat/chat-msg/unread-msg-list-v2",
                method: .get,
                query: ["chat_user_id": "chat_user_2", "login_token": "token_2"],
                payload: [:],
                externalSign: true
            )
        )
        await fulfillment(of: [secondExpectation], timeout: 2)

        let secondRequest = try XCTUnwrap(SalesmartlyURLProtocolSpy.requests.last)
        let queryItems = URLComponents(url: try XCTUnwrap(secondRequest.url), resolvingAgainstBaseURL: false)?.queryItems
        XCTAssertEqual(queryItems?.first { $0.name == "_lt" }?.value, "token_2")
        XCTAssertEqual(queryItems?.first { $0.name == "_xma_" }?.value, "project_2")
        XCTAssertEqual(queryItems?.first { $0.name == "_" }?.value, "2")
        XCTAssertEqual(queryItems?.first { $0.name == "login_token" }?.value, "token_2")
    }

    func testSocketIOTransportSerializesWidgetEventsThroughClientAdapter() async throws {
        let client = SalesmartlySocketIOClientSpy()
        let transport = SalesmartlySocketIOTransport(client: client)
        var inboundEventName = ""
        var inboundPayload: SalesmartlyPayload = [:]

        transport.setSocketInboundEventHandler { eventName, payload in
            inboundEventName = eventName
            inboundPayload = payload
        }
        transport.addSocketEventHandlers(["receive-message"])
        transport.connectSocket(
            SalesmartlySocketConnectionRequest(
                query: ["login_token": "token_1", "plugin_id": "g1omil8"],
                transports: ["websocket"],
                reconnectionAttempts: 30
            )
        )
        transport.send(
            SalesmartlyTransportRequest(
                kind: .socketEvent,
                eventName: "join-room",
                path: nil,
                method: nil,
                query: [:],
                payload: ["room_type": 6],
                externalSign: false
            )
        )
        client.emitConnect()
        client.emitInbound(eventName: "receive-message", payload: ["code": 0])

        XCTAssertEqual(client.connectedQueries.first?["login_token"] as? String, "token_1")
        XCTAssertEqual(client.connectedTransports.first, ["websocket"])
        XCTAssertEqual(client.connectedReconnectionAttempts.first, 30)
        XCTAssertEqual(client.connectedSocketIOProtocolVersions.first, 2)
        XCTAssertEqual(client.emittedEvents.first?.eventName, "join-room")
        XCTAssertEqual(client.emittedEvents.first?.jsonPayload, #"{"room_type":6}"#)
        XCTAssertEqual(inboundEventName, "receive-message")
        XCTAssertEqual(inboundPayload["code"] as? Int, 0)
    }

    func testSocketIOTransportBuffersJoinRoomUntilClientConnects() async throws {
        let client = SalesmartlySocketIOClientSpy()
        let transport = SalesmartlySocketIOTransport(client: client)

        transport.connectSocket(
            SalesmartlySocketConnectionRequest(
                query: ["login_token": "token_1", "plugin_id": "g1omil8"],
                transports: ["websocket"],
                reconnectionAttempts: 30
            )
        )
        transport.send(
            SalesmartlyTransportRequest(
                kind: .socketEvent,
                eventName: "join-room",
                path: nil,
                method: nil,
                query: [:],
                payload: ["room_type": 6],
                externalSign: false
            )
        )

        XCTAssertTrue(client.emittedEvents.isEmpty)

        client.emitConnect()

        XCTAssertEqual(client.emittedEvents.first?.eventName, "join-room")
        XCTAssertEqual(client.emittedEvents.first?.jsonPayload, #"{"room_type":6}"#)
    }

    func testNativeMessagePresentationMapsWidgetMessageTypes() async throws {
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "1", message: "Hello")).kind, .text)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "2", message: "https://cdn.example.com/a.png")).kind, .image)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "4", message: "file.pdf")).kind, .file)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "6", message: "https://cdn.example.com/a.mp4")).kind, .video)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "7", message: "{}")).kind, .email)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "8", message: "{}")).kind, .system)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "21", message: "{}")).kind, .quickReply)
        XCTAssertEqual(SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "48", message: "{}")).kind, .aggregate)
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "21", message: #"{"payload":{"text":"Choose one","buttons":[]}}"#)
            ).summary,
            "Choose one"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "3", message: #"{"type":"default","payload":{"text":"Template text","attachments":[],"buttons":[]}}"#)
            ).summary,
            "Template text"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "5", message: #"{"text":"Selected option","postback":"option_1"}"#)
            ).summary,
            "Selected option"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "5", message: #""{\"text\":\"Cached option\",\"postback\":\"option_1\"}""#)
            ).summary,
            "Cached option"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "14", message: #"{"product_info":{"product_name":"Blue Shoes"}}"#)
            ).summary,
            "Blue Shoes"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "40", message: #"{"caption":"Caption text","file_name":"catalog.pdf","file_type":"document","file_url":"https://cdn.example.com/catalog.pdf","ext":"pdf"}"#)
            ).summary,
            "Caption text"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "40", message: #"{"caption":"","file_name":"catalog.pdf","file_type":"document","file_url":"https://cdn.example.com/catalog.pdf","ext":"pdf"}"#)
            ).summary,
            "catalog.pdf"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "11", message: #"{"type":"postback","data":{"question":"Where is my order?"}}"#)
            ).summary,
            "Where is my order?"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "11", message: #"{"type":"reply","data":[{"context_type":"text","context":"AI answer"}]}"#)
            ).summary,
            "AI answer"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "11", message: #"{"type":"guide","data":[{"id":"q1","question":"What can I do?"}]}"#)
            ).summary,
            "请选择以下您想咨询的内容"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(
                for: ChatMessage(msgType: "46", message: #"[{"goods_id":"goods_1","goods_name":"Blue Shoes"}]"#)
            ).summary,
            "Blue Shoes"
        )
    }

    func testTextLinkSegmentsMatchWidgetReplaceLinkRules() async throws {
        let segments = SalesmartlyTextLinkifier.segments(
            in: "访问 salesmartly.com/a?x=1，邮箱 hi@example.com，安全 https://api.example.com/path)."
        )

        XCTAssertEqual(
            segments,
            [
                SalesmartlyTextLinkSegment(text: "访问 ", destination: nil),
                SalesmartlyTextLinkSegment(text: "salesmartly.com/a?x=1", destination: "https://salesmartly.com/a?x=1"),
                SalesmartlyTextLinkSegment(text: "，邮箱 ", destination: nil),
                SalesmartlyTextLinkSegment(text: "hi@example.com", destination: "mailto:hi@example.com"),
                SalesmartlyTextLinkSegment(text: "，安全 ", destination: nil),
                SalesmartlyTextLinkSegment(text: "https://api.example.com/path", destination: "https://api.example.com/path"),
                SalesmartlyTextLinkSegment(text: ").", destination: nil),
            ]
        )

        XCTAssertEqual(
            SalesmartlyTextLinkifier.segments(in: "文件 file.pdf 和 www.example.com"),
            [
                SalesmartlyTextLinkSegment(text: "文件 file.pdf 和 ", destination: nil),
                SalesmartlyTextLinkSegment(text: "www.example.com", destination: "https://www.example.com"),
            ]
        )
    }

    func testNativeUnsupportedMessagePresentationMatchesWidgetUnknownMessage() async throws {
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "15", message: "{}")).summary,
            "[暂不支持此消息类型]"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "20", message: "{}")).summary,
            "[暂不支持此消息类型]"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "22", message: "{}")).summary,
            "[暂不支持此消息类型]"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "23", message: "{}")).summary,
            "[暂不支持此消息类型]"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "29", message: "{}")).summary,
            "[暂不支持此消息类型]"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: ChatMessage(msgType: "48", message: "{}")).summary,
            "[暂不支持此消息类型]"
        )
    }

    func testNativeSystemMessagePresentationMatchesWidgetReceptionInfo() async throws {
        let message = ChatMessage(
            msgType: "8",
            message: #"{"type":"join_session","nickname":"Ada"}"#
        )

        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: message, showReceptionInfo: true).summary,
            "客服Ada 接入会话"
        )
        XCTAssertEqual(
            SalesmartlyNativeMessagePresentation.component(for: message, showReceptionInfo: false).summary,
            "会话被客服接起"
        )
    }

    func testNativeProductMessagePresentationKeepsWidgetProductInfoFields() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "14",
                message: #"{"product_info":{"product_picture":"https://cdn.example.com/shoe.png","product_name":"Blue Shoes","original_price":"129.00","price":"99.00","currency_code":"USD","purchase_address":"https://shop.example.com/products/blue-shoes"}}"#
            )
        )

        XCTAssertEqual(component.kind, .product)
        XCTAssertEqual(component.summary, "Blue Shoes")
        XCTAssertEqual(component.product_info?.product_picture, "https://cdn.example.com/shoe.png")
        XCTAssertEqual(component.product_info?.product_name, "Blue Shoes")
        XCTAssertEqual(component.product_info?.original_price, "129.00")
        XCTAssertEqual(component.product_info?.price, "99.00")
        XCTAssertEqual(component.product_info?.currency_code, "USD")
        XCTAssertEqual(component.product_info?.purchase_address, "https://shop.example.com/products/blue-shoes")
        XCTAssertTrue(component.product_info?.showOriginalPrice == true)

        let noOriginalPrice = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "14",
                message: #"{"product_info":{"product_picture":"https://cdn.example.com/shoe.png","product_name":"Blue Shoes","original_price":"99.00","price":"129.00","currency_code":"USD","purchase_address":"https://shop.example.com/products/blue-shoes"}}"#
            )
        )
        XCTAssertTrue(noOriginalPrice.product_info?.showOriginalPrice == false)
    }

    func testNativeMediaTextMessagePresentationKeepsWidgetMediaTextFields() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "40",
                message: #"{"caption":"Install guide","file_name":"guide.pdf","file_type":"document","file_url":"https://cdn.example.com/guide.pdf","ext":"pdf"}"#
            )
        )

        XCTAssertEqual(component.kind, .mediaText)
        XCTAssertEqual(component.summary, "Install guide")
        XCTAssertEqual(component.media_text?.caption, "Install guide")
        XCTAssertEqual(component.media_text?.file_name, "guide.pdf")
        XCTAssertEqual(component.media_text?.file_type, "document")
        XCTAssertEqual(component.media_text?.file_url, "https://cdn.example.com/guide.pdf")
        XCTAssertEqual(component.media_text?.ext, "pdf")

        let imageComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "40",
                message: #"{"caption":"Photo guide","file_type":"image","file_url":"https://cdn.example.com/photo.png"}"#
            )
        )

        XCTAssertEqual(imageComponent.kind, .mediaText)
        XCTAssertEqual(imageComponent.summary, "Photo guide")
        XCTAssertEqual(imageComponent.media_text?.caption, "Photo guide")
        XCTAssertEqual(imageComponent.media_text?.file_name, "")
        XCTAssertEqual(imageComponent.media_text?.file_type, "image")
        XCTAssertEqual(imageComponent.media_text?.file_url, "https://cdn.example.com/photo.png")
        XCTAssertEqual(imageComponent.media_text?.ext, "")
    }

    func testNativeBasicMediaPresentationKeepsWidgetMessageURLRules() async throws {
        let imageComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "2",
                message: "https://cdn.example.com/photo.png"
            )
        )
        let videoComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "6",
                message: "https://cdn.example.com/demo.mp4"
            )
        )
        let fileComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "4",
                message: "https://cdn.example.com/files/user%20guide.pdf?download=1"
            )
        )

        XCTAssertEqual(imageComponent.image_message?.img_url, "https://cdn.example.com/photo.png")
        XCTAssertEqual(videoComponent.video_message?.video_url, "https://cdn.example.com/demo.mp4")
        XCTAssertEqual(fileComponent.file_message?.file_url, "https://cdn.example.com/files/user%20guide.pdf?download=1")
        XCTAssertEqual(fileComponent.file_message?.full_file_name, "user guide.pdf")
    }

    func testNativeEmailAndAudioPresentationMatchWidgetComponents() async throws {
        let emailComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "7",
                message: "{}"
            )
        )
        let audioComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "12",
                message: "https://cdn.example.com/voice.mp3"
            )
        )

        XCTAssertEqual(emailComponent.kind, .email)
        XCTAssertEqual(emailComponent.summary, "您有一封邮件，请查收")
        XCTAssertEqual(audioComponent.kind, .audio)
        XCTAssertEqual(audioComponent.summary, "语音")
        XCTAssertEqual(audioComponent.audio_message?.audio_url, "https://cdn.example.com/voice.mp3")

        let englishAudioComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "12",
                message: "https://cdn.example.com/voice.mp3"
            ),
            showReceptionInfo: true,
            language: "en-US"
        )
        XCTAssertEqual(englishAudioComponent.summary, "voice")
    }

    func testNativeSearchSameMessagePresentationKeepsWidgetImageURLRules() async throws {
        let fileURLComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "45",
                message: #"{"file_url":"https://cdn.example.com/search-same.png"}"#
            )
        )

        XCTAssertEqual(fileURLComponent.kind, .searchSame)
        XCTAssertEqual(fileURLComponent.summary, "搜同款")
        XCTAssertEqual(fileURLComponent.search_same?.img_url, "https://cdn.example.com/search-same.png")

        let rawURLComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "45",
                message: "https://cdn.example.com/raw-search-same.png"
            )
        )

        XCTAssertEqual(rawURLComponent.search_same?.img_url, "https://cdn.example.com/raw-search-same.png")
    }

    func testNativeQuickReplyMessagePresentationKeepsWidgetPayloadButtons() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "21",
                message: #"{"payload":{"text":"Choose one","always_show":true,"buttons":[{"type":"postback","text":"Track order","payload":"track"},{"type":"web_url","text":"Open help","payload":"help","url":"https://help.example.com"}]}}"#,
                status: 0
            )
        )

        XCTAssertEqual(component.kind, .quickReply)
        XCTAssertEqual(component.summary, "Choose one")
        XCTAssertEqual(component.quick_reply?.text, "Choose one")
        XCTAssertTrue(component.quick_reply?.always_show == true)
        XCTAssertEqual(component.quick_reply?.buttons.count, 2)
        XCTAssertEqual(component.quick_reply?.buttons[0].type, "postback")
        XCTAssertEqual(component.quick_reply?.buttons[0].text, "Track order")
        XCTAssertEqual(component.quick_reply?.buttons[0].payload, "track")
        XCTAssertNil(component.quick_reply?.buttons[0].url)
        XCTAssertEqual(component.quick_reply?.buttons[1].type, "web_url")
        XCTAssertEqual(component.quick_reply?.buttons[1].text, "Open help")
        XCTAssertEqual(component.quick_reply?.buttons[1].payload, "help")
        XCTAssertEqual(component.quick_reply?.buttons[1].url, "https://help.example.com")
    }

    func testNativeAIReplyMessagePresentationKeepsWidgetGuidePostbackAndReplyFields() async throws {
        let guideComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "11",
                message: #"{"type":"guide","data":[{"id":"question_1","question":"Where is my order?"},{"id":"question_2","question":"Return policy"}]}"#
            )
        )

        XCTAssertEqual(guideComponent.kind, .ai)
        XCTAssertEqual(guideComponent.summary, "请选择以下您想咨询的内容")
        XCTAssertEqual(guideComponent.ai_reply?.type, "guide")
        XCTAssertEqual(guideComponent.ai_reply?.guide.count, 2)
        XCTAssertEqual(guideComponent.ai_reply?.guide[0].id, "question_1")
        XCTAssertEqual(guideComponent.ai_reply?.guide[0].question, "Where is my order?")
        XCTAssertEqual(guideComponent.ai_reply?.guide[1].id, "question_2")
        XCTAssertEqual(guideComponent.ai_reply?.guide[1].question, "Return policy")

        let postbackComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "11",
                message: #"{"type":"postback","data":{"id":"question_1","question":"Where is my order?"}}"#
            )
        )

        XCTAssertEqual(postbackComponent.summary, "Where is my order?")
        XCTAssertEqual(postbackComponent.ai_reply?.type, "postback")
        XCTAssertEqual(postbackComponent.ai_reply?.postback?.id, "question_1")
        XCTAssertEqual(postbackComponent.ai_reply?.postback?.question, "Where is my order?")

        let replyComponent = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "11",
                message: #"{"type":"reply","data":[{"context_type":"text","context":"AI answer"},{"context_type":"pic","context":"https://cdn.example.com/a.png"},{"context_type":"media","context":"https://cdn.example.com/files/report.pdf?token=1"}]}"#
            )
        )

        XCTAssertEqual(replyComponent.summary, "AI answer")
        XCTAssertEqual(replyComponent.ai_reply?.type, "reply")
        XCTAssertEqual(replyComponent.ai_reply?.reply.count, 3)
        XCTAssertEqual(replyComponent.ai_reply?.reply[0].context_type, "text")
        XCTAssertEqual(replyComponent.ai_reply?.reply[0].context, "AI answer")
        XCTAssertEqual(replyComponent.ai_reply?.reply[1].context_type, "pic")
        XCTAssertEqual(replyComponent.ai_reply?.reply[1].context, "https://cdn.example.com/a.png")
        XCTAssertEqual(replyComponent.ai_reply?.reply[2].context_type, "media")
        XCTAssertEqual(replyComponent.ai_reply?.reply[2].context, "https://cdn.example.com/files/report.pdf?token=1")
    }

    func testNativeTemplateMessagePresentationKeepsWidgetTemplateMediaFields() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "3",
                message: ##"{"title":"FAQ","type":"default","payload":{"text":"Choose a topic","attachments":[{"media_type":"image","url":"https://cdn.example.com/cover.png"},{"media_type":"video","url":"https://cdn.example.com/demo.mp4"},{"media_type":"audio","url":"https://cdn.example.com/voice.mp3","duration":32000}],"buttons":[{"type":"postback","text":"Track order","label":"Track","payload":"track"},{"type":"web_url","text":"Open help","payload":"help","url":"https://help.example.com"}],"session_id":"session_1","branches":[{"title":"Orders","postback":"orders"}],"promotional_card":{"type":"discount","text":"Save now","text_color":"#111111","btn_color":"#222222","image":"https://cdn.example.com/card.png","discount":80,"countdown":10},"likes":{"like":"Like","unlike":"Unlike"}}}"##
            )
        )

        XCTAssertEqual(component.kind, .template)
        XCTAssertEqual(component.summary, "Choose a topic")
        XCTAssertEqual(component.template_message?.title, "FAQ")
        XCTAssertEqual(component.template_message?.type, "default")
        XCTAssertEqual(component.template_message?.payload.text, "Choose a topic")
        XCTAssertEqual(component.template_message?.payload.attachments.count, 3)
        XCTAssertEqual(component.template_message?.payload.attachments[0].media_type, "image")
        XCTAssertEqual(component.template_message?.payload.attachments[0].url, "https://cdn.example.com/cover.png")
        XCTAssertEqual(component.template_message?.payload.attachments[1].media_type, "video")
        XCTAssertEqual(component.template_message?.payload.attachments[1].url, "https://cdn.example.com/demo.mp4")
        XCTAssertEqual(component.template_message?.payload.attachments[2].media_type, "audio")
        XCTAssertEqual(component.template_message?.payload.attachments[2].url, "https://cdn.example.com/voice.mp3")
        XCTAssertEqual(component.template_message?.payload.attachments[2].duration, 32_000)
        XCTAssertEqual(component.template_message?.payload.buttons.count, 2)
        XCTAssertEqual(component.template_message?.payload.buttons[0].type, "postback")
        XCTAssertEqual(component.template_message?.payload.buttons[0].text, "Track order")
        XCTAssertEqual(component.template_message?.payload.buttons[0].label, "Track")
        XCTAssertEqual(component.template_message?.payload.buttons[0].payload, "track")
        XCTAssertNil(component.template_message?.payload.buttons[0].url)
        XCTAssertEqual(component.template_message?.payload.buttons[1].type, "web_url")
        XCTAssertEqual(component.template_message?.payload.buttons[1].text, "Open help")
        XCTAssertEqual(component.template_message?.payload.buttons[1].payload, "help")
        XCTAssertEqual(component.template_message?.payload.buttons[1].url, "https://help.example.com")
        XCTAssertEqual(component.template_message?.payload.session_id, "session_1")
        XCTAssertEqual(component.template_message?.payload.branches?.count, 1)
        XCTAssertEqual(component.template_message?.payload.branches?[0].title, "Orders")
        XCTAssertEqual(component.template_message?.payload.branches?[0].postback, "orders")
        XCTAssertEqual(component.template_message?.payload.promotional_card?.type, "discount")
        XCTAssertEqual(component.template_message?.payload.promotional_card?.text, "Save now")
        XCTAssertEqual(component.template_message?.payload.promotional_card?.text_color, "#111111")
        XCTAssertEqual(component.template_message?.payload.promotional_card?.btn_color, "#222222")
        XCTAssertEqual(component.template_message?.payload.promotional_card?.image, "https://cdn.example.com/card.png")
        XCTAssertEqual(component.template_message?.payload.promotional_card?.discount, 80)
        XCTAssertEqual(component.template_message?.payload.promotional_card?.countdown, 10)
        XCTAssertEqual(component.template_message?.payload.likes?.like, "Like")
        XCTAssertEqual(component.template_message?.payload.likes?.unlike, "Unlike")
    }

    func testNativeTemplateMessagePresentationKeepsWidgetButtonsWhenDefaultFieldsAreMissing() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "3",
                message: #"{"payload":{"text":"Choose","buttons":[{"type":"postback","text":"Yes","payload":"yes"}]}}"#
            )
        )

        XCTAssertEqual(component.kind, .template)
        XCTAssertEqual(component.template_message?.title, "")
        XCTAssertEqual(component.template_message?.type, "default")
        XCTAssertEqual(component.template_message?.payload.text, "Choose")
        XCTAssertEqual(component.template_message?.payload.attachments.count, 0)
        XCTAssertEqual(component.template_message?.payload.buttons.count, 1)
        XCTAssertEqual(component.template_message?.payload.buttons[0].type, "postback")
        XCTAssertEqual(component.template_message?.payload.buttons[0].text, "Yes")
        XCTAssertEqual(component.template_message?.payload.buttons[0].payload, "yes")
    }

    func testNativeTemplateMessagePresentationKeepsWidgetButtonOnlyTemplate() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "3",
                message: #"{"payload":{"buttons":[{"type":"postback","text":"Yes","payload":"yes"}]}}"#
            )
        )

        XCTAssertEqual(component.kind, .template)
        XCTAssertEqual(component.template_message?.type, "default")
        XCTAssertEqual(component.template_message?.payload.text, "")
        XCTAssertEqual(component.template_message?.payload.attachments.count, 0)
        XCTAssertEqual(component.template_message?.payload.buttons.count, 1)
        XCTAssertEqual(component.template_message?.payload.buttons[0].text, "Yes")
        XCTAssertEqual(component.template_message?.payload.buttons[0].payload, "yes")
    }

    func testNativeInviteEvalutionMessagePresentationKeepsWidgetScorePayloadFields() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "3",
                message: #"{"type":"invite_evalution","payload":{"session_id":"session_1","flow_id":"flow_1","step_log_id":"step_1","invite_evaluation_id":"invite_1","invite_evaluation_order_id":"order_1"}}"#
            )
        )

        XCTAssertEqual(component.kind, .template)
        XCTAssertEqual(component.summary, "您对本次服务满意吗？")
        XCTAssertEqual(component.invite_evalution?.session_id, "session_1")
        XCTAssertEqual(component.invite_evalution?.flow_id, "flow_1")
        XCTAssertEqual(component.invite_evalution?.step_log_id, "step_1")
        XCTAssertEqual(component.invite_evalution?.invite_evaluation_id, "invite_1")
        XCTAssertEqual(component.invite_evalution?.invite_evaluation_order_id, "order_1")
    }

    func testNativeSameProductMessagePresentationKeepsWidgetProductListFields() async throws {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: ChatMessage(
                msgType: "46",
                message: #"[{"title":"Similar items","sub_title":"For you","content":"Recommended","goods_id":"goods_1","goods_name":"Blue Shoes","goods_link":"https://shop.example.com/blue-shoes","original_price":"129.00","sale_price":"99.00","currency":"USD","currency_code":"$","desc":"Running shoes","main_image":"https://cdn.example.com/blue.png","image1":"https://cdn.example.com/blue-1.png","image2":"https://cdn.example.com/blue-2.png","score":"0.98"}]"#
            )
        )

        XCTAssertEqual(component.kind, .sameProduct)
        XCTAssertEqual(component.summary, "Blue Shoes")
        XCTAssertEqual(component.same_product.count, 1)
        XCTAssertEqual(component.same_product[0].title, "Similar items")
        XCTAssertEqual(component.same_product[0].sub_title, "For you")
        XCTAssertEqual(component.same_product[0].content, "Recommended")
        XCTAssertEqual(component.same_product[0].goods_id, "goods_1")
        XCTAssertEqual(component.same_product[0].goods_name, "Blue Shoes")
        XCTAssertEqual(component.same_product[0].goods_link, "https://shop.example.com/blue-shoes")
        XCTAssertEqual(component.same_product[0].original_price, "129.00")
        XCTAssertEqual(component.same_product[0].sale_price, "99.00")
        XCTAssertEqual(component.same_product[0].currency, "USD")
        XCTAssertEqual(component.same_product[0].currency_code, "$")
        XCTAssertEqual(component.same_product[0].desc, "Running shoes")
        XCTAssertEqual(component.same_product[0].main_image, "https://cdn.example.com/blue.png")
        XCTAssertEqual(component.same_product[0].image1, "https://cdn.example.com/blue-1.png")
        XCTAssertEqual(component.same_product[0].image2, "https://cdn.example.com/blue-2.png")
        XCTAssertEqual(component.same_product[0].score, "0.98")
    }

    func testRuntimeStateObserverReceivesWidgetStoreChanges() async throws {
        let runtime = SalesmartlyRuntime()
        var snapshots: [ChatRuntimeState] = []

        let observerId = runtime.observeState { state in
            snapshots.append(state)
        }

        runtime.openChat()

        XCTAssertTrue(snapshots.contains { $0.showWrapper })

        runtime.receiveMessage(
            sequenceId: "observer_message_1",
            senderType: "2",
            msgType: "1",
            message: "Observed message",
            sendTime: 1_779_860_001_111,
            chatUserId: "chat_user_1"
        )

        XCTAssertEqual(snapshots.last?.messages.last?.id, "observer_message_1")

        let snapshotCount = snapshots.count
        runtime.removeStateObserver(observerId)
        runtime.closeChat()

        XCTAssertEqual(snapshots.count, snapshotCount)
    }

    #if canImport(UIKit) && canImport(SwiftUI)
    @MainActor
    func testUIKitHostControllerSharesRuntimeWithSwiftUIHost() async throws {
        let runtime = SalesmartlyRuntime()
        let controller = SalesmartlyChatViewController(runtime: runtime)

        SalesmartlyChat.reset(runtime: runtime)
        SalesmartlyChat.openChat()

        XCTAssertTrue(controller.runtime.state.showWrapper)
    }
    #endif
}
#else
import SalesmartlyChat

struct SalesmartlyChatTestsUnavailable {
    let reason = "XCTest is unavailable in the active Command Line Tools environment."
}
#endif
