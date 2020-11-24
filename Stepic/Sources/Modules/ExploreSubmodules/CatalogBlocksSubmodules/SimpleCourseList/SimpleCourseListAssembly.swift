import UIKit

final class SimpleCourseListAssembly: Assembly {
    private weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let catalogBlockID: CatalogBlock.IdType

    init(
        catalogBlockID: CatalogBlock.IdType,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.catalogBlockID = catalogBlockID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = SimpleCourseListProvider(
            catalogBlocksRepository: CatalogBlocksRepository(
                catalogBlocksNetworkService: CatalogBlocksNetworkService(catalogBlocksAPI: CatalogBlocksAPI()),
                catalogBlocksPersistenceService: CatalogBlocksPersistenceService()
            )
        )
        let presenter = SimpleCourseListPresenter()
        let interactor = SimpleCourseListInteractor(
            catalogBlockID: self.catalogBlockID,
            presenter: presenter,
            provider: provider
        )
        let viewController = SimpleCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
