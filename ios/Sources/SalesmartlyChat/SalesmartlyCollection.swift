import Foundation

/// 对齐 widget main:src/components/Collection/hooks/useCollection.ts 与 Android `CollectionSelectOption` 的留资选择项。
public struct SalesmartlyCollectionSelectOption: Equatable, Sendable {
    /// 对齐远端 `field_options[].select_content[].id`，提交时作为选中值。
    public var id: String
    /// 对齐远端 `field_options[].select_content[].value`，提交消息里展示的选项文案。
    public var value: String

    /// 对齐 Android `collectionSelectOptionFromRemote` 的字段集合。
    public init(id: String = "", value: String = "") {
        self.id = id
        self.value = value
    }
}

/// 对齐 widget main:src/components/Collection/hooks/useCollection.ts 与 Android `CollectionFieldOption` 的留资字段配置。
public struct SalesmartlyCollectionFieldOption: Equatable, Sendable {
    /// 对齐远端 `field_options[].id`，作为字段配置记录标识。
    public var id: String
    /// 对齐远端 `field_options[].name`，自定义字段提交时进入 `custom_field_title`。
    public var name: String
    /// 对齐远端 `field_options[].field_type`，区分文本、选择、日期和数字字段。
    public var field_type: String
    /// 对齐远端 `field_options[].required`，Android 使用数值字符串判断必填。
    public var required: String
    /// 对齐远端 `field_options[].key`，作为表单值和提交 payload 的字段名。
    public var key: String
    /// 对齐远端 `field_options[].field_name`，保留 widget 字段配置原值。
    public var field_name: String
    /// 对齐远端 `field_options[].select_type`，选择字段中 `1` 表示多选。
    public var select_type: String
    /// 对齐远端 `field_options[].select_content`，选择字段提交时由 id 映射为 value。
    public var select_content: [SalesmartlyCollectionSelectOption]

    /// 对齐 Android `CollectionFieldOption`，不增加未确认字段。
    public init(
        id: String = "",
        name: String = "",
        field_type: String = "0",
        required: String = "0",
        key: String = "",
        field_name: String = "",
        select_type: String = "0",
        select_content: [SalesmartlyCollectionSelectOption] = []
    ) {
        self.id = id
        self.name = name
        self.field_type = field_type
        self.required = required
        self.key = key
        self.field_name = field_name
        self.select_type = select_type
        self.select_content = select_content
    }
}

/// 对齐 widget main:src/components/Collection/index.vue 与 Android `CollectionConfig` 的留资/离线表单配置。
public struct SalesmartlyCollectionConfig: Equatable, Sendable {
    /// 对齐远端 `collect_switch`，控制留资入口是否启用。
    public var collect_switch: Bool
    /// 对齐远端 `collect_required`，控制发送前是否强制留资。
    public var collect_required: Bool
    /// 对齐远端 `collect_btn_switch`，控制底部留资按钮入口是否展示。
    public var collect_btn_switch: Bool
    /// 对齐远端 `guidance`，作为 overlay 顶部引导文案。
    public var guidance: String
    /// 对齐远端 `status_text`，保留留资状态文案配置。
    public var status_text: String
    /// 对齐远端 `field_options`，描述 overlay 中实际渲染和提交的字段集合。
    public var field_options: [SalesmartlyCollectionFieldOption]

    /// 对齐 Android `CollectionConfig` 默认值；默认字段只包含必填 email。
    public init(
        collect_switch: Bool = false,
        collect_required: Bool = false,
        collect_btn_switch: Bool = false,
        guidance: String = "开始聊天之前，请先留下您的信息",
        status_text: String = "",
        field_options: [SalesmartlyCollectionFieldOption] = SalesmartlyCollectionConfig.defaultFieldOptions
    ) {
        self.collect_switch = collect_switch
        self.collect_required = collect_required
        self.collect_btn_switch = collect_btn_switch
        self.guidance = guidance
        self.status_text = status_text
        self.field_options = field_options
    }

    /// 对齐 Android `DEFAULT_COLLECTION_FIELD_OPTIONS`。
    public static let defaultFieldOptions = [
        SalesmartlyCollectionFieldOption(
            id: "email",
            name: "email",
            field_type: "0",
            required: "1",
            key: "email"
        ),
    ]
}

/// 对齐 Android `CollectionFieldState`，供 SwiftUI overlay 渲染字段。
struct SalesmartlyCollectionFieldState: Equatable {
    /// 对齐 Android `CollectionFieldState.key`，作为本地表单值索引。
    var key: String
    /// 对齐 Android `CollectionFieldState.label`，作为输入框或选择框占位文案。
    var label: String
    /// 对齐 Android `CollectionFieldState.field_type`，驱动 SwiftUI 字段类型分支。
    var field_type: String
    /// 对齐 Android `CollectionFieldState.required`，供校验和 UI 状态读取。
    var required: Bool
    /// 对齐 Android `CollectionFieldState.select_type`，供选择字段区分单选与多选。
    var select_type: String
    /// 对齐 Android `CollectionFieldState.select_content`，供选择菜单展示和提交映射。
    var select_content: [SalesmartlyCollectionSelectOption]
}

/// 对齐 Android `CollectionSubmitState`，描述本次留资提交消息和回调 payload。
struct SalesmartlyCollectionSubmitState {
    /// 对齐 Android `CollectionSubmitState.type`，标识普通留资或离线留资来源。
    var type: String
    /// 对齐 widget `title.collectionSuccess`，作为 msg_type=19 的标题。
    var title: String
    /// 对齐 Android `payload`，只包含有值的字段并保留远端 key。
    var payload: SalesmartlyPayload
    /// 对齐 Android `custom_field_title`，只记录非 name/email/phone/company 的自定义字段标题。
    var custom_field_title: [String: String]
    /// 对齐 Android `callbackPayload`，在 onCollectionInfo 回调中补充 type。
    var callbackPayload: SalesmartlyPayload
    /// 对齐 Android `messagePayload`，描述 msg_type=19 的 JSON message。
    var messagePayload: SalesmartlyPayload

    /// 对齐 Android 空 payload 判断，空提交只关闭 overlay 不发留资消息。
    var isEmpty: Bool {
        payload.isEmpty
    }
}

extension SalesmartlyCollectionConfig {
    /// 对齐 Android `activeFieldOptions()`，远端字段为空时使用默认 email 字段。
    func activeFieldOptions() -> [SalesmartlyCollectionFieldOption] {
        if !field_options.isEmpty {
            return field_options
        }
        return Self.defaultFieldOptions
    }

    /// 对齐 Android `collectionFormFields()`，生成 overlay 可渲染字段。
    func collectionFormFields(language: String = "zh-CN") -> [SalesmartlyCollectionFieldState] {
        activeFieldOptions().map { field in
            SalesmartlyCollectionFieldState(
                key: field.key,
                label: field.collectionFieldLabel(language: language),
                field_type: field.field_type,
                required: Double(field.required) == 1,
                select_type: field.select_type,
                select_content: field.select_content
            )
        }
    }

    /// 对齐 Android `collectionOverlayInitialValues()`。
    func collectionInitialValues() -> SalesmartlyPayload {
        var values: SalesmartlyPayload = [:]
        collectionFormFields().forEach { field in
            if field.field_type == "1" && field.select_type == "1" {
                values[field.key] = [String]()
            } else {
                values[field.key] = ""
            }
        }
        return values
    }

    /// 对齐 Android `collectionFieldErrorTexts()`。
    func collectionFieldErrorTexts(values: SalesmartlyPayload, area: String, language: String = "zh-CN") -> [String: String] {
        var errors: [String: String] = [:]
        activeFieldOptions().forEach { field in
            if let error = field.collectionFieldErrorText(value: values[field.key], area: area) {
                errors[field.key] = Self.localizedErrorText(error, language: language)
            }
        }
        return errors
    }

    /// 对齐 Android `collectionSubmitState()`，将字段值转换为 msg_type=19 消息体和 onCollectionInfo 回调体。
    func collectionSubmitState(title: String, type: String, values: SalesmartlyPayload, area: String) -> SalesmartlyCollectionSubmitState {
        var payload: SalesmartlyPayload = [:]
        var customFieldTitle: [String: String] = [:]
        activeFieldOptions().forEach { field in
            let value = field.collectionPayloadValue(value: values[field.key], area: area)
            if !Self.hasCollectionValue(value) {
                return
            }
            payload[field.key] = value
            if !field.isCompanyOption {
                customFieldTitle[field.key] = field.name
            }
        }

        var callbackPayload = payload
        callbackPayload["type"] = type
        let messagePayload: SalesmartlyPayload = [
            "source": type,
            "title": title,
            "payload": payload,
            "custom_field_title": customFieldTitle,
        ]

        return SalesmartlyCollectionSubmitState(
            type: type,
            title: title,
            payload: payload,
            custom_field_title: customFieldTitle,
            callbackPayload: callbackPayload,
            messagePayload: messagePayload
        )
    }

    /// 对齐 Android `collectionNormalizeFieldInput()` 的最大长度规则。
    func normalizedInput(field: SalesmartlyCollectionFieldState, input: String) -> String {
        String(input.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.fieldMaxLength(field: field)))
    }

    // 对齐 Android `hasCollectionValue()`，提交时过滤空字符串和空选择列表。
    private static func hasCollectionValue(_ value: Any?) -> Bool {
        if let list = value as? [String] {
            return list.contains { !$0.isEmpty }
        }
        if let value = value as? String {
            return !value.isEmpty
        }
        return value != nil
    }

    // 对齐 Android `collectionNormalizeFieldInput()` 的字段长度上限。
    private static func fieldMaxLength(field: SalesmartlyCollectionFieldState) -> Int {
        if field.key == "name" {
            return 30
        }
        if field.key == "email" {
            return 50
        }
        if field.key == "phone" {
            return 30
        }
        if field.key == "company" {
            return 70
        }
        if field.field_type == "2" {
            return 50
        }
        if field.field_type == "3" {
            return 11
        }
        return 500
    }

    // 对齐 Android `localizedCollectionErrorText()`，把模型层固定中文错误映射为当前语言文案。
    private static func localizedErrorText(_ error: String, language: String) -> String {
        if error == "请输入名字" {
            return salesmartlyText("msg.requiredName", language: language)
        }
        if error == "请输入邮箱" {
            return salesmartlyText("msg.requiredEmail", language: language)
        }
        if error == "邮箱格式错误" {
            return salesmartlyText("msg.emailFormat", language: language)
        }
        if error == "请输入手机号码" {
            return salesmartlyText("msg.requiredPhone", language: language)
        }
        if error == "手机号码格式错误" {
            return salesmartlyText("msg.phoneFormat", language: language)
        }
        if error == "请输入公司名称" {
            return salesmartlyText("msg.requiredCompany", language: language)
        }
        if error == "请选择区号" {
            return salesmartlyText("msg.requiredArea", language: language)
        }
        if error == "请输入" {
            return salesmartlyText("msg.pleaseEnter", language: language, replacements: ["msg": ""])
        }
        if error == "请选择" {
            return salesmartlyText("msg.pleaseChoose", language: language, replacements: ["msg": ""])
        }
        if error == "请输入日期: 2050-10-01" {
            return salesmartlyText("msg.inputDate", language: language, replacements: ["format": ": 2050-10-01"])
        }
        if error == "请输入数字" {
            return salesmartlyText("msg.inputNumber", language: language)
        }
        return error
    }
}

extension SalesmartlyCollectionFieldOption {
    // 对齐 Android `required.toDoubleOrNull() == 1.0` 的必填判断。
    private var isRequired: Bool {
        Double(required) == 1
    }

    // 对齐 Android `isCompanyOption()`，系统字段不进入 `custom_field_title`。
    fileprivate var isCompanyOption: Bool {
        key == "name" || key == "email" || key == "phone" || key == "company"
    }

    // 对齐 Android `collectionFieldLabel()`，系统字段使用固定 placeholder key，自定义字段使用远端 name。
    fileprivate func collectionFieldLabel(language: String) -> String {
        if key == "name" {
            return salesmartlyText("placeholder.name", language: language)
        }
        if key == "email" {
            return salesmartlyText("placeholder.email", language: language)
        }
        if key == "phone" {
            return salesmartlyText("placeholder.phone", language: language)
        }
        if key == "company" {
            return salesmartlyText("placeholder.company", language: language)
        }
        return name
    }

    // 对齐 Android `collectionPayloadValue()`，选择字段由选项 id 映射 value，手机号拼接区号。
    fileprivate func collectionPayloadValue(value: Any?, area: String) -> Any {
        if field_type == "1" {
            let selectedIds: [String]
            if let list = value as? [String] {
                selectedIds = list.filter { !$0.isEmpty }
            } else if let value = value as? String, !value.isEmpty {
                selectedIds = [value]
            } else {
                selectedIds = []
            }
            return selectedIds.compactMap { id in
                select_content.first { $0.id == id }?.value
            }.filter { !$0.isEmpty }
        }

        let text = value as? String ?? ""
        if key == "phone" && !text.isEmpty {
            return "\(area.replacingOccurrences(of: "+", with: ""))\(text)"
        }
        return text
    }

    // 对齐 Android `collectionFieldErrorText()`，按系统字段优先级和自定义字段类型返回固定错误文本。
    fileprivate func collectionFieldErrorText(value: Any?, area: String) -> String? {
        if key == "email" {
            let text = value as? String ?? ""
            if text.isEmpty {
                return isRequired ? "请输入邮箱" : nil
            }
            return Self.emailRegex.firstMatch(in: text, range: NSRange(text.startIndex..<text.endIndex, in: text)) == nil ? "邮箱格式错误" : nil
        }
        if key == "phone" {
            return collectionPhoneErrorText(phone: value as? String ?? "", area: area, requiredField: isRequired)
        }
        if key == "name" {
            let text = value as? String ?? ""
            return isRequired && text.isEmpty ? "请输入名字" : nil
        }
        if key == "company" {
            let text = value as? String ?? ""
            return isRequired && text.isEmpty ? "请输入公司名称" : nil
        }
        if !isRequired {
            return nil
        }

        let payloadValue = collectionPayloadValue(value: value, area: area)
        if field_type == "1" {
            return SalesmartlyCollectionConfig.collectionValueExists(payloadValue) ? nil : "请选择"
        }
        if field_type == "2" {
            let text = value as? String ?? ""
            return Self.validDate(text) ? nil : "请输入日期: 2050-10-01"
        }
        if field_type == "3" {
            let text = value as? String ?? ""
            return Self.numberRegex.firstMatch(in: text, range: NSRange(text.startIndex..<text.endIndex, in: text)) == nil ? "请输入数字" : nil
        }
        return SalesmartlyCollectionConfig.collectionValueExists(payloadValue) ? nil : "请输入"
    }

    // 对齐 Android `collectionPhoneErrorText()`，校验顺序固定为区号、手机号、手机号格式。
    private func collectionPhoneErrorText(phone: String, area: String, requiredField: Bool) -> String? {
        let hasPhone = !phone.isEmpty
        let hasArea = !area.isEmpty
        if !requiredField && !hasPhone && !hasArea {
            return nil
        }
        if !requiredField && hasPhone && Self.phoneRegex.firstMatch(in: phone, range: NSRange(phone.startIndex..<phone.endIndex, in: phone)) == nil {
            return "手机号码格式错误"
        }
        if !hasArea {
            return "请选择区号"
        }
        if !hasPhone {
            return "请输入手机号码"
        }
        return Self.phoneRegex.firstMatch(in: phone, range: NSRange(phone.startIndex..<phone.endIndex, in: phone)) == nil ? "手机号码格式错误" : nil
    }

    // 对齐 Android `validCollectionDate()`，校验 yyyy-MM-dd 以及月份天数和闰年。
    private static func validDate(_ value: String) -> Bool {
        guard dateRegex.firstMatch(in: value, range: NSRange(value.startIndex..<value.endIndex, in: value)) != nil else {
            return false
        }
        let year = Int(value.prefix(4))!
        let monthStart = value.index(value.startIndex, offsetBy: 5)
        let monthEnd = value.index(value.startIndex, offsetBy: 7)
        let dayStart = value.index(value.startIndex, offsetBy: 8)
        let month = Int(value[monthStart..<monthEnd])!
        let day = Int(value[dayStart..<value.endIndex])!
        if month < 1 || month > 12 {
            return false
        }
        let maxDay: Int
        if month == 2 {
            maxDay = isLeapYear(year) ? 29 : 28
        } else if month == 4 || month == 6 || month == 9 || month == 11 {
            maxDay = 30
        } else {
            maxDay = 31
        }
        return day >= 1 && day <= maxDay
    }

    // 对齐 Android `isLeapYear()`，供日期字段校验二月天数。
    private static func isLeapYear(_ year: Int) -> Bool {
        year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }

    // 对齐 Android `COLLECTION_EMAIL_REGEX`。
    private static let emailRegex = try! NSRegularExpression(pattern: #"^[A-Za-z\d]+([-_.][A-Za-z\d]+)*@([A-Za-z\d]+[-.])+[A-Za-z\d]{2,12}$"#)
    // 对齐 Android `COLLECTION_PHONE_REGEX`。
    private static let phoneRegex = try! NSRegularExpression(pattern: #"^(\+?\d+[ -]?)?(\(\d+\))?( ?/ ?)?([\s\-.]?\d{1,5}){5,}.*\d$"#)
    // 对齐 Android `COLLECTION_DATE_REGEX`。
    private static let dateRegex = try! NSRegularExpression(pattern: #"^\d{4}-\d{2}-\d{2}$"#)
    // 对齐 Android `COLLECTION_NUMBER_REGEX`。
    private static let numberRegex = try! NSRegularExpression(pattern: #"^\d{1,11}$"#)
}

extension SalesmartlyCollectionConfig {
    // 对齐 Android `hasCollectionValue()`，校验自定义字段是否存在可提交值。
    fileprivate static func collectionValueExists(_ value: Any) -> Bool {
        if let list = value as? [String] {
            return list.contains { !$0.isEmpty }
        }
        if let value = value as? String {
            return !value.isEmpty
        }
        return true
    }
}
