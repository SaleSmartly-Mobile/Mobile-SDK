# SaleSmartly Mobile SDK

SaleSmartly 移动端 SDK 发布仓库，用于存放 Android / iOS SDK 发布产物与 Demo。

当前已提供 Android SDK 文件、Demo APK、iOS SDK 二进制包和 iOS Demo 示例工程。

## Android

- 当前版本：SDK `1.0.4`（2026-10-19），公开 Demo APK `1.0.0` 仍使用 SDK `1.0.3`（minSdk `23`）；Demo 源码已更新到 SDK `1.0.4`
- [Android 接入说明](android/README.md)
- [下载 Demo APK](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/8a57a19f19abe8ee72feb471004217c38ef4ba19/android/demo/salesmartly-chat-android-demo-v1.0.0.apk)
- [下载 SDK AAR](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/14db64bf52b33052b55fbb77aaaa30664e86efc1/android/sdk/salesmartly-chatwidget-sdk-v1.0.4.aar)
- [查看 Android Demo 源码](android/demo/demo-source)

## iOS

- 当前版本：`1.0.5`（2026-10-19，iOS 15.0+）
- SDK 不提供默认聊天入口或 Launcher；宿主需使用自定义按钮调用 `SalesmartlyChat.openChat()` 打开聊天
- [iOS 接入说明](ios/README.md)
- SwiftPM 仓库地址：`https://github.com/SaleSmartly-Mobile/Mobile-SDK`
- [下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/14db64bf52b33052b55fbb77aaaa30664e86efc1/ios/sdk/salesmartly-chat-ios-sdk-v1.0.5.zip)
- [查看 iOS Demo 源码](ios/demo/demo-source)

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
```
