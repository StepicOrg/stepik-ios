import UIKit

final class AuthorsCourseListAssembly: Assembly {
    private weak var moduleOutput: AuthorsCourseListOutputProtocol?

    private let initialContext: AuthorsCourseList.Context

    init(
        initialContext: AuthorsCourseList.Context,
        output: AuthorsCourseListOutputProtocol? = nil
    ) {
        self.initialContext = initialContext
        self.moduleOutput = output
    }

    convenience init(
        catalogBlockID: CatalogBlock.IdType,
        output: AuthorsCourseListOutputProtocol? = nil
    ) {
        self.init(initialContext: .catalogBlock(id: catalogBlockID), output: output)
    }

    convenience init(
        authors: [User.IdType],
        output: AuthorsCourseListOutputProtocol? = nil
    ) {
        self.init(initialContext: .authors(ids: authors), output: output)
    }

    func makeModule() -> UIViewController {
        let provider = AuthorsCourseListProvider(
            catalogBlocksRepository: CatalogBlocksRepository(
                catalogBlocksNetworkService: CatalogBlocksNetworkService(catalogBlocksAPI: CatalogBlocksAPI()),
                catalogBlocksPersistenceService: CatalogBlocksPersistenceService()
            ),
            usersPersistenceService: UsersPersistenceService(),
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI())
        )
        let presenter = AuthorsCourseListPresenter()
        let interactor = AuthorsCourseListInteractor(
            initialContext: self.initialContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = AuthorsCourseListViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
