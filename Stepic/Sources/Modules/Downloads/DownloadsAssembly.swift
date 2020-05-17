import UIKit

final class DownloadsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = DownloadsProvider(
            coursesPersistenceService: CoursesPersistenceService(),
            adaptiveStorageManager: AdaptiveStorageManager.shared,
            videoFileManager: VideoStoredFileManager(fileManager: .default),
            imageFileManager: ImageStoredFileManager(fileManager: .default),
            storageUsageService: StorageUsageService(
                videoFileManager: VideoStoredFileManager(fileManager: .default),
                imageFileManager: ImageStoredFileManager(fileManager: .default)
            )
        )
        let presenter = DownloadsPresenter()
        let interactor = DownloadsInteractor(
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared
        )
        let viewController = DownloadsViewController(interactor: interactor, analytics: StepikAnalytics.shared)

        presenter.viewController = viewController

        return viewController
    }
}
