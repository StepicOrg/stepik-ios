import Foundation

enum DownloadingServiceFactory {
    private static let sharedImageDownloadingService = DownloadingService(
        downloader: Downloader(session: .foreground),
        fileManager: StoredFileManagerFactory.makeStoredFileManager(type: .image)
    )

    static func makeDownloadingService(type: Type) -> DownloadingServiceProtocol {
        switch type {
        case .image:
            return self.sharedImageDownloadingService
        case .arQuickLook:
            return DownloadingService(
                downloader: Downloader(session: .foreground),
                fileManager: StoredFileManagerFactory.makeStoredFileManager(type: .arQuickLook)
            )
        }
    }

    enum `Type` {
        case image
        case arQuickLook
    }
}
