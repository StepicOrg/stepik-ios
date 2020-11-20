import UIKit

final class CatalogBlocksAssembly: Assembly {
    var moduleInput: CatalogBlocksInputProtocol?

    private weak var moduleOutput: CatalogBlocksOutputProtocol?

    init(output: CatalogBlocksOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CatalogBlocksProvider()
        let presenter = CatalogBlocksPresenter()
        let interactor = CatalogBlocksInteractor(presenter: presenter, provider: provider)
        let viewController = CatalogBlocksViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
