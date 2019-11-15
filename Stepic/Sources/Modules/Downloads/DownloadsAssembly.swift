import UIKit

final class DownloadsAssembly: Assembly {
    var moduleInput: DownloadsInputProtocol?

    private weak var moduleOutput: DownloadsOutputProtocol?

    init(output: DownloadsOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = DownloadsProvider()
        let presenter = DownloadsPresenter()
        let interactor = DownloadsInteractor(presenter: presenter, provider: provider)
        let viewController = DownloadsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
