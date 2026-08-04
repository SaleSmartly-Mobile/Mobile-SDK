# SaleSmartly Android / iOS 原生 SDK 合规配置指引

**更新日期：2026年08月04日**

**适用版本：SaleSmartly Android Native SDK 0.1.0、SaleSmartly iOS Native SDK 0.1.2**

## 一、SaleSmartly 原生 SDK 系统权限与平台配置说明

### Android

| 权限名称 | 权限说明 | 是否必选 | 权限用途 |
| --- | --- | --- | --- |
| `android.permission.INTERNET` 访问网络 | 允许应用访问网络 | 是 | 下载项目配置、创建或恢复客服会话、收发消息以及上传用户主动选择的附件 |
| `android.permission.POST_NOTIFICATIONS` 发送通知 | Android 13 及以上的通知运行时权限 | 否 | 当 SDK 消息提醒配置处于启用状态且系统已授权时展示本地未读消息通知；不影响在线客服、消息收发和附件选择等基础功能 |

上述两个权限会通过 SDK Manifest 合并到宿主应用。SDK 只检查 `POST_NOTIFICATIONS` 的授权状态，不主动发起运行时权限申请。消息提醒配置的默认值为开启；宿主不使用消息提醒时应通过 SDK 配置或接口显式关闭。宿主需要消息提醒时，应在用户同意隐私政策并了解提醒用途后，再根据 Android 系统版本申请通知权限。

图片、视频及文件通过 Android 系统 `OpenDocument` 选择器由用户主动选择，SDK 不需要申请存储、相册、相机或麦克风权限。

### iOS

| 权限或配置名称 | 权限或配置说明 | 是否必选 | 权限或配置用途 |
| --- | --- | --- | --- |
| 本地通知系统授权 | `UserNotifications` 通知授权 | 否 | 在宿主启用消息提醒后展示本地未读消息通知 |
| `NSPrivacyAccessedAPICategoryUserDefaults` | `PrivacyInfo.xcprivacy` Required Reason API，理由代码为 `CA92.1` | 是 | 使用 `UserDefaults` 保存用户、会话及消息连续性所需的本地数据 |

宿主发布 App 前，应确认最终产物中的 `PrivacyInfo.xcprivacy` 包含上述 `UserDefaults / CA92.1` 声明，并可在 Xcode Privacy Report 中识别。

iOS 使用 `PHPickerViewController` 选择图片或视频，使用 `UIDocumentPickerViewController` 选择文件。上述系统选择器只向 SDK 提供用户主动选择的内容，不需要申请完整照片库访问权限，也不需要配置相册、相机或存储用途描述键。

本仓库发布的 iOS 0.1.2 二进制包中，默认通知处理器可能在首次满足未读消息提醒条件时触发通知授权请求。宿主应在用户同意隐私政策且已向用户说明消息提醒用途后再启用通知能力；如需由宿主完全控制授权时机，应在初始化前注入自定义通知处理器。该版本仅使用本地通知，不包含 APNs 注册或远程推送能力。

## 二、基础功能以及相关个人信息

| 功能 | 信息收集字段 | 信息收集目的 |
| --- | --- | --- |
| 初始化与会话建立（基础功能） | Android：SDK 读取系统语言，生成持久访客标识和时间戳，发送固定 User-Agent 字符串 `android`；使用登录身份时，`user_id` 由宿主传入；`chat_user_id` 和会话 token 由服务端返回后由 SDK 缓存。iOS：`guestUserId`、`sourceURL`、`userAgent`、`navigatorLanguage`、`beforeSourceURL` 由宿主传入，消息标识和时间戳由 SDK 生成，`chat_user_id` 和会话 token 由服务端返回后由 SDK 缓存。两端网络连接建立时服务端会获得源 IP 地址 | 下载项目配置，创建或恢复访客身份，建立客服消息连接并保持会话连续性 |
| 在线客服消息（基础功能） | 终端用户发送的文本消息、消息发送方、消息时间、已读状态、撤回状态及消息交互状态 | 向客服发送咨询内容、接收客服回复并展示会话记录 |
| 本地会话连续性（基础功能） | Android 使用名为 `salesmartly_chat` 的应用私有、未加密 `SharedPreferences`，保存登录用户标识、持久访客标识、项目标识、token、客服会话标识、用户记录、未读数及每个会话最多 400 条消息；iOS 使用未加密 `UserDefaults` 保存或缓存用户、会话、token、用户记录及部分消息内容和状态 | 读取访客会话及消息缓存以保持会话连续性；登录身份仍需宿主在后续启动时重新设置 |

iOS 的 `guestUserId`、来源页面、User-Agent、语言和 referrer 由宿主通过初始化上下文传入，不属于 SDK 自动读取的信息。Android 的来源页面或应用路由仅在宿主调用 `trackUrl` 等接口提供后处理。

SDK 不调用平台广告标识符、硬件设备标识符、定位、通讯录或剪贴板接口。开发者仍应检查传入的自定义字段，不得通过自定义字段传输未向用户披露的信息。

网络连接会使服务端获得源 IP 地址。源 IP 是否留存、保存期限以及是否用于安全审计、故障诊断或地域判断，应由开发者根据实际服务端处理情况在隐私政策中补充说明。

## 三、可选功能以及相关个人信息

| 功能 | 信息收集字段 | 信息收集目的 |
| --- | --- | --- |
| 设置用户信息 | Android：`user_id`、`user_name`、`language`、`phone`、`email`、`description`、`label_names`、`custom_fields_ext`；iOS：`userId`、`userName`、`language`、`phone`、`email`、`description`、`labelNames`、`customFieldsExt`；以及宿主通过 `setUserInfo` 传入的业务字段 | 识别登录用户，为客服提供与当前咨询相关的用户信息 |
| 留资功能 | 终端用户主动填写的姓名、邮箱、电话、公司、区号以及项目配置的自定义表单字段 | 在客服在线或离线场景中收集联系信息并进行后续服务 |
| 来源页面或应用路由 | Android：宿主通过 `trackUrl` 提供的页面 URL 或应用路由，User-Agent 固定为 `android`，不接收独立 referrer；iOS：宿主传入的 `sourceURL`、`beforeSourceURL`、`userAgent`、`navigatorLanguage`、`trackUrl` 或其他来源上下文 | 帮助客服了解用户发起咨询的页面或应用场景 |
| 图片、视频及文件消息 | 用户通过系统选择器主动选择的图片、视频或文件内容，以及文件名称、类型和大小 | 在客服会话中发送多类型附件，提高沟通效率 |
| 评价与反馈 | 终端用户主动提交的评分、评价内容、反馈或点赞操作 | 收集用户对客服服务或消息内容的评价 |
| 本地消息提醒 | SDK 消息提醒配置、未读消息状态及本地通知内容；系统通知授权属于平台权限处理，不作为客服业务数据上传 | 当消息提醒配置处于启用状态、系统允许通知且聊天窗口不可见时提示用户查看新消息 |

未启用对应功能或用户未主动提交时，SDK 不处理该项可选信息。动态自定义字段和用户选择的任意文件必须按照其实际内容确定个人信息类型；例如文件中包含音频时，开发者应补充音频数据相关披露。

## 四、初始化步骤

**重要**

SDK 不保存宿主应用的隐私同意状态。使用 script URL 初始化时，SDK 会先下载并解析宿主提供的项目脚本；使用 config 初始化时，SDK 会直接使用宿主配置。随后 SDK 会读取本地会话缓存、请求项目配置信息，并可能创建或恢复访客身份，建立 HTTP、Socket.IO、iOS SSE 或轮询连接。因此，不能在取得用户同意前预初始化 SDK。

1. App 首次冷启动时，应先向用户展示隐私政策和第三方 SDK 清单。只有在用户明确同意后，才可以调用 Android `SalesmartlyChat.initialize(...)` 或 iOS `SalesmartlyChat.initialize(...)`；用户拒绝时不得初始化。
2. App 后续冷启动时，宿主应先确认用户的隐私同意状态仍然有效，再按业务需要调用初始化方法。用户撤回同意后，不得再次初始化 SDK。
3. 通知权限应与 SDK 初始化分开处理。Android SDK 不主动申请通知权限；使用本仓库发布的 iOS 0.1.2 默认通知处理器时，应确保用户已同意隐私政策并了解消息提醒用途，如需由宿主显式申请权限，应在初始化前注入自定义通知处理器。

`clearUser()` 用于切换 SDK 中的用户身份，不等同于撤回隐私同意、清除全部本地缓存或删除服务端数据，开发者不得将其作为个人信息撤回或删除接口进行说明。

具体接入方式请参阅 [Android SDK 接入说明](../android/README.md)和 [iOS SDK 接入说明](../ios/README.md)。

## 五、App 隐私政策披露要求与模板

开发者在 App 中集成 SaleSmartly 原生 SDK 后，应在隐私政策或第三方 SDK 清单中披露 SDK 名称、提供方、使用目的、处理的个人信息类型、所需权限、处理方式、官网链接和隐私政策链接。请根据实际接入平台、SDK 版本、启用功能和传入字段调整内容，不应披露未启用的可选功能。

开发者通过 `setUserInfo`、自定义字段、留资表单或来源上下文传入的信息，应按照字段的实际含义逐项披露。页面 URL 表示用户访问的网页时，还应根据实际用途披露相关浏览记录。服务端保存期限、数据删除方式、共享关系以及源 IP 的具体用途，应以实际合同和服务配置为准。

### Android 披露示例

以下内容仅供参考，请以实际合作和接入情况为准：

```text
SDK 名称：SaleSmartly Android Native SDK
SDK 公司名称：广州标品软件有限公司
SDK 使用目的和功能场景：为终端用户提供在线客服、消息会话、用户主动附件上传和可选的本地消息提醒
SDK 收集个人信息类型：SDK 自动生成或读取的持久访客标识、系统语言和消息时间戳；服务端返回后由 SDK 缓存的客服会话标识和会话 token；开发者按实际传入的用户标识、姓名、电话、邮箱、描述、标签、自定义字段和来源页面信息；终端用户主动提交的聊天内容、留资信息、评价、图片、视频和文件；网络连接信息（源 IP 地址）
实现 SDK 功能所需权限：android.permission.INTERNET；启用消息提醒时使用 android.permission.POST_NOTIFICATIONS（Android 13 及以上）
收集方式：SDK 自动生成或读取、服务端返回、开发者传入、终端用户主动提供、网络传输及应用私有但未加密的 SharedPreferences 本地存储
官网链接：https://www.salesmartly.com
隐私政策链接：https://www.salesmartly.com/privacy_policy/
```

### iOS 披露示例

以下内容仅供参考，请以实际合作和接入情况为准：

```text
SDK 名称：SaleSmartly iOS Native SDK
SDK 公司名称：广州标品软件有限公司
SDK 使用目的和功能场景：为终端用户提供在线客服、消息会话、用户主动附件上传和可选的本地消息提醒
SDK 收集个人信息类型：宿主传入的访客/用户标识、来源页面、User-Agent、语言和 referrer，客服会话标识、会话 token、聊天内容、消息时间及交互状态、网络连接信息（源 IP 地址）；开发者按实际传入的姓名、电话、邮箱、描述、标签和自定义字段；终端用户主动提交的留资信息、评价、图片、视频和文件
实现 SDK 功能所需权限或配置：启用本地消息提醒时使用通知系统授权；PrivacyInfo.xcprivacy 声明 UserDefaults Required Reason CA92.1；图片、视频和文件选择不需要完整照片库访问权限
收集方式：开发者传入、终端用户主动提供、服务端返回、SDK 网络传输、SDK 本地生成消息标识和时间戳，以及 UserDefaults 本地存储
官网链接：https://www.salesmartly.com
隐私政策链接：https://www.salesmartly.com/privacy_policy/
```
