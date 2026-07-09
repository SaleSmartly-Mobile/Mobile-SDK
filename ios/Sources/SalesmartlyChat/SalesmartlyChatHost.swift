#if canImport(SwiftUI)
import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(AVKit)
import AVKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(UIKit) && canImport(PhotosUI)
import PhotosUI
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
#endif
#if canImport(AppKit)
import AppKit
#endif

/// 对齐 widget main:src/styles/view.less 的 `.chat`、`.mobile .chat` 与 `.fullScreen .chat`，描述打开态聊天窗在原生 Host 中的最终布局。
struct SalesmartlyOpenedChatWindowLayoutState: Equatable {
    /// 对齐 Web `.chat` 的可见宽度，桌面上限 400px，移动端打开态按容器可用宽度铺满。
    var width: CGFloat
    /// 对齐 Web `.chat` 的可见高度，桌面 700px，移动端普通 85vh，full 模式 100vh。
    var height: CGFloat
    /// 对齐 widget main:src/styles/view.less 的 `.mobile_open`，移动端打开态左侧不保留 wrap 间距。
    var leadingInset: CGFloat
    /// 对齐 widget main:src/styles/view.less 的 `.mobile_open`，移动端打开态右侧不保留 wrap 间距。
    var trailingInset: CGFloat
    /// 对齐 Web `.mobile_open` 的 bottom: 0，移动端打开态不再保留 Launcher 底部间距。
    var bottomInset: CGFloat
    /// 对齐 Web `.fullScreen .chat` 的 border-radius: 0，普通窗口保留 12pt 圆角。
    var cornerRadius: CGFloat
    /// 对齐 Web `.fullScreen .chat` 的 box-shadow: none，普通窗口保留现有阴影半径。
    var shadowRadius: CGFloat
    /// 对齐 Web 移动端 showWrapper 时隐藏 Launcher icon；桌面端仍保留外层关闭入口。
    var showsBottomCloseButton: Bool
}

/// 对齐 widget main:src/components/VideoPreview/index.vue 的 popup 视频尺寸，记录 90vw/85vh 约束后的展示区域。
struct SalesmartlyMediaPreviewVideoLayoutState: Equatable {
    /// 对齐 Web `.popup__video` 的 max-width: 90vw。
    var width: CGFloat
    /// 对齐 Web `.popup__video` 的 max-height: 85vh。
    var height: CGFloat
    /// 对齐 Web `.popup__cover` 的 rgba(0, 0, 0, 0.35)。
    var coverOpacity: Double
}

/// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的上传菜单项，Host 用它统一菜单渲染和系统 picker 类型。
enum SalesmartlyComposerUploadMenuItem: String, Identifiable, Equatable {
    /// 对齐 Web 搜同款入口，选择图片后按 msg_type=45 发送。
    case searchSame
    /// 对齐 Web 图片上传入口，选择系统相册图片后按 msg_type=2 发送。
    case image
    /// 对齐 Web 视频上传入口，选择系统相册视频后按 msg_type=6 发送。
    case video
    /// 对齐 Web 附件上传入口，选择系统文件后按 msg_type=4 发送。
    case attachment

    /// SwiftUI sheet 和 ForEach 使用的稳定标识，避免菜单刷新时 action 目标漂移。
    var id: String { rawValue }
}

/// 对齐 widget main:src/components/TextBox/index.vue 的输入区折行状态，保证空文本和非空文本复用同一 TextField 节点。
struct SalesmartlyComposerLayoutState: Equatable {
    /// 对齐 Web textarea 的单一输入节点语义，SwiftUI 通过稳定 id 避免首字符输入后重建焦点节点。
    var textFieldIdentity: String
    /// 对齐 TextBox 空态胶囊和输入态圆角矩形。
    var cornerRadius: CGFloat
    /// 对齐 TextBox 非空态 textarea 独占首行、工具栏下沉的布局。
    var textFieldOwnsFirstRow: Bool
}

/// 对齐 widget main:src/App.vue 的 handleCloseChat/closeWindow，本地关闭时同步收起 Host 展开态、emoji 和输入焦点。
struct SalesmartlyHostCloseInteractionState: Equatable {
    /// 对齐 SideBar single_icon 展开态，关闭聊天时一并收起。
    var launcherExpanded: Bool
    /// 对齐 TextBoxEmojiPoptip 展示态，关闭聊天时一并收起。
    var showEmojiPanel: Bool
    /// 对齐 TextBox textarea 焦点，关闭聊天时一并收起键盘。
    var isComposerFocused: Bool
}

/// 对齐 widget main:src/styles/view.less 的 `.wrap_left/.wrap_right`，记录 Host 外层 frame 应贴左下还是右下。
enum SalesmartlyWidgetWrapFrameEdge: Equatable {
    /// 对齐 Web `.wrap_left`，Launcher 与聊天窗贴左下。
    case bottomLeading
    /// 对齐 Web `.wrap_right`，Launcher 与聊天窗贴右下。
    case bottomTrailing

    /// 对齐 SwiftUI `frame(alignment:)` 的实际锚点，避免外层 frame 默认 center 导致 Launcher 居中。
    var alignment: Alignment {
        switch self {
        case .bottomLeading:
            return .bottomLeading
        case .bottomTrailing:
            return .bottomTrailing
        }
    }
}

/// 对齐 widget main:src/components/Launcher/index.vue 的宿主容器，负责在 SwiftUI 中承载聊天窗口、Launcher 与未读预览入口。
public struct SalesmartlyChatHost: View {
    /// 对齐 Android `MediaPreviewTarget`，区分聊天窗内图片预览和视频预览。
    private enum MediaPreviewTarget: Equatable {
        case image(String)
        case video(String)
    }

    /// 对齐 widget main:src/App.vue 的运行时编排实例，Host 通过它读取状态并转发打开、关闭和发送动作。
    public let runtime: SalesmartlyRuntime

    /// 对齐 Web `window.open` 与 Android `UriHandler.openUri`，用于公告栏和 Header 链接跳转。
    @Environment(\.openURL) private var openURL
    @State private var snapshot: ChatRuntimeState
    /// 对齐 widget main:src/components/SideBar/index.vue 的 sideBarExpand，本地记录 single_icon 入口是否展开渠道列。
    @State private var launcherExpanded = false
    @State private var stateObservationId: Int?
    @State private var promotionalCardEmails: [String: String] = [:]
    @State private var promotionalCardErrors: [String: String] = [:]
    @State private var evalutionScores: [String: Int] = [:]
    @State private var evalutionComments: [String: String] = [:]
    @State private var evalutionErrors: [String: String] = [:]
    @State private var chatScrollViewportHeight: CGFloat = 0
    @State private var chatScrollBottomOffset: CGFloat = 0
    @State private var chatScrollDistanceToBottom: CGFloat = 0
    @State private var mediaPreviewTarget: MediaPreviewTarget?
    /// 对齐 Android `CollectionOverlay`，保存当前 overlay 表单字段值。
    @State private var collectionValues: SalesmartlyPayload = [:]
    /// 对齐 Android `PhoneNumberField` 的区号字段，提交 phone 时与号码拼接。
    @State private var collectionArea = ""
    /// 对齐 Android `CollectionOverlay` 的 fieldErrors，字段修改时只清理当前字段错误。
    @State private var collectionErrors: [String: String] = [:]
    /// 对齐 Android 普通留资/离线留资两个入口，切换类型时重置 overlay 表单状态。
    @State private var collectionActiveType: String?
    /// 对齐 Android `ChatHeaderInfoCardMode`，记录 Header 信息卡折叠、展开和详情态。
    @State private var chatHeaderInfoCardMode: SalesmartlyChatHeaderInfoCardMode = .collapsed
    /// 对齐 Web `bulletinModalVisible`，记录公告栏展开模式弹窗是否展示。
    @State private var showBulletinBoardModal = false
    /// 对齐 Android `FileBubble.isDownloading`，按 reportId 记录文件按钮下载中的 loading 状态。
    @State private var downloadingFileIDs: Set<String> = []
    @State private var showEmojiPanel = false
    /// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的相册上传入口，记录待展示的系统图片/视频 picker 类型。
    @State private var pendingPhotoUploadItem: SalesmartlyComposerUploadMenuItem?
    /// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的附件入口，记录 UIDocumentPicker 展示态。
    @State private var showDocumentUploadPicker = false
    @FocusState private var isComposerFocused: Bool
    /// 对齐 Android `CollectionOverlay` 聚焦边框状态，记录当前聚焦的留资字段 key。
    @FocusState private var collectionFocusedFieldKey: String?
    /// 对齐 widget main:src/helper/audioPlayback.ts 的 pauseAllExcept，记录当前正在播放的音频 URL。
    @State private var activeAudioURL: String?
    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 durationTime，记录音频总秒数。
    @State private var audioDurationSeconds: [String: Int] = [:]
    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 lessTime，记录播放中剩余秒数。
    @State private var audioRemainingSeconds: [String: Int] = [:]
    #if canImport(AVFoundation)
    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 创建的 audioElem，按 URL 保存原生 AVPlayer。
    @State private var audioPlayers: [String: AVPlayer] = [:]
    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 timeupdate，保存 AVPlayer 时间观察者 token。
    @State private var audioTimeObservers: [String: Any] = [:]
    #endif
    #if canImport(AVKit)
    /// 对齐 Android `VideoPreviewPlayer`，预览层复用单个 AVPlayer 播放当前视频。
    @State private var videoPreviewPlayer: AVPlayer?
    /// 对齐 Android `MEDIA_INFO_VIDEO_RENDERING_START`，记录视频预览是否已有真实播放帧。
    @State private var videoPreviewHasRenderedFrame = false
    /// 对齐 Android 视频首帧保留逻辑，观察播放时间后再隐藏缩略图。
    @State private var videoPreviewTimeObserver: Any?
    /// 对齐 widget main:src/components/VideoPreview/index.vue 的 canplay/loadeddata，记录 AVPlayerItem ready 后再触发播放。
    @State private var videoPreviewStatusObserver: NSKeyValueObservation?
    #endif

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 colorList，用于 AI guide 问题按钮背景色。
    private static let aiGuideQuestionColors = ["#EBE9CF", "#D5EBDE", "#D2EDF4", "#EDDEF2", "#EFDEDE", "#F0E4D8"]
    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 RETURN_TO_BOTTOM_THRESHOLD_PX。
    private static let returnToBottomThreshold: CGFloat = 300
    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 updateAtBottom，16px 内视为已到底部。
    private static let atBottomThreshold: CGFloat = 16
    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 listRef 滚动容器坐标系。
    private static let chatScrollCoordinateSpace = "salesmartly-chat-scroll"
    /// 对齐 widget main:src/stores/chat.ts 的 scrollConversationToBottom，作为 ScrollViewReader 的底部定位锚点。
    private static let chatBottomAnchorId = "salesmartly-chat-bottom-anchor"
    /// 对齐 widget main:src/components/VideoPreview/index.vue 的 `.popup__cover` 半透明遮罩。
    nonisolated private static let mediaPreviewCoverOpacity = 0.35
    /// 对齐 widget main:src/components/EmojiBox/useData.ts 的 emoji label 顺序，用于 TextBoxEmojiPoptip 面板。
    nonisolated static let chatInputEmojiLabels = [
        "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃",
        "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙",
        "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
        "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥",
        "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮",
        "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓",
        "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺",
        "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣",
        "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬", "😈",
        "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽", "👾",
        "🤖", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾",
        "🙈", "🙉", "🙊", "👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤏",
        "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇",
        "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐",
        "🤲", "🤝", "🙏",
    ]

    /// 对齐 widget main:src/styles/view.less 的 `.wrap_left/.wrap_right`，供 Host 内外层统一使用同一个侧边锚点。
    nonisolated static func widgetWrapFrameEdge(position: String) -> SalesmartlyWidgetWrapFrameEdge {
        position == "left" ? .bottomLeading : .bottomTrailing
    }

    /// 对齐 widget main:src/styles/view.less 的打开态布局规则，供 SwiftUI Host 和单测共享计算窗口尺寸、边距与 Launcher 关闭入口显隐。
    nonisolated static func openedChatWindowLayoutState(
        availableSize: CGSize,
        configuredBottomInset: CGFloat,
        isMobileHost: Bool,
        position: String,
        initMobileScreen: String?,
        mobileScreen: String,
        shouldShowWindowCloseButton: Bool
    ) -> SalesmartlyOpenedChatWindowLayoutState {
        let fullScreen = isMobileHost && (initMobileScreen == "full" || mobileScreen == "full")
        let height: CGFloat
        if fullScreen {
            height = max(0, availableSize.height)
        } else if isMobileHost {
            height = max(0, availableSize.height * 0.85)
        } else {
            height = 700
        }

        return SalesmartlyOpenedChatWindowLayoutState(
            width: isMobileHost ? max(0, availableSize.width) : chatWindowWidth(availableWidth: availableSize.width),
            height: height,
            leadingInset: isMobileHost ? 0 : (position == "left" ? 15 : 0),
            trailingInset: isMobileHost ? 0 : (position == "left" ? 0 : 15),
            bottomInset: isMobileHost ? 0 : configuredBottomInset,
            cornerRadius: fullScreen ? 0 : 12,
            shadowRadius: fullScreen ? 0 : 40,
            showsBottomCloseButton: !isMobileHost && shouldShowWindowCloseButton
        )
    }

    /// 对齐 widget main:src/components/TextBox/index.vue 的输入框空态/非空态布局，保持同一输入节点以避免真机首字符输入后丢焦。
    nonisolated static func composerLayoutState(hasDraftText: Bool) -> SalesmartlyComposerLayoutState {
        SalesmartlyComposerLayoutState(
            textFieldIdentity: "salesmartly-composer-input",
            cornerRadius: hasDraftText ? 10 : 100,
            textFieldOwnsFirstRow: hasDraftText
        )
    }

    /// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的 hideUpload 过滤规则，img 同时隐藏图片和搜同款。
    nonisolated static func composerUploadMenuItems(hideUploadTypes: [String]) -> [SalesmartlyComposerUploadMenuItem] {
        [
            hideUploadTypes.contains("img") ? nil : .searchSame,
            hideUploadTypes.contains("img") ? nil : .image,
            hideUploadTypes.contains("video") ? nil : .video,
            hideUploadTypes.contains("document") ? nil : .attachment,
        ].compactMap { $0 }
    }

    /// 对齐 widget main:src/App.vue 的 handleCloseChat/closeWindow，Host 关闭聊天时同时复位本地展示态和输入焦点。
    nonisolated static func closeInteractionState(
        launcherExpanded: Bool,
        showEmojiPanel: Bool,
        isComposerFocused: Bool
    ) -> SalesmartlyHostCloseInteractionState {
        SalesmartlyHostCloseInteractionState(
            launcherExpanded: false,
            showEmojiPanel: false,
            isComposerFocused: false
        )
    }

    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的 `v-click-outside="closeDetail"`，聊天内容区点击按信息卡外部点击处理。
    nonisolated static func chatHeaderInfoCardAfterChatContentTap(
        _ mode: SalesmartlyChatHeaderInfoCardMode,
        runtime: SalesmartlyRuntime
    ) -> SalesmartlyChatHeaderInfoCardMode {
        runtime.chatHeaderInfoCardAfterOutsideClick(mode, isMobile: true)
    }

    /// 对齐 widget main:src/views/Page/index.vue 的 welcomeText 与 src/locales/lang/* 的 tips.contactUs，主页 title 未配置时按当前语言展示默认联系文案。
    nonisolated static func localizedHomePageWelcomeText(homePageTitle: String, language: String) -> String {
        homePageTitle.isEmpty ? salesmartlyText("tips.contactUs", language: language) : homePageTitle
    }

    /// 对齐 widget main:src/components/VideoPreview/index.vue 的 `.popup__content` 居中规则与 `.popup__video` 90vw/85vh 上限。
    nonisolated static func mediaPreviewVideoLayoutState(
        availableSize: CGSize,
        aspectRatio: CGFloat
    ) -> SalesmartlyMediaPreviewVideoLayoutState {
        let maxWidth = availableSize.width * 0.9
        let maxHeight = availableSize.height * 0.85
        let heightByWidth = maxWidth / aspectRatio
        if heightByWidth <= maxHeight {
            return SalesmartlyMediaPreviewVideoLayoutState(
                width: maxWidth,
                height: heightByWidth,
                coverOpacity: mediaPreviewCoverOpacity
            )
        }
        return SalesmartlyMediaPreviewVideoLayoutState(
            width: maxHeight * aspectRatio,
            height: maxHeight,
            coverOpacity: mediaPreviewCoverOpacity
        )
    }

    /// 对齐 widget main:src/install/runInstall.ts 的默认接入语义，未显式传入 runtime 时使用全局 SDK runtime。
    public init(runtime: SalesmartlyRuntime = SalesmartlyChat.runtime()) {
        self.runtime = runtime
        self._snapshot = State(initialValue: runtime.state)
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 themeColors.normal，取 plugin/info 的 background_color 作为主色。
    private var themePrimary: Color {
        Color.salesmartlyHex(snapshot.backgroundColor) ?? Color.salesmartlyPrimary
    }

    /// 对齐 widget main:src/helper/useStyle.ts 的 getContrastYIQ，浅色主题入口使用深色图标文字。
    private var themeForeground: Color {
        guard let rgb = themeRGB else {
            return Color.white
        }
        let yiq = ((rgb.r * 255 * 299) + (rgb.g * 255 * 587) + (rgb.b * 255 * 114)) / 1000
        return yiq >= 128 ? Color(red: 13 / 255, green: 22 / 255, blue: 38 / 255) : Color.white
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 --theme-normal-rgb，供 iOS 生成主题透明叠加色。
    private var themeRGB: (r: Double, g: Double, b: Double)? {
        Self.themeRGBComponents(snapshot.backgroundColor)
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 themeColors.gradient 第二段颜色，默认科技蓝使用 Web 预设的青色过渡。
    private var themeGradientSecondRGB: (r: Double, g: Double, b: Double)? {
        Self.themeGradientSecondRGBComponents(snapshot.backgroundColor)
    }

    /// 对齐 widget main:src/styles/view.less 的 `.wrap_left/.wrap_right`，聊天宿主按插件 position 贴左或贴右。
    private var widgetWrapAlignment: Alignment {
        Self.widgetWrapFrameEdge(position: snapshot.position).alignment
    }

    /// 对齐 widget main:src/helper/useStyle.ts 的 chatBtnWrapStyle，贴左时渠道列改为左对齐。
    private var widgetEntryHorizontalAlignment: HorizontalAlignment {
        snapshot.position == "left" ? .leading : .trailing
    }

    /// 对齐 widget main:src/helper/useChatWrapStyle.ts，PC 下按 margin_bottom_pc / margin_bottom 还原 wrapper 边距。
    private var widgetWrapInsets: EdgeInsets {
        widgetWrapInsets(
            leadingInset: snapshot.position == "left" ? 15 : 0,
            bottomInset: configuredWidgetBottomInset,
            trailingInset: snapshot.position == "left" ? 0 : 15
        )
    }

    /// 对齐 widget main:src/helper/useChatWrapStyle.ts 与 `src/styles/view.less`，打开态移动端可覆盖左右和底部间距以匹配 `.mobile_open`。
    private func widgetWrapInsets(
        leadingInset: CGFloat,
        bottomInset: CGFloat,
        trailingInset: CGFloat
    ) -> EdgeInsets {
        EdgeInsets(
            top: 0,
            leading: leadingInset,
            bottom: bottomInset,
            trailing: trailingInset
        )
    }

    /// 对齐 widget main:src/helper/useChatWrapStyle.ts 的配置底部间距，非打开态或桌面打开态继续使用原始配置。
    private var configuredWidgetBottomInset: CGFloat {
        CGFloat(snapshot.locationConfigDivisive ? snapshot.marginBottomPC : snapshot.marginBottom)
    }

    /// 对齐 widget main:src/utils/env.ts 的 isMobile 在原生端的宿主平台判断，iOS 打开态按移动端 wrapper 规则处理。
    private static var isMobileHost: Bool {
        #if os(iOS) || os(tvOS) || os(watchOS)
        return true
        #else
        return false
        #endif
    }

    /// 对齐 widget main:src/views/Page/styles/page.less 的 @ssc-theme-gradient 第一段 `rgba(normal, 0.24)`。
    private var themeHomeGradientTop: Color {
        themeColorOnWhite(opacity: 0.24)
    }

    /// 对齐 widget main:src/constants/theme.ts 科技蓝预设的 `rgba(92, 204, 190, 0.16)` 第二段。
    private var themeHomeGradientMiddle: Color {
        themeGradientSecondColorOnWhite(opacity: 0.16)
    }

    /// 对齐 widget main:src/views/Chat/style/chatHeader.less 的 rgba(var(--theme-normal-rgb), 0.1) Header 背景。
    private var themeHeaderTint: Color {
        themeColorOnWhite(opacity: 0.10)
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 `--theme-bg-accent` 非近白主题分支，当前脚本主题用于访客侧气泡和主题按钮底色。
    private var themeBackgroundAccent: Color {
        themePrimary
    }

    /// 对齐 Web rgba(var(--theme-normal-rgb), opacity) 叠加白底后的可见颜色。
    private func themeColorOnWhite(opacity: Double) -> Color {
        guard let rgb = themeRGB else {
            return Color.salesmartlyHeaderTint
        }
        return Self.colorOnWhite(rgb: rgb, opacity: opacity)
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 gradient 第二段 rgba 叠白效果。
    private func themeGradientSecondColorOnWhite(opacity: Double) -> Color {
        guard let rgb = themeGradientSecondRGB else {
            return Color.salesmartlyHeaderTint
        }
        return Self.colorOnWhite(rgb: rgb, opacity: opacity)
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 rgba 主题色叠白结果，SwiftUI 直接生成最终显示颜色。
    private static func colorOnWhite(rgb: (r: Double, g: Double, b: Double), opacity: Double) -> Color {
        return Color(
            red: 1 - (1 - rgb.r) * opacity,
            green: 1 - (1 - rgb.g) * opacity,
            blue: 1 - (1 - rgb.b) * opacity
        )
    }

    /// 对齐 widget main:src/helper/useTheme.ts 的 normalizeBareHexPrimary，只使用 background_color 的首个主题色。
    private static func themeRGBComponents(_ value: String) -> (r: Double, g: Double, b: Double)? {
        let firstColor = value
            .split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? value
        let hex = firstColor.trimmingCharacters(in: CharacterSet(charactersIn: "# \n\t"))
        let expanded: String
        if hex.count == 3 {
            expanded = hex.map { "\($0)\($0)" }.joined()
        } else {
            expanded = hex
        }
        guard expanded.count == 6,
              let intValue = Int(expanded, radix: 16) else {
            return nil
        }
        return (
            Double((intValue >> 16) & 0xff) / 255,
            Double((intValue >> 8) & 0xff) / 255,
            Double(intValue & 0xff) / 255
        )
    }

    /// 对齐 widget main:src/constants/theme.ts 与 src/utils/themeColors.ts 的 `gradient` 第二段颜色。
    private static func themeGradientSecondRGBComponents(_ value: String) -> (r: Double, g: Double, b: Double)? {
        let colors = value.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        if colors.count == 2, let second = themeRGBComponents(colors[1]) {
            return second
        }
        if let first = themeRGBComponents(value),
           abs(first.r - 23 / 255) < 0.001,
           abs(first.g - 98 / 255) < 0.001,
           abs(first.b - 246 / 255) < 0.001 {
            return (92 / 255, 204 / 255, 190 / 255)
        }
        if let first = themeRGBComponents(value) {
            return (
                first.r + (1 - first.r) * 0.9,
                first.g + (1 - first.g) * 0.9,
                first.b + (1 - first.b) * 0.9
            )
        }
        return nil
    }

    /// 对齐 widget main:src/components/Launcher/index.vue 与 src/views/Chat/index.vue，按窗口开合状态切换聊天窗和 Launcher。
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: widgetWrapAlignment) {
                if snapshot.showWrapper {
                    let layout = Self.openedChatWindowLayoutState(
                        availableSize: proxy.size,
                        configuredBottomInset: configuredWidgetBottomInset,
                        isMobileHost: Self.isMobileHost,
                        position: snapshot.position,
                        initMobileScreen: runtime.config?.setting.initMobileScreen,
                        mobileScreen: snapshot.mobileScreen,
                        shouldShowWindowCloseButton: runtime.shouldShowWindowCloseButton()
                    )
                    openedChatEntry(layout: layout)
                        .padding(widgetWrapInsets(
                            leadingInset: layout.leadingInset,
                            bottomInset: layout.bottomInset,
                            trailingInset: layout.trailingInset
                        ))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    launcherEntry
                        .padding(widgetWrapInsets)
                }
                if mediaPreviewTarget != nil {
                    mediaPreviewOverlay
                        .transition(.opacity)
                }
                if snapshot.customEntryPopup != nil {
                    customEntryPopupOverlay
                        .transition(.opacity)
                }
                if snapshot.customEntryPreviewImageURL != nil {
                    customEntryImagePreviewOverlay
                        .transition(.opacity)
                }
                if showBulletinBoardModal {
                    bulletinBoardModalOverlay
                        .transition(.opacity)
                }
                if !snapshot.toasts.isEmpty {
                    toastOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: widgetWrapAlignment)
        }
        .animation(.easeInOut(duration: 0.2), value: snapshot.showWrapper)
        .animation(.easeInOut(duration: 0.24), value: shouldShowIconPopup)
        .animation(.easeInOut(duration: 0.16), value: mediaPreviewTarget)
        .animation(.easeInOut(duration: 0.16), value: snapshot.customEntryPopup)
        .animation(.easeInOut(duration: 0.16), value: snapshot.customEntryPreviewImageURL)
        .animation(.easeInOut(duration: 0.18), value: snapshot.toasts)
        .animation(.easeInOut(duration: 0.16), value: showBulletinBoardModal)
        .onAppear {
            startObservingRuntimeState()
        }
        .onDisappear {
            stopAudioPlayback()
            stopObservingRuntimeState()
        }
    }

    /// 对齐 widget main:src/components/SideBar/index.vue 的 single_icon 模式，折叠态展示主入口，展开态展示反向排序渠道列。
    private var launcherEntry: some View {
        HStack(alignment: .bottom, spacing: 16) {
            if shouldShowIconPopup, let message = snapshot.lastNoticeMsg, !launcherExpanded {
                iconPopupPreview(message)
                    .transition(.scale(scale: 0.88).combined(with: .opacity))
            }

            VStack(alignment: .trailing, spacing: 0) {
                if launcherExpanded {
                    launcherExpandedChannelList
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                launcherToggleButton
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            recordLauncherHeightTarget(proxy)
                        }
                        .onChange(of: proxy.frame(in: .global)) { _ in
                            recordLauncherHeightTarget(proxy)
                        }
                }
            )
        }
    }

    /// 对齐 widget main:src/components/SideBar/index.vue 的 reverseChannelList + ChannelChat 渠道列。
    private var launcherExpandedChannelList: some View {
        VStack(alignment: .trailing, spacing: 12) {
            ForEach(launcherExternalChannels, id: \.self) { channel in
                launcherChannelButton(channel)
            }

            if snapshot.channels.contains("chat") {
                launcherChatChannelButton
            }
        }
        .padding(.bottom, 12)
    }

    /// 对齐 widget main:src/components/Channel/Expand.vue，single_icon 点击在展开/收起之间切换。
    private var launcherToggleButton: some View {
        Button {
            if launcherExpanded {
                launcherExpanded = false
            } else if launcherShouldExpand {
                launcherExpanded = true
            } else {
                runtime.openLauncherEntry()
                refresh()
            }
        } label: {
            if launcherExpanded {
                launcherCircle(
                    icon: "icon-closure-circle",
                    glyphSize: 26,
                    foreground: themeForeground
                )
            } else {
                launcherChatIcon(size: 52, glyphSize: 26)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            Text(launcherExpanded ? salesmartlyText("btn.close", language: snapshot.lang) : salesmartlyText("btn.enterChat", language: snapshot.lang))
        )
    }

    /// 对齐 widget main:src/components/Channel/Chat.vue，聊天渠道图标点击进入 Home 或 Chat。
    private var launcherChatChannelButton: some View {
        Button {
            launcherExpanded = false
            openChannelFromHost("chat")
        } label: {
            launcherChatIcon(size: 52, glyphSize: 30)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(salesmartlyText("btn.enterChat", language: snapshot.lang)))
    }

    /// 对齐 widget main:src/components/Channel/*.vue 的外部渠道入口，点击后按 plugin/info 的 redirect_url 打开对应渠道。
    private func launcherChannelButton(_ channel: String) -> some View {
        Button {
            launcherExpanded = false
            openChannelFromHost(channel)
        } label: {
            homePageChannelIcon(channel: channel, size: 52, glyphSize: 36)
                .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(homePageChannelTitle(channel)))
    }

    /// 对齐 Android `handleChannelClick`，SwiftUI Host 所有 Launcher/Home/Header 渠道点击都统一从 runtime 分发并由 Host 执行 URL 打开。
    private func openChannelFromHost(_ channel: String) {
        if let urlString = runtime.handleChannelClick(
            channel,
            sourceURL: snapshot.trackedURL ?? "",
            whatsappLinkText: salesmartlyText("msg.whatsappLink", language: snapshot.lang),
            isMobile: Self.isMobileHost
        ),
            let url = URL(string: urlString),
            !urlString.isEmpty {
            openURL(url)
        }
        refresh()
    }

    /// 对齐 widget main:src/components/Channel/Chat.vue 与 Expand.vue 的主题色圆形入口，尺寸使用 Web large icon 口径。
    private func launcherCircle(icon: String, glyphSize: CGFloat, foreground: Color) -> some View {
        ZStack {
            if icon == "msg2" {
                SalesmartlyWidgetIcon(type: "msg1", size: glyphSize, color: foreground)
                SalesmartlyWidgetIcon(type: "msg2", size: glyphSize, color: foreground)
            } else {
                SalesmartlyWidgetIcon(type: icon, size: glyphSize, color: foreground)
            }
        }
        .frame(width: 52, height: 52)
        .background(themePrimary)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
    }

    /// 对齐 widget main:src/components/Channel/Chat.vue 的 `customize` 分支，自定义聊天入口直接展示 plugin_iconv 图片，不叠加默认圆底。
    @ViewBuilder
    private func launcherChatIcon(size: CGFloat, glyphSize: CGFloat) -> some View {
        if snapshot.chatIconDefine {
            chatCustomIconImage(urlString: snapshot.chatIconOutURL, size: size)
        } else {
            launcherCircle(icon: "msg1", glyphSize: glyphSize, foreground: themeForeground)
        }
    }

    /// 对齐 widget main:src/components/SideBar/index.vue 的 reverseChannelList，chat 渠道由 ChannelChat 单独渲染。
    private var launcherExternalChannels: [String] {
        runtime.makeReverseChannelList(
            channels: snapshot.channels.filter { $0 != "chat" },
            channelSort: snapshot.channelSort
        )
    }

    /// 对齐 widget main:src/components/SideBar/index.vue 的 single_icon 展开条件，存在外部渠道或 chat 渠道时优先展开。
    private var launcherShouldExpand: Bool {
        snapshot.sidebarShow &&
            snapshot.sidebarShrinkMode == "single_icon" &&
            (!launcherExternalChannels.isEmpty || snapshot.channels.contains("chat"))
    }

    /// 对齐 widget main:src/components/SideBar/index.vue 与移动端 showIcon 规则，桌面打开态保留底部关闭入口，移动端打开态只展示聊天窗本身。
    private func openedChatEntry(layout: SalesmartlyOpenedChatWindowLayoutState) -> some View {
        VStack(alignment: widgetEntryHorizontalAlignment, spacing: layout.showsBottomCloseButton ? 16 : 0) {
            chatWindow(layout: layout)

            if layout.showsBottomCloseButton {
                launcherCloseButton
            }
        }
    }

    /// 对齐 widget main:src/components/Channel/Expand.vue 的 showWrapper 关闭按钮，使用主题圆形入口和 icon-closure-circle。
    private var launcherCloseButton: some View {
        Button {
            closeChatFromHost()
        } label: {
            launcherCircle(icon: "icon-closure-circle", glyphSize: 26, foreground: themeForeground)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
    }

    /// 对齐 widget main:src/styles/view.less 的桌面 `.chat`、移动端 `.mobile .chat` 与 `.fullScreen .chat`，使用已计算布局状态渲染窗口。
    private func chatWindow(layout: SalesmartlyOpenedChatWindowLayoutState) -> some View {
        Group {
            if snapshot.currentView == .home {
                homePage
            } else {
                ZStack(alignment: .top) {
                    chatPageBackground

                    VStack(spacing: 0) {
                        header
                        bulletinBoardBanner
                            .simultaneousGesture(chatHeaderOutsideTapGesture)

                        ZStack {
                            chatMessageList

                            if let type = collectionOverlayType {
                                collectionOverlay(type: type)
                                    .transition(.opacity)
                            }
                        }
                        // 对齐 widget main:src/views/Chat/components/ChatList.vue 的 chat__list__wrap：消息区必须占用 Header 与输入栏之间的剩余高度，ScrollView 才会形成可滚动 viewport。
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        // 对齐 widget main:src/views/Chat/style/chatList.less 的 flex:1/min-height:0/overflow:hidden，防止消息内容反向撑开聊天窗并保证拖动命中真实列表区。
                        .layoutPriority(1)
                        .clipped()
                        .simultaneousGesture(chatHeaderOutsideTapGesture)

                        chatStatusFooter
                            .simultaneousGesture(chatHeaderOutsideTapGesture)
                        composer
                            .simultaneousGesture(chatHeaderOutsideTapGesture)
                    }
                }
            }
        }
        .frame(width: layout.width, height: layout.height)
        .background(Color.salesmartlyPanelBackground)
        .clipShape(RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: layout.cornerRadius, style: .continuous)
                .stroke(Color.white, lineWidth: 2)
        }
        .shadow(color: Color.black.opacity(layout.shadowRadius == 0 ? 0 : 0.20), radius: layout.shadowRadius, x: 0, y: 4)
    }

    /// 对齐 widget main:src/directives/ClickOutside.ts，聊天内容区任意点击都视为 Header 信息卡外部点击。
    private var chatHeaderOutsideTapGesture: some Gesture {
        TapGesture().onEnded {
            chatHeaderInfoCardMode = Self.chatHeaderInfoCardAfterChatContentTap(chatHeaderInfoCardMode, runtime: runtime)
        }
    }

    /// 对齐 widget main:src/styles/view.less 的 PC 400px 宽度规则，窄容器下扣除桌面 wrap 侧边距。
    nonisolated private static func chatWindowWidth(availableWidth: CGFloat) -> CGFloat {
        min(400, max(0, availableWidth - 30))
    }

    /// 对齐 widget main:src/views/Chat/style/chat.less 的 `.chat_container::before` 和 `.chat_top_gradient`，在聊天页容器层承载主题淡渐变。
    private var chatPageBackground: some View {
        ZStack(alignment: .top) {
            Color.white

            LinearGradient(
                colors: [
                    themeHomeGradientTop,
                    themeHomeGradientMiddle,
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .opacity(0.12)

            ZStack {
                LinearGradient(
                    colors: [
                        themeHomeGradientTop,
                        themeHomeGradientMiddle,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                LinearGradient(
                    stops: [
                        .init(color: themeColorOnWhite(opacity: 0.06), location: 0),
                        .init(color: Color.white.opacity(0), location: 0.68),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(height: 232)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: Color.black, location: 0),
                        .init(color: Color.black.opacity(0.90), location: 0.48),
                        .init(color: Color.black.opacity(0.34), location: 0.82),
                        .init(color: Color.black.opacity(0), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .ignoresSafeArea()
    }

    /// 对齐 widget main:src/views/Page/index.vue 的 Home 主页，展示品牌信息、主渠道卡片、其他渠道网格和独立关闭入口。
    private var homePage: some View {
        ZStack(alignment: .topTrailing) {
            homePageBackground

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    homePageHeader

                    let displayState = runtime.homeChannelDisplayState()
                    if displayState.showMainCard, let mainChannel = displayState.mainChannel {
                        homePageMainCard(channel: mainChannel, isChat: displayState.showReceptionChatCard)
                    }

                    if !displayState.gridChannels.isEmpty {
                        homePageChannelGrid(displayState.gridChannels)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }

            if runtime.shouldShowWindowCloseButton() {
                Button {
                    closeChatFromHost()
                } label: {
                    SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 18, color: Color.salesmartlyCloseIcon)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
                .padding(.top, 17)
                .padding(.trailing, 6)
            }
        }
    }

    /// 对齐 widget main:src/views/Page/styles/page.less 的主页渐变背景和底部白色渐隐层。
    private var homePageBackground: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    themeHomeGradientTop,
                    themeHomeGradientMiddle,
                    Color.salesmartlyHomeGradientBottom,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0),
                    Color.salesmartlyFooterBackground.opacity(0.96),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 382)
        }
        .ignoresSafeArea()
    }

    /// 对齐 widget main:src/views/Page/index.vue 的主页顶部品牌区域，品牌行和欢迎语分开渲染。
    private var homePageHeader: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 12) {
                homePageBrandAvatar(size: 36)

                Text(homePageBrandName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.salesmartlyCollectionTitle)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(homePageWelcomeText)
                .font(.system(size: homePageWelcomeText.count > 20 ? 28 : 34, weight: .semibold))
                .lineSpacing(4)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.salesmartlyHomeWelcomeStart,
                            themePrimary,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 48)
        .padding(.bottom, 8)
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的主渠道卡片，chat 渠道点击后进入聊天页。
    private func homePageMainCard(channel: String, isChat: Bool) -> some View {
        VStack(spacing: 8) {
            homePageMainCardContent(channel: channel, isChat: isChat)

            Button {
                openChannelFromHost(isChat ? "chat" : channel)
            } label: {
                HStack(spacing: 8) {
                    SalesmartlyWidgetIcon(type: "icon-chat-fill", size: 20, color: themeForeground)
                    Text(isChat ? salesmartlyText("btn.enterChat", language: snapshot.lang) : salesmartlyText("tips.contactUs", language: snapshot.lang))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(themeForeground)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(themePrimary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 122, alignment: .bottom)
        .background(
            LinearGradient(
                colors: [
                    themeColorOnWhite(opacity: 0.06),
                    Color.white,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 24, x: 0, y: 4)
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的主卡上半部分，优先展示最近消息摘要，否则展示默认 chat 头像和 hello 徽标。
    @ViewBuilder
    private func homePageMainCardContent(channel: String, isChat: Bool) -> some View {
        if isChat, let latestMessage = homePageLatestMessage {
            HStack(spacing: 8) {
                homePageRecentMessageAvatar(size: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text(homePageReceptionName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.salesmartlyCollectionTitle)
                        .lineLimit(1)

                    Text(homePageRecentMessagePreview(latestMessage))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.salesmartlyQuoteText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
            .padding(.bottom, 6)
        } else if isChat {
            ZStack(alignment: .topTrailing) {
                homePageRecentMessageAvatar(size: 52)
                SalesmartlyWidgetIcon(type: "icon-hello-fill", size: 22, color: themePrimary)
                    .offset(x: 24, y: -14)
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        } else {
            ZStack(alignment: .topTrailing) {
                homePageChannelIcon(channel: channel, size: 52, glyphSize: 28)
                SalesmartlyWidgetIcon(type: "icon-hello-fill", size: 22, color: themePrimary)
                    .offset(x: 28, y: -12)
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的最近消息头像优先级。
    @ViewBuilder
    private func homePageRecentMessageAvatar(size: CGFloat) -> some View {
        let avatarURL = runtime.chatHeaderAvatarURL()
        if !avatarURL.isEmpty {
            SalesmartlyCachedRemoteImage(urlString: avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                homePageDefaultAvatar(size: size)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            homePageDefaultAvatar(size: size)
        }
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的最近消息摘要，按消息类型展示 `[图片]` 等本地化标签。
    private func homePageRecentMessagePreview(_ message: ChatMessage) -> String {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: message,
            showReceptionInfo: snapshot.iconPopupShowReceptionInfo,
            language: snapshot.lang
        )
        switch component.kind {
        case .image:
            return "[\(salesmartlyText("fileType.image", language: snapshot.lang))]"
        case .video:
            return "[\(salesmartlyText("fileType.video", language: snapshot.lang))]"
        case .file:
            return "[\(salesmartlyText("fileType.attachment", language: snapshot.lang))]"
        default:
            return messageDisplayText(message, component: component)
        }
    }

    /// 对齐 widget main:src/views/Page/index.vue 的品牌名取值：window_name 优先，其次 plugin_name。
    private var homePageBrandName: String {
        if !snapshot.iconPopupWindowName.isEmpty {
            return snapshot.iconPopupWindowName
        }
        if !snapshot.pluginName.isEmpty {
            return snapshot.pluginName
        }
        return "Salesmartly"
    }

    private var homePageWelcomeText: String {
        Self.localizedHomePageWelcomeText(homePageTitle: snapshot.homePageTitle, language: snapshot.lang)
    }

    private var homePageReceptionName: String {
        let title = runtime.chatHeaderTitle()
        return title.isEmpty ? homePageBrandName : title
    }

    private var homePageLatestMessage: ChatMessage? {
        snapshot.messages.reversed().first { message in
            message.isWithdraw != "1"
        }
    }

    /// 对齐 widget main:src/views/Page/components/ChannelList.vue 的其他渠道网格，列表来源已在 runtime 中完成 sidebar 去重。
    private func homePageChannelGrid(_ channels: [String]) -> some View {
        let columnCount = channels.count >= 4 ? 2 : 1
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount), spacing: 8) {
            ForEach(channels, id: \.self) { channel in
                Button {
                    openChannelFromHost(channel)
                } label: {
                    HStack(spacing: 8) {
                        homePageChannelIcon(channel: channel, size: 30, glyphSize: 16)
                        Text(salesmartlyText("tips.contactUs", language: snapshot.lang))
                            .font(.system(size: 12))
                            .foregroundStyle(Color.salesmartlyMetaText)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        SalesmartlyWidgetIcon(type: "icon-go-to-circle", size: 8, color: Color.white)
                            .frame(width: 10, height: 10)
                            .background(themePrimary)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Color.salesmartlyHomeGridItem)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Color.black.opacity(0.02), radius: 12, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// 对齐 widget main:src/components/Channel/useChannel.ts 的渠道类型，iOS 以 Web icon type 承载已确认渠道名。
    private func homePageChannelIcon(channel: String, size: CGFloat, glyphSize: CGFloat) -> some View {
        ZStack {
            if channel == "chat" {
                SalesmartlyWidgetIcon(type: "msg1", size: glyphSize, color: themeForeground)
                SalesmartlyWidgetIcon(type: "msg2", size: glyphSize, color: themeForeground)
            } else {
                SalesmartlyWidgetIcon(type: homePageChannelWebIcon(channel), size: glyphSize, color: Color.white)
            }
        }
        .frame(width: size, height: size)
        .background(homePageChannelColor(channel))
        .clipShape(Circle())
    }

    /// 对齐 widget main:src/components/Channel/Chat.vue 的自定义 `<img>`，图片本身占满对应 large/xs 圆形入口尺寸。
    private func chatCustomIconImage(urlString: String, size: CGFloat) -> some View {
        SalesmartlyCachedRemoteImage(urlString: urlString) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                SalesmartlyWidgetIcon(type: "msg1", size: size * 0.58, color: themeForeground)
                SalesmartlyWidgetIcon(type: "msg2", size: size * 0.58, color: themeForeground)
            }
            .frame(width: size, height: size)
            .background(themePrimary)
            .clipShape(Circle())
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    /// 对齐 widget main:src/views/Page/index.vue 的品牌头像，优先展示插件 avatar_url。
    @ViewBuilder
    private func homePageBrandAvatar(size: CGFloat) -> some View {
        if !snapshot.pluginAvatarURL.isEmpty {
            SalesmartlyCachedRemoteImage(urlString: snapshot.pluginAvatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                homePageDefaultAvatar(size: size)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            homePageDefaultAvatar(size: size)
        }
    }

    private func homePageDefaultAvatar(size: CGFloat) -> some View {
        SalesmartlyWidgetIcon(type: "icon-default-logo-fill", size: size * 0.74, color: Color.white)
            .frame(width: size, height: size)
            .background(themePrimary)
            .clipShape(Circle())
    }

    private func homePageChannelTitle(_ channel: String) -> String {
        switch channel {
        case "chat":
            return salesmartlyText("btn.enterChat", language: snapshot.lang)
        case "whatsapp":
            return "WhatsApp"
        case "messenger":
            return "Messenger"
        case "email":
            return "Email"
        case "telegram":
            return "Telegram"
        case "line", "lineApp":
            return "Line"
        case "instagram":
            return "Instagram"
        case "tiktok":
            return "TikTok"
        case "zalo":
            return "Zalo"
        case "vkontakte":
            return "VKontakte"
        case "weixin":
            return "WeChat"
        default:
            return channel
        }
    }

    private func homePageChannelWebIcon(_ channel: String) -> String {
        switch channel {
        case "chat":
            return "icon-chat-fill"
        case "email":
            return "email"
        case "telegram":
            return "telegram"
        case "line", "lineApp":
            return channel == "lineApp" ? "lineapp" : "line1"
        case "instagram":
            return "instagram"
        case "tiktok":
            return "tiktok"
        case "vkontakte":
            return "vkontakte"
        case "zalo":
            return "zalo"
        case "weixin":
            return "weixin"
        case "messenger":
            return "messenger"
        case "whatsapp":
            return "whatsapp-fill"
        default:
            return "icon-chat-fill"
        }
    }

    private func homePageChannelColor(_ channel: String) -> Color {
        switch channel {
        case "chat":
            return themePrimary
        case "whatsapp":
            return Color(red: 37 / 255, green: 211 / 255, blue: 102 / 255)
        case "messenger":
            return Color(red: 0 / 255, green: 132 / 255, blue: 255 / 255)
        case "email":
            return Color(red: 74 / 255, green: 84 / 255, blue: 104 / 255)
        case "telegram":
            return Color(red: 42 / 255, green: 171 / 255, blue: 238 / 255)
        case "line", "lineApp":
            return Color(red: 6 / 255, green: 199 / 255, blue: 85 / 255)
        case "instagram":
            return Color(red: 225 / 255, green: 48 / 255, blue: 108 / 255)
        case "tiktok":
            return Color(red: 17 / 255, green: 24 / 255, blue: 39 / 255)
        case "zalo":
            return Color(red: 0 / 255, green: 104 / 255, blue: 255 / 255)
        case "vkontakte":
            return Color(red: 76 / 255, green: 117 / 255, blue: 163 / 255)
        case "weixin":
            return Color(red: 7 / 255, green: 193 / 255, blue: 96 / 255)
        default:
            return themePrimary
        }
    }

    /// 对齐 Android `MediaPreviewOverlay`、Web `ValidImager.vue` 与 `VideoPreview/index.vue`，用于聊天窗内图片和视频放大预览。
    private var mediaPreviewOverlay: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(Self.mediaPreviewCoverOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMediaPreview()
                    }

                if let mediaPreviewTarget {
                    switch mediaPreviewTarget {
                    case .image(let urlString):
                        SalesmartlyCachedRemoteImage(urlString: urlString) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        }
                        .padding(24)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    case .video(let urlString):
                        videoPreviewOverlay(urlString: urlString, availableSize: proxy.size)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(alignment: .topTrailing) {
                Button {
                    closeMediaPreview()
                } label: {
                    SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 24, color: Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.34))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
                .padding(.top, 30)
                .padding(.trailing, 40)
            }
        }
        .zIndex(20)
    }

    /// 对齐 widget main:src/views/Chat/components/BulletinBoard.vue 的公告弹窗。
    private var bulletinBoardModalOverlay: some View {
        let state = runtime.bulletinBoardState()
        return ZStack {
            Color.black.opacity(0.34)
                .ignoresSafeArea()
                .onTapGesture {
                    showBulletinBoardModal = false
                }

            VStack(spacing: 18) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 72)

                        Text(state.modalTitle)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.salesmartlyCollectionTitle)
                            .lineLimit(1)

                        Text(state.content)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.salesmartlyQuoteText)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .padding(.top, 14)

                        Spacer(minLength: 0)

                        if state.canGotoLink {
                            Button {
                                openBulletinBoardLink(state.link)
                            } label: {
                                HStack(spacing: 5) {
                                    Text(state.gotoText)
                                        .font(.system(size: 12))
                                        .foregroundStyle(themePrimary)

                                    SalesmartlyWidgetIcon(type: "icon-go-to-circle", size: 8, color: Color.white)
                                        .frame(width: 11, height: 11)
                                        .background(themePrimary)
                                        .clipShape(Circle())
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()
                            .frame(height: 24)
                    }
                    .padding(.horizontal, 22)
                    .frame(width: 294, height: 220)
                    .background(
                        LinearGradient(
                            colors: [
                                themePrimary.opacity(0.12),
                                Color.white,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                    .padding(.top, 34)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themePrimary.opacity(0.82),
                                    themePrimary.opacity(0.48),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay {
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        }
                        .overlay {
                            SalesmartlyWidgetIcon(type: "icon-announcement-fill", size: 48, color: Color.white)
                        }
                }
                .frame(width: 294, height: 254)

                Button {
                    showBulletinBoardModal = false
                } label: {
                    SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 16, color: Color.white)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.58))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
            }
        }
        .zIndex(12)
    }

    /// 对齐 widget main:src/components/VideoPreview/index.vue 的 popup video：居中展示 AVPlayer 并保持控件可点击。
    @ViewBuilder
    private func videoPreviewOverlay(urlString: String, availableSize: CGSize) -> some View {
        let layout = Self.mediaPreviewVideoLayoutState(availableSize: availableSize, aspectRatio: 16 / 9)
        #if canImport(AVKit)
        ZStack {
            Color.black
            if let videoPreviewPlayer {
                #if canImport(UIKit)
                SalesmartlyVideoPreviewPlayer(player: videoPreviewPlayer)
                    .frame(width: layout.width, height: layout.height)
                    .onAppear {
                        videoPreviewPlayer.play()
                    }
                #else
                VideoPlayer(player: videoPreviewPlayer)
                    .frame(width: layout.width, height: layout.height)
                    .onAppear {
                        videoPreviewPlayer.play()
                    }
                #endif
            }
            if !videoPreviewHasRenderedFrame {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.white.opacity(0.82))
                    .allowsHitTesting(false)
            }
        }
        .frame(width: layout.width, height: layout.height)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        #else
        SalesmartlyCachedVideoThumbnail(
            urlString: urlString,
            fileName: "",
            width: layout.width,
            height: layout.height,
            playSize: 0
        )
        #endif
    }

    /// 对齐 Android `messageImagePreviewUrl`：聊天窗图片预览使用 720px resize URL。
    private func openImagePreview(_ urlString: String) {
        mediaPreviewTarget = .image(runtime.resizeOssImgUrl(urlString, width: 720))
    }

    /// 对齐 Android `MediaPreviewTarget.Video`：点击视频缩略图后进入原生视频预览。
    private func openVideoPreview(_ urlString: String) {
        #if canImport(AVKit)
        guard let url = URL(string: urlString) else {
            return
        }
        stopVideoPreview()
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = false
        videoPreviewPlayer = player
        videoPreviewHasRenderedFrame = false
        mediaPreviewTarget = .video(urlString)
        videoPreviewStatusObserver = item.observe(\.status, options: [.initial, .new]) { item, _ in
            if item.status == .readyToPlay {
                Task { @MainActor in
                    videoPreviewHasRenderedFrame = true
                    videoPreviewPlayer?.playImmediately(atRate: 1)
                }
            }
        }
        videoPreviewTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { time in
            if time.seconds > 0 {
                Task { @MainActor in
                    videoPreviewHasRenderedFrame = true
                }
            }
        }
        player.play()
        #else
        mediaPreviewTarget = .video(urlString)
        #endif
    }

    /// 对齐 Android `MediaPreviewOverlay.onDismiss`，关闭预览时同步停止视频播放。
    private func closeMediaPreview() {
        mediaPreviewTarget = nil
        stopVideoPreview()
    }

    /// 对齐 Android custom entry popup 关闭动作，Host 转发到 runtime 后刷新快照。
    private func closeCustomEntryPopupFromHost() {
        runtime.closeCustomEntryPopup()
        refresh()
    }

    /// 对齐 Android custom entry 图片预览关闭动作。
    private func closeCustomEntryImagePreviewFromHost() {
        runtime.closeCustomEntryPopupImagePreview()
        refresh()
    }

    /// 对齐 Android Toast 展示时长，SwiftUI item 出现后延迟移除 runtime 队列项。
    private func scheduleToastDismiss(_ id: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            runtime.dismissToast(id: id)
            refresh()
        }
    }

    /// 对齐 widget main:src/App.vue 的 handleCloseChat/closeWindow，Host 关闭入口统一收起本地浮层和键盘后关闭聊天窗口。
    private func closeChatFromHost() {
        let closeState = Self.closeInteractionState(
            launcherExpanded: launcherExpanded,
            showEmojiPanel: showEmojiPanel,
            isComposerFocused: isComposerFocused
        )
        launcherExpanded = closeState.launcherExpanded
        showEmojiPanel = closeState.showEmojiPanel
        isComposerFocused = closeState.isComposerFocused
        runtime.closeChat()
        refresh()
    }

    private func stopVideoPreview() {
        #if canImport(AVKit)
        if let token = videoPreviewTimeObserver {
            videoPreviewPlayer?.removeTimeObserver(token)
        }
        videoPreviewTimeObserver = nil
        videoPreviewStatusObserver?.invalidate()
        videoPreviewStatusObserver = nil
        videoPreviewPlayer?.pause()
        videoPreviewPlayer = nil
        videoPreviewHasRenderedFrame = false
        #endif
    }

    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的顶部 floating card Header。
    private var header: some View {
        let showChannelRow = runtime.chatHeaderShowsChannelRow()
        let height = CGFloat(runtime.chatHeaderContainerHeight(chatHeaderInfoCardMode, showHeaderChannelRow: showChannelRow))
        return GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        chatHeaderInfoCardMode = runtime.chatHeaderInfoCardAfterOutsideClick(chatHeaderInfoCardMode, isMobile: true)
                    }

                chatHeaderInfoCard(
                    mode: chatHeaderInfoCardMode,
                    availableWidth: Int(proxy.size.width),
                    showChannelRow: showChannelRow
                )
                .frame(maxWidth: .infinity, alignment: .top)

                if runtime.chatHeaderShowsActionButtons(chatHeaderInfoCardMode) {
                    HStack(alignment: .top) {
                        chatHeaderActionButton(runtime.chatHeaderLeftAction(), isRightAction: false)
                        Spacer()
                        chatHeaderActionButton(runtime.chatHeaderRightAction(), isRightAction: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
        .frame(height: height)
        .background(Color.clear)
    }

    /// 对齐 Android `ChatHeaderInfoCard`，信息卡居中且宽度按 mode 和可用宽度计算。
    private func chatHeaderInfoCard(
        mode: SalesmartlyChatHeaderInfoCardMode,
        availableWidth: Int,
        showChannelRow: Bool
    ) -> some View {
        let presentation = runtime.chatHeaderInfoCardPresentation(mode, showHeaderChannelRow: showChannelRow)
        let width = CGFloat(runtime.chatHeaderInfoCardWidth(mode, availableWidth: availableWidth))
        return VStack(spacing: 0) {
            chatHeaderInfoTopRow(mode: mode, presentation: presentation)

            if presentation.showChannelRow {
                chatHeaderChannelRow(presentation: presentation, width: width)
            }
        }
        .frame(width: width)
        .padding(.vertical, CGFloat(presentation.infoCardVerticalPadding))
    }

    /// 对齐 Android `ChatHeaderInfoTopRow`，实现 Web 10% 主题色渐变、阴影、圆角和点击状态流。
    private func chatHeaderInfoTopRow(
        mode: SalesmartlyChatHeaderInfoCardMode,
        presentation: SalesmartlyChatHeaderInfoCardPresentation
    ) -> some View {
        let corner = CGFloat(presentation.topRowCornerRadius)
        return Button {
            chatHeaderInfoCardMode = runtime.chatHeaderInfoCardAfterTopRowClick(mode)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    chatHeaderAvatar(size: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(runtime.chatHeaderTitle())
                            .font(.system(size: CGFloat(presentation.titleFontSize), weight: .semibold))
                            .foregroundStyle(Color.salesmartlyCollectionTitle)
                            .lineLimit(mode == .detailOpen ? 2 : 1)

                        if mode != .detailOpen, let subtitle = runtime.chatHeaderSubtitle() {
                            Text(subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.salesmartlyMetaText)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: mode == .detailOpen ? CGFloat(260) : .infinity, alignment: .leading)
                }

                if mode == .detailOpen, let subtitle = runtime.chatHeaderSubtitle() {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.salesmartlyMetaText)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, CGFloat(presentation.topRowHorizontalPadding))
            .padding(.vertical, CGFloat(presentation.topRowVerticalPadding))
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(
                minHeight: CGFloat(presentation.topRowMinHeight),
                maxHeight: CGFloat(presentation.topRowMaxHeight),
                alignment: .center
            )
            .background(
                LinearGradient(
                    stops: [
                        .init(color: themeHeaderTint, location: 0),
                        .init(color: themeHeaderTint, location: 0.5657),
                        .init(color: Color.white, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: CGFloat(presentation.topRowShadowRadius) * 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    /// 对齐 Android `ChatHeaderChannelRow`，折叠态和展开态使用 Header 专用渠道图标尺寸。
    private func chatHeaderChannelRow(presentation: SalesmartlyChatHeaderInfoCardPresentation, width: CGFloat) -> some View {
        let rowWidth = max(0, width - CGFloat(presentation.channelRowHorizontalInset))
        let compact = presentation.channelRowHeight == 20
        return HStack(spacing: 8) {
            ForEach(runtime.chatHeaderChannels(), id: \.self) { channel in
                chatHeaderChannelIcon(channel: channel, compact: compact)
            }
        }
        .frame(width: rowWidth, height: CGFloat(presentation.channelRowHeight))
        .background(Color.white)
        .clipShape(Capsule(style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 0)
        .offset(y: CGFloat(presentation.channelRowTopOffset))
    }

    /// 对齐 Android `ChannelIconSize.HeaderCollapsed/HeaderExpanded` 的 Header 渠道 icon。
    private func chatHeaderChannelIcon(channel: String, compact: Bool) -> some View {
        let spec = runtime.chatHeaderChannelIconSpec(compact: compact)
        return Button {
            openChannelFromHost(channel)
        } label: {
            SalesmartlyWidgetIcon(type: homePageChannelWebIcon(channel), size: CGFloat(spec.iconSize), color: Color.white)
                .frame(width: CGFloat(spec.containerSize), height: CGFloat(spec.containerSize))
                .background(homePageChannelColor(channel))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(homePageChannelTitle(channel)))
    }

    /// 对齐 Android `ChatHeaderActionButton`，按左右位置使用不同 icon 尺寸。
    @ViewBuilder
    private func chatHeaderActionButton(_ action: SalesmartlyChatHeaderAction?, isRightAction: Bool) -> some View {
        if let action {
            let iconState = runtime.chatHeaderActionIconState(action, isRightAction: isRightAction)
            if action == .helpdesk, let url = URL(string: runtime.chatHeaderHelpdeskURLString()), !runtime.chatHeaderHelpdeskURLString().isEmpty {
                Link(destination: url) {
                    chatHeaderActionIcon(iconState)
                }
                .accessibilityLabel(Text(runtime.chatHeaderHelpdeskTitle()))
            } else {
                Button {
                    performChatHeaderAction(action)
                } label: {
                    chatHeaderActionIcon(iconState)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(chatHeaderActionAccessibilityLabel(action)))
            }
        } else {
            Color.clear
                .frame(width: 28, height: 28)
        }
    }

    /// 对齐 Android `WidgetIcon`，Header action 使用 Web icon 类型和尺寸口径渲染。
    private func chatHeaderActionIcon(_ iconState: SalesmartlyChatHeaderActionIconState) -> some View {
        SalesmartlyWidgetIcon(type: iconState.webIconName, size: CGFloat(iconState.size), color: Color.salesmartlyCloseIcon)
            .frame(width: 28, height: 28)
    }

    /// 对齐 Android `ChatHeaderActionButton` 的 close/back/helpdesk 动作分发。
    private func performChatHeaderAction(_ action: SalesmartlyChatHeaderAction) {
        switch action {
        case .close:
            closeChatFromHost()
            return
        case .back:
            runtime.openHome()
        case .helpdesk:
            break
        }
        refresh()
    }

    /// 对齐 Android Header action 类型，给 iOS 可访问性入口提供动作名称。
    private func chatHeaderActionAccessibilityLabel(_ action: SalesmartlyChatHeaderAction) -> String {
        switch action {
        case .close:
            return salesmartlyText("btn.close", language: snapshot.lang)
        case .back:
            return "Back"
        case .helpdesk:
            return runtime.chatHeaderHelpdeskTitle()
        }
    }

    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的 Header 头像，接待客服头像优先，否则使用插件品牌头像。
    @ViewBuilder
    private func chatHeaderAvatar(size: CGFloat) -> some View {
        let avatarURL = runtime.chatHeaderAvatarURL()
        if !avatarURL.isEmpty {
            SalesmartlyCachedRemoteImage(urlString: avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                chatHeaderDefaultAvatar(size: size)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            chatHeaderDefaultAvatar(size: size)
        }
    }

    private func chatHeaderDefaultAvatar(size: CGFloat) -> some View {
        Circle()
            .fill(themeColorOnWhite(opacity: 0.14))
            .frame(width: size, height: size)
            .overlay {
                SalesmartlyWidgetIcon(type: "icon-default-logo-fill", size: size * 0.78, color: themePrimary)
            }
    }

    /// 对齐 widget main:src/views/Chat/components/BulletinBoard.vue 的聊天页公告横条。
    @ViewBuilder
    private var bulletinBoardBanner: some View {
        let state = runtime.bulletinBoardState()
        if state.visible {
            HStack(spacing: 8) {
                SalesmartlyWidgetIcon(type: "icon-announcement-fill", size: 16, color: themePrimary)
                    .frame(width: 16, height: 16)

                if state.isMarquee {
                    SalesmartlyBulletinMarqueeText(
                        text: state.content,
                        durationSeconds: state.marqueeDurationSeconds,
                        color: themePrimary,
                        underlined: state.canJumpOnBoardClick
                    )
                    .frame(maxWidth: .infinity, minHeight: 16)
                } else {
                    Text(state.content)
                        .font(.system(size: 12))
                        .foregroundStyle(themePrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, minHeight: 16, alignment: .leading)
                }

                Button {
                    runtime.dismissBulletinBoard()
                    showBulletinBoardModal = false
                    refresh()
                } label: {
                    SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 16, color: themePrimary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(minHeight: 32)
            .background(themeColorOnWhite(opacity: 0.12))
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .stroke(themeColorOnWhite(opacity: 0.06), lineWidth: 1)
            }
            .contentShape(Capsule(style: .continuous))
            .onTapGesture {
                performBulletinBoardClick()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    /// 对齐 Android `BulletinBoardClickAction`，执行横条点击打开弹窗或链接。
    private func performBulletinBoardClick() {
        switch runtime.bulletinBoardClickAction() {
        case .none:
            break
        case .openModal:
            showBulletinBoardModal = true
        case .openLink(let urlString):
            openBulletinBoardLink(urlString)
        }
    }

    /// 对齐 Web `window.open(getBoardLink(...), '_blank')` 与 Android `UriHandler.openUri`。
    private func openBulletinBoardLink(_ urlString: String) {
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的消息渲染节点，撤回消息按 withdrawRecord 显示提示或隐藏。
    @ViewBuilder
    private func messageRenderNode(_ message: ChatMessage) -> some View {
        if message.isWithdraw == "1" {
            withdrawMessageBubble
        } else {
            messageBubble(message)
        }
    }

    /// 对齐 widget main:src/components/Bubble/index.vue 的 msg_type 分发，在 SwiftUI Host 中选择对应原生消息展示入口。
    private func messageBubble(_ message: ChatMessage) -> some View {
        let component = SalesmartlyNativeMessagePresentation.component(
            for: message,
            showReceptionInfo: snapshot.iconPopupShowReceptionInfo,
            language: snapshot.lang
        )
        return HStack(alignment: .top, spacing: 10) {
            if salesmartlyShouldShowMessageAvatar(message) {
                messageSenderAvatar(message)
            }

            VStack(alignment: message.sendType == "1" ? .trailing : .leading, spacing: 4) {
                if let quotePreview = component.quote_preview {
                    quotePreviewView(quotePreview)
                }
                messageBubbleContent(message: message, component: component)
                messageMetaLine(message)
            }
            .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/index.vue 的 bubble__avatar，客服/机器人消息在气泡左侧展示 sender_avatar 或默认 logo。
    @ViewBuilder
    private func messageSenderAvatar(_ message: ChatMessage) -> some View {
        if let urlString = messageSenderAvatarURL(message.senderAvatar) {
            SalesmartlyCachedRemoteImage(urlString: urlString) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                messageSenderDefaultAvatar
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
        } else {
            messageSenderDefaultAvatar
        }
    }

    /// 对齐 widget main:src/components/Bubble/index.vue 的 messageAvatarSrc，按 Web 头像裁剪尺寸请求 OSS 缩略图。
    private func messageSenderAvatarURL(_ avatar: String?) -> String? {
        guard let avatar, !avatar.isEmpty else {
            return nil
        }
        return "\(avatar)?x-oss-process=image/resize,m_fill,h_100,w_100"
    }

    /// 对齐 widget main:src/components/Bubble/styles/index.less 的 bubble__avatar_def，缺少 sender_avatar 时展示默认品牌图标。
    private var messageSenderDefaultAvatar: some View {
        Circle()
            .fill(Color(red: 84 / 255, green: 152 / 255, blue: 243 / 255).opacity(0.4))
            .frame(width: 36, height: 36)
            .overlay {
                SalesmartlyWidgetIcon(type: "icon-default-logo-fill", size: 28, color: Color.white)
            }
    }

    @ViewBuilder
    private func messageBubbleContent(message: ChatMessage, component: SalesmartlyNativeMessageComponent) -> some View {
        if let imageMessage = component.image_message {
            imageMessageBubble(message: message, component: component, imageMessage: imageMessage)
        } else if let videoMessage = component.video_message {
            videoMessageBubble(message: message, component: component, videoMessage: videoMessage)
        } else if let fileMessage = component.file_message {
            fileMessageBubble(message: message, component: component, fileMessage: fileMessage)
        } else if let audioMessage = component.audio_message {
            audioMessageBubble(message: message, component: component, audioMessage: audioMessage)
        } else if let productInfo = component.product_info {
            productMessageBubble(message: message, component: component, productInfo: productInfo)
        } else if let inviteEvalution = component.invite_evalution {
            inviteEvalutionBubble(message: message, component: component, inviteEvalution: inviteEvalution)
        } else if let templateMessage = component.template_message {
            templateMessageBubble(message: message, component: component, templateMessage: templateMessage)
        } else if let mediaText = component.media_text {
            mediaTextMessageBubble(message: message, component: component, mediaText: mediaText)
        } else if let quickReply = component.quick_reply {
            quickReplyMessageBubble(message: message, component: component, quickReply: quickReply)
        } else if let aiReply = component.ai_reply {
            aiReplyMessageBubble(message: message, component: component, aiReply: aiReply)
        } else if let searchSame = component.search_same {
            searchSameMessageBubble(message: message, component: component, searchSame: searchSame)
        } else if !component.same_product.isEmpty {
            sameProductMessageBubble(message: message, component: component)
        } else {
            defaultMessageBubble(message: message, component: component)
        }
    }

    /// 对齐 widget main:src/components/Bubble/index.vue 的默认 Bubble 分发，渲染非商品消息的图标与摘要。
    private func defaultMessageBubble(message: ChatMessage, component: SalesmartlyNativeMessageComponent) -> some View {
        let isVisitorMessage = message.sendType == "1"
        return HStack(spacing: 8) {
            if component.kind != .text {
                SalesmartlyWidgetIcon(
                    type: messageBubbleWebIconName(component.kind),
                    size: 14,
                    color: isVisitorMessage ? themeForeground : themePrimary
                )
            }

            messageText(messageDisplayText(message, component: component), component: component)
                .font(.system(size: 14))
                .foregroundStyle(isVisitorMessage ? themeForeground : Color.salesmartlyCollectionTitle)
                .lineLimit(nil)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(defaultMessageBubbleBackground(isVisitorMessage: isVisitorMessage))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .shadow(
            color: isVisitorMessage ? Color.clear : Color.black.opacity(0.10),
            radius: isVisitorMessage ? 0 : 4,
            x: 0,
            y: 0
        )
        .frame(maxWidth: .infinity, alignment: isVisitorMessage ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/TextMessage.vue 的 replaceLink，文本消息和 postback 文本中的 URL 与邮箱在原生端同样可点击。
    private func messageText(_ text: String, component: SalesmartlyNativeMessageComponent) -> Text {
        guard component.kind == .text || component.kind == .postback else {
            return Text(text)
        }

        return linkifiedText(text)
    }

    /// 对齐 widget main:src/utils/tool.ts 的 replaceLink，把可点击 URL 写入 AttributedString link 属性。
    private func linkifiedText(_ text: String) -> Text {
        var attributedText = AttributedString()
        SalesmartlyTextLinkifier.segments(in: text).forEach { segment in
            var attributedSegment = AttributedString(segment.text)
            if let destination = segment.destination,
               let url = URL(string: destination) {
                attributedSegment.link = url
            }
            attributedText += attributedSegment
        }
        return Text(attributedText)
    }

    /// 对齐 widget main:src/components/Bubble/ImageMessage.vue 的图片消息，按 imgUrl 展示原生图片预览。
    private func imageMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        imageMessage: SalesmartlyNativeImageMessageInfo
    ) -> some View {
        Button {
            openImagePreview(imageMessage.img_url)
        } label: {
            SalesmartlyCachedRemoteImage(urlString: runtime.resizeOssImgUrl(imageMessage.img_url, width: 280)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                salesmartlyImageLoadingPlaceholder
            }
            .frame(width: 220, height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/VideoMessage.vue 的视频消息，按 videoUrl 展示首帧并点击进入原生视频预览。
    private func videoMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        videoMessage: SalesmartlyNativeVideoMessageInfo
    ) -> some View {
        Button {
            openVideoPreview(videoMessage.video_url)
        } label: {
                SalesmartlyCachedVideoThumbnail(urlString: videoMessage.video_url, fileName: "")
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的文件消息，展示文件名和下载入口。
    private func fileMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        fileMessage: SalesmartlyNativeFileMessageInfo
    ) -> some View {
        fileAttachmentCard(message: message, fileName: fileMessage.full_file_name, fileURL: fileMessage.file_url)
            .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的白色文件卡片，普通文件消息和媒体文本文档共用同一展示。
    private func fileAttachmentCard(message: ChatMessage, fileName: String, fileURL: String) -> some View {
        let style = runtime.fileAttachmentCardStyleState()
        let reportId = runtime.fileDownloadReportId(for: message)
        let isUploading = runtime.fileMessageIsUploading(message)
        let isDownloading = downloadingFileIDs.contains(reportId)
        return HStack(spacing: CGFloat(style.gap)) {
            SalesmartlyWidgetIcon(type: "icon-document-fill", size: 22, color: themePrimary)
                .frame(width: 30, height: 30)
                .background(themePrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(fileName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !isUploading {
                Button {
                    startFileDownload(reportId: reportId, fileURL: fileURL, fileName: fileName)
                } label: {
                    Group {
                        if isDownloading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            SalesmartlyWidgetIcon(type: "icon-download-circle2", size: 20, color: themePrimary)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .disabled(isDownloading)
                .accessibilityLabel(Text(fileName))
            }
        }
        .padding(CGFloat(style.padding))
        .frame(width: CGFloat(style.width), height: CGFloat(style.height))
        .background(Color.salesmartlyPanelBackground)
        .opacity(isUploading ? 0.7 : 1)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(style.cornerRadius), style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CGFloat(style.cornerRadius), style: .continuous)
                .stroke(themePrimary, lineWidth: 1)
        }
    }

    /// 对齐 Android `FileBubble.onDownload`：按钮点击后先换签，再交给系统下载器保存文件。
    private func startFileDownload(reportId: String, fileURL: String, fileName: String) {
        if downloadingFileIDs.contains(reportId) {
            return
        }
        downloadingFileIDs.insert(reportId)
        runtime.resolveDownloadFileURL(
            reportId: reportId,
            fileURL: fileURL,
            onResolved: { resolvedURL in
                SalesmartlySystemFileDownloader.shared.downloadFile(urlString: resolvedURL, fileName: fileName)
            },
            onFinished: {
                DispatchQueue.main.async {
                    downloadingFileIDs.remove(reportId)
                }
            }
        )
    }

    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的音频消息，展示内联播放气泡。
    private func audioMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        audioMessage: SalesmartlyNativeAudioMessageInfo
    ) -> some View {
        audioMessageContent(urlString: audioMessage.audio_url, durationSeconds: nil)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 wrap，普通音频和模板音频附件共用同一内联控件。
    private func audioMessageContent(urlString: String, durationSeconds: Int?) -> some View {
        Button {
            handleAudioControl(urlString: urlString, durationSeconds: durationSeconds)
        } label: {
            audioMessageLabel(urlString: urlString, durationSeconds: durationSeconds)
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 voiceIcon、durationTime 和 lessTime 展示。
    private func audioMessageLabel(urlString: String, durationSeconds: Int?) -> some View {
        HStack(spacing: 5) {
            SalesmartlyAudioWaveIcon(isPlaying: activeAudioURL == urlString)

            if let seconds = audioDisplaySeconds(urlString: urlString, durationSeconds: durationSeconds) {
                Text("\(seconds)s")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.salesmartlyAudioText)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: 60, minHeight: 42, alignment: .leading)
        .background(Color.salesmartlyMessageBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func audioDisplaySeconds(urlString: String, durationSeconds: Int?) -> Int? {
        if activeAudioURL == urlString, let remaining = audioRemainingSeconds[urlString] {
            return remaining
        }
        if let duration = audioDurationSeconds[urlString] {
            return duration
        }
        return durationSeconds
    }

    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 handleControl：播放前暂停其它音频，再从 0 秒开始播放；播放中点击则暂停。
    private func handleAudioControl(urlString: String, durationSeconds: Int?) {
        #if canImport(AVFoundation)
        guard let url = URL(string: urlString) else {
            return
        }
        if activeAudioURL == urlString {
            pauseAudio(urlString)
            return
        }

        pauseAllAudio(except: urlString)
        let player = audioPlayers[urlString] ?? AVPlayer(url: url)
        audioPlayers[urlString] = player
        if let durationSeconds {
            audioDurationSeconds[urlString] = durationSeconds
            audioRemainingSeconds[urlString] = durationSeconds
        }
        activeAudioURL = urlString
        installAudioTimeObserver(for: urlString, player: player)
        player.seek(to: .zero)
        player.play()
        #endif
    }

    private func pauseAllAudio(except urlString: String) {
        #if canImport(AVFoundation)
        audioPlayers.forEach { item in
            if item.key != urlString {
                item.value.pause()
                if let duration = audioDurationSeconds[item.key] {
                    audioRemainingSeconds[item.key] = duration
                }
            }
        }
        if activeAudioURL != urlString {
            activeAudioURL = nil
        }
        #endif
    }

    private func pauseAudio(_ urlString: String) {
        #if canImport(AVFoundation)
        audioPlayers[urlString]?.pause()
        activeAudioURL = nil
        if let duration = audioDurationSeconds[urlString] {
            audioRemainingSeconds[urlString] = duration
        }
        #endif
    }

    private func stopAudioPlayback() {
        #if canImport(AVFoundation)
        audioPlayers.forEach { item in
            item.value.pause()
            if let token = audioTimeObservers[item.key] {
                item.value.removeTimeObserver(token)
            }
        }
        audioTimeObservers = [:]
        activeAudioURL = nil
        #endif
    }

    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 durationchange/timeupdate，用 AVPlayer 时间观察者更新总秒数和剩余秒数。
    private func installAudioTimeObserver(for urlString: String, player: AVPlayer) {
        if let token = audioTimeObservers[urlString] {
            player.removeTimeObserver(token)
            audioTimeObservers[urlString] = nil
        }
        let token = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { time in
            let durationSeconds = player.currentItem?.duration.seconds ?? 0
            let currentTimeSeconds = time.seconds
            let duration = Int(floor(durationSeconds))
            let current = Int(floor(currentTimeSeconds))
            let didFinish = durationSeconds.isFinite && duration > 0 && current > 0 && max(duration - current, 0) == 0
            if didFinish {
                player.pause()
                player.seek(to: .zero)
            }
            Task { @MainActor in
                updateAudioPlaybackTime(
                    urlString: urlString,
                    durationSeconds: durationSeconds,
                    currentTimeSeconds: currentTimeSeconds,
                    didFinish: didFinish
                )
            }
        }
        audioTimeObservers[urlString] = token
    }

    private func updateAudioPlaybackTime(
        urlString: String,
        durationSeconds: Double,
        currentTimeSeconds: Double,
        didFinish: Bool
    ) {
        guard durationSeconds.isFinite, durationSeconds > 0 else {
            return
        }
        let duration = Int(floor(durationSeconds))
        let current = Int(floor(currentTimeSeconds))
        let remaining = max(duration - current, 0)
        audioDurationSeconds[urlString] = duration
        audioRemainingSeconds[urlString] = remaining

        if didFinish {
            activeAudioURL = nil
            audioRemainingSeconds[urlString] = duration
        }
    }

    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的商品卡片，在原生 Host 展示图片、名称、原价、价格和购买入口。
    private func productMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        productInfo: SalesmartlyNativeProductInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                productImage(productInfo.product_picture)

                VStack(alignment: .leading, spacing: 4) {
                    Text(productInfo.product_name)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.primary)
                        .lineLimit(productInfo.showOriginalPrice ? 1 : 2)

                    if productInfo.showOriginalPrice {
                        Text("\(productInfo.original_price) \(productInfo.currency_code)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .overlay(alignment: .center) {
                                // 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 text-decoration: line-through，同时保持 iOS 15 可编译。
                                Rectangle()
                                    .fill(Color.secondary)
                                    .frame(height: 1)
                            }
                    }

                    Text("\(productInfo.price) \(productInfo.currency_code)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.red)
                }
            }

            if let purchaseURL = URL(string: productInfo.purchase_address) {
                Link(salesmartlyText("btn.checkoutNow", language: snapshot.lang), destination: purchaseURL)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themePrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(themePrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.salesmartlyPanelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(themePrimary, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 ValidImager 入口，加载商品主图。
    private func productImage(_ urlString: String) -> some View {
        Button {
            openImagePreview(urlString)
        } label: {
            SalesmartlyCachedRemoteImage(urlString: urlString) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.salesmartlyInputBackground
            }
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的评分模板，未评价时展示星级和评论入口，已评价时展示成功文案。
    private func inviteEvalutionBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        inviteEvalution: SalesmartlyNativeInviteEvalutionInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if message.status == nil || message.status == 0 {
                HStack(spacing: 8) {
                    SalesmartlyWidgetIcon(type: "icon-comment-fill1", size: 16, color: Color.white)
                        .frame(width: 20, height: 20)
                        .background(Color.orange)
                        .clipShape(Circle())

                    Text(salesmartlyText("tips.welcomeScore", language: snapshot.lang))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.primary)
                }

                evalutionStarPicker(message)

                let key = evalutionStateKey(message)
                let score = evalutionScores[key] ?? 0
                if score > 0 {
                    TextField(salesmartlyText("placeholder.score", language: snapshot.lang), text: evalutionCommentBinding(message))
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        .background(Color.salesmartlyInputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    Button {
                        handleEvalutionSubmit(message: message)
                    } label: {
                        Text(salesmartlyText("btn.post", language: snapshot.lang))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                let error = evalutionErrors[key] ?? ""
                if !error.isEmpty {
                    Text(error)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.red)
                }
            } else {
                VStack(spacing: 8) {
                    SalesmartlyWidgetIcon(type: "icon-grateful-fill", size: 28, color: Color.orange)
                    Text(salesmartlyText("tips.scoreSucess", language: snapshot.lang))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.08), Color.salesmartlyPanelBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.salesmartlyCollectionBorder, lineWidth: 1)
        }
        .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 Star v-model，记录 1 到 5 的评分。
    private func evalutionStarPicker(_ message: ChatMessage) -> some View {
        let key = evalutionStateKey(message)
        let currentScore = evalutionScores[key] ?? 0
        return HStack(spacing: 20) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    evalutionScores[key] = value
                    evalutionErrors[key] = ""
                } label: {
                    Text("★")
                        .font(.system(size: 30, weight: .regular))
                        .foregroundStyle(value <= currentScore ? Color.orange : Color.salesmartlyMetaText.opacity(0.55))
                        .frame(width: 30, height: 36)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 230, height: 36)
        .frame(maxWidth: .infinity)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 handleScore，提交 score/comment 到 runtime。
    private func handleEvalutionSubmit(message: ChatMessage) {
        let key = evalutionStateKey(message)
        let error = runtime.submitEvalutionMessage(
            message: message,
            score: evalutionScores[key] ?? 0,
            comment: evalutionComments[key] ?? ""
        )
        if let error {
            evalutionErrors[key] = error
        }
    }

    private func evalutionCommentBinding(_ message: ChatMessage) -> Binding<String> {
        let key = evalutionStateKey(message)
        return Binding(
            get: {
                evalutionComments[key] ?? ""
            },
            set: { value in
                evalutionComments[key] = value
            }
        )
    }

    private func evalutionStateKey(_ message: ChatMessage) -> String {
        message.tempId ?? message.id
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的默认模板分支，展示 text、attachments 与 buttons。
    @ViewBuilder
    private func templateMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        templateMessage: SalesmartlyNativeTemplateInfo
    ) -> some View {
        if let promotionalCard = templateMessage.payload.promotional_card {
            promotionalCardBubble(
                message: message,
                component: component,
                templateMessage: templateMessage,
                promotionalCard: promotionalCard
            )
        } else {
            defaultTemplateMessageBubble(
                message: message,
                component: component,
                templateMessage: templateMessage
            )
        }
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的 default 模板分支，展示 text、attachments 与 buttons。
    private func defaultTemplateMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        templateMessage: SalesmartlyNativeTemplateInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !templateMessage.payload.text.isEmpty {
                linkifiedText(templateMessage.payload.text)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(Array(templateMessage.payload.attachments.enumerated()), id: \.offset) { _, attachment in
                templateAttachmentPreview(attachment)
            }

            if !templateMessage.payload.buttons.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(templateMessage.payload.buttons.enumerated()), id: \.offset) { _, button in
                        templateButton(message: message, button: button)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(messageBubbleBackground(component.kind))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/PromotionalCard.vue 的推广卡片，展示折扣、图片、描述与邮箱领取入口。
    private func promotionalCardBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        templateMessage: SalesmartlyNativeTemplateInfo,
        promotionalCard: SalesmartlyNativeTemplatePromotionalCard
    ) -> some View {
        VStack(spacing: 10) {
            VStack(spacing: 12) {
                Text("\(100 - promotionalCard.discount)%\nOFF")
                    .font(.system(size: 42, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.salesmartlyHex(promotionalCard.text_color) ?? themePrimary)
                    .lineLimit(2)

                Divider()

                SalesmartlyCachedRemoteImage(urlString: promotionalCard.image) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.salesmartlyInputBackground
                }
                .frame(width: 240, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(promotionalCard.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.primary)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if message.status == nil || message.status == 0 {
                    promotionalCardForm(message: message, templateMessage: templateMessage, promotionalCard: promotionalCard)
                }
            }
            .padding(12)
            .background(Color.salesmartlyPanelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.salesmartlyPromoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(maxWidth: 304, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/PromotionalCard.vue 的 email 输入框和领取按钮。
    private func promotionalCardForm(
        message: ChatMessage,
        templateMessage: SalesmartlyNativeTemplateInfo,
        promotionalCard: SalesmartlyNativeTemplatePromotionalCard
    ) -> some View {
        let key = promotionalCardStateKey(message)
        let error = promotionalCardErrors[key] ?? ""

        return VStack(alignment: .leading, spacing: 8) {
            TextField("邮箱", text: promotionalCardEmailBinding(message))
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(Color.salesmartlyInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(error.isEmpty ? Color.clear : Color.red.opacity(0.72), lineWidth: 1)
                }

            if !error.isEmpty {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.red)
            }

            if let button = templateMessage.payload.buttons.first {
                Button {
                    handlePromotionalCardSubmit(message: message, button: button)
                } label: {
                    Text(button.text)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Color.salesmartlyHex(promotionalCard.btn_color) ?? themePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// 对齐 Android `CustomEntryPopup`，自定义入口文字直接展示，图片展示可点击缩略图。
    private var customEntryPopupOverlay: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.28)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeCustomEntryPopupFromHost()
                    }

                if let popup = snapshot.customEntryPopup {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Spacer(minLength: 0)
                            Button {
                                closeCustomEntryPopupFromHost()
                            } label: {
                                SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 22, color: Color.salesmartlyMetaText)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
                        }

                        if popup.type == "2" {
                            Button {
                                runtime.previewCustomEntryPopupImage()
                                refresh()
                            } label: {
                                SalesmartlyCachedRemoteImage(urlString: popup.inputValue) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(Color.salesmartlyHomeGridItem)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text(popup.inputValue)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.salesmartlyCollectionTitle)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(16)
                    .frame(width: min(320, max(0, proxy.size.width - 48)))
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 8)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    /// 对齐 Android custom entry 图片全屏预览，点击遮罩或关闭按钮退出预览。
    private var customEntryImagePreviewOverlay: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(Self.mediaPreviewCoverOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeCustomEntryImagePreviewFromHost()
                    }

                if let imageURL = snapshot.customEntryPreviewImageURL {
                    SalesmartlyCachedRemoteImage(urlString: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
                    .padding(24)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    closeCustomEntryImagePreviewFromHost()
                } label: {
                    SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 24, color: Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.34))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
                .padding(.top, 30)
                .padding(.trailing, 40)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    /// 对齐 Android Toast UI，展示 runtime 队列中最近的短提示。
    private var toastOverlay: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 0)
            ForEach(snapshot.toasts.suffix(3)) { item in
                Text(item.message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .frame(maxWidth: 320)
                    .onAppear {
                        scheduleToastDismiss(item.id)
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
        .allowsHitTesting(false)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/PromotionalCard.vue 的 postback，提交成功后隐藏表单并刷新状态。
    private func handlePromotionalCardSubmit(
        message: ChatMessage,
        button: SalesmartlyNativeTemplateButton
    ) {
        let key = promotionalCardStateKey(message)
        let email = promotionalCardEmails[key] ?? ""
        let error = runtime.submitPromotionalCardEmail(
            email: email,
            button: button,
            tempId: message.tempId
        )
        if let error {
            promotionalCardErrors[key] = error
        } else {
            promotionalCardErrors[key] = ""
            refresh()
        }
    }

    private func promotionalCardEmailBinding(_ message: ChatMessage) -> Binding<String> {
        let key = promotionalCardStateKey(message)
        return Binding(
            get: {
                promotionalCardEmails[key] ?? promotionalCardInitialEmail()
            },
            set: { value in
                promotionalCardEmails[key] = value
                promotionalCardErrors[key] = ""
            }
        )
    }

    private func promotionalCardStateKey(_ message: ChatMessage) -> String {
        message.tempId ?? message.id
    }

    private func promotionalCardInitialEmail() -> String {
        if let email = snapshot.loginInfo?.email, !email.isEmpty {
            return email
        }
        if let email = snapshot.userInfo["email"], !email.isEmpty {
            return email
        }
        return ""
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的 attachment.media_type 分支，仅渲染 image/audio/video。
    @ViewBuilder
    private func templateAttachmentPreview(_ attachment: SalesmartlyNativeTemplateAttachment) -> some View {
        if attachment.media_type == "image" {
            mediaTextImage(attachment.url)
        } else if attachment.media_type == "video" {
            Button {
                openVideoPreview(attachment.url)
            } label: {
                SalesmartlyCachedVideoThumbnail(urlString: attachment.url, fileName: "")
            }
            .buttonStyle(.plain)
        } else if attachment.media_type == "audio" {
            audioMessageContent(
                urlString: attachment.url,
                durationSeconds: attachment.duration.map { Int(floor(Double($0) / 1000)) }
            )
        } else {
            EmptyView()
        }
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的 Button 列表，点击后走 handlePostback 语义。
    private func templateButton(
        message: ChatMessage,
        button: SalesmartlyNativeTemplateButton
    ) -> some View {
        Button {
            handleTemplateButton(message: message, button: button)
        } label: {
            Text(button.text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.primary)
                .lineLimit(nil)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.salesmartlyInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的 handlePostback，web_url 打开外链并发送 msg_type=5。
    private func handleTemplateButton(
        message: ChatMessage,
        button: SalesmartlyNativeTemplateButton
    ) {
        if button.type == "web_url" {
            openQuickReplyURL(button.url)
        }

        runtime.postMessage(
            msgType: "5",
            message: [
                "text": button.text,
                "postback": button.payload,
                "btn_type": button.type,
            ],
            chatUserId: message.chatUserId
        )
        refresh()
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide/postback/reply 分支，在 SwiftUI Host 中选择 AI 原生展示。
    @ViewBuilder
    private func aiReplyMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        aiReply: SalesmartlyNativeAIReplyInfo
    ) -> some View {
        if aiReply.type == "guide" {
            aiGuideMessageBubble(message: message, component: component, aiReply: aiReply)
        } else if aiReply.type == "postback" {
            aiPostbackMessageBubble(message: message, component: component, aiReply: aiReply)
        } else if aiReply.type == "reply" {
            aiDirectReplyMessageBubble(message: message, component: component, aiReply: aiReply)
        } else {
            defaultMessageBubble(message: message, component: component)
        }
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide 分支，展示 tips.ask 和未选择时的问题按钮。
    private func aiGuideMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        aiReply: SalesmartlyNativeAIReplyInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(component.summary)
                .font(.system(size: 14))
                .foregroundStyle(Color.primary)
                .lineLimit(nil)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(themePrimary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            if shouldShowAIGuideQuestions(message: message, aiReply: aiReply) {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(Array(aiReply.guide.enumerated()), id: \.offset) { index, question in
                        aiGuideQuestionButton(message: message, question: question, index: index)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: 300, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 question_list 显示条件，status 为空或 0 才展示问题项。
    private func shouldShowAIGuideQuestions(message: ChatMessage, aiReply: SalesmartlyNativeAIReplyInfo) -> Bool {
        !aiReply.guide.isEmpty && (message.status == nil || message.status == 0)
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 question_list__item，点击后发送 msg_type=11 的 postback。
    private func aiGuideQuestionButton(
        message: ChatMessage,
        question: SalesmartlyNativeAIGuideQuestion,
        index: Int
    ) -> some View {
        Button {
            handleAIGuideQuestion(message: message, question: question)
        } label: {
            Text(question.question)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.primary)
                .lineLimit(nil)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(aiGuideQuestionBackground(index: index))
                .clipShape(Capsule(style: .continuous))
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 handleSelectedQuestion，回传 data.id/question 并把原 guide status 置 1。
    private func handleAIGuideQuestion(message: ChatMessage, question: SalesmartlyNativeAIGuideQuestion) {
        runtime.postMessage(
            msgType: "11",
            message: [
                "type": "postback",
                "data": [
                    "id": question.id,
                    "question": question.question,
                ],
            ],
            status: 1,
            mid: message.id,
            chatUserId: message.chatUserId
        )
        refresh()
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 getQuesStyle，按固定色板循环并使用 0.4 透明度。
    private func aiGuideQuestionBackground(index: Int) -> Color {
        let hex = Self.aiGuideQuestionColors[index % Self.aiGuideQuestionColors.count]
        return (Color.salesmartlyHex(hex) ?? Color.salesmartlyInputBackground).opacity(0.4)
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 postback 分支，展示用户选中的 question。
    private func aiPostbackMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        aiReply: SalesmartlyNativeAIReplyInfo
    ) -> some View {
        linkifiedText(aiReply.postback?.question ?? component.summary)
            .font(.system(size: 14))
            .foregroundStyle(Color.primary.opacity(0.8))
            .lineLimit(nil)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.salesmartlyMessageBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 reply 分支，按 context_type 渲染 text/pic/media。
    private func aiDirectReplyMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        aiReply: SalesmartlyNativeAIReplyInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(aiReply.reply.enumerated()), id: \.offset) { _, context in
                aiReplyContextView(context)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(themePrimary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 reply item v-if，仅 text/pic/media 有原生展示。
    @ViewBuilder
    private func aiReplyContextView(_ context: SalesmartlyNativeAIReplyContext) -> some View {
        if context.context_type == "text" {
            linkifiedText(context.context)
                .font(.system(size: 14))
                .foregroundStyle(Color.primary)
                .lineLimit(nil)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.salesmartlyInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        } else if context.context_type == "pic" {
            SalesmartlyCachedRemoteImage(urlString: context.context) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.salesmartlyInputBackground
            }
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else if context.context_type == "media" {
            if let mediaURL = URL(string: context.context) {
                Link(destination: mediaURL) {
                    aiReplyMediaLabel(context.context)
                }
            } else {
                aiReplyMediaLabel(context.context)
            }
        } else {
            EmptyView()
        }
    }

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 media 下载项，展示 originFileName 结果和下载图标。
    private func aiReplyMediaLabel(_ urlString: String) -> some View {
        HStack(spacing: 8) {
            SalesmartlyWidgetIcon(type: "icon-download-circle2", size: 16, color: themePrimary)

            Text(aiOriginFileName(urlString))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.salesmartlyInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 chat__list__wrap、showReturnToBottom 与 scrollConversationToBottom 行为。
    private var chatMessageList: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(salesmartlyMessageRenderNodes(messages: snapshot.messages, withdrawRecord: snapshot.withdrawRecord)) { node in
                            if node.type == .time {
                                timeDivider(timestamp: node.timestamp)
                            } else if let message = node.message {
                                messageRenderNode(message)
                                    .onAppear {
                                        startStreamRenderingIfNeeded(message)
                                    }
                            }
                        }

                        if snapshot.showRobotTyping {
                            typingBubble
                        }

                        Color.clear
                            .frame(height: 1)
                            .id(Self.chatBottomAnchorId)
                            .background {
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(
                                            key: SalesmartlyChatScrollBottomOffsetPreferenceKey.self,
                                            value: geometry.frame(in: .named(Self.chatScrollCoordinateSpace)).maxY
                                        )
                                }
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: SalesmartlyChatScrollViewportHeightPreferenceKey.self, value: geometry.size.height)
                    }
                }
                .coordinateSpace(name: Self.chatScrollCoordinateSpace)
                .onPreferenceChange(SalesmartlyChatScrollViewportHeightPreferenceKey.self) { value in
                    chatScrollViewportHeight = value
                    updateChatScrollDistance()
                }
                .onPreferenceChange(SalesmartlyChatScrollBottomOffsetPreferenceKey.self) { value in
                    chatScrollBottomOffset = value
                    updateChatScrollDistance()
                }
                .onChange(of: snapshot.messages.count) { _ in
                    scrollToBottomIfNeeded(proxy)
                }
                .onChange(of: snapshot.showRobotTyping) { _ in
                    scrollToBottomIfNeeded(proxy)
                }
                .onAppear {
                    scrollToBottom(proxy)
                }

                if showReturnToBottomButton {
                    returnToBottomButton(proxy)
                        .padding(.trailing, 16)
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.16), value: showReturnToBottomButton)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// 对齐 Android `ChatPage` 中 CollectionOverlay 的挂载顺序，离线留资优先覆盖消息列表区域。
    private var collectionOverlayType: String? {
        if snapshot.showOffline {
            return "offline"
        }
        if snapshot.showCollection {
            return "survey"
        }
        return nil
    }

    /// 对齐 Android `CollectionOverlay` 的半透明遮罩、居中卡片、底部关闭按钮和提交动作。
    private func collectionOverlay(type: String) -> some View {
        let config = runtime.collectionConfig(for: type)
        let fields = config.collectionFormFields(language: snapshot.lang)

        return ZStack {
            Color.black.opacity(0.4)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(config.guidance.isEmpty ? salesmartlyText("tips.collection", language: snapshot.lang) : config.guidance)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.salesmartlyCollectionTitle)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)

                    VStack(spacing: 8) {
                        ForEach(fields, id: \.key) { field in
                            collectionField(field, config: config)
                        }
                    }

                    Button {
                        submitCollectionOverlay(type: type, config: config)
                    } label: {
                        Text(salesmartlyText("btn.send", language: snapshot.lang))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(themePrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .frame(maxWidth: 368)
                .background(Color.salesmartlyPanelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.salesmartlyCollectionBorder, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)

                Button {
                    closeCollectionOverlay()
                } label: {
                    SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 16, color: Color.white)
                        .frame(width: 24, height: 24)
                        .background(Color.black.opacity(0.42))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
            }
            .padding(16)
        }
        .onAppear {
            prepareCollectionOverlay(type: type, config: config)
        }
    }

    /// 对齐 Android `CollectionOverlay` 的不同字段类型分支。
    @ViewBuilder
    private func collectionField(_ field: SalesmartlyCollectionFieldState, config: SalesmartlyCollectionConfig) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if field.key == "phone" {
                collectionPhoneField(field, config: config)
            } else if field.field_type == "1" {
                collectionSelectField(field)
            } else {
                collectionTextField(field, config: config)
            }

            if let error = collectionErrors[field.key] {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.salesmartlyCollectionErrorText)
                    .lineLimit(1)
                    .frame(height: 20, alignment: .topLeading)
            } else {
                Color.clear
                    .frame(height: 20)
            }
        }
    }

    /// 对齐 Android `TextField` 留资字段，按字段 key/field_type 限制最大输入长度。
    private func collectionTextField(_ field: SalesmartlyCollectionFieldState, config: SalesmartlyCollectionConfig) -> some View {
        TextField(field.label, text: collectionTextBinding(field, config: config))
            .textFieldStyle(.plain)
            .font(.system(size: 13))
            .focused($collectionFocusedFieldKey, equals: field.key)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(collectionInputBackground(fieldKey: field.key))
    }

    /// 对齐 Android `PhoneNumberField`，区号与手机号共用 phone 字段错误展示。
    private func collectionPhoneField(_ field: SalesmartlyCollectionFieldState, config: SalesmartlyCollectionConfig) -> some View {
        HStack(spacing: 8) {
            TextField(salesmartlyText("label.area", language: snapshot.lang), text: collectionAreaBinding)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($collectionFocusedFieldKey, equals: "\(field.key):area")
                .frame(width: 70)

            Rectangle()
                .fill(Color.salesmartlyCollectionBorder)
                .frame(width: 1, height: 18)

            TextField(field.label, text: collectionTextBinding(field, config: config))
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($collectionFocusedFieldKey, equals: field.key)
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(collectionInputBackground(fieldKey: field.key, extraFocusKey: "\(field.key):area"))
    }

    /// 对齐 Android select 字段：select_type=1 为多选，否则为单选。
    private func collectionSelectField(_ field: SalesmartlyCollectionFieldState) -> some View {
        Menu {
            ForEach(field.select_content, id: \.id) { option in
                Button {
                    toggleCollectionSelectOption(field: field, option: option)
                } label: {
                    HStack {
                        Text(option.value)
                        if collectionSelectedIDs(field).contains(option.id) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(collectionSelectDisplayText(field))
                    .font(.system(size: 13))
                    .foregroundStyle(collectionSelectedIDs(field).isEmpty ? Color.secondary : Color.primary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.salesmartlyMetaText)
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(collectionInputBackground(fieldKey: field.key))
        }
        .buttonStyle(.plain)
    }

    /// 对齐 Android 错误态背景色与聚焦态主色边框。
    private func collectionInputBackground(fieldKey: String, extraFocusKey: String? = nil) -> some View {
        let hasError = collectionErrors[fieldKey] != nil
        let isFocused = collectionFocusedFieldKey == fieldKey || collectionFocusedFieldKey == extraFocusKey
        return RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(hasError ? Color.salesmartlyCollectionErrorBackground : Color.salesmartlyCollectionFieldBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(isFocused ? themePrimary : Color.clear, lineWidth: 1)
            }
    }

    /// 对齐 Android 初始值规则：多选为空数组，其他字段为空字符串。
    private func prepareCollectionOverlay(type: String, config: SalesmartlyCollectionConfig) {
        guard collectionActiveType != type else {
            return
        }
        collectionActiveType = type
        collectionValues = config.collectionInitialValues()
        collectionArea = ""
        collectionErrors = [:]
    }

    /// 对齐 Android 提交流程，先校验再调用 runtime 的 submitCollection。
    private func submitCollectionOverlay(type: String, config: SalesmartlyCollectionConfig) {
        let errors = config.collectionFieldErrorTexts(values: collectionValues, area: collectionArea, language: snapshot.lang)
        collectionErrors = errors
        guard errors.isEmpty else {
            return
        }

        _ = runtime.submitCollection(type: type, values: collectionValues, area: collectionArea)
        resetCollectionOverlayState()
        refresh()
    }

    /// 对齐 Android 关闭按钮，关闭当前留资弹窗并清理本地表单状态。
    private func closeCollectionOverlay() {
        runtime.closeCollection()
        resetCollectionOverlayState()
        refresh()
    }

    /// 对齐 Android 字段变更只清除当前字段错误。
    private func clearCollectionFieldError(_ key: String) {
        collectionErrors.removeValue(forKey: key)
    }

    /// 对齐 Android overlay 关闭后的本地状态重置。
    private func resetCollectionOverlayState() {
        collectionActiveType = nil
        collectionValues = [:]
        collectionArea = ""
        collectionErrors = [:]
        collectionFocusedFieldKey = nil
    }

    /// 对齐 Android `CollectionOverlay` 文本字段更新，写入前执行对应字段长度裁剪并清理当前字段错误。
    private func collectionTextBinding(_ field: SalesmartlyCollectionFieldState, config: SalesmartlyCollectionConfig) -> Binding<String> {
        Binding(
            get: {
                collectionValues[field.key] as? String ?? ""
            },
            set: { value in
                collectionValues[field.key] = config.normalizedInput(field: field, input: value)
                clearCollectionFieldError(field.key)
            }
        )
    }

    /// 对齐 Android `PhoneNumberField` 区号更新，区号变化时只清理 phone 字段错误。
    private var collectionAreaBinding: Binding<String> {
        Binding(
            get: {
                collectionArea
            },
            set: { value in
                collectionArea = value.trimmingCharacters(in: .whitespacesAndNewlines)
                clearCollectionFieldError("phone")
            }
        )
    }

    /// 对齐 Android 选择字段值读取，多选读取 id 数组，单选读取 id 字符串。
    private func collectionSelectedIDs(_ field: SalesmartlyCollectionFieldState) -> [String] {
        if let ids = collectionValues[field.key] as? [String] {
            return ids
        }
        if let id = collectionValues[field.key] as? String, !id.isEmpty {
            return [id]
        }
        return []
    }

    /// 对齐 Android 多选/单选值形态，多选保存 id 数组，单选保存 id 字符串。
    private func toggleCollectionSelectOption(field: SalesmartlyCollectionFieldState, option: SalesmartlyCollectionSelectOption) {
        if field.select_type == "1" {
            var ids = collectionSelectedIDs(field)
            if let index = ids.firstIndex(of: option.id) {
                ids.remove(at: index)
            } else {
                ids.append(option.id)
            }
            collectionValues[field.key] = ids
        } else {
            collectionValues[field.key] = option.id
        }
        clearCollectionFieldError(field.key)
    }

    /// 对齐 Android 选择字段展示，已选项展示 value 文案，未选时展示字段 label。
    private func collectionSelectDisplayText(_ field: SalesmartlyCollectionFieldState) -> String {
        let selectedIDs = collectionSelectedIDs(field)
        let titles = field.select_content.filter { selectedIDs.contains($0.id) }.map(\.value)
        if titles.isEmpty {
            return field.label
        }
        return titles.joined(separator: ", ")
    }

    private var showReturnToBottomButton: Bool {
        !snapshot.conversationAtBottom && chatScrollDistanceToBottom >= Self.returnToBottomThreshold
    }

    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 updateAtBottom，按底部距离同步 store 的 conversationAtBottom。
    private func updateChatScrollDistance() {
        guard chatScrollViewportHeight > 0 else {
            return
        }

        let distance = max(0, chatScrollBottomOffset - chatScrollViewportHeight)
        if abs(chatScrollDistanceToBottom - distance) > 0.5 {
            chatScrollDistanceToBottom = distance
        }

        let atBottom = distance <= Self.atBottomThreshold
        guard snapshot.conversationAtBottom != atBottom else {
            return
        }

        runtime.setConversationAtBottom(atBottom)
        refresh()
    }

    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 stickyBottomEnabled，新消息到达前仍在底部或接近底部时才自动贴底。
    private func scrollToBottomIfNeeded(_ proxy: ScrollViewProxy) {
        guard snapshot.conversationAtBottom || chatScrollDistanceToBottom < Self.returnToBottomThreshold else {
            return
        }
        scrollToBottom(proxy)
    }

    /// 对齐 widget main:src/stores/chat.ts 的 scrollConversationToBottom，滚动到底部后清除 conversationHasNewMessage。
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.16)) {
                proxy.scrollTo(Self.chatBottomAnchorId, anchor: .bottom)
            }
            runtime.setConversationAtBottom(true)
            runtime.clearConversationNewMessage()
            refresh()
        }
    }

    /// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 return_bottom/return_bottom_withText 样式。
    private func returnToBottomButton(_ proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(snapshot.conversationHasNewMessage ? themePrimary : Color.salesmartlyCloseIcon)

                if snapshot.conversationHasNewMessage {
                    Text(salesmartlyText("msg.newMsg", language: snapshot.lang))
                        .font(.system(size: 12))
                        .foregroundStyle(themePrimary)
                        .lineLimit(1)
                }
            }
            .frame(width: snapshot.conversationHasNewMessage ? nil : 40, height: 40)
            .padding(.leading, snapshot.conversationHasNewMessage ? 12 : 0)
            .padding(.trailing, snapshot.conversationHasNewMessage ? 14 : 0)
            .background(Color.salesmartlyPanelBackground)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .stroke(themePrimary.opacity(0.26), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(salesmartlyText("msg.newMsg", language: snapshot.lang)))
    }

    /// 对齐 widget main:src/utils/tool.ts 的 originFileName，供 AI media context 展示下载文件名。
    private func aiOriginFileName(_ urlString: String) -> String {
        let filename = urlString.split(separator: "/").last.map(String.init) ?? ""
        let filenameWithoutQuery = filename.split(separator: "?").first.map(String.init) ?? filename
        return filenameWithoutQuery.removingPercentEncoding ?? filenameWithoutQuery
    }

    /// 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 的快捷回复正文与按钮区域展示。
    private func quickReplyMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        quickReply: SalesmartlyNativeQuickReplyInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if let text = quickReply.text, !text.isEmpty {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.primary)
                    .lineLimit(nil)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.salesmartlyPanelBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 1)
            }

            if shouldShowQuickReplyButtons(message: message, quickReply: quickReply) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(salesmartlyText("tips.guessQuestion", language: snapshot.lang))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)

                    ForEach(Array(quickReply.buttons.enumerated()), id: \.offset) { _, button in
                        quickReplyButton(message: message, quickReply: quickReply, button: button)
                    }
                }
            }
        }
        .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 的 showButton：有按钮且 status 为空或 0 时展示。
    private func shouldShowQuickReplyButtons(message: ChatMessage, quickReply: SalesmartlyNativeQuickReplyInfo) -> Bool {
        !quickReply.buttons.isEmpty && (message.status == nil || message.status == 0)
    }

    /// 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 的 question_list__item，点击后走 handleSelectedItem 语义。
    private func quickReplyButton(
        message: ChatMessage,
        quickReply: SalesmartlyNativeQuickReplyInfo,
        button: SalesmartlyNativeQuickReplyButton
    ) -> some View {
        Button {
            handleQuickReplyButton(message: message, quickReply: quickReply, button: button)
        } label: {
            HStack(spacing: 8) {
                // 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 的 `<Icon type="icon-quick-reply-fill">`。
                SalesmartlyWidgetIcon(type: "icon-quick-reply-fill", size: 16, color: themePrimary)
                    .frame(width: 16, height: 16)

                Text(button.text)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.primary)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.salesmartlyInputBackground)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .stroke(Color.salesmartlyPanelBackground, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 的 handleSelectedItem，web_url 打开外链并发送 msg_type=5 postback。
    private func handleQuickReplyButton(
        message: ChatMessage,
        quickReply: SalesmartlyNativeQuickReplyInfo,
        button: SalesmartlyNativeQuickReplyButton
    ) {
        if button.type == "web_url" {
            openQuickReplyURL(button.url)
        }

        runtime.postMessage(
            msgType: "5",
            message: [
                "text": button.text,
                "postback": button.payload,
            ],
            status: quickReply.always_show == true ? 0 : 1,
            mid: message.id,
            chatUserId: message.chatUserId
        )
        refresh()
    }

    /// 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 的 openParentWindow，仅在 web_url 按钮存在 url 时打开宿主平台外链。
    private func openQuickReplyURL(_ urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            return
        }

        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }

    /// 对齐 widget main:src/components/Bubble/SearchSameMessage.vue 的卡片，展示搜同款图片和底部“搜同款”文案。
    private func searchSameMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        searchSame: SalesmartlyNativeSearchSameInfo
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                openImagePreview(searchSame.img_url)
            } label: {
                SalesmartlyCachedRemoteImage(
                    urlString: runtime.resizeOssImgUrl(searchSame.img_url, height: 160, width: 280)
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.salesmartlyInputBackground
                }
                .frame(width: 280, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 12)

            Text(salesmartlyText("btn.searchSame", language: snapshot.lang))
                .font(.system(size: 12))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(themePrimary)
        }
        .background(messageBubbleBackground(component.kind))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(maxWidth: 332, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/SameProductMessage.vue 的商品推荐列表，展示标题和同款商品卡片。
    private func sameProductMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(salesmartlyText("searchProduct.productTips", language: snapshot.lang))
                .font(.system(size: 14))
                .foregroundStyle(Color.primary)

            ForEach(component.same_product, id: \.goods_id) { product in
                sameProductCard(product)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(messageBubbleBackground(component.kind))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(maxWidth: 300, alignment: message.sendType == "1" ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
    }

    /// 对齐 widget main:src/components/Bubble/SameProductMessage.vue 的 card，展示主图、商品名、原价、售价和详情入口。
    private func sameProductCard(_ product: SalesmartlyNativeSameProductInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                productImage(product.main_image)

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.goods_name)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)

                    HStack(spacing: 0) {
                        Text("\(salesmartlyText("searchProduct.originalPrice", language: snapshot.lang))：")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                        Text("\(product.currency_code)\(product.original_price)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                    }

                    Text("\(product.currency_code)\(product.sale_price)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.red)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let goodsURL = URL(string: product.goods_link) {
                Link(salesmartlyText("btn.detail", language: snapshot.lang), destination: goodsURL)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themePrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(themePrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
        }
        .padding(10)
        .background(Color.salesmartlyPanelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.salesmartlyInputBackground, lineWidth: 1)
        }
    }

    /// 对齐 widget main:src/components/Bubble/MediaTextMessage.vue 的 file_type 分发，在原生 Host 展示图片、视频或文档，并在下方展示 caption。
    @ViewBuilder
    private func mediaTextMessageBubble(
        message: ChatMessage,
        component: SalesmartlyNativeMessageComponent,
        mediaText: SalesmartlyNativeMediaTextInfo
    ) -> some View {
        if mediaText.caption.isEmpty {
            mediaTextPreview(message: message, mediaText: mediaText)
                .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                mediaTextPreview(message: message, mediaText: mediaText)
                Text(mediaText.caption)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.primary)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(messageBubbleBackground(component.kind))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .frame(maxWidth: 280, alignment: message.sendType == "1" ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: message.sendType == "1" ? .trailing : .leading)
        }
    }

    /// 对齐 widget main:src/components/Bubble/MediaTextMessage.vue 的 componentMap，按 image/video/document 选择原生媒体展示。
    @ViewBuilder
    private func mediaTextPreview(message: ChatMessage, mediaText: SalesmartlyNativeMediaTextInfo) -> some View {
        if mediaText.file_type == "image" {
            mediaTextImage(mediaText.file_url)
        } else if mediaText.file_type == "video" {
            mediaTextVideo(mediaText)
        } else if mediaText.file_type == "document" {
            mediaTextDocument(message: message, mediaText: mediaText)
        }
    }

    /// 对齐 widget main:src/components/Bubble/ImageMessage.vue 在 msg_type=40 时读取 MediaTextMsgType.file_url 展示图片。
    private func mediaTextImage(_ urlString: String) -> some View {
        Button {
            openImagePreview(urlString)
        } label: {
            SalesmartlyCachedRemoteImage(urlString: runtime.resizeOssImgUrl(urlString, height: 160, width: 280)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.salesmartlyInputBackground
            }
            .frame(width: 220, height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/Bubble/VideoMessage.vue 在 msg_type=40 时读取 MediaTextMsgType.file_url 展示视频入口。
    private func mediaTextVideo(_ mediaText: SalesmartlyNativeMediaTextInfo) -> some View {
        Button {
            openVideoPreview(mediaText.file_url)
        } label: {
                SalesmartlyCachedVideoThumbnail(urlString: mediaText.file_url, fileName: mediaText.file_name)
        }
        .buttonStyle(.plain)
    }

    private func mediaTextVideoLabel(_ fileName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.salesmartlyInputBackground)

            VStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(themePrimary)

                if !fileName.isEmpty {
                    Text(fileName)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
        }
        .frame(width: 220, height: 132)
    }

    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 在 msg_type=40 时读取 MediaTextMsgType.file_url 与 file_name 展示文档消息。
    private func mediaTextDocument(message: ChatMessage, mediaText: SalesmartlyNativeMediaTextInfo) -> some View {
        fileAttachmentCard(message: message, fileName: mediaTextDocumentFileName(mediaText), fileURL: mediaText.file_url)
    }

    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的 fullFileName，图文 document 缺 file_name 时从 file_url 提取文件名。
    private func mediaTextDocumentFileName(_ mediaText: SalesmartlyNativeMediaTextInfo) -> String {
        if !mediaText.file_name.isEmpty {
            return mediaText.file_name
        }
        return aiOriginFileName(mediaText.file_url)
    }

    /// 对齐 widget main:src/components/Bubble/index.vue 的原生消息 fallback 图标，返回已确认 Web icon type。
    private func messageBubbleWebIconName(_ kind: SalesmartlyNativeMessageKind) -> String {
        switch kind {
        case .image:
            return "icon-default-logo-fill"
        case .file:
            return "icon-document-fill"
        case .postback:
            return "icon-return-circle-2"
        case .video:
            return "icon-chat-fill"
        case .email:
            return "email"
        case .audio:
            return "icon-chat-fill"
        case .product, .template, .quickReply, .mediaText, .searchSame, .sameProduct, .aggregate:
            return "icon-chat-fill"
        case .system, .action, .collection, .mention, .sticker, .location, .contact, .introduction, .ai, .unknown:
            return "icon-default-logo-fill"
        case .text:
            return "icon-chat-fill"
        }
    }

    private func messageBubbleBackground(_ kind: SalesmartlyNativeMessageKind) -> Color {
        switch kind {
        case .system, .unknown:
            return Color.salesmartlyInputBackground
        case .template, .product, .quickReply, .mediaText, .searchSame, .sameProduct, .aggregate:
            return Color.salesmartlyPanelBackground
        default:
            return Color.salesmartlyMessageBackground
        }
    }

    /// 对齐 widget main:src/components/Bubble/styles/index.less 的 `.bubble__content_right/.bubble__content_left`，访客气泡使用主题色，客服气泡白底带阴影。
    private func defaultMessageBubbleBackground(isVisitorMessage: Bool) -> Color {
        isVisitorMessage ? themeBackgroundAccent : Color.salesmartlyPanelBackground
    }

    /// 对齐 widget main:src/components/Bubble/TimeDivider.vue 的时间分隔线样式。
    private func timeDivider(timestamp: Int64) -> some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.salesmartlyDivider)
                .frame(height: 1)

            Text(salesmartlyFormatMessageTime(timestamp: timestamp, language: snapshot.lang))
                .font(.system(size: 12))
                .foregroundStyle(Color.salesmartlyMetaText)
                .lineLimit(1)

            Rectangle()
                .fill(Color.salesmartlyDivider)
                .frame(height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的引用条，展示回复标签、媒体缩略、类型标签和单行摘要。
    private func quotePreviewView(_ state: SalesmartlyNativeQuotePreviewInfo) -> some View {
        HStack(spacing: 4) {
            Text("\(salesmartlyText("tips.reply", language: snapshot.lang))：")
                .foregroundStyle(Color.salesmartlyMetaText)

            if !state.media_url.isEmpty {
                quotePreviewMedia(state)
            }

            if !state.tag.isEmpty {
                Text(state.tag)
                    .foregroundStyle(Color.salesmartlyQuoteText)
            }

            if !state.text.isEmpty {
                Text(state.text)
                    .foregroundStyle(Color.salesmartlyQuoteText)
                    .lineLimit(1)
            }
        }
        .font(.system(size: 12))
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.salesmartlyInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .frame(maxWidth: 280, alignment: .leading)
    }

    @ViewBuilder
    private func quotePreviewMedia(_ state: SalesmartlyNativeQuotePreviewInfo) -> some View {
        if state.media_type == "video" {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.black)
                Image(systemName: "play.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 24, height: 24)
        } else {
            SalesmartlyCachedRemoteImage(urlString: state.media_url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                salesmartlyImageLoadingPlaceholder
            }
            .frame(width: 24, height: 24)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        }
    }

    /// 对齐 widget main:src/components/Bubble/index.vue 的撤回消息展示。
    private var withdrawMessageBubble: some View {
        Text(salesmartlyText("msg.withdrawMessage", language: snapshot.lang))
            .font(.system(size: 12))
            .foregroundStyle(Color.salesmartlyWithdrawText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
    }

    /// 对齐 widget main:src/components/Bubble/Typing.vue 的机器人输入态，输入态是 UI 状态而非消息。
    private var typingBubble: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.black.opacity(0.35)).frame(width: 8, height: 8)
            Circle().fill(Color.black.opacity(0.55)).frame(width: 8, height: 8)
            Circle().fill(Color.black.opacity(0.85)).frame(width: 8, height: 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(Color.salesmartlyPanelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 50)
    }

    private func messageMetaLine(_ message: ChatMessage) -> some View {
        Group {
            if snapshot.showSenderName,
               message.sendType != "1",
               message.msgType != "11",
               message.msgType != "21",
               let senderName = message.senderName,
               !senderName.isEmpty {
                Text(senderName)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.salesmartlyMetaText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            }
        }
    }

    /// 对齐 widget main:src/views/Chat/components/ChatFooter.vue，排队和人工服务提示位于 TextBox 之前。
    @ViewBuilder
    private var chatStatusFooter: some View {
        if snapshot.queueStatus == "waiting" {
            Text(salesmartlyText("msg.queueWaiting", language: snapshot.lang, replacements: ["count": "\(snapshot.queueCount)"]))
                .font(.system(size: 12))
                .foregroundStyle(Color.salesmartlyMetaText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
        }

        if snapshot.showHumanService {
            humanServiceFooter
        }
    }

    /// 对齐 widget main:src/components/BottomBar/index.vue，report_switch 对应的举报入口放在 TextBox 之后的底部信息栏。
    @ViewBuilder
    private var bottomBarInfo: some View {
        if snapshot.reportSwitch, let reportURL = runtime.bottomBarReportURL() {
            Link(destination: reportURL) {
                Text(salesmartlyText("verifyLangInfo.report", language: snapshot.lang))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.salesmartlyMetaText)
            }
            .frame(maxWidth: .infinity, minHeight: 20, alignment: .center)
        }
    }

    @ViewBuilder
    private var humanServiceFooter: some View {
        if snapshot.showHumanMsg {
            humanServiceText(salesmartlyText("msg.humanService", language: snapshot.lang))
        } else if snapshot.showHumanTips {
            humanServiceText(salesmartlyText("msg.joinSession", language: snapshot.lang))
        } else if snapshot.humanServiceEnabled {
            Button {
                _ = runtime.sendHumanServiceTransportRequest()
                runtime.closeHumanService()
                refresh()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 14))
                    Text(salesmartlyText("btn.human", language: snapshot.lang))
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color.salesmartlyMetaText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(themePrimary.opacity(0.72), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 8)
        }
    }

    private func humanServiceText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.salesmartlyMetaText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay {
                Capsule(style: .continuous)
                    .stroke(themePrimary.opacity(0.72), lineWidth: 1)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 8)
    }

    private var salesmartlyImageLoadingPlaceholder: some View {
        ZStack {
            Color.salesmartlyInputBackground
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
                .tint(themePrimary)
        }
    }

    @ViewBuilder
    private var composer: some View {
        #if canImport(UIKit) && canImport(PhotosUI)
        composerContent
            .sheet(item: $pendingPhotoUploadItem) { item in
                SalesmartlyPhotoUploadPicker(item: item) { files in
                    handlePickedUploadFiles(files, sourceItem: item)
                }
            }
            .sheet(isPresented: $showDocumentUploadPicker) {
                SalesmartlyDocumentUploadPicker { files in
                    handlePickedUploadFiles(files, sourceItem: .attachment)
                }
            }
        #else
        composerContent
        #endif
    }

    private var composerContent: some View {
        let layout = Self.composerLayoutState(hasDraftText: !snapshot.draftText.isEmpty)
        return VStack(alignment: .leading, spacing: 8) {
            if showEmojiPanel {
                emojiPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            ZStack(alignment: .topLeading) {
                HStack(spacing: 8) {
                    composerToolRow
                    Spacer()
                    composerSendButton
                }
                .padding(.top, layout.textFieldOwnsFirstRow ? 34 : 3)

                composerTextField
                    .id(layout.textFieldIdentity)
                    .padding(.top, layout.textFieldOwnsFirstRow ? 0 : 8)
                    .padding(.leading, layout.textFieldOwnsFirstRow ? 0 : 64)
                    .padding(.trailing, 40)
            }
            .frame(minHeight: layout.textFieldOwnsFirstRow ? 74 : 50)
            .padding(.top, layout.textFieldOwnsFirstRow ? 8 : 6)
            .padding(.leading, layout.textFieldOwnsFirstRow ? 12 : 14)
            .padding(.trailing, layout.textFieldOwnsFirstRow ? 12 : 6)
            .padding(.bottom, 6)
            .background(composerInputBackground(cornerRadius: layout.cornerRadius))

            bottomBarInfo
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .padding(.bottom, snapshot.reportSwitch ? 6 : 16)
        .background(Color.clear)
    }

    /// 对齐 widget main:src/components/TextBox/index.vue 的 textarea，占位文案使用 Web locale key。
    private var composerTextField: some View {
        TextField(
            text: draftBinding,
            prompt: Text(salesmartlyText("placeholder.input", language: snapshot.lang))
                .foregroundColor(Color.salesmartlyComposerPlaceholder)
        ) {
            EmptyView()
        }
            .textFieldStyle(.plain)
            .focused($isComposerFocused)
            .font(.system(size: 14))
            .foregroundStyle(Color.salesmartlyCollectionTitle)
            .onChange(of: snapshot.draftText) { _ in
                if !snapshot.draftText.isEmpty {
                    showEmojiPanel = false
                }
            }
    }

    /// 对齐 widget main:src/components/TextBox/index.vue 的 left_tools，包含上传入口和 emoji 入口。
    private var composerToolRow: some View {
        HStack(spacing: 8) {
            composerUploadMenu
            Button {
                showEmojiPanel.toggle()
            } label: {
                composerIcon(webIconName: "icon-expression-circle", size: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(salesmartlyText("btn.emoji", language: snapshot.lang)))
        }
    }

    /// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的上传入口与菜单项图标。
    private var composerUploadMenu: some View {
        Menu {
            ForEach(Self.composerUploadMenuItems(hideUploadTypes: snapshot.hideUploadTypes)) { item in
                Button(composerUploadMenuTitle(item)) {
                    handleComposerUploadMenuItem(item)
                }
            }
        } label: {
            composerIcon(webIconName: "icon-more-circle", size: 24)
                .frame(width: 24, height: 24)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    /// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的菜单文案 key。
    private func composerUploadMenuTitle(_ item: SalesmartlyComposerUploadMenuItem) -> String {
        switch item {
        case .searchSame:
            return salesmartlyText("btn.searchSame", language: snapshot.lang)
        case .image:
            return salesmartlyText("fileType.image", language: snapshot.lang)
        case .video:
            return salesmartlyText("fileType.video", language: snapshot.lang)
        case .attachment:
            return salesmartlyText("fileType.attachment", language: snapshot.lang)
        }
    }

    /// 对齐 widget main:src/components/TextBoxUploadMenuPoptip.vue 的点击分发，留资开启时先进入 collection，否则打开原生选择器。
    private func handleComposerUploadMenuItem(_ item: SalesmartlyComposerUploadMenuItem) {
        if runtime.handleClickUploadBtn(enabledCollect: snapshot.collectInformation.collect_switch) {
            refresh()
            return
        }

        #if canImport(UIKit) && canImport(PhotosUI)
        switch item {
        case .searchSame, .image, .video:
            pendingPhotoUploadItem = item
        case .attachment:
            showDocumentUploadPicker = true
        }
        #endif
    }

    /// 对齐 widget main:src/helper/useUpload.ts 的 uploadFile 调用场景，picker 返回多个文件时按选择顺序逐个上传。
    private func handlePickedUploadFiles(
        _ files: [SalesmartlyPickedUploadFile],
        sourceItem: SalesmartlyComposerUploadMenuItem
    ) {
        guard !files.isEmpty else {
            return
        }

        Task {
            for file in files {
                await runtime.uploadPickedFile(
                    file,
                    requestedMsgType: sourceItem == .searchSame ? "45" : nil
                )
            }
            await MainActor.run {
                refresh()
            }
        }
    }

    /// 对齐 widget main:src/components/TextBox/index.vue 的发送/停止按钮尺寸与图标状态。
    private var composerSendButton: some View {
        Button {
            runtime.handleComposerSubmit()
            refresh()
        } label: {
            ZStack {
                Circle()
                    .fill(isComposerSendDisabled ? Color.salesmartlyComposerDisabledFill : themePrimary)

                composerIcon(
                    webIconName: snapshot.isStreamSending ? "icon-generating-fill" : "icon-send-fill",
                    size: 26,
                    foreground: Color.white
                )
            }
            .frame(width: 32, height: 32)
            .opacity(isComposerSendDisabled ? 0.5 : 1)
        }
        .disabled(isComposerSendDisabled)
        .buttonStyle(.plain)
        .accessibilityLabel(
            Text(snapshot.isStreamSending ? "Stop stream" : salesmartlyText("btn.send", language: snapshot.lang))
        )
    }

    /// 对齐 widget main:src/components/TextBox/TextBoxEmojiPoptip.vue 的 emoji 面板尺寸、单项尺寸和点击回填。
    private var emojiPanel: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(40), spacing: 0), count: 8), spacing: 0) {
                ForEach(Self.chatInputEmojiLabels, id: \.self) { emoji in
                    Button {
                        runtime.appendComposerEmoji(emoji)
                        showEmojiPanel = false
                        refresh()
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 336, height: 200)
        .background(Color.salesmartlyPanelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.salesmartlyInputBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 6)
    }

    private func composerInputBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white)
            .shadow(color: Color.salesmartlyInputShadow, radius: 20, x: 0, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isComposerFocused ? themePrimary : Color.salesmartlyInputBorder, lineWidth: 1)
            }
    }

    private func composerIcon(
        webIconName: String,
        size: CGFloat,
        foreground: Color = Color.salesmartlyComposerIcon
    ) -> some View {
        SalesmartlyWidgetIcon(type: webIconName, size: size, color: foreground)
            .frame(width: size, height: size)
    }

    private var shouldShowIconPopup: Bool {
        snapshot.lastNoticeMsg != nil &&
            snapshot.iconPopupEnabled &&
            snapshot.channels.contains("chat") &&
            !snapshot.isLimit &&
            !snapshot.showWrapper
    }

    private func iconPopupPreview(_ message: ChatMessage) -> some View {
        ZStack(alignment: .topTrailing) {
            iconPopupPreviewBody(message)
            .frame(minWidth: 240, maxWidth: 312, alignment: .leading)
            .background(runtime.iconPopupPreviewIsPromotionalCard() ? Color.salesmartlyPromoBackground : Color.salesmartlyPanelBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.salesmartlyCollectionBorder, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture {
                runtime.openChatFromIconPopup()
                refresh()
            }
            .accessibilityLabel(Text(runtime.iconPopupPreviewText()))

            Button {
                runtime.clearLastNoticeMsg()
                refresh()
            } label: {
                SalesmartlyWidgetIcon(type: "icon-closure-circle", size: 12, color: Color.salesmartlyCloseIcon)
                    .frame(width: 18, height: 18)
                    .background(Color.white.clipShape(Circle()))
            }
            .offset(x: 6, y: -20)
            .accessibilityLabel(Text(salesmartlyText("btn.close", language: snapshot.lang)))
        }
    }

    @ViewBuilder
    private func iconPopupPreviewBody(_ message: ChatMessage) -> some View {
        let component = runtime.iconPopupPreviewComponent()
        if component == .text {
            iconPopupTextPreview(message)
        } else {
            iconPopupComponentPreview(message, component: component)
        }
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的文本消息预览分支，展示头像、发送者名称和文本摘要。
    private func iconPopupTextPreview(_ message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            iconPopupAvatar(message)

            VStack(alignment: .leading, spacing: 6) {
                let title = runtime.iconPopupPreviewTitle()
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                }

                Text(runtime.iconPopupPreviewText())
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的非文本 component 分支，在 SwiftUI Host 中按组件类型提供预览入口。
    private func iconPopupComponentPreview(_ message: ChatMessage, component: SalesmartlyIconPopupPreviewComponent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                SalesmartlyWidgetIcon(type: iconPopupPreviewWebIconName(component), size: 16, color: themePrimary)
                    .frame(width: 28, height: 28)
                    .background(themePrimary.opacity(0.12))
                    .clipShape(Circle())

                Text(iconPopupPreviewLabel(component))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
            }

            iconPopupMediaPreview(message, component: component)
        }
        .padding(runtime.iconPopupPreviewNeedsPadding() ? 12 : 16)
    }

    /// 对齐 widget main:src/components/IconPopup/index.vue 的媒体预览，图片和视频在弹窗中展示对应缩略入口。
    @ViewBuilder
    private func iconPopupMediaPreview(_ message: ChatMessage, component: SalesmartlyIconPopupPreviewComponent) -> some View {
        let previewText = runtime.iconPopupPreviewText()
        if component == .image {
            SalesmartlyCachedRemoteImage(urlString: message.message) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color.salesmartlyInputBackground)
            }
            .frame(width: 180, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else if component == .video {
            SalesmartlyCachedVideoThumbnail(
                urlString: message.message,
                fileName: "",
                width: 180,
                height: 108,
                playSize: 24
            )
        } else if !previewText.isEmpty {
            Text(previewText)
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func iconPopupAvatar(_ message: ChatMessage) -> some View {
        if let avatarURL = iconPopupAvatarURL(message.senderAvatar) {
            SalesmartlyCachedRemoteImage(urlString: avatarURL.absoluteString) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                iconPopupDefaultAvatar
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())
        } else {
            iconPopupDefaultAvatar
        }
    }

    private var iconPopupDefaultAvatar: some View {
        Circle()
            .fill(themePrimary.opacity(0.12))
            .frame(width: 36, height: 36)
            .overlay {
                SalesmartlyWidgetIcon(type: "icon-default-logo-fill", size: 28, color: themePrimary)
            }
    }

    private func iconPopupAvatarURL(_ avatar: String?) -> URL? {
        guard let avatar, !avatar.isEmpty else {
            return nil
        }

        return URL(string: "\(avatar)?x-oss-process=image/resize,m_fill,h_96,w_96")
    }

    /// 对齐 widget main:src/components/UnreadPreviewPopup/index.vue 的组件分支，返回对应 Web icon type。
    private func iconPopupPreviewWebIconName(_ component: SalesmartlyIconPopupPreviewComponent) -> String {
        switch component {
        case .image:
            return "icon-default-logo-fill"
        case .video:
            return "icon-chat-fill"
        case .file:
            return "icon-document-fill"
        case .email:
            return "email"
        case .ai:
            return "icon-chat-fill"
        case .product, .mediaText, .template, .quickReply:
            return "icon-chat-fill"
        case .text, .unknown:
            return "icon-default-logo-fill"
        }
    }

    private func iconPopupPreviewLabel(_ component: SalesmartlyIconPopupPreviewComponent) -> String {
        switch component {
        case .image:
            return "Image"
        case .template:
            return runtime.iconPopupPreviewIsPromotionalCard() ? "Coupon" : "Template"
        case .file:
            return "File"
        case .video:
            return "Video"
        case .email:
            return "Email"
        case .ai:
            return "AI"
        case .product:
            return "Product"
        case .quickReply:
            return "Quick reply"
        case .mediaText:
            return "Media"
        case .text, .unknown:
            return "Message"
        }
    }

    private var draftBinding: Binding<String> {
        Binding(
            get: {
                snapshot.draftText
            },
            set: { value in
                runtime.setDraftText(value)
                snapshot.draftText = value
            }
        )
    }

    private var isComposerSendDisabled: Bool {
        !snapshot.isStreamSending && snapshot.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func messageDisplayText(_ message: ChatMessage, component: SalesmartlyNativeMessageComponent? = nil) -> String {
        if snapshot.currentStreamInfo.mid == message.mid,
           message.isStream == "1",
           !snapshot.streamMsg.isEmpty {
            return snapshot.streamMsg
        }

        if snapshot.currentStreamInfo.mid == message.mid,
           message.isStream == "1",
           !snapshot.currentStreamInfo.msg.isEmpty {
            return snapshot.currentStreamInfo.msg
        }

        if let component, !component.summary.isEmpty {
            return component.summary
        }

        return message.message
    }

    private func startStreamRenderingIfNeeded(_ message: ChatMessage) {
        guard runtime.startStreamMessageRendering(mid: message.mid) else {
            return
        }

        refresh()
        Task { @MainActor in
            while runtime.state.isStreamAnimating {
                try? await Task.sleep(nanoseconds: 20_000_000)
                _ = runtime.advanceStreamMessageRendering()
                refresh()
            }
        }
    }

    private func recordLauncherHeightTarget(_ proxy: GeometryProxy) {
        // 对齐 widget main:src/utils/sidebarHeight.ts：将 SwiftUI 全局 frame 映射为 DOMRect 风格目标，再交给 runtime 按 top/bottom 聚合。
        let frame = proxy.frame(in: .global)
        let target = SalesmartlyLauncherHeightTargetFrame(
            top: Double(frame.minY),
            bottom: Double(frame.maxY),
            height: Double(frame.height)
        )
        guard snapshot.launcherHeightTargetFrames != [target] else {
            return
        }

        runtime.setLauncherHeightTargetFrames([target])
        refresh()
    }

    private func refresh() {
        snapshot = runtime.state
    }

    private func startObservingRuntimeState() {
        guard stateObservationId == nil else {
            return
        }

        // 对齐 widget main:src/stores/app.ts 与 src/stores/chat.ts 的响应式 store 更新，异步 Socket/HTTP reducer 后刷新 SwiftUI 快照。
        stateObservationId = runtime.observeState { nextState in
            Task { @MainActor in
                snapshot = nextState
            }
        }
    }

    private func stopObservingRuntimeState() {
        guard let stateObservationId else {
            return
        }

        runtime.removeStateObserver(stateObservationId)
        self.stateObservationId = nil
    }
}

/// 对齐 widget main:src/views/Chat/style/bulletinBoard.less 的 marquee 动画，0%-10% 保持原位后线性滚动到 -100%。
private struct SalesmartlyBulletinMarqueeText: View {
    /// 对齐公告栏 `content`，作为轮播文本。
    var text: String
    /// 对齐 widget main:src/helper/useStyle.ts 的 `animationDuration` 秒数。
    var durationSeconds: Int
    /// 对齐 Web `@ssc-theme-active`，用于公告文本颜色。
    var color: Color
    /// 对齐 Web 轮播链接态的 underline 样式。
    var underlined: Bool

    /// 对齐 Web 文本自身宽度的 `translateX(-100%)` 位移目标。
    @State private var textWidth: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let duration = Double(max(durationSeconds, 1))
                let progress = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration
                let movingProgress = max(0, (progress - 0.1) / 0.9)
                let travelWidth = max(textWidth, proxy.size.width)

                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    // 对齐 Web 轮播链接态的下划线；iOS 15 无可用的带颜色 underline API，使用同色底部线条承载迁移语义。
                    .overlay(alignment: .bottom) {
                        if underlined {
                            Rectangle()
                                .fill(color)
                                .frame(height: 1)
                        }
                    }
                    .background(
                        GeometryReader { textProxy in
                            Color.clear
                                .preference(
                                    key: SalesmartlyBulletinMarqueeTextWidthPreferenceKey.self,
                                    value: textProxy.size.width
                                )
                        }
                    )
                    .offset(x: -travelWidth * CGFloat(movingProgress))
                    .frame(height: 16, alignment: .leading)
            }
        }
        .frame(height: 16)
        .clipped()
        .onPreferenceChange(SalesmartlyBulletinMarqueeTextWidthPreferenceKey.self) { value in
            textWidth = value
        }
    }
}

/// 对齐 Web marquee 的文本宽度量测，用于 SwiftUI 计算 -100% 位移。
private struct SalesmartlyBulletinMarqueeTextWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 listRef.clientHeight，用于计算返回底部浮层显示阈值。
private struct SalesmartlyChatScrollViewportHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 对齐 widget main:src/views/Chat/components/ChatList.vue 的 scrollHeight - clientHeight - scrollTop，提供底部锚点在滚动容器坐标系内的位置。
private struct SalesmartlyChatScrollBottomOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private let salesmartlyRemoteImageDataCache = SalesmartlyRemoteResourceCache<Data>(maxEntries: 200)
/// 对齐 Android 迁移记录 `2026-06-10 滚动不重复加载图片等资源` 与 widget main:src/components/Bubble/VideoMessage.vue，按视频 URL 缓存首帧数据。
private let salesmartlyVideoThumbnailDataCache = SalesmartlyRemoteResourceCache<Data>(maxEntries: 80)

#if canImport(UIKit)
private typealias SalesmartlyPlatformImage = UIImage

private func salesmartlyPlatformImage(from data: Data) -> SalesmartlyPlatformImage? {
    UIImage(data: data)
}

/// 将 AVFoundation 生成的视频首帧转换为 SwiftUI 可缓存的数据，供视频消息复用。
private func salesmartlyPNGData(from cgImage: CGImage) -> Data? {
    UIImage(cgImage: cgImage).pngData()
}

private extension Image {
    init(salesmartlyPlatformImage image: SalesmartlyPlatformImage) {
        self.init(uiImage: image)
    }
}
#elseif canImport(AppKit)
private typealias SalesmartlyPlatformImage = NSImage

private func salesmartlyPlatformImage(from data: Data) -> SalesmartlyPlatformImage? {
    NSImage(data: data)
}

/// 将 AVFoundation 生成的视频首帧转换为 SwiftUI 可缓存的数据，供视频消息复用。
private func salesmartlyPNGData(from cgImage: CGImage) -> Data? {
    NSBitmapImageRep(cgImage: cgImage).representation(using: .png, properties: [:])
}

private extension Image {
    init(salesmartlyPlatformImage image: SalesmartlyPlatformImage) {
        self.init(nsImage: image)
    }
}
#endif

/// 对齐 Android `RemoteImage` 接入 `RemoteResourceCache`，SwiftUI 侧按 URL 复用图片数据并共享并发加载任务。
private struct SalesmartlyCachedRemoteImage<Content: View, Placeholder: View>: View {
    let urlString: String
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    @State private var image: SalesmartlyPlatformImage?

    var body: some View {
        Group {
            if let image {
                content(Image(salesmartlyPlatformImage: image))
            } else {
                placeholder()
            }
        }
        .task(id: urlString) {
            image = nil
            let data = await salesmartlyRemoteImageData(urlString)
            if let data {
                image = salesmartlyPlatformImage(from: data)
            }
        }
    }
}

private func salesmartlyRemoteImageData(_ urlString: String) async -> Data? {
    await salesmartlyRemoteImageDataCache.getOrLoad(key: urlString) {
        guard let url = URL(string: urlString),
              let response = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        return response.0
    }
}

/// 对齐 Android `VideoThumbnail`、`cachedVideoFrameBitmap` 与 widget main:src/components/Bubble/VideoMessage.vue，SwiftUI 侧按视频 URL 缓存首帧并展示播放入口。
private struct SalesmartlyCachedVideoThumbnail: View {
    let urlString: String
    let fileName: String
    var width: CGFloat = 220
    var height: CGFloat = 132
    var playSize: CGFloat = 30
    @State private var thumbnail: SalesmartlyPlatformImage?
    @State private var loaded = false

    var body: some View {
        ZStack {
            Color.black

            if let thumbnail {
                Image(salesmartlyPlatformImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else if !loaded {
                ProgressView()
                    .controlSize(.small)
                    .tint(Color.white.opacity(0.72))
            }

            Image(systemName: "play.fill")
                .font(.system(size: playSize, weight: .bold))
                .foregroundStyle(Color.white)
                .shadow(color: Color.black.opacity(0.28), radius: 4, x: 0, y: 2)

            if !fileName.isEmpty {
                VStack {
                    Spacer()
                    Text(fileName)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.48))
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .task(id: urlString) {
            thumbnail = nil
            loaded = false
            let data = await salesmartlyVideoThumbnailData(urlString)
            loaded = true
            if let data {
                thumbnail = salesmartlyPlatformImage(from: data)
            }
        }
    }
}

private func salesmartlyVideoThumbnailData(_ urlString: String) async -> Data? {
    await salesmartlyVideoThumbnailDataCache.getOrLoad(key: urlString) {
        await Task.detached(priority: .utility) {
            guard let url = URL(string: urlString) else {
                return nil
            }
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 560, height: 320)
            guard let image = try? generator.copyCGImage(at: .zero, actualTime: nil) else {
                return nil
            }
            return salesmartlyPNGData(from: image)
        }.value
    }
}

#if canImport(AVKit) && canImport(UIKit)
/// 对齐 widget main:src/components/VideoPreview/index.vue 的 `<video controls autoplay playsinline>`，在 iOS 预览层使用系统 AVPlayerViewController 播放。
private struct SalesmartlyVideoPreviewPlayer: UIViewControllerRepresentable {
    /// 对齐 Web `videoRef` 当前播放实例，由 Host 在打开视频预览时创建并负责关闭时 pause。
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        controller.allowsPictureInPicturePlayback = false
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
        player.play()
    }
}
#endif

#if canImport(UIKit) && canImport(PhotosUI)
/// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的图片/视频入口，使用系统相册选择器生成本地上传文件。
private struct SalesmartlyPhotoUploadPicker: UIViewControllerRepresentable {
    /// 对齐上传菜单项，决定 PHPicker 过滤图片、视频以及搜同款 msg_type。
    let item: SalesmartlyComposerUploadMenuItem
    /// 对齐 useUpload.ts 的 File 入参，picker 完成后把本地二进制交给 runtime 上传链路。
    let onPicked: ([SalesmartlyPickedUploadFile]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = item == .video ? .videos : .images
        configuration.selectionLimit = item == .image ? 9 : 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: SalesmartlyPhotoUploadPicker

        init(parent: SalesmartlyPhotoUploadPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else {
                return
            }

            let group = DispatchGroup()
            let lock = NSLock()
            var files: [Int: SalesmartlyPickedUploadFile] = [:]

            for (index, result) in results.enumerated() {
                group.enter()
                if parent.item == .video {
                    loadVideo(result.itemProvider) { file in
                        lock.lock()
                        files[index] = file
                        lock.unlock()
                        group.leave()
                    }
                } else {
                    loadImage(result.itemProvider) { file in
                        lock.lock()
                        files[index] = file
                        lock.unlock()
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) { [self] in
                self.parent.onPicked(results.indices.compactMap { files[$0] })
            }
        }

        private func loadImage(
            _ provider: NSItemProvider,
            completion: @escaping (SalesmartlyPickedUploadFile?) -> Void
        ) {
            let typeIdentifier = Self.preferredTypeIdentifier(provider: provider, conformingTo: .image) ?? "public.image"
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in
                guard let data else {
                    completion(nil)
                    return
                }
                let name = Self.fileName(
                    suggestedName: provider.suggestedName,
                    typeIdentifier: typeIdentifier,
                    fallbackExtension: "png"
                )
                let localURL = Self.writeTemporaryData(data, fileName: name)?.absoluteString ?? ""
                completion(
                    SalesmartlyPickedUploadFile(
                        name: name,
                        data: data,
                        isImage: true,
                        isVideo: false,
                        localURL: localURL
                    )
                )
            }
        }

        private func loadVideo(
            _ provider: NSItemProvider,
            completion: @escaping (SalesmartlyPickedUploadFile?) -> Void
        ) {
            let typeIdentifier = Self.preferredTypeIdentifier(provider: provider, conformingTo: .movie) ?? "public.movie"
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, _ in
                guard let url,
                      let data = try? Data(contentsOf: url) else {
                    completion(nil)
                    return
                }
                let fallbackExtension = url.pathExtension.isEmpty ? "mov" : url.pathExtension
                let name = Self.fileName(
                    suggestedName: provider.suggestedName ?? url.deletingPathExtension().lastPathComponent,
                    typeIdentifier: typeIdentifier,
                    fallbackExtension: fallbackExtension
                )
                let localURL = Self.writeTemporaryData(data, fileName: name)?.absoluteString ?? url.absoluteString
                completion(
                    SalesmartlyPickedUploadFile(
                        name: name,
                        data: data,
                        isImage: false,
                        isVideo: true,
                        localURL: localURL
                    )
                )
            }
        }

        /// 对齐系统 NSItemProvider 后台回调语义，纯类型匹配不访问 SwiftUI 状态，避免真机 Swift 6 主线程隔离断言。
        nonisolated private static func preferredTypeIdentifier(provider: NSItemProvider, conformingTo type: UTType) -> String? {
            provider.registeredTypeIdentifiers.first { identifier in
                UTType(identifier)?.conforms(to: type) == true
            }
        }

        /// 对齐 widget main:src/helper/useUpload.ts 的 File.name 传递，后台读取相册数据时生成上传文件名。
        nonisolated private static func fileName(
            suggestedName: String?,
            typeIdentifier: String?,
            fallbackExtension: String
        ) -> String {
            let rawName = suggestedName?.trimmingCharacters(in: .whitespacesAndNewlines)
            let safeName = (rawName?.isEmpty == false ? rawName! : UUID().uuidString)
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            if !URL(fileURLWithPath: safeName).pathExtension.isEmpty {
                return safeName
            }
            let preferredExtension = typeIdentifier.flatMap { UTType($0)?.preferredFilenameExtension } ?? fallbackExtension
            return "\(safeName).\(preferredExtension)"
        }

        /// 对齐 picker 本地预览地址语义，后台回调里写入临时文件供占位消息展示。
        nonisolated private static func writeTemporaryData(_ data: Data, fileName: String) -> URL? {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("salesmartly-upload-\(UUID().uuidString)-\(fileName)")
            do {
                try data.write(to: url, options: .atomic)
                return url
            } catch {
                return nil
            }
        }
    }
}

/// 对齐 widget main:src/components/TextBox/TextBoxUploadMenuPoptip.vue 的附件入口，使用系统文件选择器读取本地文件后交给上传链路。
private struct SalesmartlyDocumentUploadPicker: UIViewControllerRepresentable {
    /// 对齐 useUpload.ts 的 File 入参，文件选择完成后把二进制和本地 URL 交给 runtime。
    let onPicked: ([SalesmartlyPickedUploadFile]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = true
        return controller
    }

    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let parent: SalesmartlyDocumentUploadPicker

        init(parent: SalesmartlyDocumentUploadPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let files = urls.compactMap { url -> SalesmartlyPickedUploadFile? in
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                let type = UTType(filenameExtension: url.pathExtension)
                return SalesmartlyPickedUploadFile(
                    name: url.lastPathComponent,
                    data: data,
                    isImage: type?.conforms(to: .image) == true,
                    isVideo: type?.conforms(to: .movie) == true,
                    localURL: url.absoluteString
                )
            }
            parent.onPicked(files)
        }
    }
}
#endif

/// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 voiceSvg，绘制圆点和两段声波。
private struct SalesmartlyAudioWaveIcon: View {
    var isPlaying: Bool
    @State private var animateWave = false

    var body: some View {
        ZStack {
            Circle()
                .fill(currentColor)
                .frame(width: 3.6, height: 3.6)
                .position(x: 5, y: 11)

            SalesmartlyAudioWaveArc(radius: 4.5)
                .stroke(currentColor, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                .opacity(isPlaying ? (animateWave ? 1 : 0.25) : 0.8)

            SalesmartlyAudioWaveArc(radius: 7)
                .stroke(currentColor, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                .opacity(isPlaying ? (animateWave ? 0.25 : 1) : 0.8)
        }
        .frame(width: 22, height: 22)
        .onAppear {
            animateWave = isPlaying
        }
        .onChange(of: isPlaying) { value in
            animateWave = value
        }
        .animation(
            isPlaying ? .easeInOut(duration: 0.45).repeatForever(autoreverses: true) : .default,
            value: animateWave
        )
    }

    private var currentColor: Color {
        isPlaying ? Color.salesmartlyPrimary : Color.salesmartlyAudioText
    }
}

/// 对齐 widget main:src/components/Bubble/AudioMessage.vue 中 `M8 8A4.5...` 与 `M11 6A7...` 两段声波路径。
private struct SalesmartlyAudioWaveArc: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: 5, y: rect.midY),
            radius: radius,
            startAngle: .degrees(-52),
            endAngle: .degrees(52),
            clockwise: false
        )
        return path
    }
}

private extension Color {
    static let salesmartlyPrimary = Color(red: 23 / 255, green: 98 / 255, blue: 246 / 255)
    static let salesmartlyPanelBackground = Color(red: 1, green: 1, blue: 1)
    static let salesmartlyHeaderBackground = Color(red: 248 / 255, green: 250 / 255, blue: 255 / 255)
    /// 对齐 widget main:src/views/Page/styles/page.less 的主页顶部主题渐变起始色。
    static let salesmartlyHomeGradientTop = Color(red: 196 / 255, green: 222 / 255, blue: 255 / 255)
    /// 对齐 widget main:src/views/Page/styles/page.less 的主页中段浅色渐变。
    static let salesmartlyHomeGradientMiddle = Color(red: 223 / 255, green: 244 / 255, blue: 244 / 255)
    /// 对齐 widget main:src/views/Page/styles/page.less 的主页底部浅色渐变。
    static let salesmartlyHomeGradientBottom = Color(red: 249 / 255, green: 250 / 255, blue: 255 / 255)
    /// 对齐 widget main:src/views/Page/styles/page.less 的欢迎语强调渐变深色。
    static let salesmartlyHomeWelcomeStart = Color(red: 16 / 255, green: 54 / 255, blue: 111 / 255)
    /// 对齐 widget main:src/views/Page/styles/page.less 的主页渠道行背景。
    static let salesmartlyHomeGridItem = Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255)
    /// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 的主题色 10% Header 渐变底色。
    static let salesmartlyHeaderTint = Color(red: 232 / 255, green: 239 / 255, blue: 254 / 255)
    static let salesmartlyFooterBackground = Color(red: 250 / 255, green: 251 / 255, blue: 253 / 255)
    static let salesmartlyInputBackground = Color(red: 244 / 255, green: 246 / 255, blue: 249 / 255)
    static let salesmartlyInputBorder = Color(red: 234 / 255, green: 239 / 255, blue: 245 / 255)
    /// 对齐 widget main:src/components/TextBox/index.vue 的 input_inner 阴影 `rgba(18, 38, 63, 0.06)`。
    static let salesmartlyInputShadow = Color(red: 18 / 255, green: 38 / 255, blue: 63 / 255).opacity(0.06)
    /// 对齐 widget main:src/components/TextBox/index.vue 的 textarea placeholder 颜色 #B0B7C3。
    static let salesmartlyComposerPlaceholder = Color(red: 176 / 255, green: 183 / 255, blue: 195 / 255)
    /// 对齐 widget main:src/components/TextBox/index.vue 的 disabled send_btn 背景 #C9CDD4。
    static let salesmartlyComposerDisabledFill = Color(red: 201 / 255, green: 205 / 255, blue: 212 / 255)
    static let salesmartlyComposerIcon = Color(red: 74 / 255, green: 84 / 255, blue: 104 / 255)
    static let salesmartlyMessageBackground = Color(red: 234 / 255, green: 241 / 255, blue: 255 / 255)
    static let salesmartlyCloseIcon = Color(red: 74 / 255, green: 84 / 255, blue: 104 / 255)
    static let salesmartlyPromoBackground = Color(red: 255 / 255, green: 250 / 255, blue: 244 / 255)
    static let salesmartlyDivider = Color(red: 229 / 255, green: 234 / 255, blue: 242 / 255)
    static let salesmartlyMetaText = Color(red: 134 / 255, green: 144 / 255, blue: 156 / 255)
    static let salesmartlyQuoteText = Color(red: 78 / 255, green: 89 / 255, blue: 105 / 255)
    static let salesmartlyWithdrawText = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)
    static let salesmartlyAudioText = Color(red: 43 / 255, green: 47 / 255, blue: 56 / 255)
    /// 对齐 widget main:src/components/Collection/styles/index.less 的标题色 #1D2129。
    static let salesmartlyCollectionTitle = Color(red: 29 / 255, green: 33 / 255, blue: 41 / 255)
    /// 对齐 widget main:src/components/Collection/styles/index.less 的卡片边框色 #E5E6EB。
    static let salesmartlyCollectionBorder = Color(red: 229 / 255, green: 230 / 255, blue: 235 / 255)
    /// 对齐 widget main:src/components/Collection/styles/index.less 的字段背景色 #F2F3F5。
    static let salesmartlyCollectionFieldBackground = Color(red: 242 / 255, green: 243 / 255, blue: 245 / 255)
    /// 对齐 widget main:src/components/Collection/styles/index.less 的字段错误背景色 #FFECE8。
    static let salesmartlyCollectionErrorBackground = Color(red: 255 / 255, green: 236 / 255, blue: 232 / 255)
    /// 对齐 widget main:src/components/Collection/styles/index.less 的错误文案色 #ED4014。
    static let salesmartlyCollectionErrorText = Color(red: 237 / 255, green: 64 / 255, blue: 20 / 255)

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/PromotionalCard.vue 的 text_color/btn_color，解析 #RRGGBB 颜色值。
    static func salesmartlyHex(_ hex: String) -> Color? {
        let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard value.count == 6,
              let intValue = Int(value, radix: 16) else {
            return nil
        }
        return Color(
            red: Double((intValue >> 16) & 0xff) / 255,
            green: Double((intValue >> 8) & 0xff) / 255,
            blue: Double(intValue & 0xff) / 255
        )
    }
}
#endif
