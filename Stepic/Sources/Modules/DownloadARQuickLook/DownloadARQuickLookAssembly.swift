import UIKit

final class DownloadARQuickLookAssembly: Assembly {
    var moduleInput: DownloadARQuickLookInputProtocol?

    private weak var moduleOutput: DownloadARQuickLookOutputProtocol?

    init(output: DownloadARQuickLookOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = DownloadARQuickLookProvider()
        let presenter = DownloadARQuickLookPresenter()
        let interactor = DownloadARQuickLookInteractor(presenter: presenter, provider: provider)
        let viewController = DownloadARQuickLookViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
