import Foundation

enum DownloadARQuickLook {
    enum StartDownload {
        struct Request {}
    }

    enum DownloadProgressUpdate {
        struct Response {
            let progress: Float
        }

        struct ViewModel {
            let progress: Float
        }
    }
}
