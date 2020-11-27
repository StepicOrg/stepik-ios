import UIKit

protocol AuthorsCourseListPresenterProtocol {
    func presentSomeActionResult(response: AuthorsCourseList.SomeAction.Response)
}

final class AuthorsCourseListPresenter: AuthorsCourseListPresenterProtocol {
    weak var viewController: AuthorsCourseListViewControllerProtocol?

    func presentSomeActionResult(response: AuthorsCourseList.SomeAction.Response) {}
}
