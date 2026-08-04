# SaleSmartly Android / iOS 原生 SDK 合规配置与申报指南

## 1. 文档范围

本文是 `SaleSmartly Android Native SDK` 与 `SaleSmartly iOS Native SDK` 的合规事实源，供以下场景使用：

- 宿主应用隐私政策和第三方 SDK 清单；
- Google Play Data Safety；
- App Store Connect App Privacy；
- Android 权限审核；
- iOS `PrivacyInfo.xcprivacy`；
- SaleSmartly 帮助中心原生 SDK 合规页面。

SDK 提供方为广州标品软件有限公司，当前用途限于在线客服、消息会话、用户主动附件上传以及可选的消息提醒。

[原 Android SDK 合规配置规范](https://help.salesmartly.com/docs/salesmartly-android-sdk-regulation-deploy-guidelines)适用于旧版 Android WebView SDK。该页面所列网络状态、Wi-Fi、存储权限以及设备型号、系统版本、应用包名等内容，不得直接用于当前原生 SDK。帮助中心发布原生 SDK 页面后，旧页面应保留并明确标注“仅适用于 Android WebView 旧版 SDK”。

本文按三类事实组织：

1. **固定项**：当前 SDK 本身必然涉及的行为；
2. **条件项**：仅在宿主启用相应功能、传入相应数据或后端进行相应处理时涉及；
3. **待确认项**：必须由后端、法务或合同事实确认，确认前不得对外作肯定承诺。

## 2. 权限与平台配置

| 平台 | 固定项 | 条件项 | 当前不应声明 |
| --- | --- | --- | --- |
| Android | `android.permission.INTERNET`，由 SDK Manifest 合并到宿主应用 | `android.permission.POST_NOTIFICATIONS`；仅用于本地消息提醒，Android 13 及以上由宿主在有明确上下文时申请 | 网络状态、Wi-Fi 状态、读写或管理存储、相机、麦克风、定位、通讯录、剪贴板、广告 ID、Android ID |
| iOS | SDK 自带 `PrivacyInfo.xcprivacy`；声明 `UserDefaults` Required Reason `CA92.1` | 本地通知系统授权；由宿主在有明确上下文时申请，不需要 Info.plist 用途描述键 | 相机、麦克风、定位、ATT/IDFA、完整相册访问、远程推送 entitlement |

### 2.1 Android

SDK Manifest 当前仅包含：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

附件通过系统文件选择器 `ActivityResultContracts.OpenDocument()` 由用户主动选择，不需要申请读写存储或管理存储权限。

SDK 只在展示本地通知前检查 `POST_NOTIFICATIONS` 状态，不主动弹出权限请求。宿主应在以下条件同时满足时自行申请：

- 用户已经同意宿主应用隐私政策；
- 用户主动启用消息提醒，或已经进入能够理解授权用途的消息提醒场景；
- 系统版本为 Android 13 或更高版本。

宿主拒绝通知权限不影响聊天和附件选择等核心能力。

### 2.2 iOS

iOS 使用 `PHPickerViewController` 选择图片或视频，使用 `UIDocumentPickerViewController` 选择文件，不需要申请完整相册访问权限，也不需要为上述选择器配置相册、相机或存储用途描述键。

SDK 使用 `UserDefaults.standard` 保存本地数据，因此 SDK 自己的 `PrivacyInfo.xcprivacy` 至少必须包含：

```xml
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyTrackingDomains</key>
<array/>
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>CA92.1</string>
        </array>
    </dict>
</array>
```

依赖库中的隐私清单不能替代 SaleSmartly SDK 自己的隐私清单。

iOS 默认通知处理器不会调用 `UNUserNotificationCenter.requestAuthorization(options:)`。宿主需要消息提醒时，应在用户已经同意宿主隐私政策且能够理解授权用途的场景中显式申请通知权限。

## 3. 数据处理事实

### 3.1 SDK 自动生成或读取

| 数据 | Android | iOS | 用途 |
| --- | --- | --- | --- |
| 系统语言 | SDK 读取 | 核心初始化上下文主要由宿主传入；部分本地国际化逻辑读取系统语言 | 展示语言和会话语言 |
| 访客标识 | SDK 生成并持久保存 | `guestUserId` 由宿主传入；是否由宿主持久生成取决于宿主实现 | 创建或恢复访客会话 |
| 会话标识、用户标识、token | SDK 读取、接收并缓存 | SDK 读取、接收并缓存 | 身份和会话连续性 |
| 消息时间、临时消息标识、交互状态 | SDK 生成或记录 | SDK 生成或记录 | 消息发送、重试、排序及界面状态 |

Android 访客标识是持久标识，Google Play Data Safety 应保守归入 `Device or other IDs`。iOS 核心 SDK 不自行读取 IDFA、IDFV 或其他设备标识；只有宿主把 `guestUserId` 定义为安装级设备标识时，宿主才需要补充申报 Device ID。

### 3.2 开发者传入

宿主可根据实际业务传入以下信息：

- 用户 ID、姓名、电话、邮箱和语言；
- 用户描述、标签和自定义字段；
- 来源页面、页面路由或 URL；
- User-Agent、来源页或其他启动上下文。

这些数据不是全部由 SDK 主动读取。宿主必须根据实际传入字段逐项更新隐私政策和商店后台，不能统一描述为“SDK 自行采集”。动态自定义字段必须按照字段真实语义申报，不能全部隐藏在“其他用户内容”中。

### 3.3 用户主动提供

用户使用客服功能时可能主动提供：

- 聊天文本和其他消息内容；
- 留资信息；
- 评价、反馈和点赞等互动内容；
- 图片、视频和文件附件。

图片、视频和文件均由用户通过系统选择器主动选择。未启用对应入口或用户未选择时，不处理对应附件。

### 3.4 服务端获得或处理

SDK 发起网络连接时，接收请求的服务器会获得源 IP。以下事项必须按服务端实际处理方式决定是否申报：

- 是否保存 IP 以及保存期限；
- 是否将 IP 用于故障诊断；
- 是否通过 IP 推断粗略位置；
- 是否将来源 URL 用作浏览历史、产品交互或其他用途；
- 是否存在分析、营销、画像或跨应用跟踪。

没有后端事实确认时，不得声明 SDK 不保存 IP，也不得声明 IP 仅用于某一特定目的。

### 3.5 本地处理

Android 使用应用私有的 `SharedPreferences`，iOS 使用 `UserDefaults`，用于保存或缓存访客/用户标识、token、留资状态及部分消息数据。

上述存储不是加密存储。对外不得描述为“本地数据已加密”。宿主的备份规则可能影响应用私有数据是否进入系统备份，宿主需结合自身 Android 备份配置和 iOS 数据保护策略核验。

### 3.6 当前源码未发现向服务端采集或传输的内容

当前原生 SDK 源码未发现向服务端采集或传输以下内容。系统版本等信息可能仅用于平台权限或界面逻辑，不属于当前对外传输字段：

- Android ID、OAID、IDFA、IDFV、IMEI；
- MAC 地址、SSID、已安装应用列表；
- 设备厂商和设备型号；
- 宿主应用包名和版本号；
- 网络连接类型和 Wi-Fi 状态；
- 精确或粗略定位；
- 通讯录、相机、麦克风和剪贴板。

不得沿用旧 WebView 页面中的对应声明。若后续版本新增上述能力，必须先更新代码审计、权限配置、隐私清单及本文，再发布 SDK。

## 4. 隐私同意与生命周期

### 4.1 初始化时机

首次安装和后续冷启动都必须遵守以下顺序：

1. 宿主展示自己的隐私政策，并在第三方 SDK 清单中列明 SaleSmartly 原生 SDK；
2. 用户明确同意后，宿主才调用 `initialize`；
3. SDK 初始化完成后，再调用依赖运行时的聊天 API；
4. 通知权限在用户理解其用途的独立场景中申请。

用户拒绝隐私政策时不得调用 `initialize`。初始化可能读取本地缓存，并请求项目脚本或配置信息、创建或恢复访客以及建立 Socket.IO、SSE 或 HTTP 会话，因此不能把“只初始化但暂不打开聊天”视为未处理数据。

### 4.2 `clearUser()` 的能力边界

当前 Android 和 iOS 的 `clearUser()` 用于退出当前用户身份或切回访客态，不等同于：

- 撤回隐私同意；
- 完整停止 SDK 的所有网络活动；
- 清空 SDK 的全部本地缓存；
- 删除服务端保存的数据；
- 完成账号注销或个人信息删除请求。

两端当前没有统一的公开 API 同时完成停网、全量本地清理和服务端删除。对外政策不得把 `clearUser()` 描述为撤回同意或数据删除能力。用户权利请求的具体入口、响应期限、宿主与 SaleSmartly 的协作流程及删除范围属于待法务及后端确认项；发布隐私政策前必须形成可执行的受理流程。

## 5. 宿主隐私政策推荐结构

宿主的第三方 SDK 清单至少应包含：

| 字段 | Android | iOS |
| --- | --- | --- |
| SDK 名称 | SaleSmartly Android Native SDK | SaleSmartly iOS Native SDK |
| 提供方 | 广州标品软件有限公司 | 广州标品软件有限公司 |
| 使用目的 | 在线客服、消息会话、用户主动附件上传、可选消息提醒 | 在线客服、消息会话、用户主动附件上传、可选消息提醒 |
| 处理方式 | SDK 自动生成或读取、开发者传入、用户主动提供、网络传输、本地缓存 | SDK 自动生成或读取、开发者传入、用户主动提供、网络传输、本地缓存 |
| 固定数据 | 系统语言、访客/用户/会话标识、token、聊天消息和交互状态 | 用户/会话标识、token、聊天消息和交互状态；启动上下文由宿主传入 |
| 条件数据 | 姓名、电话、邮箱、描述、标签、自定义字段、来源信息、图片、视频、文件和反馈 | 姓名、电话、邮箱、描述、标签、自定义字段、来源信息、图片、视频、文件和反馈 |
| 权限 | 网络；通知权限为条件项 | 本地通知系统授权为条件项 |

不能使用“SDK 自行采集”概括所有数据来源，也不能写入与当前客服用途无关的广告、画像或变现目的。

## 6. Google Play Data Safety

Google Play 后台应按宿主实际启用能力填写，并计入第三方 SDK 的处理行为。具体规则以 [Google Play Data Safety 官方说明](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)为准。

### 6.1 固定或核心申报

| Google Play 类型 | 条件 | 默认目的 |
| --- | --- | --- |
| User IDs | 用户 ID、访客 ID 或聊天用户 ID 被传输 | App functionality |
| Other in-app messages | 使用聊天功能 | App functionality |
| Device or other IDs | 使用 Android 持久访客标识 | App functionality |

### 6.2 条件申报

| Google Play 类型 | 触发条件 |
| --- | --- |
| Name | 宿主或用户提供姓名 |
| Email address | 宿主或用户提供邮箱 |
| Phone number | 宿主或用户提供电话 |
| Other info | 描述、标签、自定义个人信息或留资字段涉及该类型 |
| Photos / Videos | 用户上传图片或视频 |
| Files and docs | 用户上传文件 |
| Other user-generated content | 用户提交评价、反馈或其他自由输入内容 |
| Browsing history | `sourceURL` 或 referrer 表示用户访问的站外页面 |
| App interactions | 来源值仅表示 App 内页面、路由或功能交互 |
| Diagnostics | 后端保存 IP 或其他数据用于故障诊断 |
| Approximate location | 后端实际通过 IP 推断粗略位置 |

目的默认只选择 `App functionality`。只有后端存在对应处理行为时，才选择 Account management、Analytics、Advertising or marketing、Personalization 等其他目的。

“是否共享”必须根据 SaleSmartly 与宿主之间的 DPA、合同和实际处理角色判断。确认 SaleSmartly 仅按宿主指示作为服务提供商处理数据后，才能适用相应例外；确认前如必须提交，应保守选择 shared。

只有在所有生产 API、Socket、上传、自定义地址和远程媒体地址都强制使用 HTTPS/WSS 后，才能统一回答“传输过程已加密”。当前仍允许宿主配置或服务端下发地址，确认前不得作该承诺。

## 7. Apple Privacy Manifest 与 App Store Connect

Apple 申报应同时覆盖 SDK 自身 `PrivacyInfo.xcprivacy` 和宿主 App Store Connect App Privacy。具体定义以 [Apple App Privacy 官方说明](https://developer.apple.com/app-store/app-privacy-details/)和 [Privacy Manifest 官方说明](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)为准。

### 7.1 固定申报

| Apple 数据类型 | Manifest 标识符 | 配置 |
| --- | --- | --- |
| User ID | `NSPrivacyCollectedDataTypeUserID` | Linked `true`；Tracking `false`；Purpose `App Functionality` |
| Emails or Text Messages | `NSPrivacyCollectedDataTypeEmailsOrTextMessages` | Linked `true`；Tracking `false`；Purpose `App Functionality` |
| Customer Support | `NSPrivacyCollectedDataTypeCustomerSupport` | Linked `true`；Tracking `false`；Purpose `App Functionality` |
| Product Interaction | `NSPrivacyCollectedDataTypeProductInteraction` | Linked `true`；Tracking `false`；Purpose `App Functionality` |

### 7.2 能力相关申报

由于公开 API 和客服流程支持这些数据，iOS SDK 发布包的隐私清单保守包含以下能力类型；宿主 App Store Connect 再按实际启用能力和传入字段核对申报：

- Name：`NSPrivacyCollectedDataTypeName`；
- Email Address：`NSPrivacyCollectedDataTypeEmailAddress`；
- Phone Number：`NSPrivacyCollectedDataTypePhoneNumber`；
- Photos or Videos：`NSPrivacyCollectedDataTypePhotosorVideos`；
- Other User Content：`NSPrivacyCollectedDataTypeOtherUserContent`；
- Other Data Types：`NSPrivacyCollectedDataTypeOtherDataTypes`。

SDK 发布包还保守包含 `NSPrivacyCollectedDataTypeBrowsingHistory`，用于覆盖 `sourceURL` 表示用户访问站外页面的情况。若宿主只传 App 内页面或路由，App Store Connect 应根据实际用途按 Product Interaction 核对，而不能仅依据字段名称判断。

### 7.3 条件申报

- Audio Data：SDK 或宿主实际上传音频；
- Other Diagnostic Data：后端实际保存 IP 或其他数据用于故障诊断；
- Coarse Location：后端实际通过 IP 推断粗略位置；
- Device ID：宿主将 `guestUserId` 定义为安装级设备标识。

上述条件行为一旦成立，必须在发布前同步更新 SDK 隐私清单和宿主 App Store Connect；不能只改宿主后台。随 guest、user、chat 或 token 关联传输的数据保守设置为 Linked `true`、Tracking `false`，目的为 App Functionality。只有经后端事实确认存在其他目的时才调整。

## 8. 发布前待确认项

以下事项在后端、法务或合同事实确认前，不得写成公开承诺：

- IP 是否留存、用途和保存期限；
- 来源 URL、User-Agent 和自定义字段的服务端用途及保存期限；
- 用户数据、会话、消息和附件的保存期限及删除范围；
- 用户访问、更正、删除和撤回同意的受理入口、响应期限和技术链路；
- `mix-ads.oss-accelerate.aliyuncs.com` 对应的阿里云 OSS 处理角色、存储区域、保留期限和合同安排；
- SaleSmartly 是独立处理者、共同处理者，还是仅按宿主指示处理数据的服务提供商；
- 是否存在分析、营销、画像、跨应用跟踪或其他非客服目的；
- 所有生产 API、Socket、SSE、上传、自定义地址和远程媒体地址是否强制 HTTPS/WSS；
- 数据是否全部存储于中国境内，是否发生跨境传输；
- Android 系统备份和 iOS 数据保护策略是否符合产品安全要求。

确认前不得发布以下表述：

- “绝不共享数据”；
- “数据全部存储于中国境内”；
- “所有传输均已加密”；
- “本地缓存均已加密”；
- “调用 `clearUser()` 即可撤回同意并删除全部数据”。

## 9. 发布验收清单

1. 全新安装且未同意隐私政策时，Android 和 iOS 均无 SDK 项目脚本、配置、访客创建、Socket.IO、SSE、HTTP 或上传请求，也不弹出通知权限。
2. 用户明确同意后才调用 `initialize`，拒绝时不初始化；后续冷启动继续遵守宿主保存的有效同意状态。
3. Android 发布 AAR 的合并 Manifest 仅包含 SDK 所需的 `INTERNET` 和条件通知权限，不包含旧 WebView 存储或网络状态权限。
4. Android 在未授予存储权限时，图片、视频和文件选择及上传仍可正常工作。
5. Android 13 及以上的通知权限只在用户主动启用消息提醒或明确通知场景中申请，拒绝后聊天功能仍可用。
6. iOS 发布产物包含 SaleSmartly SDK 自有 `PrivacyInfo.xcprivacy`，Xcode Privacy Report 可识别 `UserDefaults` 和 `CA92.1`。
7. iOS 图片、视频和文件选择不触发完整相册权限；本地通知授权行为与公开说明一致。
8. 抓包核对实际请求 payload、Cookie、源 IP、来源 URL、User-Agent、上传目标及 TLS，确认未传输旧 WebView 页面所列但当前文档未声明的设备信息。
9. 分别验证匿名访客、登录用户、留资、消息、图片、视频、文件、评价、通知启用与通知拒绝场景，并据结果更新条件申报项。
10. 验证 `clearUser()` 后的网络连接、本地缓存和服务端数据状态；在完整撤回与删除能力上线前，文档持续保留其能力边界。
11. SDK 隐私政策、帮助中心、Android Manifest、iOS Privacy Manifest、Google Play、App Store Connect 与实际发布产物采用同一版本口径。

## 10. 默认边界

当前合规口径默认 SDK 不用于广告、用户画像或跨应用跟踪。该默认边界不是对后端事实的替代；一旦后端、宿主配置或后续 SDK 版本出现相关用途，必须在发布前重新完成数据流审计并同步更新全部申报材料。
