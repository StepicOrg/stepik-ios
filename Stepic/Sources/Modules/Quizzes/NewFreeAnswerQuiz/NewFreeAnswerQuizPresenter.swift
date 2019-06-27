import UIKit

protocol NewFreeAnswerQuizPresenterProtocol {
    func presentReply(response: NewFreeAnswerQuiz.ReplyLoad.Response)
}

final class NewFreeAnswerQuizPresenter: NewFreeAnswerQuizPresenterProtocol {
    weak var viewController: NewFreeAnswerQuizViewControllerProtocol?

    private lazy var quizPlaceholder = NSLocalizedString("StringQuizPlaceholder", comment: "")

    func presentReply(response: NewFreeAnswerQuiz.ReplyLoad.Response) {
        let viewModel = NewFreeAnswerQuizViewModel(
            text: response.text,
            placeholderText: self.quizPlaceholder,
            isEnabled: response.status != .correct
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
