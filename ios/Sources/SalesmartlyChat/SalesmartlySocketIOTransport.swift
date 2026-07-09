import Foundation
#if canImport(SocketIO)
import SocketIO
#endif

/// 对齐 widget main:src/helper/socket.ts 的 Socket.io client 能力，抽象真实依赖以便单元测试注入。
protocol SalesmartlySocketIOClienting: AnyObject {
    /// 对齐 widget main:src/helper/socket.ts 的 io(wsHost, { transports, query, reconnectionAttempts })，并暴露 connect 事件给 Swift 侧发送缓冲。
    func connect(
        query: [String: Any],
        transports: [String],
        reconnectionAttempts: Int,
        socketIOProtocolVersion: SalesmartlySocketIOProtocolVersion,
        onConnect: @escaping () -> Void
    )
    /// 对齐 widget main:src/helper/socket.ts 的 socket.disconnect。
    func disconnect()
    /// 对齐 widget main:src/helper/socket.ts 的 socket.emit(eventName, JSON.stringify(payload), ack)。
    func emit(eventName: String, jsonPayload: String, ack: @escaping (SalesmartlyPayload) -> Void)
    /// 对齐 widget main:src/helper/socket.ts 的 socket.on(eventName)。
    func on(eventName: String, callback: @escaping (SalesmartlyPayload) -> Void)
    /// 对齐 widget main:src/helper/socket.ts 的 socket.off(eventName)。
    func off(eventName: String)
    /// 对齐 widget main:src/helper/socket.ts 的 removeEmitBuffer；真实 Swift client 无公开 sendBuffer 时由适配器保持 no-op。
    func removeBufferedEvent(_ eventName: String)
    /// 对齐 widget main:src/helper/socket.ts 的 pong 心跳监听。
    func addPongHandler(_ callback: @escaping () -> Void)
    /// 对齐 widget main:src/helper/socket.ts 的 socket.off("pong")。
    func removePongHandler()
    /// 对齐 widget main:src/helper/socket.ts 的 pong timeout 后 close/connect/reconnect。
    func reconnectAfterHeartbeatTimeout(delayMilliseconds: Int)
}

#if canImport(SocketIO)
/// 对齐 widget main:src/helper/socket.ts 的真实 Socket.IO Swift client 包装。
final class SalesmartlyDefaultSocketIOClient: SalesmartlySocketIOClienting {
    private let socketURL: URL
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    init(socketURL: URL) {
        self.socketURL = socketURL
    }

    func connect(
        query: [String: Any],
        transports: [String],
        reconnectionAttempts: Int,
        socketIOProtocolVersion: SalesmartlySocketIOProtocolVersion,
        onConnect: @escaping () -> Void
    ) {
        let socketIOVersion: SocketIOVersion
        switch socketIOProtocolVersion {
        case .two:
            socketIOVersion = .two
        }
        let configuration: SocketIOClientConfiguration = [
            .log(false),
            .compress,
            .forceWebsockets(transports.contains("websocket")),
            .connectParams(query),
            .reconnectAttempts(reconnectionAttempts),
            .version(socketIOVersion),
        ]
        let manager = SocketManager(socketURL: socketURL, config: configuration)
        self.manager = manager
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { _, _ in
            onConnect()
        }
        self.socket = socket
        socket.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }

    func emit(eventName: String, jsonPayload: String, ack: @escaping (SalesmartlyPayload) -> Void) {
        socket?.emitWithAck(eventName, jsonPayload).timingOut(after: 20) { data in
            ack(Self.payload(from: data.first))
        }
    }

    func on(eventName: String, callback: @escaping (SalesmartlyPayload) -> Void) {
        socket?.on(eventName) { data, _ in
            callback(Self.payload(from: data.first))
        }
    }

    func off(eventName: String) {
        socket?.off(eventName)
    }

    func removeBufferedEvent(_ eventName: String) {
        _ = eventName
    }

    func addPongHandler(_ callback: @escaping () -> Void) {
        socket?.on(clientEvent: .pong) { _, _ in
            callback()
        }
    }

    func removePongHandler() {
        socket?.off(clientEvent: .pong)
    }

    func reconnectAfterHeartbeatTimeout(delayMilliseconds: Int) {
        _ = delayMilliseconds
        socket?.disconnect()
        socket?.connect()
        socket?.emit("reconnect")
    }

    private static func payload(from value: Any?) -> SalesmartlyPayload {
        if let payload = value as? SalesmartlyPayload {
            return payload
        }
        if let string = value as? String,
           let data = string.data(using: .utf8),
           let payload = try? JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload {
            return payload
        }
        return [:]
    }
}
#endif

/// 对齐 widget main:src/helper/useSocket.ts 的 Socket.io transport，负责事件序列化、ack 回调和 inbound reducer 转发。
final class SalesmartlySocketIOTransport: SalesmartlyTransporting {
    private let client: SalesmartlySocketIOClienting
    private var responseHandler: SalesmartlyTransportResponseHandler?
    private var socketInboundEventHandler: SalesmartlySocketInboundEventHandler?
    private var registeredSocketEvents: Set<String> = []
    /// 对齐 widget main:src/helper/socket.ts 的 emit buffer；Swift Socket.IO 在 connected 前会拒绝 emit，因此这里记录连接前的 socket event。
    private var pendingSocketRequests: [SalesmartlyTransportRequest] = []
    /// 对齐 widget main:src/helper/socket.ts 的 socket.connected 状态，用于决定 join-room 是否需要等 connect 后补发。
    private var socketConnected = false

    init(client: SalesmartlySocketIOClienting) {
        self.client = client
    }

    #if canImport(SocketIO)
    convenience init(socketURL: URL) {
        self.init(client: SalesmartlyDefaultSocketIOClient(socketURL: socketURL))
    }
    #endif

    func send(_ request: SalesmartlyTransportRequest) {
        guard request.kind == .socketEvent, let eventName = request.eventName else {
            return
        }

        guard socketConnected else {
            pendingSocketRequests.append(request)
            return
        }

        emitSocketEvent(request, eventName: eventName)
    }

    /// 对齐 widget main:src/helper/socket.ts 的 socket.emit(eventName, JSON.stringify(payload), ack)，集中处理 ack 回写 runtime reducer。
    private func emitSocketEvent(_ request: SalesmartlyTransportRequest, eventName: String) {
        client.emit(eventName: eventName, jsonPayload: request.payloadJSONString()) { [weak self] payload in
            self?.responseHandler?(payload, request)
        }
    }

    func setResponseHandler(_ handler: @escaping SalesmartlyTransportResponseHandler) {
        responseHandler = handler
    }

    func setSocketInboundEventHandler(_ handler: @escaping SalesmartlySocketInboundEventHandler) {
        socketInboundEventHandler = handler
    }

    func connectSocket(_ request: SalesmartlySocketConnectionRequest) {
        socketConnected = false
        client.connect(
            query: request.query,
            transports: request.transports,
            reconnectionAttempts: request.reconnectionAttempts,
            socketIOProtocolVersion: request.socketIOProtocolVersion
        ) { [weak self] in
            self?.handleSocketConnected()
        }
    }

    func disconnectSocket() {
        socketConnected = false
        pendingSocketRequests.removeAll()
        client.disconnect()
    }

    func removeBufferedSocketEvent(_ eventName: String) {
        client.removeBufferedEvent(eventName)
    }

    func removeSocketEventHandlers(_ eventNames: [String]) {
        eventNames.forEach { eventName in
            client.off(eventName: eventName)
            registeredSocketEvents.remove(eventName)
        }
    }

    func addSocketEventHandlers(_ eventNames: [String]) {
        eventNames.forEach { eventName in
            guard !registeredSocketEvents.contains(eventName) else {
                return
            }
            registeredSocketEvents.insert(eventName)
            client.on(eventName: eventName) { [weak self] payload in
                self?.socketInboundEventHandler?(eventName, payload)
            }
        }
    }

    func addSocketPongHandler() {
        client.addPongHandler { [weak self] in
            self?.socketInboundEventHandler?("pong", [:])
        }
    }

    func removeSocketPongHandler() {
        client.removePongHandler()
    }

    func reconnectSocketAfterHeartbeatTimeout(delayMilliseconds: Int) {
        socketConnected = false
        client.reconnectAfterHeartbeatTimeout(delayMilliseconds: delayMilliseconds)
    }

    /// 对齐 widget main:src/helper/socket.ts 的连接后发送缓冲语义，确保 join-room 这类事件不会在 Swift Socket.IO 未连接时丢失。
    private func handleSocketConnected() {
        socketConnected = true
        let requests = pendingSocketRequests
        pendingSocketRequests.removeAll()
        requests.forEach { request in
            if let eventName = request.eventName {
                emitSocketEvent(request, eventName: eventName)
            }
        }
    }
}

/// 对齐 widget main:src/helper/useSocket.ts 与 src/api/api.request.ts 的双通道 transport，HTTP 与 Socket.io 共享同一 runtime reducer。
final class SalesmartlyCompositeTransport: SalesmartlyTransporting {
    private let httpTransport: SalesmartlyTransporting
    private let socketTransport: SalesmartlyTransporting

    init(httpTransport: SalesmartlyTransporting, socketTransport: SalesmartlyTransporting) {
        self.httpTransport = httpTransport
        self.socketTransport = socketTransport
    }

    func send(_ request: SalesmartlyTransportRequest) {
        switch request.kind {
        case .http:
            httpTransport.send(request)
        case .socketEvent:
            socketTransport.send(request)
        }
    }

    func setResponseHandler(_ handler: @escaping SalesmartlyTransportResponseHandler) {
        httpTransport.setResponseHandler(handler)
        socketTransport.setResponseHandler(handler)
    }

    func setSocketInboundEventHandler(_ handler: @escaping SalesmartlySocketInboundEventHandler) {
        socketTransport.setSocketInboundEventHandler(handler)
    }

    func setSSEInboundPayloadHandler(_ handler: @escaping SalesmartlySSEInboundPayloadHandler) {
        httpTransport.setSSEInboundPayloadHandler(handler)
    }

    func connectSocket(_ request: SalesmartlySocketConnectionRequest) {
        socketTransport.connectSocket(request)
    }

    func disconnectSocket() {
        socketTransport.disconnectSocket()
    }

    func connectSSE(_ request: SalesmartlySSEConnectionRequest) {
        httpTransport.connectSSE(request)
    }

    func disconnectSSE() {
        httpTransport.disconnectSSE()
    }

    func removeBufferedSocketEvent(_ eventName: String) {
        socketTransport.removeBufferedSocketEvent(eventName)
    }

    func removeSocketEventHandlers(_ eventNames: [String]) {
        socketTransport.removeSocketEventHandlers(eventNames)
    }

    func addSocketEventHandlers(_ eventNames: [String]) {
        socketTransport.addSocketEventHandlers(eventNames)
    }

    func addSocketPongHandler() {
        socketTransport.addSocketPongHandler()
    }

    func removeSocketPongHandler() {
        socketTransport.removeSocketPongHandler()
    }

    func reconnectSocketAfterHeartbeatTimeout(delayMilliseconds: Int) {
        socketTransport.reconnectSocketAfterHeartbeatTimeout(delayMilliseconds: delayMilliseconds)
    }
}
