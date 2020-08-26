import UIKit

protocol FillBlanksQuizPresenterProtocol {
    func presentReply(response: FillBlanksQuiz.ReplyLoad.Response)
}

final class FillBlanksQuizPresenter: FillBlanksQuizPresenterProtocol {
    weak var viewController: FillBlanksQuizViewControllerProtocol?

    func presentReply(response: FillBlanksQuiz.ReplyLoad.Response) {
        let state: FillBlanksQuizViewModel.State? = {
            guard let status = response.status else {
                return nil
            }

            switch status {
            case .correct, .partiallyCorrect:
                return .correct
            case .wrong:
                return .wrong
            case .evaluation:
                return .evaluation
            }
        }()

        let viewModel = FillBlanksQuizViewModel(components: response.components, finalState: state)

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
