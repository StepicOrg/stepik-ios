import UIKit

final class DownloadsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = DownloadsProvider()
        let presenter = DownloadsPresenter()
        let interactor = DownloadsInteractor(presenter: presenter, provider: provider)
        let viewController = DownloadsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
