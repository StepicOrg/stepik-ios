import UIKit

protocol NewCodeQuizPresenterProtocol {
    func presentReply(response: NewCodeQuiz.ReplyLoad.Response)
}

final class NewCodeQuizPresenter: NewCodeQuizPresenterProtocol {
    weak var viewController: NewCodeQuizViewControllerProtocol?

    func presentReply(response: NewCodeQuiz.ReplyLoad.Response) {
        let viewModel = NewCodeQuizViewModel(
            samples: response.samples
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
