import Foundation

/// 对齐 widget main:src/helper/types.ts 的 MsgType，用于 iOS 原生消息 UI 选择对应 bubble 渲染分支。
public enum SalesmartlyNativeMessageKind: String, Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 0，展示介绍类消息。
    case introduction
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 1，展示文本消息。
    case text
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 2，展示图片消息。
    case image
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 3，展示模板消息。
    case template
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 4，展示文件消息。
    case file
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 5，展示 postback 消息。
    case postback
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 6，展示视频消息。
    case video
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 7，展示邮件消息。
    case email
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 8，展示系统消息。
    case system
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 11，展示 AI/stream 相关消息。
    case ai
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 12，展示音频消息。
    case audio
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 14，展示商品消息。
    case product
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 15/16/17，展示动作类消息。
    case action
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 19，展示留资采集消息。
    case collection
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 20，展示 mention 消息。
    case mention
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 21，展示 quick reply 消息。
    case quickReply
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 22，展示贴纸消息。
    case sticker
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 23，展示位置消息。
    case location
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 29，展示联系人消息。
    case contact
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 40，展示 media text 消息。
    case mediaText
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 45，展示搜同款消息。
    case searchSame
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 46，展示同款商品消息。
    case sameProduct
    /// 对齐 widget main:src/helper/types.ts 的 MsgType 48，展示聚合消息。
    case aggregate
    /// 对齐 widget main:src/components/Bubble/index.vue 的未知类型兜底展示分支，事实源未确认 payload 时仅标记 unsupported。
    case unknown
}

/// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo 字段，用于 iOS 原生商品卡片展示。
public struct SalesmartlyNativeProductInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.product_picture。
    public var product_picture: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.product_name。
    public var product_name: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.original_price。
    public var original_price: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.price。
    public var price: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.currency_code。
    public var currency_code: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.purchase_address。
    public var purchase_address: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 showOriginalPrice 计算结果，原价大于售价时展示原价。
    public var showOriginalPrice: Bool

    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的商品卡片字段构造。
    public init(
        product_picture: String,
        product_name: String,
        original_price: String,
        price: String,
        currency_code: String,
        purchase_address: String,
        showOriginalPrice: Bool
    ) {
        self.product_picture = product_picture
        self.product_name = product_name
        self.original_price = original_price
        self.price = price
        self.currency_code = currency_code
        self.purchase_address = purchase_address
        self.showOriginalPrice = showOriginalPrice
    }
}

/// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType，用于 iOS 原生图文/视频文案/文件文案消息展示。
public struct SalesmartlyNativeMediaTextInfo: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType.caption，作为媒体消息下方描述文本。
    public var caption: String
    /// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType.file_name，作为 document 分支文件名。
    public var file_name: String
    /// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType.file_type，按 image/video/document 分发原生展示。
    public var file_type: String
    /// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType.file_url，作为媒体或文件资源地址。
    public var file_url: String
    /// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType.ext，保留文件扩展名供原生文件分支展示。
    public var ext: String

    /// 对齐 widget main:src/helper/types.ts 的 MediaTextMsgType 字段构造，不补充未确认字段。
    public init(
        caption: String,
        file_name: String,
        file_type: String,
        file_url: String,
        ext: String
    ) {
        self.caption = caption
        self.file_name = file_name
        self.file_type = file_type
        self.file_url = file_url
        self.ext = ext
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn，用于 iOS 原生 quick reply 按钮展示与点击分发。
public struct SalesmartlyNativeQuickReplyButton: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.type，仅使用 postback/web_url 事实源值。
    public var type: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.text，作为原生按钮可见文案。
    public var text: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.label，可选保留给后续展示或埋点语义。
    public var label: String?
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.payload，点击 postback 时随消息发送。
    public var payload: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.url，type=web_url 时作为外链地址。
    public var url: String?

    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn 字段构造，不补充未确认字段。
    public init(
        type: String,
        text: String,
        label: String?,
        payload: String,
        url: String?
    ) {
        self.type = type
        self.text = text
        self.label = label
        self.payload = payload
        self.url = url
    }
}

/// 对齐 widget main:src/helper/types.ts 的 QuickReplyPayload，用于 iOS 原生快捷回复正文与按钮列表展示。
public struct SalesmartlyNativeQuickReplyInfo: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 QuickReplyPayload.text，作为快捷回复正文。
    public var text: String?
    /// 对齐 widget main:src/helper/types.ts 的 QuickReplyPayload.buttons，作为可点击问题项。
    public var buttons: [SalesmartlyNativeQuickReplyButton]
    /// 对齐 widget main:src/helper/types.ts 的 QuickReplyPayload.always_show，控制点击后是否保持按钮显示。
    public var always_show: Bool?

    /// 对齐 widget main:src/helper/types.ts 的 QuickReplyPayload 字段构造。
    public init(
        text: String?,
        buttons: [SalesmartlyNativeQuickReplyButton],
        always_show: Bool?
    ) {
        self.text = text
        self.buttons = buttons
        self.always_show = always_show
    }
}

/// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide.data 项，用于 iOS 原生 AI 问题引导按钮展示。
public struct SalesmartlyNativeAIGuideQuestion: Equatable {
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 item.id，点击问题时随 postback data 原样发送。
    public var id: String
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 item.question，作为问题按钮和 postback 可见文案。
    public var question: String

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide.data 字段构造，不补充未确认字段。
    public init(id: String, question: String) {
        self.id = id
        self.question = question
    }
}

/// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 reply.data 项，用于 iOS 原生 AI 回复分发 text/pic/media。
public struct SalesmartlyNativeAIReplyContext: Equatable {
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 item.context_type，仅按 text/pic/media 三类渲染。
    public var context_type: String
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 item.context，作为文本、图片 URL 或媒体文件 URL。
    public var context: String

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 reply.data 字段构造，不补充未确认字段。
    public init(context_type: String, context: String) {
        self.context_type = context_type
        self.context = context
    }
}

/// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 postback.data，用于 iOS 原生展示用户选中的 AI 问题。
public struct SalesmartlyNativeAIPostbackQuestion: Equatable {
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 data.id，服务端原样下发或本地点击 guide 时回传。
    public var id: String
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 data.question，作为 postback 气泡文本。
    public var question: String

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 postback.data 字段构造。
    public init(id: String, question: String) {
        self.id = id
        self.question = question
    }
}

/// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 AI 消息体，承载 guide/postback/reply 三种分支。
public struct SalesmartlyNativeAIReplyInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 message.type，取值为 guide/postback/reply。
    public var type: String
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide.data，只有 type=guide 时填充。
    public var guide: [SalesmartlyNativeAIGuideQuestion]
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 reply.data，只有 type=reply 时填充。
    public var reply: [SalesmartlyNativeAIReplyContext]
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 postback.data，只有 type=postback 时填充。
    public var postback: SalesmartlyNativeAIPostbackQuestion?

    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide/postback/reply 字段构造。
    public init(
        type: String,
        guide: [SalesmartlyNativeAIGuideQuestion] = [],
        reply: [SalesmartlyNativeAIReplyContext] = [],
        postback: SalesmartlyNativeAIPostbackQuestion? = nil
    ) {
        self.type = type
        self.guide = guide
        self.reply = reply
        self.postback = postback
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn，用于 iOS 原生默认模板按钮展示与 postback 分发。
public struct SalesmartlyNativeTemplateButton: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.type，仅保留 postback/web_url 事实源值。
    public var type: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.text，作为模板按钮可见文案。
    public var text: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.label，保留服务端传入的按钮标签。
    public var label: String?
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.payload，点击模板按钮时随 postback 发送。
    public var payload: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn.url，type=web_url 时作为外链地址。
    public var url: String?

    /// 对齐 widget main:src/helper/types.ts 的 TemplateMediaBtn 字段构造，不补充未确认字段。
    public init(
        type: String,
        text: String,
        label: String?,
        payload: String,
        url: String?
    ) {
        self.type = type
        self.text = text
        self.label = label
        self.payload = payload
        self.url = url
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.attachments，用于 iOS 原生默认模板媒体展示。
public struct SalesmartlyNativeTemplateAttachment: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.attachments.media_type，按 image/audio/video 分发。
    public var media_type: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.attachments.url，作为媒体资源地址。
    public var url: String
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的 attachment.duration，音频附件按毫秒换算秒数展示。
    public var duration: Int?

    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.attachments 字段构造。
    public init(media_type: String, url: String, duration: Int? = nil) {
        self.media_type = media_type
        self.url = url
        self.duration = duration
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateBranches，用于 iOS 原生保留问答模板分支上下文。
public struct SalesmartlyNativeTemplateBranch: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 TemplateBranches.title。
    public var title: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateBranches.postback。
    public var postback: String

    /// 对齐 widget main:src/helper/types.ts 的 TemplateBranches 字段构造。
    public init(title: String, postback: String) {
        self.title = title
        self.postback = postback
    }
}

/// 对齐 widget main:src/helper/types.ts 与 src/components/Bubble/TemplateMessage/PromotionalCard.vue 的 promotional_card 字段。
public struct SalesmartlyNativeTemplatePromotionalCard: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.type。
    public var type: String
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.text。
    public var text: String
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.text_color。
    public var text_color: String
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.btn_color。
    public var btn_color: String
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.image。
    public var image: String
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.discount。
    public var discount: Int
    /// 对齐 widget main:src/helper/types.ts 的 promotional_card.countdown。
    public var countdown: Int

    /// 对齐 widget main:src/helper/types.ts 的 promotional_card 字段构造。
    public init(
        type: String,
        text: String,
        text_color: String,
        btn_color: String,
        image: String,
        discount: Int,
        countdown: Int
    ) {
        self.type = type
        self.text = text
        self.text_color = text_color
        self.btn_color = btn_color
        self.image = image
        self.discount = discount
        self.countdown = countdown
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.likes，用于 iOS 原生保留点赞文案。
public struct SalesmartlyNativeTemplateLikes: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 likes.like。
    public var like: String
    /// 对齐 widget main:src/helper/types.ts 的 likes.unlike。
    public var unlike: String

    /// 对齐 widget main:src/helper/types.ts 的 likes 字段构造。
    public init(like: String, unlike: String) {
        self.like = like
        self.unlike = unlike
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload，用于 iOS 原生默认模板展示和后续交互上下文。
public struct SalesmartlyNativeTemplatePayload: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.text。
    public var text: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.attachments。
    public var attachments: [SalesmartlyNativeTemplateAttachment]
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.buttons。
    public var buttons: [SalesmartlyNativeTemplateButton]
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.session_id。
    public var session_id: String?
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.branches。
    public var branches: [SalesmartlyNativeTemplateBranch]?
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.promotional_card。
    public var promotional_card: SalesmartlyNativeTemplatePromotionalCard?
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.likes。
    public var likes: SalesmartlyNativeTemplateLikes?

    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload 字段构造，不补充未确认字段。
    public init(
        text: String,
        attachments: [SalesmartlyNativeTemplateAttachment],
        buttons: [SalesmartlyNativeTemplateButton],
        session_id: String?,
        branches: [SalesmartlyNativeTemplateBranch]?,
        promotional_card: SalesmartlyNativeTemplatePromotionalCard?,
        likes: SalesmartlyNativeTemplateLikes?
    ) {
        self.text = text
        self.attachments = attachments
        self.buttons = buttons
        self.session_id = session_id
        self.branches = branches
        self.promotional_card = promotional_card
        self.likes = likes
    }
}

/// 对齐 widget main:src/helper/types.ts 的 TemplateMedia，用于 iOS 原生模板消息结构化展示。
public struct SalesmartlyNativeTemplateInfo: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.title。
    public var title: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.type，default/invite_evalution/promotional_card 等按 widget 事实源保留。
    public var type: String
    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload。
    public var payload: SalesmartlyNativeTemplatePayload

    /// 对齐 widget main:src/helper/types.ts 的 TemplateMedia 字段构造。
    public init(
        title: String,
        type: String,
        payload: SalesmartlyNativeTemplatePayload
    ) {
        self.title = title
        self.type = type
        self.payload = payload
    }
}

/// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 invite_evalution payload，用于 iOS 原生评分模板展示和提交。
public struct SalesmartlyNativeInviteEvalutionInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 payload.session_id。
    public var session_id: String?
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 payload.flow_id。
    public var flow_id: String?
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 payload.step_log_id。
    public var step_log_id: String?
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 payload.invite_evaluation_id。
    public var invite_evaluation_id: String?
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 payload.invite_evaluation_order_id。
    public var invite_evaluation_order_id: String?

    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 invite_evalution 字段构造。
    public init(
        session_id: String?,
        flow_id: String?,
        step_log_id: String?,
        invite_evaluation_id: String?,
        invite_evaluation_order_id: String?
    ) {
        self.session_id = session_id
        self.flow_id = flow_id
        self.step_log_id = step_log_id
        self.invite_evaluation_id = invite_evaluation_id
        self.invite_evaluation_order_id = invite_evaluation_order_id
    }
}

/// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo，用于 iOS 原生同款商品列表展示。
public struct SalesmartlyNativeSameProductInfo: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.title。
    public var title: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.sub_title。
    public var sub_title: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.content。
    public var content: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.goods_id。
    public var goods_id: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.goods_name。
    public var goods_name: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.goods_link。
    public var goods_link: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.original_price。
    public var original_price: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.sale_price。
    public var sale_price: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.currency。
    public var currency: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.currency_code。
    public var currency_code: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.desc。
    public var desc: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.main_image。
    public var main_image: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.image1。
    public var image1: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.image2。
    public var image2: String
    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo.score。
    public var score: String

    /// 对齐 widget main:src/helper/types.ts 的 SameStyleProductInfo 字段构造。
    public init(
        title: String,
        sub_title: String,
        content: String,
        goods_id: String,
        goods_name: String,
        goods_link: String,
        original_price: String,
        sale_price: String,
        currency: String,
        currency_code: String,
        desc: String,
        main_image: String,
        image1: String,
        image2: String,
        score: String
    ) {
        self.title = title
        self.sub_title = sub_title
        self.content = content
        self.goods_id = goods_id
        self.goods_name = goods_name
        self.goods_link = goods_link
        self.original_price = original_price
        self.sale_price = sale_price
        self.currency = currency
        self.currency_code = currency_code
        self.desc = desc
        self.main_image = main_image
        self.image1 = image1
        self.image2 = image2
        self.score = score
    }
}

/// 对齐 widget main:src/components/Bubble/SearchSameMessage.vue 的 imgUrl，用于 iOS 原生搜同款图片卡片展示。
public struct SalesmartlyNativeSearchSameInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/SearchSameMessage.vue 的 imgUrl，由 getMessageUrl 从字符串或 file_url/url 解析得到。
    public var img_url: String

    /// 对齐 widget main:src/components/Bubble/SearchSameMessage.vue 的 imgUrl 字段构造。
    public init(img_url: String) {
        self.img_url = img_url
    }
}

/// 对齐 widget main:src/components/Bubble/ImageMessage.vue 的 imgUrl，用于 iOS 原生图片消息展示。
public struct SalesmartlyNativeImageMessageInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/ImageMessage.vue 的 imgUrl，普通图片消息来自 info.message.toString()。
    public var img_url: String

    /// 对齐 widget main:src/components/Bubble/ImageMessage.vue 的 imgUrl 字段构造。
    public init(img_url: String) {
        self.img_url = img_url
    }
}

/// 对齐 widget main:src/components/Bubble/VideoMessage.vue 的 videoUrl，用于 iOS 原生视频消息入口展示。
public struct SalesmartlyNativeVideoMessageInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/VideoMessage.vue 的 videoUrl，普通视频消息来自 info.message.toString()。
    public var video_url: String

    /// 对齐 widget main:src/components/Bubble/VideoMessage.vue 的 videoUrl 字段构造。
    public init(video_url: String) {
        self.video_url = video_url
    }
}

/// 对齐 widget main:src/components/Bubble/FileMessage.vue 的 fileUrl/fullFileName，用于 iOS 原生文件消息展示。
public struct SalesmartlyNativeFileMessageInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的 fileUrl，普通文件消息来自 info.message.toString()。
    public var file_url: String
    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的 fullFileName，来自 src/utils/tool.ts 的 originFileName。
    public var full_file_name: String

    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的文件字段构造。
    public init(file_url: String, full_file_name: String) {
        self.file_url = file_url
        self.full_file_name = full_file_name
    }
}

/// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 audioElem.src，用于 iOS 原生音频消息入口展示。
public struct SalesmartlyNativeAudioMessageInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 audioElem.src，普通音频消息来自 info.message。
    public var audio_url: String

    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 audioElem.src 字段构造。
    public init(audio_url: String) {
        self.audio_url = audio_url
    }
}

/// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的引用消息预览状态，用于 iOS 原生气泡上方展示回复条。
public struct SalesmartlyNativeQuotePreviewInfo: Equatable {
    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 preview.media，取 image/video/searchSame 或空字符串。
    public var media_type: String
    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 preview.url，用于 24px 媒体缩略图。
    public var media_url: String
    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 preview.tag，用于文件、模板、商品等类型标签。
    public var tag: String
    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 preview.text，用于单行引用摘要。
    public var text: String

    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 preview 计算结果。
    public init(media_type: String, media_url: String, tag: String, text: String) {
        self.media_type = media_type
        self.media_url = media_url
        self.tag = tag
        self.text = text
    }
}

/// 对齐 widget main:src/components/Bubble/* 的原生展示分发结果，承载 SwiftUI/UIKit 可共享的消息摘要。
public struct SalesmartlyNativeMessageComponent: Equatable {
    /// 对齐 widget main:src/helper/types.ts 的 msg_type 分支。
    public var kind: SalesmartlyNativeMessageKind
    /// 对齐 widget main:src/components/Bubble/* 各组件的基础文本摘要。
    public var summary: String
    /// 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 product_info，仅商品消息存在。
    public var product_info: SalesmartlyNativeProductInfo?
    /// 对齐 widget main:src/components/Bubble/MediaTextMessage.vue 与 src/helper/types.ts 的 media text 消息体，仅 msg_type=40 存在。
    public var media_text: SalesmartlyNativeMediaTextInfo?
    /// 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 与 src/helper/types.ts 的 quick reply 消息体，仅 msg_type=21 存在。
    public var quick_reply: SalesmartlyNativeQuickReplyInfo?
    /// 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 AI 消息体，仅 msg_type=11 存在。
    public var ai_reply: SalesmartlyNativeAIReplyInfo?
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 与 src/helper/types.ts 的 TemplateMedia，仅 msg_type=3 存在。
    public var template_message: SalesmartlyNativeTemplateInfo?
    /// 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 invite_evalution，仅 msg_type=3 且 type=invite_evalution 时存在。
    public var invite_evalution: SalesmartlyNativeInviteEvalutionInfo?
    /// 对齐 widget main:src/components/Bubble/SameProductMessage.vue 与 src/helper/types.ts 的 same product 商品列表，仅 msg_type=46 存在。
    public var same_product: [SalesmartlyNativeSameProductInfo]
    /// 对齐 widget main:src/components/Bubble/SearchSameMessage.vue 的 search same 图片卡片，仅 msg_type=45 存在。
    public var search_same: SalesmartlyNativeSearchSameInfo?
    /// 对齐 widget main:src/components/Bubble/ImageMessage.vue 的图片消息体，仅 msg_type=2 存在。
    public var image_message: SalesmartlyNativeImageMessageInfo?
    /// 对齐 widget main:src/components/Bubble/VideoMessage.vue 的视频消息体，仅 msg_type=6 存在。
    public var video_message: SalesmartlyNativeVideoMessageInfo?
    /// 对齐 widget main:src/components/Bubble/FileMessage.vue 的文件消息体，仅 msg_type=4 存在。
    public var file_message: SalesmartlyNativeFileMessageInfo?
    /// 对齐 widget main:src/components/Bubble/AudioMessage.vue 的音频消息体，仅 msg_type=12 存在。
    public var audio_message: SalesmartlyNativeAudioMessageInfo?
    /// 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 quote_chat 预览，仅引用消息存在。
    public var quote_preview: SalesmartlyNativeQuotePreviewInfo?

    /// 对齐 widget main:src/components/Bubble/index.vue 的组件选择结果，构造原生 Host 可渲染的消息摘要。
    public init(
        kind: SalesmartlyNativeMessageKind,
        summary: String,
        product_info: SalesmartlyNativeProductInfo? = nil,
        media_text: SalesmartlyNativeMediaTextInfo? = nil,
        quick_reply: SalesmartlyNativeQuickReplyInfo? = nil,
        ai_reply: SalesmartlyNativeAIReplyInfo? = nil,
        template_message: SalesmartlyNativeTemplateInfo? = nil,
        invite_evalution: SalesmartlyNativeInviteEvalutionInfo? = nil,
        same_product: [SalesmartlyNativeSameProductInfo] = [],
        search_same: SalesmartlyNativeSearchSameInfo? = nil,
        image_message: SalesmartlyNativeImageMessageInfo? = nil,
        video_message: SalesmartlyNativeVideoMessageInfo? = nil,
        file_message: SalesmartlyNativeFileMessageInfo? = nil,
        audio_message: SalesmartlyNativeAudioMessageInfo? = nil,
        quote_preview: SalesmartlyNativeQuotePreviewInfo? = nil
    ) {
        self.kind = kind
        self.summary = summary
        self.product_info = product_info
        self.media_text = media_text
        self.quick_reply = quick_reply
        self.ai_reply = ai_reply
        self.template_message = template_message
        self.invite_evalution = invite_evalution
        self.same_product = same_product
        self.search_same = search_same
        self.image_message = image_message
        self.video_message = video_message
        self.file_message = file_message
        self.audio_message = audio_message
        self.quote_preview = quote_preview
    }
}

/// 对齐 widget main:src/components/Bubble/index.vue 的组件选择逻辑，为 iOS 原生 UI 提供 msg_type 分发。
public enum SalesmartlyNativeMessagePresentation {
    /// 对齐 widget main:src/components/Bubble/index.vue 的动态组件选择，返回 SwiftUI/UIKit 共用展示模型。
    public static func component(for message: ChatMessage) -> SalesmartlyNativeMessageComponent {
        component(for: message, showReceptionInfo: true)
    }

    /// 对齐 widget main:src/components/Bubble/SystemMessage.vue 与 src/stores/app.ts 的 widgetInfo.showReceptionInfo，返回受接待信息开关影响的展示模型。
    public static func component(
        for message: ChatMessage,
        showReceptionInfo: Bool,
        language: String = "zh-CN"
    ) -> SalesmartlyNativeMessageComponent {
        let kind = kind(for: message.msgType)
        return SalesmartlyNativeMessageComponent(
            kind: kind,
            summary: summary(for: message, kind: kind, showReceptionInfo: showReceptionInfo, language: language),
            product_info: productInfo(from: message.message, kind: kind),
            media_text: mediaTextInfo(from: message.message, kind: kind),
            quick_reply: quickReplyInfo(from: message.message, kind: kind),
            ai_reply: aiReplyInfo(from: message.message, kind: kind),
            template_message: templateInfo(from: message.message, kind: kind),
            invite_evalution: inviteEvalutionInfo(from: message.message, kind: kind),
            same_product: sameProductInfo(from: message.message, kind: kind),
            search_same: searchSameInfo(from: message.message, kind: kind),
            image_message: imageMessageInfo(from: message.message, kind: kind),
            video_message: videoMessageInfo(from: message.message, kind: kind),
            file_message: fileMessageInfo(from: message.message, kind: kind),
            audio_message: audioMessageInfo(from: message.message, kind: kind),
            quote_preview: quotePreviewInfo(from: message.quoteChat, language: language)
        )
    }

    /// 对齐 widget main:src/helper/types.ts 的 MsgType 常量，将 Web msg_type 映射到原生消息类型。
    public static func kind(for msgType: String) -> SalesmartlyNativeMessageKind {
        switch msgType {
        case "0":
            return .introduction
        case "1":
            return .text
        case "2":
            return .image
        case "3":
            return .template
        case "4":
            return .file
        case "5":
            return .postback
        case "6":
            return .video
        case "7":
            return .email
        case "8":
            return .system
        case "11":
            return .ai
        case "12":
            return .audio
        case "14":
            return .product
        case "15", "16", "17":
            return .action
        case "19":
            return .collection
        case "20":
            return .mention
        case "21":
            return .quickReply
        case "22":
            return .sticker
        case "23":
            return .location
        case "29":
            return .contact
        case "40":
            return .mediaText
        case "45":
            return .searchSame
        case "46":
            return .sameProduct
        case "48":
            return .aggregate
        default:
            return .unknown
        }
    }

    private static func summary(
        for message: ChatMessage,
        kind: SalesmartlyNativeMessageKind,
        showReceptionInfo: Bool,
        language: String
    ) -> String {
        switch kind {
        case .image:
            return "Image"
        case .file:
            return message.message.isEmpty ? "File" : message.message
        case .video:
            return "Video"
        case .email:
            return "您有一封邮件，请查收"
        case .system:
            return systemSummary(from: message.message, showReceptionInfo: showReceptionInfo) ?? message.message
        case .audio:
            return salesmartlyText("msgType.12", language: language)
        case .template:
            return templateSummary(from: message.message) ?? message.message
        case .postback:
            return postbackSummary(from: message.message) ?? message.message
        case .product:
            return productSummary(from: message.message) ?? "Product"
        case .ai:
            return aiSummary(from: message.message) ?? message.message
        case .quickReply:
            return quickReplySummary(from: message.message) ?? message.message
        case .mediaText:
            return mediaTextSummary(from: message.message) ?? message.message
        case .searchSame:
            return "搜同款"
        case .sameProduct:
            return sameProductSummary(from: message.message) ?? message.message
        case .action, .mention, .sticker, .location, .contact, .aggregate, .unknown:
            return unsupportedMessageSummary()
        default:
            return message.message
        }
    }

    // 对齐 widget main:src/components/Bubble/index.vue 的 default 分支与 UnknowMessage.vue，以及 src/locales/lang/zh-CN/index.ts 的 tips.noSupportType。
    private static func unsupportedMessageSummary() -> String {
        "[暂不支持此消息类型]"
    }

    // 对齐 widget main:src/components/Bubble/SystemMessage.vue 的 join_session 文案，以及 src/locales/lang/zh-CN/index.ts 的 msg.joinSession/msg.queueAssigned。
    private static func systemSummary(from message: String, showReceptionInfo: Bool) -> String? {
        guard let payload = payloadObject(from: message),
              nonEmptyString(payload["type"]) == "join_session" else {
            return nil
        }

        if showReceptionInfo,
           let nickname = nonEmptyString(payload["nickname"]) {
            return "客服\(nickname) 接入会话"
        }

        if !showReceptionInfo {
            return "会话被客服接起"
        }

        return nil
    }

    // 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 与 src/helper/types.ts 的 QuickReplyMessageBody.payload.text。
    private static func quickReplySummary(from message: String) -> String? {
        guard let payload = payloadObject(from: message),
              let quickReplyPayload = payload["payload"] as? [String: Any] else {
            return nil
        }

        return nonEmptyString(quickReplyPayload["text"])
    }

    // 对齐 widget main:src/components/Bubble/QuickReplyMessage.vue 与 src/helper/types.ts 的 QuickReplyPayload/buttons/always_show。
    private static func quickReplyInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeQuickReplyInfo? {
        guard kind == .quickReply else {
            return nil
        }
        guard let payload = payloadObject(from: message),
              let quickReplyPayload = payload["payload"] as? [String: Any] else {
            return nil
        }

        var buttons: [SalesmartlyNativeQuickReplyButton] = []
        if let buttonPayloads = quickReplyPayload["buttons"] as? [[String: Any]] {
            buttons = buttonPayloads.compactMap { buttonPayload in
                guard let type = string(buttonPayload["type"]),
                      let text = string(buttonPayload["text"]),
                      let payload = string(buttonPayload["payload"]) else {
                    return nil
                }

                return SalesmartlyNativeQuickReplyButton(
                    type: type,
                    text: text,
                    label: string(buttonPayload["label"]),
                    payload: payload,
                    url: string(buttonPayload["url"])
                )
            }
        }

        return SalesmartlyNativeQuickReplyInfo(
            text: string(quickReplyPayload["text"]),
            buttons: buttons,
            always_show: quickReplyPayload["always_show"] as? Bool
        )
    }

    // 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 默认模板分支的 message.payload.text。
    private static func templateSummary(from message: String) -> String? {
        guard let payload = payloadObject(from: message),
              let templatePayload = payload["payload"] as? [String: Any] else {
            return nil
        }

        if string(payload["type"]) == "invite_evalution" {
            return "您对本次服务满意吗？"
        }
        return nonEmptyString(templatePayload["text"])
    }

    // 对齐 widget main:src/components/Bubble/TemplateMessage/ScoreTpl.vue 的 invite_evalution payload。
    private static func inviteEvalutionInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeInviteEvalutionInfo? {
        guard kind == .template else {
            return nil
        }
        guard let payload = payloadObject(from: message),
              string(payload["type"]) == "invite_evalution",
              let templatePayload = payload["payload"] as? [String: Any] else {
            return nil
        }

        return SalesmartlyNativeInviteEvalutionInfo(
            session_id: string(templatePayload["session_id"]),
            flow_id: string(templatePayload["flow_id"]),
            step_log_id: string(templatePayload["step_log_id"]),
            invite_evaluation_id: string(templatePayload["invite_evaluation_id"]),
            invite_evaluation_order_id: string(templatePayload["invite_evaluation_order_id"])
        )
    }

    // 对齐 widget main:src/components/Bubble/TemplateMessage/index.vue 的 message computed 与 normalizedPayload：
    // 默认模板允许缺少 title/type/text/attachments/buttons，按 Web 规整为空标题、default 类型、空文本和空数组，确保按钮-only 模板仍可展示。
    private static func templateInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeTemplateInfo? {
        guard kind == .template else {
            return nil
        }
        guard let payload = payloadObject(from: message),
              let templatePayload = payload["payload"] as? [String: Any] else {
            return nil
        }

        let title = string(payload["title"]) ?? ""
        let type = string(payload["type"]) ?? "default"
        let text = string(templatePayload["text"]) ?? ""
        let attachmentPayloads = templatePayload["attachments"] as? [[String: Any]] ?? []
        let buttonPayloads = templatePayload["buttons"] as? [[String: Any]] ?? []

        let attachments = attachmentPayloads.compactMap { attachmentPayload -> SalesmartlyNativeTemplateAttachment? in
            guard let mediaType = string(attachmentPayload["media_type"]),
                  let url = string(attachmentPayload["url"]) else {
                return nil
            }

            return SalesmartlyNativeTemplateAttachment(
                media_type: mediaType,
                url: url,
                duration: int(attachmentPayload["duration"])
            )
        }

        let buttons = buttonPayloads.compactMap { buttonPayload -> SalesmartlyNativeTemplateButton? in
            guard let buttonType = string(buttonPayload["type"]),
                  let buttonText = string(buttonPayload["text"]),
                  let buttonPostback = string(buttonPayload["payload"]) else {
                return nil
            }

            return SalesmartlyNativeTemplateButton(
                type: buttonType,
                text: buttonText,
                label: string(buttonPayload["label"]),
                payload: buttonPostback,
                url: string(buttonPayload["url"])
            )
        }

        let branches = templateBranches(from: templatePayload)
        let promotionalCard = templatePromotionalCard(from: templatePayload)
        let likes = templateLikes(from: templatePayload)
        let parsedPayload = SalesmartlyNativeTemplatePayload(
            text: text,
            attachments: attachments,
            buttons: buttons,
            session_id: string(templatePayload["session_id"]),
            branches: branches,
            promotional_card: promotionalCard,
            likes: likes
        )

        return SalesmartlyNativeTemplateInfo(
            title: title,
            type: type,
            payload: parsedPayload
        )
    }

    // 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.branches。
    private static func templateBranches(from templatePayload: [String: Any]) -> [SalesmartlyNativeTemplateBranch]? {
        guard let branchPayloads = templatePayload["branches"] as? [[String: Any]] else {
            return nil
        }

        return branchPayloads.compactMap { branchPayload in
            guard let title = string(branchPayload["title"]),
                  let postback = string(branchPayload["postback"]) else {
                return nil
            }

            return SalesmartlyNativeTemplateBranch(
                title: title,
                postback: postback
            )
        }
    }

    // 对齐 widget main:src/helper/types.ts 与 TemplateMessage/PromotionalCard.vue 的 promotional_card。
    private static func templatePromotionalCard(from templatePayload: [String: Any]) -> SalesmartlyNativeTemplatePromotionalCard? {
        guard let promotionalCardPayload = templatePayload["promotional_card"] as? [String: Any],
              let type = string(promotionalCardPayload["type"]),
              let text = string(promotionalCardPayload["text"]),
              let textColor = string(promotionalCardPayload["text_color"]),
              let btnColor = string(promotionalCardPayload["btn_color"]),
              let image = string(promotionalCardPayload["image"]),
              let discount = promotionalCardPayload["discount"] as? Int,
              let countdown = promotionalCardPayload["countdown"] as? Int else {
            return nil
        }

        return SalesmartlyNativeTemplatePromotionalCard(
            type: type,
            text: text,
            text_color: textColor,
            btn_color: btnColor,
            image: image,
            discount: discount,
            countdown: countdown
        )
    }

    // 对齐 widget main:src/helper/types.ts 的 TemplateMedia.payload.likes。
    private static func templateLikes(from templatePayload: [String: Any]) -> SalesmartlyNativeTemplateLikes? {
        guard let likesPayload = templatePayload["likes"] as? [String: Any],
              let like = string(likesPayload["like"]),
              let unlike = string(likesPayload["unlike"]) else {
            return nil
        }

        return SalesmartlyNativeTemplateLikes(
            like: like,
            unlike: unlike
        )
    }

    // 对齐 widget main:src/components/Bubble/PostbackMessage.vue 的 message.text。
    private static func postbackSummary(from message: String) -> String? {
        guard let payload = postbackPayloadObject(from: message) else {
            return nil
        }

        return nonEmptyString(payload["text"])
    }

    // 对齐 widget main:src/components/Bubble/PostbackMessage.vue 的 JSON.parse(info.message) 与 message.text 展示：
    // 旧 iOS 发送成功 ACK 曾把 msg_type=5 本地缓存写成 JSON 字符串字面量，原生展示前仅恢复内层 postback 对象字符串。
    private static func postbackPayloadObject(from message: String) -> [String: Any]? {
        if let payload = payloadObject(from: message) {
            return payload
        }

        guard let data = message.data(using: .utf8),
              let decodedMessage = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? String else {
            return nil
        }

        return payloadObject(from: decodedMessage)
    }

    // 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo.product_name。
    private static func productSummary(from message: String) -> String? {
        guard let payload = payloadObject(from: message),
              let productInfo = payload["product_info"] as? [String: Any] else {
            return nil
        }

        return nonEmptyString(productInfo["product_name"])
    }

    // 对齐 widget main:src/components/Bubble/ProductMessage.vue 的 productInfo 与 showOriginalPrice 计算。
    private static func productInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeProductInfo? {
        guard kind == .product else {
            return nil
        }
        guard let payload = payloadObject(from: message),
              let productInfo = payload["product_info"] as? [String: Any],
              let productPicture = string(productInfo["product_picture"]),
              let productName = string(productInfo["product_name"]),
              let originalPrice = string(productInfo["original_price"]),
              let price = string(productInfo["price"]),
              let currencyCode = string(productInfo["currency_code"]),
              let purchaseAddress = string(productInfo["purchase_address"]) else {
            return nil
        }

        let showOriginalPrice: Bool
        if let originalPriceNumber = Double(originalPrice),
           let priceNumber = Double(price) {
            showOriginalPrice = originalPriceNumber > priceNumber
        } else {
            showOriginalPrice = false
        }

        return SalesmartlyNativeProductInfo(
            product_picture: productPicture,
            product_name: productName,
            original_price: originalPrice,
            price: price,
            currency_code: currencyCode,
            purchase_address: purchaseAddress,
            showOriginalPrice: showOriginalPrice
        )
    }

    // 对齐 widget main:src/components/Bubble/MediaTextMessage.vue 与 src/helper/types.ts 的 MediaTextMsgType.caption/file_name。
    private static func mediaTextSummary(from message: String) -> String? {
        guard let payload = payloadObject(from: message) else {
            return nil
        }

        if let caption = nonEmptyString(payload["caption"]) {
            return caption
        }
        if let fileName = nonEmptyString(payload["file_name"]) {
            return fileName
        }
        if string(payload["file_type"]) == "document",
           let fileURL = nonEmptyString(payload["file_url"]) {
            return originFileName(fileURL)
        }
        return nil
    }

    // 对齐 widget main:src/components/Bubble/MediaTextMessage.vue 的 componentMap 与 msgCaption，图片/视频图文只依赖 file_type/file_url，caption/file_name/ext 缺失时按 Web 空字符串展示。
    private static func mediaTextInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeMediaTextInfo? {
        guard kind == .mediaText else {
            return nil
        }
        guard let payload = payloadObject(from: message),
              let fileType = string(payload["file_type"]),
              let fileURL = string(payload["file_url"]) else {
            return nil
        }

        return SalesmartlyNativeMediaTextInfo(
            caption: string(payload["caption"]) ?? "",
            file_name: string(payload["file_name"]) ?? "",
            file_type: fileType,
            file_url: fileURL,
            ext: string(payload["ext"]) ?? ""
        )
    }

    // 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 guide/postback/reply 可见文本字段。
    private static func aiSummary(from message: String) -> String? {
        guard let payload = payloadObject(from: message),
              let type = nonEmptyString(payload["type"]) else {
            return nil
        }

        if type == "postback",
           let data = payload["data"] as? [String: Any] {
            return nonEmptyString(data["question"])
        }

        if type == "reply",
           let data = payload["data"] as? [[String: Any]] {
            return data.first { item in
                nonEmptyString(item["context_type"]) == "text"
            }.flatMap { item in
                nonEmptyString(item["context"])
            }
        }

        if type == "guide" {
            return "请选择以下您想咨询的内容"
        }

        return nil
    }

    // 对齐 widget main:src/components/Bubble/AiReplyMessage.vue 的 message computed，解析 guide/postback/reply 三种 AI 消息体。
    private static func aiReplyInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeAIReplyInfo? {
        guard kind == .ai else {
            return nil
        }
        guard let payload = payloadObject(from: message),
              let type = string(payload["type"]) else {
            return nil
        }

        if type == "guide" {
            let questions = (payload["data"] as? [[String: Any]] ?? []).compactMap { item -> SalesmartlyNativeAIGuideQuestion? in
                guard let id = string(item["id"]),
                      let question = string(item["question"]) else {
                    return nil
                }

                return SalesmartlyNativeAIGuideQuestion(id: id, question: question)
            }
            return SalesmartlyNativeAIReplyInfo(type: type, guide: questions)
        }

        if type == "postback",
           let data = payload["data"] as? [String: Any],
           let question = string(data["question"]) {
            return SalesmartlyNativeAIReplyInfo(
                type: type,
                postback: SalesmartlyNativeAIPostbackQuestion(
                    id: string(data["id"]) ?? "",
                    question: question
                )
            )
        }

        if type == "reply" {
            let contexts = (payload["data"] as? [[String: Any]] ?? []).compactMap { item -> SalesmartlyNativeAIReplyContext? in
                guard let contextType = string(item["context_type"]),
                      let context = string(item["context"]) else {
                    return nil
                }

                return SalesmartlyNativeAIReplyContext(
                    context_type: contextType,
                    context: context
                )
            }
            return SalesmartlyNativeAIReplyInfo(type: type, reply: contexts)
        }

        return nil
    }

    // 对齐 widget main:src/components/Bubble/SameProductMessage.vue 与 src/helper/types.ts 的 SameStyleProductInfo.goods_name。
    private static func sameProductSummary(from message: String) -> String? {
        payloadArray(from: message)?.compactMap { item in
            nonEmptyString(item["goods_name"])
        }.first
    }

    // 对齐 widget main:src/components/Bubble/SameProductMessage.vue 与 src/helper/types.ts 的 SameStyleProductInfo 商品列表字段。
    private static func sameProductInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> [SalesmartlyNativeSameProductInfo] {
        guard kind == .sameProduct else {
            return []
        }
        guard let payload = payloadArray(from: message) else {
            return []
        }

        return payload.compactMap { item in
            guard let title = string(item["title"]),
                  let subTitle = string(item["sub_title"]),
                  let content = string(item["content"]),
                  let goodsId = string(item["goods_id"]),
                  let goodsName = string(item["goods_name"]),
                  let goodsLink = string(item["goods_link"]),
                  let originalPrice = string(item["original_price"]),
                  let salePrice = string(item["sale_price"]),
                  let currency = string(item["currency"]),
                  let currencyCode = string(item["currency_code"]),
                  let desc = string(item["desc"]),
                  let mainImage = string(item["main_image"]),
                  let image1 = string(item["image1"]),
                  let image2 = string(item["image2"]),
                  let score = string(item["score"]) else {
                return nil
            }

            return SalesmartlyNativeSameProductInfo(
                title: title,
                sub_title: subTitle,
                content: content,
                goods_id: goodsId,
                goods_name: goodsName,
                goods_link: goodsLink,
                original_price: originalPrice,
                sale_price: salePrice,
                currency: currency,
                currency_code: currencyCode,
                desc: desc,
                main_image: mainImage,
                image1: image1,
                image2: image2,
                score: score
            )
        }
    }

    // 对齐 widget main:src/components/Bubble/SearchSameMessage.vue 的 getMessageUrl：字符串 JSON 读取 file_url/url，否则使用原始字符串。
    private static func searchSameInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeSearchSameInfo? {
        guard kind == .searchSame else {
            return nil
        }

        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{"), trimmed.hasSuffix("}"),
           let payload = payloadObject(from: trimmed) {
            if let fileURL = string(payload["file_url"]) {
                return SalesmartlyNativeSearchSameInfo(img_url: fileURL)
            }
            if let url = string(payload["url"]) {
                return SalesmartlyNativeSearchSameInfo(img_url: url)
            }
            return nil
        }

        return SalesmartlyNativeSearchSameInfo(img_url: message)
    }

    // 对齐 widget main:src/components/Bubble/ImageMessage.vue 的 getMessageUrl：普通图片消息直接读取 info.message.toString()。
    private static func imageMessageInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeImageMessageInfo? {
        guard kind == .image else {
            return nil
        }

        return SalesmartlyNativeImageMessageInfo(img_url: message)
    }

    // 对齐 widget main:src/components/Bubble/VideoMessage.vue 的 getMessageUrl：普通视频消息直接读取 info.message.toString()。
    private static func videoMessageInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeVideoMessageInfo? {
        guard kind == .video else {
            return nil
        }

        return SalesmartlyNativeVideoMessageInfo(video_url: message)
    }

    // 对齐 widget main:src/components/Bubble/FileMessage.vue 的 fileUrl/fullFileName：普通文件消息读取 info.message.toString() 并用 originFileName 提取文件名。
    private static func fileMessageInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeFileMessageInfo? {
        guard kind == .file else {
            return nil
        }

        return SalesmartlyNativeFileMessageInfo(
            file_url: message,
            full_file_name: originFileName(message)
        )
    }

    // 对齐 widget main:src/components/Bubble/AudioMessage.vue 的 audioElem.src：普通音频消息直接读取 info.message。
    private static func audioMessageInfo(from message: String, kind: SalesmartlyNativeMessageKind) -> SalesmartlyNativeAudioMessageInfo? {
        guard kind == .audio else {
            return nil
        }

        return SalesmartlyNativeAudioMessageInfo(audio_url: message)
    }

    // 对齐 widget main:src/components/Bubble/QuotePreview.vue 的 preview 计算，quote_chat 无 chat_user_id 时不展示。
    private static func quotePreviewInfo(from quoteChat: String, language: String) -> SalesmartlyNativeQuotePreviewInfo? {
        guard !quoteChat.isEmpty,
              let quote = payloadObject(from: quoteChat),
              nonEmptyString(quote["chat_user_id"]) != nil else {
            return nil
        }

        let content = quote["content"] as? [String: Any]
        let msgType = string(quote["msg_type"]) ?? string(content?["msg_type"]) ?? ""
        let rawMessage = content?["message"] ?? content?["msg"]

        if msgType == "3" {
            let template = payloadObjectValue(rawMessage)
            let payload = template?["payload"] as? [String: Any]
            let isPromotionalCard = string(template?["type"]) == "promotional_card" || payload?["promotional_card"] != nil
            return SalesmartlyNativeQuotePreviewInfo(
                media_type: "",
                media_url: "",
                tag: "[\(salesmartlyText(isPromotionalCard ? "msgType.promotional_card" : "msgType.3", language: language))]",
                text: ""
            )
        }

        if msgType == "40" {
            guard let media = payloadObjectValue(rawMessage) else {
                return nil
            }
            let caption = stripQuoteText(media["caption"])
            let fileType = string(media["file_type"]) ?? ""
            if fileType == "image" {
                let url = string(media["file_url"]) ?? ""
                return quotePreviewIfVisible(mediaType: url.isEmpty ? "" : "image", mediaURL: url, tag: "", text: caption)
            }
            if fileType == "video" {
                let url = string(media["file_url"]) ?? ""
                return quotePreviewIfVisible(mediaType: url.isEmpty ? "" : "video", mediaURL: url, tag: "", text: caption)
            }
            if fileType == "document" {
                let name = string(media["file_name"]) ?? originFileName(string(media["file_url"]) ?? "")
                let text = [name, caption].filter { !$0.isEmpty }.joined(separator: " ")
                return quotePreviewIfVisible(
                    mediaType: "",
                    mediaURL: "",
                    tag: "[\(salesmartlyText("msgType.4", language: language))]",
                    text: text
                )
            }
            return quotePreviewIfVisible(mediaType: "", mediaURL: "", tag: "", text: caption)
        }

        if msgType == "1" {
            return quotePreviewIfVisible(mediaType: "", mediaURL: "", tag: "", text: stripQuoteText(rawMessage))
        }

        if ["12", "14"].contains(msgType) {
            return SalesmartlyNativeQuotePreviewInfo(
                media_type: "",
                media_url: "",
                tag: "[\(salesmartlyText("msgType.\(msgType)", language: language))]",
                text: ""
            )
        }

        if msgType == "4" {
            return quotePreviewIfVisible(
                mediaType: "",
                mediaURL: "",
                tag: "[\(salesmartlyText("msgType.4", language: language))]",
                text: originFileName(stripQuoteText(rawMessage))
            )
        }

        if msgType == "2" {
            let url = stripQuoteText(rawMessage)
            return quotePreviewIfVisible(mediaType: "image", mediaURL: url, tag: "", text: "")
        }

        if msgType == "45" {
            let url = searchSameQuoteURL(rawMessage)
            return quotePreviewIfVisible(mediaType: "searchSame", mediaURL: url, tag: "", text: "")
        }

        if msgType == "6" {
            let url = stripQuoteText(rawMessage)
            return quotePreviewIfVisible(mediaType: "video", mediaURL: url, tag: "", text: "")
        }

        return quotePreviewIfVisible(mediaType: "", mediaURL: "", tag: "", text: stripQuoteText(rawMessage))
    }

    private static func quotePreviewIfVisible(
        mediaType: String,
        mediaURL: String,
        tag: String,
        text: String
    ) -> SalesmartlyNativeQuotePreviewInfo? {
        if mediaURL.isEmpty && tag.isEmpty && text.isEmpty {
            return nil
        }
        return SalesmartlyNativeQuotePreviewInfo(
            media_type: mediaType,
            media_url: mediaURL,
            tag: tag,
            text: text
        )
    }

    private static func payloadObject(from message: String) -> [String: Any]? {
        guard let data = message.data(using: .utf8) else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    private static func payloadObjectValue(_ value: Any?) -> [String: Any]? {
        if let payload = value as? [String: Any] {
            return payload
        }
        if let message = value as? String {
            return payloadObject(from: message)
        }
        return nil
    }

    private static func payloadArray(from message: String) -> [[String: Any]]? {
        guard let data = message.data(using: .utf8) else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    }

    private static func nonEmptyString(_ value: Any?) -> String? {
        guard let value = value as? String, !value.isEmpty else {
            return nil
        }

        return value
    }

    private static func string(_ value: Any?) -> String? {
        value as? String
    }

    private static func int(_ value: Any?) -> Int? {
        (value as? NSNumber)?.intValue
    }

    private static func stripQuoteText(_ value: Any?) -> String {
        guard let value else {
            return ""
        }
        return String(describing: value)
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func searchSameQuoteURL(_ value: Any?) -> String {
        if let payload = payloadObjectValue(value) {
            if let fileURL = string(payload["file_url"]) {
                return fileURL
            }
            if let url = string(payload["url"]) {
                return url
            }
        }
        return stripQuoteText(value)
    }

    // 对齐 widget main:src/utils/tool.ts 的 originFileName：取最后路径片段、移除 query 并做 percent decode。
    private static func originFileName(_ url: String) -> String {
        let filename = url.split(separator: "/").last.map(String.init) ?? ""
        let filenameWithoutQuery = filename.split(separator: "?").first.map(String.init) ?? filename
        return filenameWithoutQuery.removingPercentEncoding ?? filenameWithoutQuery
    }
}
