import Foundation

final class CourseInfoTabReviewsAssembly: Assembly {
    // Input
    var moduleInput: CourseInfoTabReviewsInputProtocol?

    func makeModule() -> UIViewController {
        let presenter = CourseInfoTabReviewsPresenter()
        let provider = CourseInfoTabReviewsProvider(
            courseReviewsPersistenceService: CourseReviewsPersistenceService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(courseReviewsAPI: CourseReviewsAPI()),
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI())
        )
        let interactor = CourseInfoTabReviewsInteractor(presenter: presenter, provider: provider)
        let viewController = CourseInfoTabReviewsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
