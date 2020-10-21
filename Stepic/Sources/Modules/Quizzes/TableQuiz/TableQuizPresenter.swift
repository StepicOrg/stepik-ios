import UIKit

protocol TableQuizPresenterProtocol {
    func presentReply(response: TableQuiz.ReplyLoad.Response)
}

final class TableQuizPresenter: TableQuizPresenterProtocol {
    weak var viewController: TableQuizViewControllerProtocol?

    func presentReply(response: TableQuiz.ReplyLoad.Response) {
        let state: TableQuizViewModel.State? = {
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

        let viewModel = TableQuizViewModel(
            title: NSLocalizedString("TableQuizTitle", comment: ""),
            rows: response.rows,
            columns: response.columns,
            isMultipleChoice: response.isMultipleChoice,
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }
}
