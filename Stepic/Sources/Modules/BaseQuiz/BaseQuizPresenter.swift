import UIKit

protocol BaseQuizPresenterProtocol {
    func presentSomeActionResult(response: BaseQuiz.SomeAction.Response)
}

final class BaseQuizPresenter: BaseQuizPresenterProtocol {
    weak var viewController: BaseQuizViewControllerProtocol?

    func presentSomeActionResult(response: BaseQuiz.SomeAction.Response) { }
}