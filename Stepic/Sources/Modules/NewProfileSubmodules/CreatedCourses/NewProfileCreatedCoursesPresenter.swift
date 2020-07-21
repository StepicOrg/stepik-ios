import UIKit

protocol NewProfileCreatedCoursesPresenterProtocol {
    func presentSomeActionResult(response: NewProfileCreatedCourses.SomeAction.Response)
}

final class NewProfileCreatedCoursesPresenter: NewProfileCreatedCoursesPresenterProtocol {
    weak var viewController: NewProfileCreatedCoursesViewControllerProtocol?

    func presentSomeActionResult(response: NewProfileCreatedCourses.SomeAction.Response) {}
}
