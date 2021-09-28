import UIKit

final class UserCoursesReviewsWidgetAssembly: Assembly {
    var moduleInput: UserCoursesReviewsWidgetInputProtocol?

    func makeModule() -> UIViewController {
        let userCoursesReviewsProvider = UserCoursesReviewsProvider(
            userAccountService: UserAccountService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(courseReviewsAPI: CourseReviewsAPI()),
            courseReviewsPersistenceService: CourseReviewsPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            userCoursesNetworkService: UserCoursesNetworkService(userCoursesAPI: UserCoursesAPI())
        )

        let provider = UserCoursesReviewsWidgetProvider(userCoursesReviewsProvider: userCoursesReviewsProvider)
        let presenter = UserCoursesReviewsWidgetPresenter()
        let interactor = UserCoursesReviewsWidgetInteractor(presenter: presenter, provider: provider)
        let viewController = UserCoursesReviewsWidgetViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
