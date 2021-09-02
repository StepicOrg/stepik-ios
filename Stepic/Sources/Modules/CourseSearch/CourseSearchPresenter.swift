import UIKit

protocol CourseSearchPresenterProtocol {
    func presentSomeActionResult(response: CourseSearch.SomeAction.Response)
}

final class CourseSearchPresenter: CourseSearchPresenterProtocol {
    weak var viewController: CourseSearchViewControllerProtocol?

    func presentSomeActionResult(response: CourseSearch.SomeAction.Response) {}
}
