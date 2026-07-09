import Foundation

/// 对齐 Android `enqueueFileDownload` 与 Web `FileMessage.vue` 的 `saveAs`：接收换签后的 URL 并保存文件。
protocol SalesmartlyFileDownloading: AnyObject {
    /// 对齐 Android `DownloadManager.Request.setTitle(fileName)`，系统下载任务使用文件名作为保存名。
    func downloadFile(urlString: String, fileName: String)
}

/// 对齐 Android `DownloadManager` 的原生下载入口；iOS 保存到 Documents，macOS 保存到 Downloads。
final class SalesmartlySystemFileDownloader: SalesmartlyFileDownloading, @unchecked Sendable {
    static let shared = SalesmartlySystemFileDownloader()

    private let fileManager: FileManager
    private let session: URLSession

    init(fileManager: FileManager = .default, session: URLSession = .shared) {
        self.fileManager = fileManager
        self.session = session
    }

    func downloadFile(urlString: String, fileName: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        let task = session.downloadTask(with: url) { [weak self] temporaryURL, _, _ in
            guard let self, let temporaryURL else {
                return
            }
            let destinationURL = self.destinationURL(fileName: fileName)
            try? self.fileManager.copyItem(at: temporaryURL, to: destinationURL)
        }
        task.resume()
    }

    private func destinationURL(fileName: String) -> URL {
        let directoryURL = destinationDirectoryURL()
        let sourceURL = URL(fileURLWithPath: fileName)
        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        let pathExtension = sourceURL.pathExtension
        var candidateURL = directoryURL.appendingPathComponent(fileName)
        var index = 1
        while fileManager.fileExists(atPath: candidateURL.path) {
            let nextFileName = pathExtension.isEmpty ? "\(baseName)-\(index)" : "\(baseName)-\(index).\(pathExtension)"
            candidateURL = directoryURL.appendingPathComponent(nextFileName)
            index += 1
        }
        return candidateURL
    }

    private func destinationDirectoryURL() -> URL {
        #if os(macOS)
        fileManager.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        #else
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
    }
}
