import Foundation

enum RestorableBackgroundDownloaderError: Error {
    case invalidTask
}

protocol RestorableBackgroundDownloaderProtocol: DownloaderProtocol {
    var id: String? { get }
    var restoredTasks: [DownloaderTaskProtocol] { get }

    func resumeRestoredTasks()
}
