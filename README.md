# SaleSmartly Mobile SDK

SaleSmartly 移动端 SDK 发布仓库，用于存放 Android / iOS SDK 发布产物与 Demo。

当前已提供 Android SDK 文件、Demo APK、iOS SDK 二进制包和 iOS Demo 示例工程。

## Android

- 当前版本：SDK `1.0.3`，Demo `1.0.0`（minSdk `23`）
- [Android 接入说明](android/README.md)
- [下载 Demo APK](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/main/android/demo/salesmartly-chat-android-demo-v1.0.0.apk)
- [下载 SDK AAR](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/1.0.3/android/sdk/salesmartly-chatwidget-sdk-v1.0.3.aar)
- [查看 Android Demo 源码](android/demo/demo-source)

## iOS

- 当前版本：`1.0.3`（2026-09-22 自定义渠道图标修订，iOS 15.0+）
- SDK 不提供默认聊天入口或 Launcher；宿主需使用自定义按钮调用 `SalesmartlyChat.openChat()` 打开聊天
- [iOS 接入说明](ios/README.md)
- SwiftPM 仓库地址：`https://github.com/SaleSmartly-Mobile/Mobile-SDK`
- [下载 SDK ZIP](https://raw.githubusercontent.com/SaleSmartly-Mobile/Mobile-SDK/3ff97f974025b9045e68a6725fe6a1122818d4fe/ios/sdk/salesmartly-chat-ios-sdk-v1.0.3.zip)
- [查看 iOS Demo 源码](ios/demo/demo-source)

## 1.0.3 更新与升级

- Android / iOS 修复客服首页已配置渠道被侧边栏设置隐藏的问题，首页显示条件与 Web SDK 保持一致。
- iOS 同版本修订补齐首页自定义渠道的 `entry_url` 图片渲染。ZIP 文件名和 SDK 版本号仍为 `1.0.3`，请使用上方新的固定提交下载链接；原 `1.0.3` 标签保留旧包。
- iOS 使用 SwiftPM 指定本次修订提交，或完整替换 XCFramework；Android 替换新版 AAR 并更新依赖文件名，具体步骤见两端接入说明。
- 现有初始化和聊天入口 API 保持不变。接入方需重新构建并发布 App，已安装的 App 不会因仓库更新而自动生效。
- Android Demo 源码已引用新版 AAR；下载区现有 Demo APK 仍为历史 1.0.0，验证本次修复请使用新版 SDK 或自行构建 Demo。

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
```
