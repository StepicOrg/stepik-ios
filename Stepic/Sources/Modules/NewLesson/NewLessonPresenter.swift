import UIKit

protocol NewLessonPresenterProtocol {
    func presentSomeActionResult(response: NewLesson.SomeAction.Response)
}

final class NewLessonPresenter: NewLessonPresenterProtocol {
    weak var viewController: NewLessonViewControllerProtocol?

    func presentSomeActionResult(response: NewLesson.SomeAction.Response) { }
}