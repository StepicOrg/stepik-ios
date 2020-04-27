import UIKit

final class UserCoursesAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = UserCoursesProvider()
        let presenter = UserCoursesPresenter()
        let interactor = UserCoursesInteractor(presenter: presenter, provider: provider)
        let viewController = UserCoursesViewController(
            interactor: interactor,
            availableTabs: UserCourses.Tab.allCases,
            initialTab: .allCourses
        )

        presenter.viewController = viewController

        return viewController
    }
}
