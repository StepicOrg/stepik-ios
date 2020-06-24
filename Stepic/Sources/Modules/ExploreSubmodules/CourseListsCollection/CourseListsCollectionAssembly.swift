import Foundation

final class CourseListsCollectionAssembly: Assembly {
    let contentLanguage: ContentLanguage

    private weak var moduleOutput: (CourseListCollectionOutputProtocol & CourseListOutputProtocol)?

    init(
        contentLanguage: ContentLanguage,
        output: (CourseListCollectionOutputProtocol & CourseListOutputProtocol)? = nil
    ) {
        self.contentLanguage = contentLanguage
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseListsCollectionProvider(
            language: self.contentLanguage,
            courseListsCollectionsPersistenceService: CourseListsCollectionPersistenceService(),
            collectionsNetworkService: CourseListsCollectionNetworkService(
                courseListsAPI: CourseListsAPI()
            )
        )
        let presenter = CourseListsCollectionPresenter()
        let interactor = CourseListsCollectionInteractor(presenter: presenter, provider: provider)
        let viewController = CourseListsCollectionViewController(interactor: interactor)
        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
