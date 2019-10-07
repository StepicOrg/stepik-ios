import UIKit

protocol UnsupportedQuizPresenterProtocol {
    func presentUnsupportedQuiz(response: UnsupportedQuiz.UnsupportedQuizPresentation.Response)
}

final class UnsupportedQuizPresenter: UnsupportedQuizPresenterProtocol {
    weak var viewController: UnsupportedQuizViewControllerProtocol?

    func presentUnsupportedQuiz(response: UnsupportedQuiz.UnsupportedQuizPresentation.Response) {
        self.viewController?.displayUnsupportedQuiz(
            viewModel: UnsupportedQuiz.UnsupportedQuizPresentation.ViewModel(stepURLPath: response.stepURLPath)
        )
    }
}
