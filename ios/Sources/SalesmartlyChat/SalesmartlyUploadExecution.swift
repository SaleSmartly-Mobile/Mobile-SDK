import CryptoKit
import Foundation

/// 对齐 widget main:src/helper/useUpload.ts 的 File 运行态缓存，承载系统 picker 选中文件的本地二进制和预览地址。
struct SalesmartlyPickedUploadFile: Equatable {
    var name: String
    var data: Data
    var isImage: Bool
    var isVideo: Bool
    var localURL: String
}

/// 对齐 widget main:src/helper/useUpload.ts 的 uploadFile 链路，执行 OSS 配置获取与直传。
protocol SalesmartlyUploadExecuting: AnyObject {
    @MainActor
    func upload(_ request: SalesmartlyUploadExecutionRequest) async throws -> String
}

enum SalesmartlyUploadExecutionError: Error {
    case invalidConfigResponse
    case invalidUploadResponse
    case missingFileData
}

/// 对齐 widget main:src/api/sys/tools.ts 的 uploadOSSByUrl，使用 URLSession 获取 OSS 配置并 multipart 直传文件。
final class SalesmartlyURLSessionUploadExecutor: SalesmartlyUploadExecuting {
    private static let uploadConfigHTTPPath = "/sys/company/plugin/get-oss-config"
    private static let salesmartlyOssHost = "https://mix-ads.oss-accelerate.aliyuncs.com"
    private static let uploadObjectMaxSize = 1024 * 1024 * 1024
    private static let dewsMap = [
        "1": "default",
        "2": "public-read-write",
        "3": "public-read",
        "4": "private",
    ]
    private static let encodeURIComponentAllowedCharacters: CharacterSet = {
        var characters = CharacterSet.alphanumerics
        characters.insert(charactersIn: "-_.!~*'()")
        return characters
    }()

    private let environment: SalesmartlyEnvironment
    private let contextProvider: () -> SalesmartlyPluginRequestContext
    private let session: URLSession

    init(
        environment: SalesmartlyEnvironment,
        contextProvider: @escaping () -> SalesmartlyPluginRequestContext,
        session: URLSession = .shared
    ) {
        self.environment = environment
        self.contextProvider = contextProvider
        self.session = session
    }

    @MainActor
    func upload(_ request: SalesmartlyUploadExecutionRequest) async throws -> String {
        if request.fileData.isEmpty {
            throw SalesmartlyUploadExecutionError.missingFileData
        }
        let config = try await uploadConfig(for: request)
        let form = makeUploadOSSDirectForm(
            config: config,
            fileName: request.file.name,
            replaceName: request.replaceName,
            nowMilliseconds: Int64(Date().timeIntervalSince1970 * 1000),
            timeoutMilliseconds: request.uploadTimeoutMilliseconds
        )
        try await uploadFile(request, form: form)
        return form.objectURL
    }

    @MainActor
    private func uploadConfig(for request: SalesmartlyUploadExecutionRequest) async throws -> SalesmartlyOSSConfigCache {
        let transportRequest = SalesmartlyTransportRequest(
            kind: .http,
            eventName: nil,
            path: Self.uploadConfigHTTPPath,
            method: .post,
            query: [:],
            payload: request.uploadConfigPayload,
            externalSign: false
        )
        let urlRequest = try SalesmartlyHTTPRequestBuilder(
            environment: environment,
            context: contextProvider()
        ).makeURLRequest(for: transportRequest)
        let response = try await session.data(for: urlRequest)
        return try makeUploadOSSConfigCache(from: response.0)
    }

    private func makeUploadOSSConfigCache(from data: Data) throws -> SalesmartlyOSSConfigCache {
        guard let response = try JSONSerialization.jsonObject(with: data) as? SalesmartlyPayload,
              let responseData = response["data"] as? SalesmartlyPayload,
              let stsConfig = responseData["sts_config"] as? SalesmartlyPayload,
              let accessKeyId = uploadString(stsConfig["access_key_id"]),
              let accessKeySecret = uploadString(stsConfig["access_key_secret"]),
              let expiration = uploadString(stsConfig["expiration"]),
              let securityToken = uploadString(stsConfig["security_token"]),
              let path = uploadString(responseData["path"]) else {
            throw SalesmartlyUploadExecutionError.invalidConfigResponse
        }
        let dewsCode = uploadString(responseData["dews"]) ?? ""
        return SalesmartlyOSSConfigCache(
            stsConfig: SalesmartlyOSSSTSConfig(
                accessKeyId: accessKeyId,
                accessKeySecret: accessKeySecret,
                expiration: expiration,
                securityToken: securityToken
            ),
            path: path,
            effectiveTime: 0,
            dews: Self.dewsMap[dewsCode] ?? "default"
        )
    }

    private func makeUploadOSSDirectForm(
        config: SalesmartlyOSSConfigCache,
        fileName: String,
        replaceName: String,
        nowMilliseconds: Int64,
        timeoutMilliseconds: Int
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

    @MainActor
    private func uploadFile(_ request: SalesmartlyUploadExecutionRequest, form: SalesmartlyOSSDirectUploadForm) async throws {
        let boundary = "SalesmartlyBoundary-\(UUID().uuidString)"
        var urlRequest = URLRequest(url: URL(string: form.url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = TimeInterval(form.timeoutMilliseconds) / 1000
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = multipartBody(
            fields: form.fields,
            fileFieldName: form.fileFieldName,
            fileName: request.replaceName.isEmpty ? request.file.name : request.replaceName,
            fileData: request.fileData,
            mimeType: mimeType(fileName: request.file.name),
            boundary: boundary
        )
        let response = try await session.data(for: urlRequest)
        guard let httpResponse = response.1 as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw SalesmartlyUploadExecutionError.invalidUploadResponse
        }
    }

    private func multipartBody(
        fields: [String: String],
        fileFieldName: String,
        fileName: String,
        fileData: Data,
        mimeType: String,
        boundary: String
    ) -> Data {
        var data = Data()
        fields.keys.sorted().forEach { key in
            data.appendString("--\(boundary)\r\n")
            data.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            data.appendString("\(fields[key] ?? "")\r\n")
        }
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n--\(boundary)--\r\n")
        return data
    }

    private func uploadString(_ value: Any?) -> String? {
        if let value = value as? String, !value.isEmpty {
            return value
        }
        if let value = value as? Int {
            return String(value)
        }
        return nil
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

    private func mimeType(fileName: String) -> String {
        let ext = fileName.split(separator: ".").last.map { String($0).lowercased() } ?? ""
        if ext == "jpg" || ext == "jpeg" {
            return "image/jpeg"
        }
        if ext == "png" {
            return "image/png"
        }
        if ext == "mp4" {
            return "video/mp4"
        }
        if ext == "mov" {
            return "video/quicktime"
        }
        return "application/octet-stream"
    }
}

private extension Data {
    mutating func appendString(_ value: String) {
        append(Data(value.utf8))
    }
}
