import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif
#if canImport(AudioToolbox)
import AudioToolbox
#endif

/// 对齐 Android 默认通知/声音处理器与 widget main:src/helper/useNotification.ts，未注入宿主处理器时由 iOS 系统本地通知和系统声音承担提醒。
public final class SalesmartlyDefaultNotificationHandler: SalesmartlyNotificationHandling {
    public init() {}

    /// 对齐 widget Notification.permission：iOS 首次请求权限时同步返回 `default`，异步授权结果由系统维护。
    public func requestUnreadNotificationPermission(currentStatus: String) -> String {
        #if os(iOS) && canImport(UserNotifications)
        if currentStatus == "granted" || currentStatus == "denied" {
            return currentStatus
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        return currentStatus.isEmpty ? "default" : currentStatus
        #else
        return currentStatus.isEmpty ? "default" : currentStatus
        #endif
    }

    /// 对齐 widget `new Notification`，iOS 使用本地通知展示未读提醒。
    public func showUnreadNotification() {
        #if os(iOS) && canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        content.title = "Salesmartly"
        content.body = "You have a new message"
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "salesmartly.unread.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
        #endif
    }

    /// 对齐 widget `soundElem.play()` 与 Android 默认声音提示，iOS 使用系统声音。
    public func playUnreadSound() {
        #if os(iOS) && canImport(AudioToolbox)
        AudioServicesPlaySystemSound(1007)
        #endif
    }

    /// 对齐 widget `focusParentWindow/window.focus`；SDK 默认处理器无宿主窗口引用，因此保留为空操作，宿主可注入自定义实现。
    public func focusNotificationTarget() {}

    /// 对齐 widget Notification click 后 close；iOS 本地通知由系统管理，默认处理器无待关闭实例。
    public func closeUnreadNotification() {}
}
