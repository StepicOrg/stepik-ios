import UIKit

protocol EditLessonPresenterProtocol {
    func presentSomeActionResult(response: EditLesson.SomeAction.Response)
}

final class EditLessonPresenter: EditLessonPresenterProtocol {
    weak var viewController: EditLessonViewControllerProtocol?

    func presentSomeActionResult(response: EditLesson.SomeAction.Response) { }
}