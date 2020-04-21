import Foundation

enum DownloadARQuickLook {
    enum StartDownload {
        struct Request {}
    }

    enum CancelDownload {
        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum CompleteDownload {
        struct Response {}

        struct ViewModel {}
    }

    enum FailDownload {
        struct Response {
            let error: Error
        }

        struct ViewModel {}
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
