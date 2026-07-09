import CryptoKit
import Foundation

/// 对齐 widget main:src/constants/env.ts 的运行环境域名集合；plugin_sign 同步 Android `CommonRequestFactory` 默认密钥，polling secret 同步 Web 公共常量。
public struct SalesmartlyEnvironment: Equatable {
    /// 对齐 widget main:src/constants/plugin.ts 的 POLLING_REQUEST_SECRET，用于 plugin/info、轮询类请求的 external-sign。
    public static let defaultPollingRequestSecret = "62767a26b6abd87a258eeb52d16371ee"
    /// 对齐 Android `CommonRequestFactory.kt` 的 PLUGIN_REQUEST_SECRET，用于 create-user 等普通 API 的 plugin_sign。
    public static let defaultPluginRequestSecret = "9c2210efee9b603e09f8d742917bb538"

    /// 对齐 widget main:src/constants/env.ts 的 BASE_HOST。
    public var baseAPIURL: URL
    /// 对齐 widget main:src/constants/env.ts 的 WS_HOST。
    public var webSocketURL: URL
    /// 对齐 widget main:src/constants/env.ts 的 WS_HTTP。
    public var webSocketHTTPURL: URL
    /// 对齐 widget main:.env.* 的 VITE_CENTRIFUGO_HOST，用于 SSE EventSource 下行连接。
    public var centrifugoURL: URL
    /// 对齐 widget main:src/constants/env.ts 的 LOG_HOST。
    public var logURL: URL
    /// 对齐 widget main:src/constants/env.ts 的 WIDGET_HOST。
    public var widgetURL: URL
    /// 对齐 widget main:src/api/axios.ts 的 SECRET；生产值由构建注入。
    public var pluginSigningSecret: String
    /// 对齐 widget main:src/constants/plugin.ts 的 POLLING_REQUEST_SECRET；默认同步 Web 公共常量，宿主仍可覆盖。
    public var pollingRequestSecret: String

    /// 对齐 widget main:src/constants/env.ts 的环境常量，允许测试或宿主构建注入域名与签名 secret。
    public init(
        baseAPIURL: URL,
        webSocketURL: URL,
        webSocketHTTPURL: URL,
        centrifugoURL: URL = URL(string: "https://events.salesmartly.com/")!,
        logURL: URL,
        widgetURL: URL,
        pluginSigningSecret: String = SalesmartlyEnvironment.defaultPluginRequestSecret,
        pollingRequestSecret: String = SalesmartlyEnvironment.defaultPollingRequestSecret
    ) {
        self.baseAPIURL = baseAPIURL
        self.webSocketURL = webSocketURL
        self.webSocketHTTPURL = webSocketHTTPURL
        self.centrifugoURL = centrifugoURL
        self.logURL = logURL
        self.widgetURL = widgetURL
        self.pluginSigningSecret = pluginSigningSecret
        self.pollingRequestSecret = pollingRequestSecret
    }

    /// 对齐线上 widget bundle 的生产域名；plugin_sign 默认同步 Android `CommonRequestFactory`，宿主仍可覆盖。
    public static func production(
        pluginSigningSecret: String = SalesmartlyEnvironment.defaultPluginRequestSecret,
        pollingRequestSecret: String = SalesmartlyEnvironment.defaultPollingRequestSecret
    ) -> SalesmartlyEnvironment {
        SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api.salesmartly.com/")!,
            webSocketURL: URL(string: "wss://msg-ws.salesmartly.com")!,
            webSocketHTTPURL: URL(string: "https://msg.salesmartly.com/")!,
            centrifugoURL: URL(string: "https://events.salesmartly.com/")!,
            logURL: URL(string: "https://srz.salesmartly.com/")!,
            widgetURL: URL(string: "https://widget.salesmartly.com/")!,
            pluginSigningSecret: pluginSigningSecret,
            pollingRequestSecret: pollingRequestSecret
        )
    }

    /// 对齐 Android `ProjectScriptConfigLoader` 的 pre install path 端点推导。
    public static func pre(
        pluginSigningSecret: String = SalesmartlyEnvironment.defaultPluginRequestSecret,
        pollingRequestSecret: String = SalesmartlyEnvironment.defaultPollingRequestSecret
    ) -> SalesmartlyEnvironment {
        SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api-pre.salesmartly.com/")!,
            webSocketURL: URL(string: "wss://msg-ws-pre.salesmartly.com")!,
            webSocketHTTPURL: URL(string: "https://msg-pre.salesmartly.com/")!,
            centrifugoURL: URL(string: "https://events-pre.salesmartly.com/")!,
            logURL: URL(string: "https://srz-pre.salesmartly.com/")!,
            widgetURL: URL(string: "https://widget-pre.salesmartly.com/")!,
            pluginSigningSecret: pluginSigningSecret,
            pollingRequestSecret: pollingRequestSecret
        )
    }

    /// 对齐 Android `ProjectScriptConfigLoader` 的 dev install path 端点推导。
    public static func dev(
        pluginSigningSecret: String = SalesmartlyEnvironment.defaultPluginRequestSecret,
        pollingRequestSecret: String = SalesmartlyEnvironment.defaultPollingRequestSecret
    ) -> SalesmartlyEnvironment {
        SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api-dev.salesmartly.com/")!,
            webSocketURL: URL(string: "wss://msg-ws-dev.salesmartly.com")!,
            webSocketHTTPURL: URL(string: "https://msg-dev.salesmartly.com/")!,
            centrifugoURL: URL(string: "https://ss-centrifugo-dev.xmp.one")!,
            logURL: URL(string: "https://srz-dev.salesmartly.com/")!,
            widgetURL: URL(string: "https://widget-dev.salesmartly.com/")!,
            pluginSigningSecret: pluginSigningSecret,
            pollingRequestSecret: pollingRequestSecret
        )
    }

    /// 对齐 widget main:.env.testing1 与用户提供的 testing1 install path 端点推导。
    public static func test1(
        pluginSigningSecret: String = SalesmartlyEnvironment.defaultPluginRequestSecret,
        pollingRequestSecret: String = SalesmartlyEnvironment.defaultPollingRequestSecret
    ) -> SalesmartlyEnvironment {
        SalesmartlyEnvironment(
            baseAPIURL: URL(string: "https://api-test1.salesmartly.com/")!,
            webSocketURL: URL(string: "wss://msg-ws-test1.salesmartly.com")!,
            webSocketHTTPURL: URL(string: "https://msg-test1.salesmartly.com")!,
            centrifugoURL: URL(string: "https://ss-centrifugo-test1.xmp.one")!,
            logURL: URL(string: "https://api-test1.salesmartly.com/")!,
            widgetURL: URL(string: "https://widget-test1.salesmartly.com/")!,
            pluginSigningSecret: pluginSigningSecret,
            pollingRequestSecret: pollingRequestSecret
        )
    }

    /// 对齐 Android `ProjectScriptConfigLoader.parseConfig`，根据 project_*.js 中已确认的 install path 选择运行环境。
    static func projectScriptEnvironment(installPath: String) -> SalesmartlyEnvironment {
        if installPath.range(of: #"/chat/widget-v2/dev/install\.js"#, options: .regularExpression) != nil {
            return .dev()
        }
        if installPath.range(of: #"/chat/widget-v2/pre/install\.js"#, options: .regularExpression) != nil {
            return .pre()
        }
        if installPath.range(of: #"/chat/widget-v2/testing1/install\.js"#, options: .regularExpression) != nil {
            return .test1()
        }
        return .production()
    }

    /// 对齐 Android `EndpointResolver` 的 config 初始化域名推导：`requestOriginURL` 读取 Android `r_o_url` base64 后由 `app-*` 推导 api/msg/msg-ws，`widgetHost` 独立决定 widget 域名。
    public static func androidEndpointEnvironment(
        requestOriginURL: String?,
        widgetHost: String?
    ) -> SalesmartlyEnvironment {
        let placeholderURL = URL(string: "https://example.invalid/")!
        let placeholderEnvironment = SalesmartlyEnvironment(
            baseAPIURL: placeholderURL,
            webSocketURL: placeholderURL,
            webSocketHTTPURL: placeholderURL,
            centrifugoURL: placeholderURL,
            logURL: placeholderURL,
            widgetURL: placeholderURL
        )
        guard let requestOriginURL,
              let originURL = decodedAndroidRequestOriginURL(requestOriginURL) ?? normalizedURL(requestOriginURL) else {
            if let widgetURL = widgetHost.flatMap(normalizedURL(_:)) {
                var environment = placeholderEnvironment
                environment.widgetURL = widgetURL
                return environment
            }
            return placeholderEnvironment
        }

        let baseAPIURL = appOriginURL(originURL, replacingAppPrefixWith: "api")
            .map(ensuringTrailingSlash(_:)) ?? placeholderEnvironment.baseAPIURL
        let webSocketHTTPURL = appOriginURL(originURL, replacingAppPrefixWith: "msg")
            .map(ensuringTrailingSlash(_:)) ?? placeholderEnvironment.webSocketHTTPURL
        let webSocketURL = appOriginURL(originURL, replacingAppPrefixWith: "msg-ws", scheme: "wss")
            .map(ensuringTrailingSlash(_:)) ?? placeholderEnvironment.webSocketURL
        let widgetURL = widgetHost.flatMap(normalizedURL(_:))
            ?? appOriginURL(originURL, replacingAppPrefixWith: "widget").map(ensuringTrailingSlash(_:))
            ?? placeholderEnvironment.widgetURL

        return SalesmartlyEnvironment(
            baseAPIURL: baseAPIURL,
            webSocketURL: webSocketURL,
            webSocketHTTPURL: webSocketHTTPURL,
            centrifugoURL: placeholderEnvironment.centrifugoURL,
            logURL: baseAPIURL,
            widgetURL: widgetURL,
            pluginSigningSecret: placeholderEnvironment.pluginSigningSecret,
            pollingRequestSecret: placeholderEnvironment.pollingRequestSecret
        )
    }

    private static func decodedAndroidRequestOriginURL(_ value: String) -> URL? {
        guard let data = Data(base64Encoded: value),
              let decoded = String(data: data, encoding: .utf8) else {
            return nil
        }
        return normalizedURL(decoded)
    }

    private static func normalizedURL(_ value: String) -> URL? {
        var normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedValue.isEmpty else {
            return nil
        }
        if normalizedValue.hasSuffix("/") {
            normalizedValue.removeLast()
        }
        guard let url = URL(string: normalizedValue),
              url.scheme != nil,
              url.host != nil else {
            return nil
        }
        return ensuringTrailingSlash(url)
    }

    private static func appOriginURL(
        _ url: URL,
        replacingAppPrefixWith prefix: String,
        scheme: String? = nil
    ) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return nil
        }
        components.scheme = scheme ?? components.scheme
        components.host = host.replacingOccurrences(
            of: #"^app"#,
            with: prefix,
            options: .regularExpression
        )
        components.path = ""
        components.query = nil
        components.fragment = nil
        return components.url
    }

    private static func ensuringTrailingSlash(_ url: URL) -> URL {
        var value = url.absoluteString
        if !value.hasSuffix("/") {
            value += "/"
        }
        return URL(string: value) ?? url
    }

}

/// 对齐 widget main:src/api/axios.ts 的请求上下文公共参数。
public struct SalesmartlyPluginRequestContext: Equatable {
    /// 对齐 widget main:src/constants/plugin.ts 的 PLUGIN_ID。
    public var pluginId: String
    /// 对齐 widget main:src/constants/plugin.ts 的 CHAT_MODE/env。
    public var mode: String
    /// 对齐 widget main:src/constants/plugin.ts 的 OVER_TIME。
    public var overTime: String
    /// 对齐 widget main:src/api/axios.ts 的 _lt。
    public var localToken: String
    /// 对齐 widget main:src/api/axios.ts 的 _u。
    public var uid: String
    /// 对齐 widget main:src/api/axios.ts 的 _xma_。
    public var projectId: String
    /// 对齐 widget main:src/api/axios.ts 的 Date.now()。
    public var timestampMilliseconds: Int64

    public init(
        pluginId: String,
        mode: String = "chat",
        overTime: String = "",
        localToken: String = "",
        uid: String = "",
        projectId: String = "",
        timestampMilliseconds: Int64? = nil
    ) {
        self.pluginId = pluginId
        self.mode = mode
        self.overTime = overTime
        self.localToken = localToken
        self.uid = uid
        self.projectId = projectId
        self.timestampMilliseconds = timestampMilliseconds ?? Int64(Date().timeIntervalSince1970 * 1000)
    }
}

/// 对齐 widget main:src/api/axios.ts 的 genSign，按 key 排序后执行 MD5(secret&k=v...)。
public enum SalesmartlyRequestSigner {
    /// 对齐 widget main:src/api/axios.ts 的 genSign，供 HTTP builder 生成 plugin_sign 或 external-sign。
    public static func md5Sign(payload: [String: String], secret: String) -> String {
        let sorted = payload.keys.sorted().map { key in
            "\(key)=\(payload[key] ?? "")"
        }.joined(separator: "&")
        let digest = Insecure.MD5.hash(data: Data("\(secret)&\(sorted)".utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

/// 对齐 widget main:src/api/axios.ts 的 createRequest，将 runtime transport 请求转换为 URLRequest。
struct SalesmartlyHTTPRequestBuilder {
    var environment: SalesmartlyEnvironment
    var context: SalesmartlyPluginRequestContext

    func makeURLRequest(for request: SalesmartlyTransportRequest) throws -> URLRequest {
        let method = request.method ?? .get
        var requestPayload = stringPayload(from: request.payload)
        requestPayload.merge(request.query) { _, new in new }
        let commonPayload = commonPayload()
        var queryPayload = request.query
        commonPayload.forEach { key, value in
            queryPayload[key] = value
        }

        if request.externalSign {
            let signPayload: [String: String] = method == .get ? queryPayload : requestPayload
            queryPayload.removeValue(forKey: "plugin_sign")
            var urlRequest = try makeBaseURLRequest(for: request, queryPayload: queryPayload, method: method)
            urlRequest.setValue(
                SalesmartlyRequestSigner.md5Sign(payload: signPayload, secret: environment.pollingRequestSecret),
                forHTTPHeaderField: "external-sign"
            )
            if method != .get {
                applyBody(requestPayload, encoding: request.bodyEncoding, to: &urlRequest)
            }
            return urlRequest
        }

        let pluginSignPayload: [String: String] = method == .get ? queryPayload : requestPayload
        queryPayload["plugin_sign"] = SalesmartlyRequestSigner.md5Sign(
            payload: pluginSignPayload,
            secret: environment.pluginSigningSecret
        )
        var urlRequest = try makeBaseURLRequest(for: request, queryPayload: queryPayload, method: method)
        if method != .get {
            applyBody(requestPayload, encoding: request.bodyEncoding, to: &urlRequest)
        }
        return urlRequest
    }

    private func makeBaseURLRequest(
        for request: SalesmartlyTransportRequest,
        queryPayload: [String: String],
        method: SalesmartlyHTTPMethod
    ) throws -> URLRequest {
        let baseURL = baseURL(for: request.path ?? "")
        let path = normalizedPath(request.path ?? "")
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = queryPayload
            .keys
            .sorted()
            .map { key in URLQueryItem(name: key, value: queryPayload[key] ?? "") }
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

    private func baseURL(for path: String) -> URL {
        let normalized = normalizedPath(path)
        if normalized.hasPrefix("plugin/") {
            return environment.widgetURL
        }
        if normalized.hasPrefix("chat/chat-msg/") ||
            normalized.hasPrefix("chat/chat-auto/") {
            return environment.webSocketHTTPURL
        }
        return environment.baseAPIURL
    }

    private func normalizedPath(_ path: String) -> String {
        var value = path
        while value.hasPrefix("/") {
            value.removeFirst()
        }
        return value
    }

    private func commonPayload() -> [String: String] {
        [
            "plugin_id": context.pluginId,
            "over_time": context.overTime,
            "env": context.mode,
            "_": String(context.timestampMilliseconds),
            "_lt": context.localToken,
            "_u": context.uid,
            "_xma_": context.projectId,
        ]
    }

    private func stringPayload(from payload: [String: Any]) -> [String: String] {
        var result: [String: String] = [:]
        payload.forEach { key, value in
            result[key] = String(describing: value)
        }
        return result
    }

    private func formBody(from payload: [String: String]) -> Data {
        payload.keys.sorted().map { key in
            "\(percentEncode(key))=\(percentEncode(payload[key] ?? ""))"
        }.joined(separator: "&").data(using: .utf8) ?? Data()
    }

    private func applyBody(_ payload: [String: String], encoding: SalesmartlyHTTPBodyEncoding, to request: inout URLRequest) {
        switch encoding {
        case .form:
            request.httpBody = formBody(from: payload)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        case .json:
            request.httpBody = jsonBody(from: payload)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }

    private func jsonBody(from payload: [String: String]) -> Data {
        (try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data()
    }

    private func percentEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.!~*'()")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}
