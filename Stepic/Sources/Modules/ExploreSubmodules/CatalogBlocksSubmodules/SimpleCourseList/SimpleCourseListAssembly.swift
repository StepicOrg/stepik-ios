import UIKit

final class SimpleCourseListAssembly: Assembly {
    private weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let initialContext: SimpleCourseList.Context

    init(
        initialContext: SimpleCourseList.Context,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.initialContext = initialContext
        self.moduleOutput = output
    }

    convenience init(
        catalogBlockID: CatalogBlock.IdType,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.init(initialContext: .catalogBlock(id: catalogBlockID), output: output)
    }

    convenience init(
        courseLists: [CourseListModel.IdType],
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.init(initialContext: .courseLists(ids: courseLists), output: output)
    }

    func makeModule() -> UIViewController {
        let provider = SimpleCourseListProvider(
            catalogBlocksRepository: CatalogBlocksRepository(
                catalogBlocksNetworkService: CatalogBlocksNetworkService(catalogBlocksAPI: CatalogBlocksAPI()),
                catalogBlocksPersistenceService: CatalogBlocksPersistenceService()
            ),
            courseListsPersistenceService: CourseListsPersistenceService(),
            courseListsNetworkService: CourseListsNetworkService(courseListsAPI: CourseListsAPI())
        )
        let presenter = SimpleCourseListPresenter()
        let interactor = SimpleCourseListInteractor(
            initialContext: self.initialContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = SimpleCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
