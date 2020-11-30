import UIKit

final class AuthorsCourseListAssembly: Assembly {
    private weak var moduleOutput: AuthorsCourseListOutputProtocol?

    private let catalogBlockID: CatalogBlock.IdType

    init(
        catalogBlockID: CatalogBlock.IdType,
        output: AuthorsCourseListOutputProtocol? = nil
    ) {
        self.catalogBlockID = catalogBlockID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = AuthorsCourseListProvider(
            catalogBlocksRepository: CatalogBlocksRepository(
                catalogBlocksNetworkService: CatalogBlocksNetworkService(catalogBlocksAPI: CatalogBlocksAPI()),
                catalogBlocksPersistenceService: CatalogBlocksPersistenceService()
            )
        )
        let presenter = AuthorsCourseListPresenter()
        let interactor = AuthorsCourseListInteractor(
            catalogBlockID: self.catalogBlockID,
            presenter: presenter,
            provider: provider
        )
        let viewController = AuthorsCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
