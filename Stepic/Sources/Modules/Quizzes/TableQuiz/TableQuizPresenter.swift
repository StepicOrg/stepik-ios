import UIKit

protocol TableQuizPresenterProtocol {
    func presentSomeActionResult(response: TableQuiz.SomeAction.Response)
}

final class TableQuizPresenter: TableQuizPresenterProtocol {
    weak var viewController: TableQuizViewControllerProtocol?

    func presentSomeActionResult(response: TableQuiz.SomeAction.Response) {}
}
