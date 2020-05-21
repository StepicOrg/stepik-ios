import UIKit

protocol UnsupportedQuizPresenterProtocol {
    func presentUnsupportedQuiz(response: UnsupportedQuiz.UnsupportedQuizPresentation.Response)
}

final class UnsupportedQuizPresenter: UnsupportedQuizPresenterProtocol {
    weak var viewController: UnsupportedQuizViewControllerProtocol?

    func presentUnsupportedQuiz(response: UnsupportedQuiz.UnsupportedQuizPresentation.Response) {
        guard let encodedPath = response.stepURLPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let stepURL = URL(string: encodedPath) else {
            return
        }

        self.viewController?.displayUnsupportedQuiz(viewModel: .init(stepURL: stepURL))
    }
}
