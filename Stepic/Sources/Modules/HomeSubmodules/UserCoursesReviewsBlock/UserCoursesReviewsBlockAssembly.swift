import UIKit

final class UserCoursesReviewsBlockAssembly: Assembly {
    var moduleInput: UserCoursesReviewsBlockInputProtocol?

    func makeModule() -> UIViewController {
        let userCoursesReviewsProvider = UserCoursesReviewsProvider(
            userAccountService: UserAccountService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(courseReviewsAPI: CourseReviewsAPI()),
            courseReviewsPersistenceService: CourseReviewsPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService()
        )

        let provider = UserCoursesReviewsBlockProvider(userCoursesReviewsProvider: userCoursesReviewsProvider)
        let presenter = UserCoursesReviewsBlockPresenter()
        let interactor = UserCoursesReviewsBlockInteractor(presenter: presenter, provider: provider)
        let viewController = UserCoursesReviewsBlockViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
