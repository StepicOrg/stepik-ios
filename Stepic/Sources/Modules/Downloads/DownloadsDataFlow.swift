import Foundation

enum Downloads {
    // MARK: Common structs

    struct DownloadsData {
        struct Item {
            let sizeInBytes: UInt64
        }

        let downloadedItemsByCourse: [Course: [Item]]
        let adaptiveCoursesIDs: [Course.IdType]
    }

    // MARK: - Use cases -

    /// Show downloads
    enum DownloadsLoad {
        struct Request { }

        struct Response {
            let data: DownloadsData
        }

        struct ViewModel {
            let downloads: [DownloadsItemViewModel]
        }
    }

    /// Deletes download by id
    enum DeleteDownload {
        struct Request {
            let id: Int
        }

        struct Response {
            let data: DownloadsData
        }

        struct ViewModel {
            let downloads: [DownloadsItemViewModel]
        }
    }
}
