import Foundation
import PromiseKit

protocol DownloadsDeletionServiceProtocol: AnyObject {
    /// Deletes all stored video, image and AR Quick Look files.
    func deleteAllDownloads() -> Guarantee<Void>
}

final class DownloadsDeletionService: DownloadsDeletionServiceProtocol {
    private let downloadsProvider: DownloadsProviderProtocol
    private let arQuickLookStoredFileManager: ARQuickLookStoredFileManagerProtocol

    init(
        downloadsProvider: DownloadsProviderProtocol,
        arQuickLookStoredFileManager: ARQuickLookStoredFileManagerProtocol
    ) {
        self.downloadsProvider = downloadsProvider
        self.arQuickLookStoredFileManager = arQuickLookStoredFileManager
    }

    convenience init() {
        self.init(
            downloadsProvider: DownloadsProvider(
                coursesPersistenceService: CoursesPersistenceService(),
                adaptiveStorageManager: AdaptiveStorageManager.shared,
                videoFileManager: VideoStoredFileManager(fileManager: .default),
                imageFileManager: ImageStoredFileManager(fileManager: .default),
                storageUsageService: StorageUsageService(
                    videoFileManager: VideoStoredFileManager(fileManager: .default),
                    imageFileManager: ImageStoredFileManager(fileManager: .default)
                )
            ),
            arQuickLookStoredFileManager: ARQuickLookStoredFileManager(fileManager: .default)
        )
    }

    func deleteAllDownloads() -> Guarantee<Void> {
        firstly {
            self.downloadsProvider.fetchCachedCourses()
        }.then { cachedCourses in
            self.downloadsProvider.deleteCachedCourses(cachedCourses)
        }.then { _ -> Guarantee<Void> in
            try? self.arQuickLookStoredFileManager.removeAllARQuickLookStoredFiles()
            return Guarantee.value(())
        }
    }
}
