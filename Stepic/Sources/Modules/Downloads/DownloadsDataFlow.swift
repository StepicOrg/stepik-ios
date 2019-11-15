import Foundation

enum Downloads {
    // MARK: Common structs

    struct DownloadsData {
        struct Item {
            let sizeInBytes: UInt64
        }

        let downloadedItemsByCourse: [Course: [Item]]
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
}
