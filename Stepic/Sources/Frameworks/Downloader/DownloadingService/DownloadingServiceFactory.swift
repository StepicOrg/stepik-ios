import Foundation

enum DownloadingServiceFactory {
    enum `Type` {
        case image
    }

    static func makeDownloadingService(type: Type) -> DownloadingServiceProtocol {
        switch type {
        case .image:
            return DownloadingService(
                downloader: Downloader(session: .background(id: "image.main")),
                fileManager: StoredFileManagerFactory.makeStoredFileManager(type: .image)
            )
        }
    }
}
