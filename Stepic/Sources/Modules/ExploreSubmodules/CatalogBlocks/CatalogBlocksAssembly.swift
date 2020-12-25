import UIKit

final class CatalogBlocksAssembly: Assembly {
    private let contentLanguage: ContentLanguage

    private weak var moduleOutput: CatalogBlocksOutputProtocol?

    init(
        contentLanguage: ContentLanguage,
        output: CatalogBlocksOutputProtocol? = nil
    ) {
        self.contentLanguage = contentLanguage
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CatalogBlocksProvider(
            contentLanguage: self.contentLanguage,
            catalogBlocksRepository: CatalogBlocksRepository(
                catalogBlocksNetworkService: CatalogBlocksNetworkService(catalogBlocksAPI: CatalogBlocksAPI()),
                catalogBlocksPersistenceService: CatalogBlocksPersistenceService()
            )
        )
        let presenter = CatalogBlocksPresenter()
        let interactor = CatalogBlocksInteractor(presenter: presenter, provider: provider)
        let viewController = CatalogBlocksViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
