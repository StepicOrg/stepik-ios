import UIKit

protocol FillBlanksQuizPresenterProtocol {
    func presentSomeActionResult(response: FillBlanksQuiz.SomeAction.Response)
}

final class FillBlanksQuizPresenter: FillBlanksQuizPresenterProtocol {
    weak var viewController: FillBlanksQuizViewControllerProtocol?

    func presentSomeActionResult(response: FillBlanksQuiz.SomeAction.Response) {}
}
