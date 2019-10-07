import UIKit

protocol UnsupportedQuizPresenterProtocol {
    func presentSomeActionResult(response: UnsupportedQuiz.SomeAction.Response)
}

final class UnsupportedQuizPresenter: UnsupportedQuizPresenterProtocol {
    weak var viewController: UnsupportedQuizViewControllerProtocol?

    func presentSomeActionResult(response: UnsupportedQuiz.SomeAction.Response) { }
}