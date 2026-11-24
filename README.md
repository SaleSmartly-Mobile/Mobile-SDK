# SaleSmartly Mobile SDK

SaleSmartly 移动端 SDK 发布仓库，用于存放 Android / iOS SDK 发布产物与 Demo。

当前已提供 Android SDK 文件、Demo APK、iOS SDK 二进制包和 iOS Demo 示例工程。

## Android

- 本次发布 SDK `1.1.1`（2026-11-19，minSdk `23`）。Demo 源码使用 `1.1.1`，公开 Demo APK `1.0.0` 使用 SDK `1.0.3`。
- [Android 接入说明](android/README.md)
- [Android API 参考](docs/android-api.md)
- [下载 Demo APK](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/8a57a19f19abe8ee72feb471004217c38ef4ba19/android/demo/salesmartly-chat-android-demo-v1.0.0.apk)
- [下载 SDK 1.1.1 AAR](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/130179239110d014a5e446acffdcc051efa56f52/android/sdk/salesmartly-chatwidget-sdk-v1.1.1.aar)
- [查看 Android Demo 源码](android/demo/demo-source)

## iOS

- 本次发布 SDK `1.1.1`（2026-11-19，iOS 15.0+）。Demo 源码使用 `1.1.1`。
- SDK 不提供默认聊天入口或 Launcher；宿主需使用自定义按钮调用 `SalesmartlyChat.openChat()` 打开聊天
- [iOS 接入说明](ios/README.md)
- [CocoaPods 安装](ios/README.md#cocoapods)
- [iOS API 参考](docs/ios-api.md)
- SwiftPM 仓库地址：`https://github.com/SaleSmartly-Mobile/Mobile-SDK`
- [下载 SDK 1.1.1 ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/130179239110d014a5e446acffdcc051efa56f52/ios/sdk/salesmartly-chat-ios-sdk-v1.1.1.zip)
- [查看 iOS Demo 源码](ios/demo/demo-source)

## 2026-11-24 · 1.2.0 发送成功日志修订

Android 和 iOS SDK 在 Socket.IO、普通 HTTP 和 SSE 发送获得业务成功确认后，通过现有客户端日志入口记录发送统计。同一发送的重复确认和重试不会重复上报。

SDK 版本为 `1.2.0`，本次修订的源码标签为 `v1.2.0-send-log-r1`。产物固定在提交 `347ccdf6d1bcdb07a9161f250d20340665bce318`。

- [Android AAR](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/android/sdk/salesmartly-chatwidget-sdk-v1.2.0-send-log-r1.aar) · [校验清单](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/android/sdk/salesmartly-chatwidget-sdk-v1.2.0-send-log-r1.manifest.json)
- [iOS XCFramework ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0-send-log-r1.zip) · [校验清单](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/347ccdf6d1bcdb07a9161f250d20340665bce318/ios/sdk/salesmartly-chat-ios-sdk-v1.2.0-send-log-r1.manifest.json) · [CocoaPods podspec](ios/sdk/SalesmartlyChat-1.2.0-send-log-r1.podspec)

## 2026-11-19 · 1.1.x 维护更新

- 修复 SS-434。Android 留资与 iOS 留资、促销卡支持邮箱用户名中连续出现的连字符。
- `1.1.1` 基于 `1.1.x` 维护线。发送请求沿用该分支的载荷，不再自动附加 `sdk_platform` 和 `host_app`。需要继续使用 `1.2.0` 的接入方可保留已有固定依赖。
- Android 669 项 JVM 单测、SDK 和示例 Release/R8、分发 Demo Debug 构建通过。iOS 6 项定向测试、设备及双架构模拟器 Release、三架构消费检查、SwiftPM 解析和分发 Demo 模拟器构建通过。
- 两端产物固定在提交 `130179239110d014a5e446acffdcc051efa56f52`。源码提交、字节数及 SHA-256 见各端接入说明。

## 2026-11-17 更新

- Android、iOS SDK `1.2.0` 在 Socket.IO、普通 HTTP 和 SSE 会话的 HTTP 发送请求中携带 `sdk_platform` 和 `host_app`，供后台按平台和宿主归属统计发送量。接入方继续使用现有的发送接口。
- Android 669 项 SDK 单测、SDK 与示例 Release/R8、分发 Demo Debug 构建通过。iOS 16 项定向测试、设备与模拟器 Release、三架构消费检查、SwiftPM 解析和分发 Demo 构建通过。
- SaleSmartly App `5.3.5+549` 的 Android 桥接与 APK、iOS arm64 模拟器宿主已验证实际嵌入 `1.2.0`。
- 两端包固定到提交 `86d1cf20279209b0feb0e120434870e60a33c367`。源码提交、大小及 SHA-256 见各端接入说明。公开 Android Demo APK 仍使用 SDK `1.0.3`，两端 Demo 源码使用 `1.2.0`。

## 2026-11-16 更新

- Android、iOS `1.1.0` 在普通视频、视频图文和模板视频的预览页增加保存到系统相册入口；保存中禁止重复点击，完成后显示成功、失败或权限提示。现有公开 API 和消息协议保持不变。
- Android 6–9（API 23–28）在用户点击保存时申请 `WRITE_EXTERNAL_STORAGE`；Android 10（API 29）及以上使用 MediaStore，无需读取图库权限。iOS 仅申请新增相册内容权限，宿主须配置 `NSPhotoLibraryAddUsageDescription`，示例见 [iOS 接入说明](ios/README.md#视频保存到相册权限)。
- 固定产物提交为 `cdcb8d3a4aeb8389980398dff84a93e7941a57c2`；两端源码提交、文件大小和 SHA-256 见接入说明。旧包与历史链接保留，公开 Android Demo APK 仍使用 SDK `1.0.3`；两端 Demo 源码均已使用 `1.1.0`。
- Android 668 项 JVM 单测、9 项 API 36 模拟器视频保存服务与 UI 测试，以及 SDK / 示例 Release、R8、Maven 元数据和分发 Demo 构建通过。
- iOS 4 项视频下载与保存服务测试、普通视频 / 视频图文 / 模板视频入口及权限拒绝 UI 验证、8 项版本测试和 1 项文案测试通过；三个架构的 Release、解包后二进制消费类型检查、dSYM UUID / 资源 / 许可证核验、SwiftPM 解析及分发 Demo 构建通过。这是本功能的定向验证，未执行全量 iOS 回归。
- 本批未执行物理真机、Android 6–9 相册运行、最低 iOS 15 设备、线上真实客服会话或分发 Demo UI 验证。

## 2026-11-04 更新

- Android `1.0.6`、iOS `1.0.7` 新增 `sendAttachment`：宿主完成截图提示、预览确认或本地日志选择后，将本地文件及明确的图片 / 文件类型交给 SDK，直接打开聊天、上传并发送，不再二次预览。
- 单文件上限为 20 MiB；最终结果以服务端 ACK 或匹配消息 ID 的回显为准，上传完成不等于发送成功。支持同消息重试、身份切换取消、关窗保留任务；180 秒总超时在留资等待期间暂停。截图检测、日志查找、打包与脱敏由宿主完成。
- 固定产物提交为 `b8defdc91e4bdcdc74389c54aefa3dbfc1a84d28`；两端溯源清单、大小和 SHA-256 见接入说明。旧包、历史链接和公开 Demo APK 保留；Demo 源码已使用新包。
- Android 663 项单测、4 项 Android 16 模拟器附件与宿主生命周期测试，以及正式 SDK / 示例 Release、R8、Maven 元数据和分发 Demo 构建通过。
- iOS 295 项 SwiftPM 回归、2 项 iOS 27 App 宿主交互测试通过；设备 arm64、模拟器 arm64 / x86_64 的 Release、新 API 消费类型检查、dSYM / 资源核验、SwiftPM 解析及分发 Demo 构建通过。
- 宿主交互使用模拟器与测试传输实现验证；本批未执行物理真机或线上真实客服会话测试。

## 2026-10-26 更新

- Android `1.0.5`、iOS `1.0.6` 修复会话恢复与后台自动重连：后台暂停自动重试、轮询和心跳，回前台按已有会话恢复，保留用户发送及回包。
- iOS 作废后台迟到的 token / SSE 打开回调，避免重新建流；重复前台通知不重复补拉或绕过退避，入房成功清除旧会话错误。
- 保留 `phase`、`operation`、`code`、`message`，增加可选脱敏诊断 `native_error_code`、`http_status`、`is_transient`。宿主可据此区分明确瞬时网络失败；TLS、DNS、HTTP、解析和未知故障不应被整体忽略。
- 固定产物提交为 `d98a52d9fc30dd1f094bfb05d69466d2b220f653`。两端溯源清单、文件大小和 SHA-256 见对应接入说明；旧包与历史链接继续保留，需重新构建宿主 App 才会生效。
- Android 641 项单测、2 项 Android 16 模拟器 HTTP/SSE/TLS 与 Compose 生命周期恢复测试，以及 SDK / 示例 release、R8 构建通过。iOS 恢复代码的 276 项 SwiftPM 测试、24 项 iOS 27 模拟器恢复测试及 8 项版本相关测试通过，无相关失败或跳过。
- iOS 断网场景通过 URLSession / URLProtocol 故障注入，生命周期通知在模拟器执行；Android 网络测试使用本地故障服务器。本批未执行真机飞行模式或真实客服会话验证。
- iOS 设备与模拟器三个架构的 Release 构建、Swift 消费类型检查、UUID / 资源核验通过；根 SwiftPM 解析及两端 Demo 源码消费新版包构建通过。公开 Android Demo APK 仍使用 SDK `1.0.3`，未替换原包。

## 2026-10-19 更新

- Android `1.0.4`、iOS `1.0.5` 补齐引用图片点击预览：普通图片、图文图片和搜同款引用加载成功后打开原图，加载中或失败时不打开预览。
- iOS 修复长文字消息超出气泡宽度后显示不全的问题，并保留文字选区和复制功能。现有初始化及聊天入口 API 保持不变。
- 本次 SDK 固定发布提交为 `14db64bf52b33052b55fbb77aaaa30664e86efc1`；源提交、文件大小与 SHA-256 见两端接入说明。旧包和历史固定链接继续保留，接入方需更新依赖并重新构建 App。
- Android 636 项单测、6 项 API 36 模拟器真实触控回归、Release AAR 和示例 R8 构建通过。iOS App 宿主中 6 项引用图片与文字回归通过，另有 7 项图片管线与媒体测试、3 项版本断言通过；引用图片通过 SwiftUI 无障碍激活动作验证，未执行真机手势或 XCUITest 触控。
- iOS 三个架构的 Release 构建与二进制接入类型检查、两端 Demo 源码的新依赖构建及根 SwiftPM 解析通过。本次未运行 Demo UI，也未执行真机或真实客服会话回归；公开 Android APK 仍保留原包，可从 Demo 源码构建验证新 SDK。

## 2026-10-16 同版本修订

- Android `1.0.3`、iOS `1.0.4` 均从各自最新 `main` 构建，版本号和文件名保持不变；下载后请核对两端接入说明中的 SHA-256，并重新构建宿主 App。
- 图片加载分别接入 Coil `3.4.0` 与 Nuke `12.8.0`，按显示尺寸降采样，并复用图片下载和缓存。Android 手动引入 AAR 时须补充 `coil-compose-core`、`coil-network-okhttp` 两项依赖；iOS 已将 Nuke 封装在 SDK 中，无需单独安装。
- 调整顶部栏安全区、主行与渠道行叠层及圆角阴影，补齐评价完成后的感谢插图和布局。
- iOS 在语音首次播放前显示时长，纯音轨 MP4 预览隐藏系统占位图并保留播放控件；两端补齐失败媒体的可点击反馈。
- 公开接口保持不变。Android Demo 已使用本次新版 AAR 重建，继续使用 `1.0.0` 版本号。
- Android 636 项单测、Release AAR 和 R8 构建通过；iOS 269 项单测、三个架构的 Release 构建及二进制接入类型检查通过，资源、dSYM 和许可证已核验。本次未执行真机运行或真实客服会话回归。

## 历史更新：iOS 1.0.4（2026-09-24）

- 增加 Ogg/Opus 语音解码，并支持长按文字消息后拖动选区、仅复制选中文字。
- 已使用早期 `1.0.4` 包的项目也需更新产物并重新构建 App；当前接入方式及固定提交见 [iOS 接入说明](ios/README.md)。

## 历史更新：1.0.3

- Android / iOS 修复客服首页已配置渠道被侧边栏设置隐藏的问题，首页显示条件与 Web SDK 保持一致。
- iOS `1.0.3` 同版本修订补齐首页自定义渠道的 `entry_url` 图片渲染，原 `1.0.3` 标签保留修订前的包；当前下载入口已更新到包含该修复的 `1.0.4`。
- iOS 使用 SwiftPM 指定本次修订提交，或完整替换 XCFramework；Android 替换新版 AAR 并更新依赖文件名，具体步骤见两端接入说明。
- 现有初始化和聊天入口 API 保持不变。接入方需重新构建并发布 App，已安装的 App 不会因仓库更新而自动生效。
- Android Demo 源码引用 SDK `1.0.3`；Demo APK 的构建信息和校验值见 [Android 接入说明](android/README.md)。

## 目录结构

```text
Package.swift
docs/
  android-api.md
  ios-api.md
android/
  README.md
  demo/
    salesmartly-chat-android-demo-v1.0.0.apk
    demo-source/
  sdk/
    salesmartly-chatwidget-sdk-v0.1.0.aar
    salesmartly-chatwidget-sdk-v1.0.0.aar
    salesmartly-chatwidget-sdk-v1.0.1.aar
    salesmartly-chatwidget-sdk-v1.0.3.aar
    salesmartly-chatwidget-sdk-v1.0.4.aar
    salesmartly-chatwidget-sdk-v1.0.5.aar
    salesmartly-chatwidget-sdk-v1.0.6.aar
    salesmartly-chatwidget-sdk-v1.1.0.aar
    salesmartly-chatwidget-sdk-v1.1.0.manifest.json
    salesmartly-chatwidget-sdk-v1.1.1.aar
    salesmartly-chatwidget-sdk-v1.1.1.manifest.json
ios/
  README.md
  demo/
    demo-source/
  sdk/
    salesmartly-chat-ios-sdk-v0.1.0.zip
    salesmartly-chat-ios-sdk-v0.1.1.zip
    salesmartly-chat-ios-sdk-v0.1.2.zip
    salesmartly-chat-ios-sdk-v0.1.3.zip
    salesmartly-chat-ios-sdk-v0.1.4.zip
    salesmartly-chat-ios-sdk-v1.0.0.zip
    salesmartly-chat-ios-sdk-v1.0.1.zip
    salesmartly-chat-ios-sdk-v1.0.2.zip
    salesmartly-chat-ios-sdk-v1.0.3.zip
    salesmartly-chat-ios-sdk-v1.0.4.zip
    salesmartly-chat-ios-sdk-v1.0.5.zip
    salesmartly-chat-ios-sdk-v1.0.6.zip
    salesmartly-chat-ios-sdk-v1.0.7.zip
    SalesmartlyChat-1.0.7.podspec
    salesmartly-chat-ios-sdk-v1.1.0.zip
    salesmartly-chat-ios-sdk-v1.1.0.manifest.json
    SalesmartlyChat-1.1.0.podspec
    salesmartly-chat-ios-sdk-v1.1.1.zip
    salesmartly-chat-ios-sdk-v1.1.1.manifest.json
    SalesmartlyChat-1.1.1.podspec
```
