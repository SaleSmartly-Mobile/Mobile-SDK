#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

/// 对齐 widget main:src/components/Launcher/index.vue 的宿主容器语义，供 UIKit App 以原生 UIViewController 方式承载 iOS SDK。
public final class SalesmartlyChatViewController: UIViewController {
    /// 对齐 widget main:src/App.vue 的运行时编排实例，UIKit 与 SwiftUI Host 共享同一 runtime。
    public let runtime: SalesmartlyRuntime
    private let hostingController: UIHostingController<SalesmartlyChatHost>
    /// 对齐 widget main:src/App.vue 的 showWrapper 关闭态，UIKit presented 场景需要在 closeWindow 后同步 dismiss。
    private var closeObservationId: Int?
    /// 对齐 showWrapper 从 true 到 false 的边沿检测，避免初始化时误触发 dismiss。
    private var previousShowWrapper: Bool

    /// 对齐 widget main:src/install/runInstall.ts 的单实例挂载语义，默认承载全局 runtime，也允许宿主注入同一会话实例。
    public init(runtime: SalesmartlyRuntime = SalesmartlyChat.runtime()) {
        self.runtime = runtime
        self.hostingController = UIHostingController(rootView: SalesmartlyChatHost(runtime: runtime))
        self.previousShowWrapper = runtime.state.showWrapper
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// 对齐 widget main:src/App.vue 的根视图挂载，将 SwiftUI Host 铺满 UIKit 容器视图。
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
        startObservingCloseState()
    }

    /// 对齐 widget main:src/App.vue 的关闭状态监听释放，Swift 6 真机构建下保持 UIKit 主线程生命周期隔离。
    isolated deinit {
        if let closeObservationId {
            runtime.removeStateObserver(closeObservationId)
        }
    }

    /// 对齐 widget main:src/App.vue 的 closeWindow，SwiftUI close 后 presented UIKit 容器自动退出全屏承载层。
    private func startObservingCloseState() {
        closeObservationId = runtime.observeState { [weak self] state in
            let showWrapper = state.showWrapper
            Task { @MainActor in
                guard let self else {
                    return
                }
                let shouldDismiss = self.previousShowWrapper && !showWrapper && self.presentingViewController != nil
                self.previousShowWrapper = showWrapper
                if shouldDismiss {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
#endif
