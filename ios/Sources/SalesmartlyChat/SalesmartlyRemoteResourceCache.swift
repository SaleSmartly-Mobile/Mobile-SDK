import Foundation

/// 对齐 widget main 浏览器资源复用体验与 Android `RemoteResourceCache<T>`，按 URL 缓存远程图片、头像和媒体首帧等资源。
actor SalesmartlyRemoteResourceCache<Value: Sendable> {
    private let maxEntries: Int
    private var values: [String: Value] = [:]
    private var order: [String] = []
    private var loading: [String: (id: UUID, task: Task<Value?, Never>)] = [:]

    /// 对齐 Android `RemoteResourceCache(maxEntries)`，限制内存中保留的资源数量。
    init(maxEntries: Int) {
        self.maxEntries = maxEntries
    }

    /// 对齐 Android `getOrLoad(key, loader)`：命中缓存直接返回，同一 URL 并发加载共享同一个任务。
    func getOrLoad(key: String, loader: @escaping @Sendable () async -> Value?) async -> Value? {
        if let cached = values[key] {
            touch(key)
            return cached
        }

        if let running = loading[key] {
            let loaded = await running.task.value
            if let cached = values[key] {
                touch(key)
                return cached
            }
            return loaded
        }

        let loadId = UUID()
        let task = Task {
            await loader()
        }
        loading[key] = (loadId, task)

        let loaded = await task.value
        if let current = loading[key], current.id == loadId {
            loading[key] = nil
            if let loaded {
                store(loaded, for: key)
            }
        }

        if let cached = values[key] {
            touch(key)
            return cached
        }
        return loaded
    }

    private func store(_ value: Value, for key: String) {
        values[key] = value
        touch(key)
        while order.count > maxEntries {
            let oldest = order.removeFirst()
            values[oldest] = nil
        }
    }

    private func touch(_ key: String) {
        order.removeAll { $0 == key }
        order.append(key)
    }
}
