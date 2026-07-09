import Foundation

/// 对齐 widget main:src/install/loader.ts 与线上 project_*.js 外层脚本，描述 iOS 原生 SDK 从宿主脚本入口解析出的最小启动信息。
public struct SalesmartlyProjectScriptBootstrap: Equatable {
    /// 对齐线上 project_*.js 的 window.__ssc.license，作为后续 plugin/info、token、Socket 连接的插件标识。
    public var license: String
    /// 对齐线上 project_*.js 的 deUrl atob(...)，记录 install.js 默认来源域名。
    public var defaultInstallOrigin: String
    /// 对齐线上 project_*.js 的 path，记录 Web widget install.js 路径，仅用于事实核验和诊断，不在 iOS 侧运行 Web bundle。
    public var installPath: String
    /// 对齐线上 project_*.js 中 csUrl + path 的拼接语义，记录当前脚本来源下的 install.js URL。
    public var resolvedInstallURL: URL

    /// 对齐线上 project_*.js 外层脚本字段，构造 iOS 原生初始化所需的 license 与 install 诊断信息。
    public init(license: String, defaultInstallOrigin: String, installPath: String, resolvedInstallURL: URL) {
        self.license = license
        self.defaultInstallOrigin = defaultInstallOrigin
        self.installPath = installPath
        self.resolvedInstallURL = resolvedInstallURL
    }
}

/// 对齐 widget main:src/install/loader.ts 之前的 project_*.js 脚本拉取动作，供测试注入 fixture，生产使用 URLSession。
protocol SalesmartlyProjectScriptFetching: AnyObject {
    /// 对齐 Web 宿主 script src 加载 project_*.js 的网络请求，返回脚本文本。
    func fetchProjectScript(from url: URL) async throws -> String
}

/// 对齐 Web 宿主通过 script src 加载 project_*.js 的默认实现，iOS SDK 只读取外层配置脚本，不执行其中 JS。
final class SalesmartlyURLSessionProjectScriptFetcher: SalesmartlyProjectScriptFetching {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProjectScript(from url: URL) async throws -> String {
        let (data, _) = try await session.data(from: url)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

/// 对齐线上 project_*.js 的 license/deUrl/path 字面量解析；不得解析或运行压缩后的 widget bundle。
enum SalesmartlyProjectScriptParser {
    enum ParseError: Error, Equatable {
        case missingLicense
        case missingInstallOrigin
        case missingInstallPath
        case invalidInstallURL
    }

    /// 对齐线上 project_*.js：读取 window.__ssc.license、deUrl atob(...) 与 path。
    static func parse(_ script: String, scriptURL: URL) throws -> SalesmartlyProjectScriptBootstrap {
        guard let license = firstMatch(
            in: script,
            pattern: #"__ssc\.license\s*=\s*['"]([^'"]+)['"]"#
        ) else {
            throw ParseError.missingLicense
        }

        guard let installOriginBase64 = firstMatch(
            in: script,
            pattern: #"deUrl\s*=\s*atob\(['"]([^'"]+)['"]\)"#
        ),
              let installOriginData = Data(base64Encoded: installOriginBase64),
              let defaultInstallOrigin = String(data: installOriginData, encoding: .utf8)
        else {
            throw ParseError.missingInstallOrigin
        }

        guard let installPath = firstMatch(
            in: script,
            pattern: #"path\s*=\s*['"]([^'"]+)['"]"#
        ) else {
            throw ParseError.missingInstallPath
        }

        let resolvedOrigin = scriptURL.scheme.flatMap { scheme -> String? in
            guard let host = scriptURL.host else {
                return nil
            }
            let port = scriptURL.port.map { ":\($0)" } ?? ""
            return "\(scheme)://\(host)\(port)"
        } ?? defaultInstallOrigin
        guard let resolvedInstallURL = URL(string: "\(resolvedOrigin)\(installPath)") else {
            throw ParseError.invalidInstallURL
        }

        return SalesmartlyProjectScriptBootstrap(
            license: license,
            defaultInstallOrigin: defaultInstallOrigin,
            installPath: installPath,
            resolvedInstallURL: resolvedInstallURL
        )
    }

    private static func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let valueRange = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return String(text[valueRange])
    }
}
