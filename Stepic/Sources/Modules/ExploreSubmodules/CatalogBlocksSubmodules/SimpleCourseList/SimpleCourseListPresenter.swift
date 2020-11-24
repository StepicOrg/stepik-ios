import UIKit

protocol SimpleCourseListPresenterProtocol {
    func presentSomeActionResult(response: SimpleCourseList.SomeAction.Response)
}

final class SimpleCourseListPresenter: SimpleCourseListPresenterProtocol {
    weak var viewController: SimpleCourseListViewControllerProtocol?

    func presentSomeActionResult(response: SimpleCourseList.SomeAction.Response) {}
}
