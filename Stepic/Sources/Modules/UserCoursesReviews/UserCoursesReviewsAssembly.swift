import UIKit

final class UserCoursesReviewsAssembly: Assembly {
    private weak var moduleOutput: UserCoursesReviewsOutputProtocol?

    init(output: UserCoursesReviewsOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = UserCoursesReviewsProvider(
            userAccountService: UserAccountService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(courseReviewsAPI: CourseReviewsAPI()),
            courseReviewsPersistenceService: CourseReviewsPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            userCoursesNetworkService: UserCoursesNetworkService(userCoursesAPI: UserCoursesAPI())
        )
        let presenter = UserCoursesReviewsPresenter()
        let interactor = UserCoursesReviewsInteractor(
            presenter: presenter,
            provider: provider,
            userAccountService: UserAccountService(),
            adaptiveStorageManager: AdaptiveStorageManager(),
            analytics: StepikAnalytics.shared
        )
        let viewController = UserCoursesReviewsViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
