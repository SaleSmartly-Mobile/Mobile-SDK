import Foundation

/// 对齐 widget main:src/helper/types.ts 的 `bulletin_board` 与 Android `BulletinBoard` 的公告栏远端配置。
public struct SalesmartlyBulletinBoardConfig: Equatable, Sendable {
    /// 对齐远端 `bulletin_board.enabled`，控制公告栏是否展示。
    public var enabled: Bool
    /// 对齐远端 `bulletin_board.content`，作为横条和弹窗正文。
    public var content: String
    /// 对齐远端 `bulletin_board.link`，启用跳转时用于生成公告链接。
    public var link: String
    /// 对齐远端 `bulletin_board.background_color`，保留 Web 配置色值供状态同步。
    public var background_color: String
    /// 对齐远端 `bulletin_board.enable_link`，控制轮播点击和弹窗前往入口是否启用。
    public var enable_link: Bool
    /// 对齐远端 `bulletin_board.board_mode`，`1` 为展开弹窗，`2` 为轮播横条。
    public var board_mode: String

    /// 对齐 Android `BulletinBoard` 默认值，不增加未确认字段。
    public init(
        enabled: Bool = false,
        content: String = "",
        link: String = "",
        background_color: String = "#F3C141",
        enable_link: Bool = true,
        board_mode: String = "1"
    ) {
        self.enabled = enabled
        self.content = content
        self.link = link
        self.background_color = background_color
        self.enable_link = enable_link
        self.board_mode = board_mode
    }
}

/// 对齐 Android `BulletinBoardState`，描述 iOS 公告栏横条、轮播和弹窗的渲染状态。
struct SalesmartlyBulletinBoardState: Equatable {
    /// 对齐 Web `v-show="widgetInfo.bulletin_board.enabled"` 与 Android dismissed 运行态。
    var visible: Bool
    /// 对齐 Web 公告内容文本。
    var content: String
    /// 对齐 Web `getBoardLink` 处理后的公告链接。
    var link: String
    /// 对齐远端 `background_color`，保留公告配置背景色。
    var backgroundColor: String
    /// 对齐 Web `board_mode === '2'` 的轮播模式。
    var isMarquee: Bool
    /// 对齐 Web 非轮播且内容非空时点击打开公告弹窗。
    var canOpenModal: Bool
    /// 对齐 Web 轮播且启用链接时点击横条直接打开链接。
    var canJumpOnBoardClick: Bool
    /// 对齐 Web 非轮播且启用链接时弹窗展示“前往”入口。
    var canGotoLink: Bool
    /// 对齐 Web `chat__board_clickable`，决定横条是否可点击。
    var isBoardClickable: Bool
    /// 对齐 widget main:src/helper/useStyle.ts 的 `ceil(content.length / 6)` 轮播时长。
    var marqueeDurationSeconds: Int
    /// 对齐 widget main:src/locales 的 `title.board` 弹窗标题。
    var modalTitle: String
    /// 对齐 widget main:src/locales 的 `btn.go` 弹窗跳转文案。
    var gotoText: String
}

/// 对齐 Android `BulletinBoardClickAction`，描述公告栏点击后的业务动作。
enum SalesmartlyBulletinBoardClickAction: Equatable {
    /// 对齐 Web 不满足跳转或弹窗条件时不处理点击。
    case none
    /// 对齐 Web 展开模式点击公告栏打开弹窗。
    case openModal
    /// 对齐 Web 轮播模式且启用链接时打开公告链接。
    case openLink(String)
}

extension SalesmartlyRuntime {
    /// 对齐 Android `bulletinBoardState`，从当前 runtime state 生成公告栏展示状态。
    func bulletinBoardState() -> SalesmartlyBulletinBoardState {
        let board = state.bulletinBoard
        let isMarquee = board.board_mode == "2"
        let isLink = board.enable_link && !board.link.isEmpty
        let canOpenModal = !isMarquee && !board.content.isEmpty
        let canJumpOnBoardClick = isMarquee && isLink
        let canGotoLink = !isMarquee && isLink

        return SalesmartlyBulletinBoardState(
            visible: board.enabled && !state.bulletinBoardDismissed,
            content: board.content,
            link: salesmartlyBulletinBoardLink(board.link),
            backgroundColor: board.background_color,
            isMarquee: isMarquee,
            canOpenModal: canOpenModal,
            canJumpOnBoardClick: canJumpOnBoardClick,
            canGotoLink: canGotoLink,
            isBoardClickable: canOpenModal || canJumpOnBoardClick,
            marqueeDurationSeconds: Int(ceil(Double(board.content.count) / 6.0)),
            modalTitle: salesmartlyText("title.board", language: state.lang),
            gotoText: salesmartlyText("btn.go", language: state.lang)
        )
    }

    /// 对齐 Android `bulletinBoardClickAction`，将 Web 点击规则映射为 iOS 可执行动作。
    func bulletinBoardClickAction() -> SalesmartlyBulletinBoardClickAction {
        let boardState = bulletinBoardState()
        if !boardState.visible {
            return .none
        }
        if boardState.canJumpOnBoardClick {
            return .openLink(boardState.link)
        }
        if boardState.canOpenModal {
            return .openModal
        }
        return .none
    }

    /// 对齐 Android `dismissBulletinBoard` 与 Web `closeBoard`，仅隐藏当前运行态公告栏。
    func dismissBulletinBoard() {
        state.bulletinBoardDismissed = true
    }
}

/// 对齐 Web `getBoardLink`，未带 http/https 协议的公告链接补 `//`。
private func salesmartlyBulletinBoardLink(_ link: String) -> String {
    if link.isEmpty {
        return ""
    }

    if link.range(of: #"^https?://"#, options: .regularExpression) != nil {
        return link
    }
    return "//\(link)"
}
