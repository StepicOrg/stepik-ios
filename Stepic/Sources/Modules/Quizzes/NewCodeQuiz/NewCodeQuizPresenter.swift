import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentSomeActionResult(response: NewCodeQuiz.SomeAction.Response)
}

final class NewCodeQuizPresenter: NewCodeQuizPresenterProtocol {
    weak var viewController: NewCodeQuizViewControllerProtocol?

    func presentSomeActionResult(response: NewCodeQuiz.SomeAction.Response) { }
}
