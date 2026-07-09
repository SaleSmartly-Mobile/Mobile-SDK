import Foundation

/// 对齐 widget main:src/helper/realtime/sseClient.ts 的 EventSource 实例抽象，供 transport 启停 Centrifugo SSE 流并允许单测触发 onopen。
protocol SalesmartlySSEStreaming: AnyObject {
    func start()
    func stop()
}

/// 对齐 widget main:src/helper/realtime/sseClient.ts 的 new EventSource(url)，由 transport 创建实际 SSE stream。
typealias SalesmartlySSEStreamFactory = (
    URL,
    @escaping () -> Void,
    @escaping (SalesmartlyPayload) -> Void
) -> SalesmartlySSEStreaming

private func makeSalesmartlyURLSessionSSEStream(
    url: URL,
    onOpen: @escaping () -> Void,
    onPayload: @escaping (SalesmartlyPayload) -> Void
) -> SalesmartlySSEStreaming {
    SalesmartlyURLSessionSSEStream(url: url, onOpen: onOpen, onPayload: onPayload)
}

/// 对齐 widget main:src/api/axios.ts、src/api/api.request.ts 的真实 HTTP transport，负责 form 请求、签名和 JSON 响应回调。
final class SalesmartlyURLSessionTransport: SalesmartlyTransporting, @unchecked Sendable {
    /// 对齐 widget main:src/api/axios.ts 每次请求从 localStorage/Cookie 读取 _lt/_u/_xma_ 的语义。
    private let environment: SalesmartlyEnvironment
    private let contextProvider: () -> SalesmartlyPluginRequestContext
    private let session: URLSession
    private var responseHandler: SalesmartlyTransportResponseHandler?
    private var socketInboundEventHandler: SalesmartlySocketInboundEventHandler?
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 onMessage，下行 payload 由 runtime 决定 receive-message/notice 分发。
    private var sseInboundPayloadHandler: SalesmartlySSEInboundPayloadHandler?
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 eventSource 实例，iOS 用 URLSessionDataDelegate 承载。
    private var sseStream: SalesmartlySSEStreaming?
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 EventSource 构造点，生产使用 URLSession SSE，测试可注入可控 stream。
    private let sseStreamFactory: SalesmartlySSEStreamFactory
    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 authParams，stop 时复用该请求通知后端断开。
    private var sseDisconnectRequest: SalesmartlyTransportRequest?

    init(
        environment: SalesmartlyEnvironment,
        context: SalesmartlyPluginRequestContext,
        session: URLSession = .shared,
        sseStreamFactory: @escaping SalesmartlySSEStreamFactory = makeSalesmartlyURLSessionSSEStream
    ) {
        self.environment = environment
        self.contextProvider = { context }
        self.session = session
        self.sseStreamFactory = sseStreamFactory
    }

    /// 对齐 widget main:src/api/axios.ts 的 getInsideConfig，请求发出时读取最新 token/project_id 公共参数。
    init(
        environment: SalesmartlyEnvironment,
        contextProvider: @escaping () -> SalesmartlyPluginRequestContext,
        session: URLSession = .shared,
        sseStreamFactory: @escaping SalesmartlySSEStreamFactory = makeSalesmartlyURLSessionSSEStream
    ) {
        self.environment = environment
        self.contextProvider = contextProvider
        self.session = session
        self.sseStreamFactory = sseStreamFactory
    }

    func send(_ request: SalesmartlyTransportRequest) {
        send(request, completion: nil)
    }

    private func send(_ request: SalesmartlyTransportRequest, completion: (@Sendable () -> Void)?) {
        guard request.kind == .http else {
            completion?()
            return
        }

        do {
            let builder = SalesmartlyHTTPRequestBuilder(environment: environment, context: contextProvider())
            let urlRequest = try builder.makeURLRequest(for: request)
            let task = session.dataTask(with: urlRequest) { [weak self] data, _, _ in
                guard let self else {
                    return
                }
                let payload = Self.payload(from: data)
                self.responseHandler?(payload, request)
                completion?()
            }
            task.resume()
        } catch {
            responseHandler?([:], request)
            completion?()
        }
    }

    func setResponseHandler(_ handler: @escaping SalesmartlyTransportResponseHandler) {
        responseHandler = handler
    }

    func setSocketInboundEventHandler(_ handler: @escaping SalesmartlySocketInboundEventHandler) {
        socketInboundEventHandler = handler
    }

    func setSSEInboundPayloadHandler(_ handler: @escaping SalesmartlySSEInboundPayloadHandler) {
        sseInboundPayloadHandler = handler
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 EventSource.start；打开后先 sse-connect，再执行 join-room 等 onOpen 请求。
    func connectSSE(_ request: SalesmartlySSEConnectionRequest) {
        disconnectSSE()
        sseDisconnectRequest = request.disconnectRequest
        let stream = sseStreamFactory(
            request.eventSourceURL,
            { [weak self] in
                guard let self else {
                    return
                }
                self.send(request.connectRequest) { [weak self] in
                    guard let self else {
                        return
                    }
                    request.openRequests.forEach { self.send($0) }
                }
            },
            { [weak self] payload in
                self?.sseInboundPayloadHandler?(payload)
            }
        )
        sseStream = stream
        stream.start()
    }

    /// 对齐 widget main:src/helper/realtime/sseClient.ts 的 stop，关闭 EventSource 后通知后端 sse-disconnect。
    func disconnectSSE() {
        sseStream?.stop()
        sseStream = nil
        if let request = sseDisconnectRequest {
            sseDisconnectRequest = nil
            send(request)
        }
    }

    private static func payload(from data: Data?) -> SalesmartlyPayload {
        guard let data,
              let object = try? JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload
        else {
            return [:]
        }

        return object
    }
}

/// 对齐 widget main:src/helper/realtime/sseClient.ts 的 EventSource message.data 解析，只消费 SSE `data:` JSON payload。
final class SalesmartlyEventSourceParser {
    private var buffer = ""

    func append(_ data: Data) -> [SalesmartlyPayload] {
        guard let chunk = String(data: data, encoding: .utf8) else {
            return []
        }

        buffer += chunk.replacingOccurrences(of: "\r\n", with: "\n")
        var payloads: [SalesmartlyPayload] = []
        while let range = buffer.range(of: "\n\n") {
            let block = String(buffer[..<range.lowerBound])
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
            if let payload = payload(from: block) {
                payloads.append(payload)
            }
        }
        return payloads
    }

    private func payload(from block: String) -> SalesmartlyPayload? {
        let dataLines = block
            .split(separator: "\n", omittingEmptySubsequences: false)
            .compactMap { line -> String? in
                guard line.hasPrefix("data:") else {
                    return nil
                }
                var value = String(line.dropFirst("data:".count))
                if value.hasPrefix(" ") {
                    value.removeFirst()
                }
                return value
            }
        let dataText = dataLines.joined(separator: "\n")
        guard !dataText.isEmpty,
              let data = dataText.data(using: .utf8),
              let payload = try? JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload else {
            return nil
        }
        return payload
    }
}

/// 对齐 widget main:src/helper/realtime/sseClient.ts 的 EventSource 生命周期，用 URLSessionDataDelegate 承载 iOS 流式读取。
final class SalesmartlyURLSessionSSEStream: NSObject, SalesmartlySSEStreaming, URLSessionDataDelegate, @unchecked Sendable {
    private let url: URL
    private let onOpen: () -> Void
    private let onPayload: (SalesmartlyPayload) -> Void
    private let parser = SalesmartlyEventSourceParser()
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var hasOpened = false

    init(
        url: URL,
        onOpen: @escaping () -> Void,
        onPayload: @escaping (SalesmartlyPayload) -> Void
    ) {
        self.url = url
        self.onOpen = onOpen
        self.onPayload = onPayload
    }

    func start() {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        self.session = session
        let task = session.dataTask(with: request)
        self.task = task
        task.resume()
    }

    func stop() {
        task?.cancel()
        task = nil
        session?.invalidateAndCancel()
        session = nil
        hasOpened = false
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if !hasOpened {
            hasOpened = true
            onOpen()
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        parser.append(data).forEach(onPayload)
    }
}
