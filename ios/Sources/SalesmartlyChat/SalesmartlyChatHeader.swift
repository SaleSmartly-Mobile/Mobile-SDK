import Foundation

/// 对齐 widget main:src/views/Chat/components/ChatHeader.vue 与 Android `ChatHeaderAction` 的 Header 顶部按钮类型。
enum SalesmartlyChatHeaderAction: Equatable {
    /// 对齐 Web `icon-closure-circle` 关闭聊天窗动作。
    case close
    /// 对齐 Web `icon-return-circle` 返回 Home 动作。
    case back
    /// 对齐 Web `icon-help-center-fill` 打开帮助中心动作。
    case helpdesk
}

/// 对齐 Android `WidgetIconState`，描述 Header action 在 iOS 中使用的 Web icon 名称和尺寸。
struct SalesmartlyChatHeaderActionIconState: Equatable {
    /// 对齐 Web iconfont 类型名，用于测试迁移口径。
    var webIconName: String
    /// 对齐 Android `chatHeaderActionIconState` 的 icon 尺寸。
    var size: Int
}

/// 对齐 Android `ChatHeaderInfoCardMode`，描述 Header 信息卡折叠、展开和详情状态。
enum SalesmartlyChatHeaderInfoCardMode: Equatable {
    /// 对齐 Web 初始收起态。
    case collapsed
    /// 对齐 Web 移动端第一下点击后的展开态。
    case expanded
    /// 对齐 Web 第二下点击后的详情态。
    case detailOpen
}

/// 对齐 Android `ChatHeaderTitleLineAlignment`，描述 Header 标题行水平排列方式。
enum SalesmartlyChatHeaderTitleLineAlignment: Equatable {
    /// 对齐 Android 当前详情态和非详情态的左侧起始排列。
    case start
    /// 保留 Android 已确认枚举值，当前 Web 口径未在 iOS UI 中使用居中态。
    case center
}

/// 对齐 Android `ChatHeaderInfoCardPresentation`，固化 Web Header 信息卡关键尺寸。
struct SalesmartlyChatHeaderInfoCardPresentation: Equatable {
    /// 对齐 Web/Android 信息卡目标宽度。
    var cardWidth: Int
    /// 对齐 Web 信息卡外层纵向 padding。
    var infoCardVerticalPadding: Int
    /// 对齐 Web top row 最小高度。
    var topRowMinHeight: Int
    /// 对齐 Web top row 最大高度。
    var topRowMaxHeight: Int
    /// 对齐 Web top row 圆角。
    var topRowCornerRadius: Int
    /// 对齐 Web top row 水平 padding。
    var topRowHorizontalPadding: Int
    /// 对齐 Web top row 垂直 padding。
    var topRowVerticalPadding: Int
    /// 对齐 Android `topRowShadowElevationDp`，iOS 用作阴影半径口径。
    var topRowShadowRadius: Int
    /// 对齐 Web 标题字号。
    var titleFontSize: Int
    /// 对齐 Web 标题行高。
    var titleLineHeight: Int
    /// 对齐 Web 详情态左侧起始排列。
    var titleLineAlignment: SalesmartlyChatHeaderTitleLineAlignment
    /// 对齐 Android `showChannelRow`，详情态隐藏 Header 渠道行。
    var showChannelRow: Bool
    /// 对齐 Web Header 渠道行高度。
    var channelRowHeight: Int
    /// 对齐 Android 渠道行相对 top row 偏移。
    var channelRowTopOffset: Int
    /// 对齐 Android 渠道行水平内缩。
    var channelRowHorizontalInset: Int
}

/// 对齐 Android `ChannelIconSize.HeaderCollapsed/HeaderExpanded` 的 Header 渠道图标尺寸。
struct SalesmartlyChatHeaderChannelIconSpec: Equatable {
    /// 对齐 Web Header 渠道入口容器尺寸。
    var containerSize: Int
    /// 对齐 Web Header 渠道 glyph 尺寸。
    var iconSize: Int
}

extension SalesmartlyRuntime {
    /// 对齐 Android `chatHeaderSubtitle`，按窗口副标题开关、离线留资 status_text 和 welcome 生成副标题。
    func chatHeaderSubtitle() -> String? {
        if state.windowSubheadSwitch != "1" {
            return nil
        }

        if !state.isOnline && state.offlineSurvey.collect_switch {
            let offlineStatusText = state.offlineSurvey.status_text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !offlineStatusText.isEmpty {
                return offlineStatusText
            }
            return nil
        }

        if !state.welcome.isEmpty {
            return state.welcome
        }
        return nil
    }

    /// 对齐 Android `WidgetInfo.isHelpdeskEnabled()`，`show_helpdesk_config.switch` 数值为 1 时展示帮助中心入口。
    func chatHeaderIsHelpdeskEnabled() -> Bool {
        Double(state.helpdeskSwitch) == 1
    }

    /// 对齐 Android `WidgetInfo.helpdeskTitle()`，空标题使用已确认默认文案。
    func chatHeaderHelpdeskTitle() -> String {
        let title = state.helpdeskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty {
            return title
        }
        return "帮助中心"
    }

    /// 对齐 Android `WidgetInfo.helpdeskUrl()`，移除 Web 已确认的引号和反引号。
    func chatHeaderHelpdeskURLString() -> String {
        state.helpdeskURL
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\"", with: "")
    }

    /// 对齐 Android `chatHeaderShowsCloseIcon`，专属链接、hideCloseIcon 和移动端 full 首屏隐藏关闭入口。
    func chatHeaderShowsCloseIcon() -> Bool {
        if state.hideCloseIcon {
            return false
        }
        if config?.setting.mode == .exclusiveLink {
            return false
        }
        if config?.setting.initMobileScreen == "full" {
            return false
        }
        return true
    }

    /// 对齐 Android `chatHeaderLeftAction`，无 Home 时左侧为关闭，有 Home 时左侧为返回。
    func chatHeaderLeftAction() -> SalesmartlyChatHeaderAction? {
        if chatHeaderShowsCloseIcon() && !state.homePageEnabled {
            return .close
        }
        if state.homePageEnabled {
            return .back
        }
        return nil
    }

    /// 对齐 Android `chatHeaderRightAction`，有 Home 时右侧为关闭；无 Home 时可展示帮助中心。
    func chatHeaderRightAction() -> SalesmartlyChatHeaderAction? {
        if chatHeaderShowsCloseIcon() && state.homePageEnabled {
            return .close
        }
        if chatHeaderIsHelpdeskEnabled() && !state.homePageEnabled {
            return .helpdesk
        }
        return nil
    }

    /// 对齐 Android `chatHeaderActionIconState` 的 Web icon 类型与尺寸。
    func chatHeaderActionIconState(_ action: SalesmartlyChatHeaderAction, isRightAction: Bool) -> SalesmartlyChatHeaderActionIconState {
        switch action {
        case .close:
            return SalesmartlyChatHeaderActionIconState(webIconName: "icon-closure-circle", size: isRightAction ? 20 : 24)
        case .back:
            return SalesmartlyChatHeaderActionIconState(webIconName: "icon-return-circle", size: 24)
        case .helpdesk:
            return SalesmartlyChatHeaderActionIconState(webIconName: "icon-help-center-fill", size: 20)
        }
    }

    /// 对齐 Android `defaultLogoIconState`，Header 默认头像使用 36 容器内 28 的 logo glyph。
    func chatHeaderDefaultLogoIconState() -> SalesmartlyChatHeaderActionIconState {
        SalesmartlyChatHeaderActionIconState(webIconName: "icon-default-logo-fill", size: 28)
    }

    /// 对齐 Android `chatHeaderShowsChannelRow`。
    func chatHeaderShowsChannelRow() -> Bool {
        state.integrationType == "chat" &&
            state.channels.contains("chat") &&
            !state.homePageEnabled &&
            !chatHeaderChannels().isEmpty
    }

    /// 对齐 Android `chatHeaderChannels`，Header 渠道行排除 chat。
    func chatHeaderChannels() -> [String] {
        makeChannelList(channels: state.channels, channelSort: state.channelSort).filter { $0 != "chat" }
    }

    /// 对齐 Android `chatHeaderShowsActionButtons`，只有折叠态显示左右按钮。
    func chatHeaderShowsActionButtons(_ mode: SalesmartlyChatHeaderInfoCardMode) -> Bool {
        mode == .collapsed
    }

    /// 对齐 Android `chatHeaderInfoCardAfterTopRowClick`。
    func chatHeaderInfoCardAfterTopRowClick(_ mode: SalesmartlyChatHeaderInfoCardMode) -> SalesmartlyChatHeaderInfoCardMode {
        switch mode {
        case .collapsed:
            return .expanded
        case .expanded:
            return .detailOpen
        case .detailOpen:
            return .detailOpen
        }
    }

    /// 对齐 Android `chatHeaderInfoCardAfterOutsideClick`。
    func chatHeaderInfoCardAfterOutsideClick(_ mode: SalesmartlyChatHeaderInfoCardMode, isMobile: Bool = true) -> SalesmartlyChatHeaderInfoCardMode {
        if mode == .detailOpen {
            return .collapsed
        }
        if mode == .expanded && isMobile {
            return .collapsed
        }
        return mode
    }

    /// 对齐 Android `chatHeaderInfoCardAfterPointerEnter`，iOS 移动端不使用 hover。
    func chatHeaderInfoCardAfterPointerEnter(_ mode: SalesmartlyChatHeaderInfoCardMode, isMobile: Bool = true) -> SalesmartlyChatHeaderInfoCardMode {
        if !isMobile && mode == .collapsed {
            return .expanded
        }
        return mode
    }

    /// 对齐 Android `chatHeaderInfoCardAfterPointerExit`，桌面展开态离开时收起。
    func chatHeaderInfoCardAfterPointerExit(_ mode: SalesmartlyChatHeaderInfoCardMode, isMobile: Bool = true) -> SalesmartlyChatHeaderInfoCardMode {
        if !isMobile && mode == .expanded {
            return .collapsed
        }
        return mode
    }

    /// 对齐 Android `chatHeaderInfoCardPresentation`，返回不同 mode 的 Web 尺寸。
    func chatHeaderInfoCardPresentation(_ mode: SalesmartlyChatHeaderInfoCardMode, showHeaderChannelRow: Bool) -> SalesmartlyChatHeaderInfoCardPresentation {
        switch mode {
        case .collapsed:
            return SalesmartlyChatHeaderInfoCardPresentation(
                cardWidth: 260,
                infoCardVerticalPadding: 10,
                topRowMinHeight: 52,
                topRowMaxHeight: 52,
                topRowCornerRadius: 100,
                topRowHorizontalPadding: 8,
                topRowVerticalPadding: 10,
                topRowShadowRadius: 2,
                titleFontSize: 12,
                titleLineHeight: 16,
                titleLineAlignment: .start,
                showChannelRow: showHeaderChannelRow,
                channelRowHeight: 20,
                channelRowTopOffset: -6,
                channelRowHorizontalInset: 20
            )
        case .expanded:
            return SalesmartlyChatHeaderInfoCardPresentation(
                cardWidth: 368,
                infoCardVerticalPadding: 10,
                topRowMinHeight: 52,
                topRowMaxHeight: 52,
                topRowCornerRadius: 100,
                topRowHorizontalPadding: 8,
                topRowVerticalPadding: 10,
                topRowShadowRadius: 2,
                titleFontSize: 12,
                titleLineHeight: 16,
                titleLineAlignment: .start,
                showChannelRow: showHeaderChannelRow,
                channelRowHeight: 52,
                channelRowTopOffset: 8,
                channelRowHorizontalInset: 0
            )
        case .detailOpen:
            return SalesmartlyChatHeaderInfoCardPresentation(
                cardWidth: 368,
                infoCardVerticalPadding: 10,
                topRowMinHeight: 0,
                topRowMaxHeight: 300,
                topRowCornerRadius: 20,
                topRowHorizontalPadding: 16,
                topRowVerticalPadding: 16,
                topRowShadowRadius: 2,
                titleFontSize: 14,
                titleLineHeight: 20,
                titleLineAlignment: .start,
                showChannelRow: false,
                channelRowHeight: 0,
                channelRowTopOffset: 0,
                channelRowHorizontalInset: 0
            )
        }
    }

    /// 对齐 Android `chatHeaderInfoCardWidthDp`，展开和详情态最大 368，折叠态为 190...260。
    func chatHeaderInfoCardWidth(_ mode: SalesmartlyChatHeaderInfoCardMode, availableWidth: Int) -> Int {
        let presentation = chatHeaderInfoCardPresentation(mode, showHeaderChannelRow: false)
        let containerWidth = max(0, availableWidth)
        if mode != .collapsed {
            return min(presentation.cardWidth, containerWidth)
        }
        let widthWithActionSafeArea = max(containerWidth - 104, 190)
        return min(presentation.cardWidth, widthWithActionSafeArea, containerWidth)
    }

    /// 对齐 Android `chatHeaderContainerHeightDp`，供 SwiftUI Header 固定顶部区域高度。
    func chatHeaderContainerHeight(_ mode: SalesmartlyChatHeaderInfoCardMode, showHeaderChannelRow: Bool) -> Int {
        let presentation = chatHeaderInfoCardPresentation(mode, showHeaderChannelRow: showHeaderChannelRow)
        let topRowHeight = mode == .detailOpen ? 94 : presentation.topRowMinHeight
        let infoCardHeight = presentation.infoCardVerticalPadding * 2 + topRowHeight
        if !presentation.showChannelRow {
            return infoCardHeight
        }
        return infoCardHeight + presentation.channelRowHeight + presentation.channelRowTopOffset
    }

    /// 对齐 Android `ChannelIconSize.HeaderCollapsed/HeaderExpanded`。
    func chatHeaderChannelIconSpec(compact: Bool) -> SalesmartlyChatHeaderChannelIconSpec {
        if compact {
            return SalesmartlyChatHeaderChannelIconSpec(containerSize: 12, iconSize: 8)
        }
        return SalesmartlyChatHeaderChannelIconSpec(containerSize: 24, iconSize: 14)
    }
}
