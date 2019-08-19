import UIKit

protocol NewSortingQuizPresenterProtocol {
    func presentSomeActionResult(response: NewSortingQuiz.SomeAction.Response)
}

final class NewSortingQuizPresenter: NewSortingQuizPresenterProtocol {
    weak var viewController: NewSortingQuizViewControllerProtocol?

    func presentSomeActionResult(response: NewSortingQuiz.SomeAction.Response) { }
}
