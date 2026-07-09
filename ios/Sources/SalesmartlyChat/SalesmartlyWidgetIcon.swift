#if canImport(SwiftUI)
import SwiftUI
#if canImport(CoreText)
import CoreText
#endif

/// 对齐 widget main:src/components/Icon.vue 的 iconfont 使用方式，用 Web `type` 和尺寸驱动 iOS 原生图标绘制。
struct SalesmartlyWidgetIcon: View {
    /// 对齐 Web `<Icon :type="...">` 的真实 iconfont 类型名。
    var type: String
    /// 对齐 Web `<Icon :size="...">` 的字号尺寸。
    var size: CGFloat
    /// 对齐 Web icon 当前继承的 CSS color。
    var color: Color

    var body: some View {
        let _ = SalesmartlyIconFontRegistry.registerIfNeeded()
        let glyph = SalesmartlyIconFontGlyph.character(for: type)
        let frameWidth = SalesmartlyIconFontGlyph.frameWidth(for: type, size: size)
        Group {
            if let glyph {
                Text(glyph)
                    .font(.custom("ssc-iconfont", size: size))
                    .foregroundStyle(color)
            } else {
                Canvas { context, canvasSize in
                    var context = context
                    SalesmartlyWidgetIconPainter.draw(type: type, size: canvasSize, color: color, context: &context)
                }
            }
        }
        .frame(width: frameWidth, height: size)
        .accessibilityIdentifier(type)
    }
}

/// 对齐 widget main:public/fonts/iconfont.less 的 type 到 unicode 映射，保持 iOS 图标入口与 Web `<Icon type>` 同名。
private enum SalesmartlyIconFontGlyph {
    static func character(for type: String) -> String? {
        let value: UInt32
        switch type {
        case "line1":
            value = 0xe69e
        case "lineapp":
            value = 0xe841
        case "zalo":
            value = 0xe7de
        case "telegram":
            value = 0xeaf9
        case "whatsapp-fill":
            value = 0xeb92
        case "weixin":
            value = 0xe69d
        case "instagram":
            value = 0xe88f
        case "messenger":
            value = 0xe980
        case "vkontakte":
            value = 0xe8cc
        case "whatsapp":
            value = 0xe636
        case "email":
            value = 0xe637
        case "msg1":
            value = 0xe63d
        case "msg2":
            value = 0xe63e
        case "tiktok":
            value = 0xe78d
        case "icon-comment-fill1":
            value = 0xe822
        case "icon-download-circle2":
            value = 0xe820
        case "icon-default-logo-fill":
            value = 0xe81f
        case "icon-send-fill":
            value = 0xe806
        case "icon-generating-fill":
            value = 0xe808
        case "icon-quick-reply-fill":
            value = 0xe80a
        case "icon-return-circle-1":
            value = 0xe80b
        case "icon-go-to-circle":
            value = 0xe80c
        case "icon-return-to-bottom-circle":
            value = 0xe80f
        case "icon-expression-circle":
            value = 0xe810
        case "icon-more-circle":
            value = 0xe811
        case "icon-help-center-fill":
            value = 0xe812
        case "icon-return-circle-2":
            value = 0xe813
        case "icon-return-circle":
            value = 0xe814
        case "icon-hello-fill":
            value = 0xe816
        case "icon-default-fill":
            value = 0xe817
        case "icon-announcement-fill":
            value = 0xe81b
        case "icon-chat-fill":
            value = 0xe81d
        case "icon-closure-circle":
            value = 0xe81e
        default:
            return nil
        }
        guard let scalar = UnicodeScalar(value) else {
            return nil
        }
        return String(Character(scalar))
    }

    /// 对齐 widget main:public/fonts/iconfont.js 中 `icon-msg1/msg2` 的 1251x1024 viewBox，避免 SwiftUI 以正方形字号盒裁掉聊天入口右侧。
    static func frameWidth(for type: String, size: CGFloat) -> CGFloat {
        switch type {
        case "msg1", "msg2":
            return size * 1251 / 1024
        default:
            return size
        }
    }
}

/// 对齐 widget main:public/fonts/iconfont.ttf，将 Web iconfont 作为 SwiftPM 资源注册给原生 Text 渲染。
@MainActor
private enum SalesmartlyIconFontRegistry {
    private static var registered = false

    static func registerIfNeeded() {
        guard !registered else {
            return
        }
        registered = true
        #if canImport(CoreText)
        guard let url = Bundle.module.url(
            forResource: "iconfont",
            withExtension: "ttf",
            subdirectory: "salesmartly"
        ) else {
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        #endif
    }
}

/// 对齐 Android `WidgetIcon` 的平台绘制层，避免可见 UI 继续使用 SF Symbols 临时替代 Web iconfont。
private enum SalesmartlyWidgetIconPainter {
    static func draw(type: String, size: CGSize, color: Color, context: inout GraphicsContext) {
        let rect = CGRect(origin: .zero, size: size)
        let lineWidth = max(1.2, min(size.width, size.height) * 0.08)

        switch type {
        case "icon-closure-circle":
            drawCircleIcon(rect: rect, color: color, context: &context)
            stroke(line(from: point(rect, 0.36, 0.36), to: point(rect, 0.64, 0.64)), color: color, lineWidth: lineWidth, context: &context)
            stroke(line(from: point(rect, 0.64, 0.36), to: point(rect, 0.36, 0.64)), color: color, lineWidth: lineWidth, context: &context)
        case "icon-return-circle", "icon-return-circle-2":
            drawCircleIcon(rect: rect, color: color, context: &context)
            var path = Path()
            path.move(to: point(rect, 0.60, 0.30))
            path.addLine(to: point(rect, 0.38, 0.50))
            path.addLine(to: point(rect, 0.60, 0.70))
            stroke(path, color: color, lineWidth: lineWidth, context: &context)
        case "icon-help-center-fill":
            drawCircleIcon(rect: rect, color: color, context: &context)
            drawQuestion(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "icon-default-logo-fill":
            drawChatBubble(rect: rect.insetBy(dx: rect.width * 0.16, dy: rect.height * 0.18), color: color, lineWidth: lineWidth, context: &context)
            drawChatBubble(rect: rect.insetBy(dx: rect.width * 0.30, dy: rect.height * 0.30).offsetBy(dx: rect.width * 0.10, dy: rect.height * 0.08), color: color.opacity(0.8), lineWidth: lineWidth, context: &context)
        case "icon-chat-fill":
            drawChatBubble(rect: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.18), color: color, lineWidth: lineWidth, context: &context)
        case "icon-hello-fill":
            drawHelloBadge(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "icon-go-to-circle":
            drawCircleIcon(rect: rect, color: color, context: &context)
            var path = Path()
            path.move(to: point(rect, 0.42, 0.30))
            path.addLine(to: point(rect, 0.62, 0.50))
            path.addLine(to: point(rect, 0.42, 0.70))
            stroke(path, color: color, lineWidth: lineWidth, context: &context)
        case "icon-announcement-fill":
            drawAnnouncement(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "icon-comment-fill1":
            drawChatBubble(rect: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.18), color: color, lineWidth: lineWidth, context: &context)
        case "icon-grateful-fill":
            drawCircleIcon(rect: rect, color: color, context: &context)
            var path = Path()
            path.move(to: point(rect, 0.32, 0.52))
            path.addLine(to: point(rect, 0.46, 0.66))
            path.addLine(to: point(rect, 0.70, 0.36))
            stroke(path, color: color, lineWidth: lineWidth, context: &context)
        case "icon-more-circle":
            drawCircleIcon(rect: rect, color: color, context: &context)
            stroke(line(from: point(rect, 0.32, 0.50), to: point(rect, 0.68, 0.50)), color: color, lineWidth: lineWidth, context: &context)
            stroke(line(from: point(rect, 0.50, 0.32), to: point(rect, 0.50, 0.68)), color: color, lineWidth: lineWidth, context: &context)
        case "icon-expression-circle":
            drawCircleIcon(rect: rect, color: color, context: &context)
            drawSmile(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "icon-send-fill":
            drawSend(rect: rect, color: color, context: &context)
        case "icon-generating-fill":
            drawCircleIcon(rect: rect, color: color, context: &context)
            let square = rect.insetBy(dx: rect.width * 0.35, dy: rect.height * 0.35)
            context.fill(Path(roundedRect: square, cornerRadius: rect.width * 0.06), with: .color(color))
        case "icon-document-fill":
            drawDocument(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "icon-download-circle2":
            drawCircleIcon(rect: rect, color: color, context: &context)
            drawDownload(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "email":
            drawEnvelope(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "telegram":
            drawSend(rect: rect, color: color, context: &context)
        case "instagram":
            drawCamera(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        case "tiktok":
            drawMusic(rect: rect, color: color, lineWidth: lineWidth, context: &context)
        default:
            drawChatBubble(rect: rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.18), color: color, lineWidth: lineWidth, context: &context)
        }
    }

    private static func drawCircleIcon(rect: CGRect, color: Color, context: inout GraphicsContext) {
        context.stroke(Path(ellipseIn: rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.08)), with: .color(color), lineWidth: max(1.2, rect.width * 0.08))
    }

    private static func drawChatBubble(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        var path = Path(roundedRect: rect, cornerRadius: rect.height * 0.36)
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.32, y: rect.maxY - lineWidth * 0.4))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.maxY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.48, y: rect.maxY - lineWidth * 0.4))
        stroke(path, color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawQuestion(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        var path = Path()
        path.move(to: point(rect, 0.38, 0.38))
        path.addCurve(to: point(rect, 0.50, 0.58), control1: point(rect, 0.38, 0.24), control2: point(rect, 0.68, 0.28))
        stroke(path, color: color, lineWidth: lineWidth, context: &context)
        context.fill(Path(ellipseIn: CGRect(x: rect.midX - lineWidth * 0.7, y: rect.maxY - rect.height * 0.28, width: lineWidth * 1.4, height: lineWidth * 1.4)), with: .color(color))
    }

    private static func drawAnnouncement(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        var horn = Path()
        horn.move(to: point(rect, 0.18, 0.52))
        horn.addLine(to: point(rect, 0.58, 0.34))
        horn.addLine(to: point(rect, 0.58, 0.68))
        horn.addLine(to: point(rect, 0.18, 0.56))
        horn.closeSubpath()
        stroke(horn, color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.62, 0.38), to: point(rect, 0.82, 0.28)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.62, 0.62), to: point(rect, 0.82, 0.72)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.30, 0.56), to: point(rect, 0.38, 0.82)), color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawSmile(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        context.fill(Path(ellipseIn: CGRect(x: rect.minX + rect.width * 0.34, y: rect.minY + rect.height * 0.36, width: lineWidth * 1.1, height: lineWidth * 1.1)), with: .color(color))
        context.fill(Path(ellipseIn: CGRect(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.36, width: lineWidth * 1.1, height: lineWidth * 1.1)), with: .color(color))
        var smile = Path()
        smile.move(to: point(rect, 0.34, 0.60))
        smile.addQuadCurve(to: point(rect, 0.66, 0.60), control: point(rect, 0.50, 0.76))
        stroke(smile, color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawHelloBadge(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        var palm = Path(roundedRect: rect.insetBy(dx: rect.width * 0.22, dy: rect.height * 0.16), cornerRadius: rect.width * 0.22)
        palm.move(to: point(rect, 0.44, 0.64))
        palm.addLine(to: point(rect, 0.30, 0.84))
        palm.addLine(to: point(rect, 0.56, 0.70))
        context.fill(palm, with: .color(color))
        stroke(line(from: point(rect, 0.22, 0.20), to: point(rect, 0.08, 0.08)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.78, 0.20), to: point(rect, 0.92, 0.08)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.50, 0.12), to: point(rect, 0.50, 0.00)), color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawSend(rect: CGRect, color: Color, context: inout GraphicsContext) {
        var path = Path()
        path.move(to: point(rect, 0.14, 0.20))
        path.addLine(to: point(rect, 0.86, 0.50))
        path.addLine(to: point(rect, 0.14, 0.80))
        path.addLine(to: point(rect, 0.28, 0.54))
        path.addLine(to: point(rect, 0.56, 0.50))
        path.addLine(to: point(rect, 0.28, 0.46))
        path.closeSubpath()
        context.fill(path, with: .color(color))
    }

    private static func drawDocument(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        var path = Path()
        path.move(to: point(rect, 0.26, 0.12))
        path.addLine(to: point(rect, 0.62, 0.12))
        path.addLine(to: point(rect, 0.78, 0.28))
        path.addLine(to: point(rect, 0.78, 0.88))
        path.addLine(to: point(rect, 0.26, 0.88))
        path.closeSubpath()
        stroke(path, color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.62, 0.12), to: point(rect, 0.62, 0.30)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.62, 0.30), to: point(rect, 0.78, 0.30)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.38, 0.48), to: point(rect, 0.66, 0.48)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.38, 0.62), to: point(rect, 0.66, 0.62)), color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawDownload(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        stroke(line(from: point(rect, 0.50, 0.26), to: point(rect, 0.50, 0.62)), color: color, lineWidth: lineWidth, context: &context)
        var arrow = Path()
        arrow.move(to: point(rect, 0.34, 0.48))
        arrow.addLine(to: point(rect, 0.50, 0.66))
        arrow.addLine(to: point(rect, 0.66, 0.48))
        stroke(arrow, color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.32, 0.76), to: point(rect, 0.68, 0.76)), color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawEnvelope(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        let box = rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.24)
        stroke(Path(roundedRect: box, cornerRadius: rect.width * 0.08), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: CGPoint(x: box.minX, y: box.minY), to: CGPoint(x: box.midX, y: box.midY)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: CGPoint(x: box.maxX, y: box.minY), to: CGPoint(x: box.midX, y: box.midY)), color: color, lineWidth: lineWidth, context: &context)
    }

    private static func drawCamera(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        let box = rect.insetBy(dx: rect.width * 0.16, dy: rect.height * 0.22)
        stroke(Path(roundedRect: box, cornerRadius: rect.width * 0.12), color: color, lineWidth: lineWidth, context: &context)
        context.stroke(Path(ellipseIn: rect.insetBy(dx: rect.width * 0.36, dy: rect.height * 0.36)), with: .color(color), lineWidth: lineWidth)
        context.fill(Path(ellipseIn: CGRect(x: rect.minX + rect.width * 0.64, y: rect.minY + rect.height * 0.30, width: lineWidth, height: lineWidth)), with: .color(color))
    }

    private static func drawMusic(rect: CGRect, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        stroke(line(from: point(rect, 0.58, 0.20), to: point(rect, 0.58, 0.68)), color: color, lineWidth: lineWidth, context: &context)
        stroke(line(from: point(rect, 0.58, 0.20), to: point(rect, 0.76, 0.26)), color: color, lineWidth: lineWidth, context: &context)
        context.stroke(Path(ellipseIn: CGRect(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.60, width: rect.width * 0.28, height: rect.height * 0.20)), with: .color(color), lineWidth: lineWidth)
    }

    private static func point(_ rect: CGRect, _ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
    }

    private static func line(from: CGPoint, to: CGPoint) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }

    private static func stroke(_ path: Path, color: Color, lineWidth: CGFloat, context: inout GraphicsContext) {
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }
}
#endif
