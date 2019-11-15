import UIKit

final class DownloadsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = DownloadsProvider(
            coursesPersistenceService: CoursesPersistenceService(),
            videoFileManager: VideoStoredFileManager(fileManager: FileManager.default)
        )
        let presenter = DownloadsPresenter()
        let interactor = DownloadsInteractor(presenter: presenter, provider: provider)
        let viewController = DownloadsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
