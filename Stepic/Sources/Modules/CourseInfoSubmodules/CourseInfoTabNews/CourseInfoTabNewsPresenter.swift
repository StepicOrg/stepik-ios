import UIKit

protocol CourseInfoTabNewsPresenterProtocol {
    func presentSomeActionResult(response: CourseInfoTabNews.SomeAction.Response)
}

final class CourseInfoTabNewsPresenter: CourseInfoTabNewsPresenterProtocol {
    weak var viewController: CourseInfoTabNewsViewControllerProtocol?

    func presentSomeActionResult(response: CourseInfoTabNews.SomeAction.Response) {}
}
