import UIKit

final class SimpleCourseListAssembly: Assembly {
    private weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let initialContext: SimpleCourseList.Context
    private let layoutType: SimpleCourseList.LayoutType

    init(
        initialContext: SimpleCourseList.Context,
        layoutType: SimpleCourseList.LayoutType,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.initialContext = initialContext
        self.layoutType = layoutType
        self.moduleOutput = output
    }

    convenience init(
        catalogBlockID: CatalogBlock.IdType,
        layoutType: SimpleCourseList.LayoutType,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.init(initialContext: .catalogBlock(id: catalogBlockID), layoutType: layoutType, output: output)
    }

    convenience init(
        courseLists: [CourseListModel.IdType],
        layoutType: SimpleCourseList.LayoutType,
        output: SimpleCourseListOutputProtocol? = nil
    ) {
        self.init(initialContext: .courseLists(ids: courseLists), layoutType: layoutType, output: output)
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
        let viewController = SimpleCourseListViewController(
            interactor: interactor,
            layoutType: self.layoutType
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
