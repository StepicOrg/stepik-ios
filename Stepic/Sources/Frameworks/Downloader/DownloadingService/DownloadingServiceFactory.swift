import Foundation

enum DownloadingServiceFactory {
    private static let sharedImageDownloadingService = DownloadingService(
        downloader: Downloader(session: .background(id: "image.main")),
        fileManager: StoredFileManagerFactory.makeStoredFileManager(type: .image)
    )

    static func makeDownloadingService(type: Type) -> DownloadingServiceProtocol {
        switch type {
        case .image:
            return self.sharedImageDownloadingService
        }
    }

    enum `Type` {
        case image
    }
}
