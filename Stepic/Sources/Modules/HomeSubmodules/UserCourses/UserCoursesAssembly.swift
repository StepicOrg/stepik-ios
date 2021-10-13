import UIKit

final class UserCoursesAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = UserCoursesPresenter()
        let interactor = UserCoursesInteractor(presenter: presenter)
        let viewController = UserCoursesViewController(
            interactor: interactor,
            availableTabs: UserCourses.Tab.allCases,
            initialTab: .allCourses,
            analytics: StepikAnalytics.shared
        )

        presenter.viewController = viewController

        return viewController
    }
}
