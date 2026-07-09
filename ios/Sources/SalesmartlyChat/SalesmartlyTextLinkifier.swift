import Foundation

/// 对齐 widget main:src/utils/tool.ts 的 replaceLink 输出片段，记录普通文本或可点击链接目标。
struct SalesmartlyTextLinkSegment: Equatable {
    /// 对齐 Web `<a>` 内部展示文本，保持用户看到的原始 URL 或邮箱文本。
    var text: String
    /// 对齐 Web `<a href>`，裸域名在原生端补为 https，邮箱补为 mailto。
    var destination: String?
}

/// 对齐 widget main:src/components/Bubble/TextMessage.vue 的 replaceLink(escapeHtml(text), { replaceEmail: true })，为 iOS 文本气泡生成可点击链接片段。
enum SalesmartlyTextLinkifier {
    private struct Match {
        var range: Range<String.Index>
        var segment: SalesmartlyTextLinkSegment
    }

    private static let excludedFileTLDs: Set<String> = [
        "jpg", "jpeg", "png", "gif", "svg", "webp", "pdf", "doc", "docx", "xls", "xlsx",
        "ppt", "pptx", "zip", "rar", "7z", "mp3", "mp4", "avi", "mov", "txt", "csv", "md",
        "apk", "dmg", "exe",
    ]
    private static let trailingPunctuation = CharacterSet(charactersIn: ".,!?;:)]}'\"、，。！？；：【】《》（）")
    private static let emailRegex = try! NSRegularExpression(
        pattern: #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"#
    )
    private static let urlRegex = try! NSRegularExpression(
        pattern: #"(?:(?:https?|wss?|ftps?)://)?(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,}|(?:\d{1,3}\.){3}\d{1,3})(?::\d+)?(?:[/?#][^\s，。！？、“”‘’《》〈〉（）【】『』；：]*)?"#
    )

    /// 对齐 Web replaceLink 的分段结果，供 SwiftUI Text 生成 link 属性并供单测验证 URL 识别口径。
    static func segments(in text: String) -> [SalesmartlyTextLinkSegment] {
        let matches = linkMatches(in: text)
        if matches.isEmpty {
            return [SalesmartlyTextLinkSegment(text: text, destination: nil)]
        }

        var segments: [SalesmartlyTextLinkSegment] = []
        var cursor = text.startIndex
        matches.forEach { match in
            if cursor < match.range.lowerBound {
                segments.append(
                    SalesmartlyTextLinkSegment(
                        text: String(text[cursor..<match.range.lowerBound]),
                        destination: nil
                    )
                )
            }
            segments.append(match.segment)
            cursor = match.range.upperBound
        }
        if cursor < text.endIndex {
            segments.append(SalesmartlyTextLinkSegment(text: String(text[cursor..<text.endIndex]), destination: nil))
        }
        return segments
    }

    private static func linkMatches(in text: String) -> [Match] {
        let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let emailMatches = emailRegex.matches(in: text, range: fullRange).compactMap { result -> Match? in
            guard let range = Range(result.range, in: text) else {
                return nil
            }
            let value = String(text[range])
            return Match(
                range: range,
                segment: SalesmartlyTextLinkSegment(text: value, destination: "mailto:\(value)")
            )
        }
        let urlMatches = urlRegex.matches(in: text, range: fullRange).compactMap { result -> Match? in
            guard let rawRange = Range(result.range, in: text),
                  !emailMatches.contains(where: { $0.range.overlaps(rawRange) }) else {
                return nil
            }
            let rawValue = String(text[rawRange])
            let value = rawValue.trimmingCharacters(in: trailingPunctuation)
            guard !value.isEmpty,
                  !isExcludedBareFileName(value),
                  let endIndex = text.index(rawRange.lowerBound, offsetBy: value.count, limitedBy: rawRange.upperBound) else {
                return nil
            }
            return Match(
                range: rawRange.lowerBound..<endIndex,
                segment: SalesmartlyTextLinkSegment(text: value, destination: destination(for: value))
            )
        }

        return (emailMatches + urlMatches).sorted { left, right in
            left.range.lowerBound < right.range.lowerBound
        }
    }

    private static func destination(for value: String) -> String {
        if value.range(of: #"^(https?|wss?|ftps?)://"#, options: .regularExpression) != nil {
            return value
        }
        return "https://\(value)"
    }

    private static func isExcludedBareFileName(_ value: String) -> Bool {
        if value.range(of: #"^(https?|wss?|ftps?)://"#, options: .regularExpression) != nil {
            return false
        }
        let host = value.split(whereSeparator: { "/?#".contains($0) }).first.map(String.init) ?? value
        let hostWithoutPort = host.replacingOccurrences(of: #":\d+$"#, with: "", options: .regularExpression)
        guard let tld = hostWithoutPort.split(separator: ".").last.map({ String($0).lowercased() }) else {
            return false
        }
        return excludedFileTLDs.contains(tld)
    }
}
