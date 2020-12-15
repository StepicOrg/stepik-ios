import UIKit

final class SimpleCourseListAssembly: Assembly {
    private weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let catalogBlockID: CatalogBlock.IdType
    private let layoutType: SimpleCourseList.LayoutType

    init(
        catalogBlockID: CatalogBlock.IdType,
        layoutType: SimpleCourseList.LayoutType,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.catalogBlockID = catalogBlockID
        self.layoutType = layoutType
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
        let viewController = SimpleCourseListViewController(
            interactor: interactor,
            layoutType: self.layoutType
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
