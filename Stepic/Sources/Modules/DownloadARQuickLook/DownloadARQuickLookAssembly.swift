import UIKit

final class DownloadARQuickLookAssembly: Assembly {
    private weak var moduleOutput: DownloadARQuickLookOutputProtocol?

    private let url: URL

    init(url: URL, output: DownloadARQuickLookOutputProtocol? = nil) {
        self.url = url
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = DownloadARQuickLookPresenter()
        let interactor = DownloadARQuickLookInteractor(
            url: self.url,
            presenter: presenter,
            downloadingService: DownloadingServiceFactory.makeDownloadingService(type: .arQuickLook),
            arQuickLookStoredFileManager: ARQuickLookStoredFileManager(fileManager: .default)
        )
        let viewController = DownloadARQuickLookViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
