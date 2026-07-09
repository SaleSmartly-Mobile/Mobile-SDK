import Foundation

/// 对齐 widget main:src/locales/index.ts 与 Android `ChatI18n`，负责插件语言映射、内置 Web all.json 读取和 `{key}` 占位符替换。
enum SalesmartlyI18n {
    /// 对齐 widget main:src/locales/index.ts 的 lang 初始值和不支持语言处理。
    static let defaultLanguage = "en-US"

    /// 对齐 widget main:src/locales/index.ts 的 supportLang，限定 iOS runtime 可接受的语言代码。
    static let supportedLanguages: Set<String> = [
        "zh-CN",
        "en-US",
        "ru-RU",
        "zh-HK",
        "th-TH",
        "mn",
        "vi-VN",
        "ja-JP",
        "fr",
        "pt",
        "ar",
        "es",
        "de",
        "ro",
        "pl",
        "id",
        "ko",
        "nl",
        "da",
        "it",
        "tr",
        "bn",
    ]

    /// 对齐 widget main:src/locales/index.ts 的 setLang 输入优先级：setLoginInfo.language > widgetInfo.language > auto。
    static func resolveLanguage(userLanguage: String?, widgetLanguage: String?, systemLanguage: String) -> String {
        if let userLanguage, !userLanguage.isEmpty {
            return setLang(userLanguage, systemLanguage: systemLanguage)
        }
        if let widgetLanguage, !widgetLanguage.isEmpty {
            return setLang(widgetLanguage, systemLanguage: systemLanguage)
        }
        return setLang("auto", systemLanguage: systemLanguage)
    }

    /// 对齐 widget main:src/locales/index.ts 的 setLang；`auto` 使用系统语言映射，不支持时回到 Web 默认 `en-US`。
    static func setLang(_ language: String, systemLanguage: String = Locale.current.identifier) -> String {
        if language == "auto" {
            let navLang = dealLanguageMap(systemLanguage.replacingOccurrences(of: "_", with: "-"))
            return supportedLanguages.contains(navLang) ? navLang : defaultLanguage
        }

        let mappedLanguage = dealLanguageMap(language)
        return supportedLanguages.contains(mappedLanguage) ? mappedLanguage : defaultLanguage
    }

    /// 对齐 widget main:src/locales/index.ts 的 dealLanguageMap，处理产品要求的语言别名和前缀匹配。
    static func dealLanguageMap(_ language: String) -> String {
        var result = language
        switch language {
        case "zh-TW":
            result = "zh-HK"
        case "ru":
            result = "ru-RU"
        case "zh":
            result = "zh-CN"
        case "ja":
            result = "ja-JP"
        case "ind":
            result = "id"
        case "ko-KR":
            result = "ko"
        case "nl-NL", "nl-BE":
            result = "nl"
        case "da-DK":
            result = "da"
        case "it-CH", "it-IT":
            result = "it"
        case "tr-TR":
            result = "tr"
        default:
            break
        }

        let lowercasedResult = result.lowercased()
        if lowercasedResult.hasPrefix("th") {
            result = "th-TH"
        }
        if lowercasedResult.hasPrefix("vi") {
            result = "vi-VN"
        }
        if lowercasedResult.hasPrefix("mn") {
            result = "mn"
        }
        if lowercasedResult.hasPrefix("ja") {
            result = "ja-JP"
        }
        if lowercasedResult.hasPrefix("fr") {
            result = "fr"
        }
        if lowercasedResult.hasPrefix("es") {
            result = "es"
        }
        if lowercasedResult.hasPrefix("ar") {
            result = "ar"
        }
        if lowercasedResult.hasPrefix("pt") {
            result = "pt"
        }
        if lowercasedResult.hasPrefix("de") {
            result = "de"
        }
        if lowercasedResult.hasPrefix("ro") {
            result = "ro"
        }
        if lowercasedResult.hasPrefix("pl") {
            result = "pl"
        }
        if lowercasedResult.hasPrefix("id") {
            result = "id"
        }
        if lowercasedResult.hasPrefix("ko") {
            result = "ko"
        }
        if lowercasedResult.hasPrefix("nl") {
            result = "nl"
        }
        if lowercasedResult.hasPrefix("da") {
            result = "da"
        }
        if lowercasedResult.hasPrefix("it") {
            result = "it"
        }
        if lowercasedResult.hasPrefix("tr") {
            result = "tr"
        }
        if lowercasedResult.hasPrefix("bn") {
            result = "bn"
        }

        return result
    }

    /// 对齐 Android `ChatI18n.text` 与 widget `$t`，按 Web dot key 读取当前语言文案并替换占位符。
    static func text(_ key: String, language: String, replacements: [String: String] = [:]) -> String {
        let mappedLanguage = setLang(language)
        let raw = zhCnMessages[mappedLanguage]?[key]
            ?? resourceText(language: mappedLanguage, key: key)
            ?? enUsMessages[key]
            ?? key
        return replaceTextKey(raw, replacements: replacements)
    }

    private static func resourceText(language: String, key: String) -> String? {
        guard let root = resourceRoot(language: language) else {
            return nil
        }

        var current: Any? = root
        key.split(separator: ".").forEach { path in
            current = (current as? [String: Any])?[String(path)]
        }
        return current as? String
    }

    private static func resourceRoot(language: String) -> [String: Any]? {
        guard let url = Bundle.module.url(
            forResource: "all",
            withExtension: "json",
            subdirectory: "salesmartly/locales/\(language)"
        ) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    private static func replaceTextKey(_ text: String, replacements: [String: String]) -> String {
        var result = text
        replacements.forEach { key, value in
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }

    /// 对齐 Android `ChatI18n` 的 zh-CN 静态文案表，来源为 widget main:src/locales/lang/zh-CN/index.ts 中当前 iOS 原生渲染已使用的 key。
    private static let zhCnMessages = [
        "zh-CN": [
            "tips.failSend": "发送失败",
            "tips.noSupportType": "[暂不支持此消息类型]",
            "tips.welcomeScore": "您对本次服务满意吗？",
            "tips.scoreSucess": "感谢您的评价！",
            "tips.ask": "请选择以下您想咨询的内容",
            "tips.contactUs": "联系我们",
            "tips.reply": "回复",
            "tips.newEmail": "您有一封邮件，请查收",
            "tips.collection": "开始聊天之前，请先留下您的信息",
            "tips.uploadFail": "文件上传失败，请检查网络后重试",
            "tips.likeMsg": "此回答对您是否有帮助",
            "tips.disableReply": " 企业未完成实名认证无法通过中国大陆网络使用插件发送消息",
            "tips.guessQuestion": "猜你想问",
            "tips.searchSameCommodity": "为你推荐以下商品",
            "tips.uploadFailText": "上传失败",
            "errorCode.140001": "当前会话已完成评价，无法重新评价",
            "errorCode.140002": "评价链接已过期",
            "tips.receivedCoupon": "收到{num}张优惠券",
            "title.collectionSuccess": "信息提交成功",
            "title.board": "公告",
            "fileType.image": "图片",
            "fileType.video": "视频",
            "fileType.attachment": "附件",
            "placeholder.input": "输入信息...",
            "placeholder.score": "让我们了解更多...",
            "placeholder.name": "名字",
            "placeholder.email": "邮箱",
            "placeholder.phone": "手机号码",
            "placeholder.company": "公司名称",
            "btn.cancel": "取消",
            "btn.send": "发送",
            "btn.retry": "点击重试",
            "btn.post": "提交",
            "btn.collectionBtn": "请在开始聊天前填写信息",
            "btn.showMore": "展开",
            "btn.enterChat": "进入聊天",
            "btn.searchSame": "搜同款",
            "btn.checkoutNow": "立即购买",
            "btn.evaluate": "立即评价",
            "btn.receiveCoupon": "立即领取",
            "btn.go": "前往",
            "btn.close": "收起",
            "btn.message": "消息",
            "btn.detail": "详情",
            "btn.emoji": "表情",
            "btn.human": "转人工",
            "msg.requiredScore": "请选择评分",
            "msg.humanService": "等待客服接待中，請稍候",
            "msg.joinSession": "会话被客服接起",
            "msg.queueWaiting": "前面还有 {count} 位访客在排队，请稍候",
            "msg.queueAssigned": "客服{name} 接入会话",
            "msg.withdrawMessage": "消息已被撤回",
            "msg.requiredName": "请输入名字",
            "msg.requiredEmail": "请输入邮箱",
            "msg.emailFormat": "邮箱格式错误",
            "msg.requiredPhone": "请输入手机号码",
            "msg.phoneFormat": "手机号码格式错误",
            "msg.requiredCompany": "请输入公司名称",
            "msg.requiredArea": "请选择区号",
            "msg.pleaseEnter": "请输入{msg}",
            "msg.pleaseChoose": "请选择{msg}",
            "msg.inputDate": "请输入日期{format}",
            "msg.inputNumber": "请输入数字",
            "msg.typing": "正在输入",
            "msg.newMsg": "新消息",
            "time.yesterday": "昨天",
            "label.email": "邮箱",
            "label.phone": "手机号码",
            "label.name": "名字",
            "label.company": "公司",
            "label.area": "区号",
            "verifyLangInfo.aboutAccount": "关于该账号",
            "verifyLangInfo.verifyType": "认证类型",
            "verifyLangInfo.enterprise": "企业",
            "verifyLangInfo.personal": "个人",
            "verifyLangInfo.report": "举报",
            "verifyLangInfo.riskTips": "SaleSmartly不对聊天行为及结果承担任何责任，请谨慎使用并自行辨别风险；涉及转账交易时务必核实，谨防诈骗导致钱款损失。",
            "searchProduct.originalPrice": "原价",
            "searchProduct.productTips": "为您推荐以下商品",
            "msgType.2": "图片",
            "msgType.3": "模板消息",
            "msgType.4": "文件",
            "msgType.6": "视频",
            "msgType.12": "语音",
            "msgType.14": "推荐商品",
            "msgType.promotional_card": "推广卡片",
            "msgType.invite_evalution": "评价",
        ],
    ]

    /// 对齐 Android `ChatI18n` 的 en-US 静态文案表，用于资源缺失时保持本地单测和默认文案与 Web key 一致。
    private static let enUsMessages = [
        "tips.failSend": "Failed to send",
        "tips.noSupportType": "[Unsupported message type]",
        "tips.welcomeScore": "Are you satisfied with this service?",
        "tips.scoreSucess": "Thank you for your review!",
        "tips.ask": "Please select the content you would like to consult below",
        "tips.contactUs": "Contact us",
        "tips.reply": "Reply",
        "tips.newEmail": "New email",
        "tips.collection": "Please leave your information before start chatting",
        "tips.likeMsg": "Is this answer helpful?",
        "tips.disableReply": "Enterprises that have not completed real-name authentication cannot use plug-ins to send messages through the Chinese mainland network",
        "tips.guessQuestion": "I guess you want to ask",
        "tips.searchSameCommodity": "We recommend the following products for you",
        "tips.uploadFailText": "Upload failed",
        "tips.receivedCoupon": "Received {num} coupons",
        "title.collectionSuccess": "Information submitted successfully",
        "title.board": "announcement",
        "fileType.image": "Image",
        "fileType.video": "Video",
        "fileType.attachment": "Attachment",
        "placeholder.input": "Type a message...",
        "placeholder.score": "Let's learn more...",
        "placeholder.name": "Name",
        "placeholder.email": "Email address",
        "placeholder.phone": "Mobile number",
        "placeholder.company": "Company name",
        "btn.cancel": "Cancel",
        "btn.send": "Send",
        "btn.retry": "Click to try again",
        "btn.post": "Submit",
        "btn.collectionBtn": "Please fill in the information before starting the chat.",
        "btn.showMore": "Show more",
        "btn.enterChat": "Enter chat",
        "btn.searchSame": "Search for similar items",
        "btn.checkoutNow": "Buy it now",
        "btn.evaluate": "Rate it now",
        "btn.receiveCoupon": "Claim Now",
        "btn.go": "Go to",
        "btn.close": "Close",
        "btn.message": "information",
        "btn.detail": "Details",
        "btn.emoji": "expression",
        "btn.human": "Transfer to manual",
        "msg.requiredScore": "Please rate our service",
        "msg.humanService": "Someone is connecting to you, please wait",
        "msg.joinSession": "Connected",
        "msg.queueWaiting": "There are {count} visitors ahead of you in the queue, please wait.",
        "msg.queueAssigned": "Customer service {name} access session",
        "msg.withdrawMessage": "message retracted",
        "msg.requiredName": "Please enter your name",
        "msg.requiredEmail": "Please enter your email address",
        "msg.emailFormat": "Incorrect email format",
        "msg.requiredPhone": "Please enter your mobile phone number",
        "msg.phoneFormat": "Wrong mobile number format",
        "msg.requiredCompany": "Please enter company name",
        "msg.requiredArea": "Please select area code",
        "msg.pleaseEnter": "Please enter {msg}",
        "msg.pleaseChoose": "Please select {msg}",
        "msg.inputDate": "Please enter the date {format}",
        "msg.inputNumber": "Please enter a number",
        "msg.typing": "Typing",
        "msg.newMsg": "Breaking news",
        "time.yesterday": "Yesterday",
        "label.email": "Email",
        "label.phone": "Phone number",
        "label.name": "Name",
        "label.company": "Company",
        "label.area": "Area Code",
        "verifyLangInfo.aboutAccount": "About this account",
        "verifyLangInfo.verifyType": "Certification Type",
        "verifyLangInfo.enterprise": "enterprise",
        "verifyLangInfo.personal": "personal",
        "verifyLangInfo.report": "report",
        "verifyLangInfo.riskTips": "SaleSmartly assumes no responsibility for chat behavior or results. Please use with caution and identify risks on your own. Be sure to verify any transfer transactions and beware of fraud that may lead to financial loss.",
        "searchProduct.originalPrice": "Original Price",
        "searchProduct.productTips": "Recommend the following products for you",
        "msgType.2": "picture",
        "msgType.3": "Template message",
        "msgType.4": "document",
        "msgType.6": "video",
        "msgType.12": "voice",
        "msgType.14": "Recommended products",
        "msgType.promotional_card": "Promotional cards",
        "msgType.invite_evalution": "evaluate",
    ]
}
