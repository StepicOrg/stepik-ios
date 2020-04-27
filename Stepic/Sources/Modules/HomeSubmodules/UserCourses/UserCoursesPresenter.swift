import UIKit

protocol UserCoursesPresenterProtocol {
    func presentUserCourses(response: UserCourses.UserCoursesLoad.Response)
}

final class UserCoursesPresenter: UserCoursesPresenterProtocol {
    weak var viewController: UserCoursesViewControllerProtocol?

    func presentUserCourses(response: UserCourses.UserCoursesLoad.Response) {
        self.viewController?.displayUserCourses(viewModel: .init())
    }
}
