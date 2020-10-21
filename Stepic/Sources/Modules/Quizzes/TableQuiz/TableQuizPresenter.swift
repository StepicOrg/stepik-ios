import UIKit

protocol TableQuizPresenterProtocol {
    func presentReply(response: TableQuiz.ReplyLoad.Response)
    func presentRowChoiceUpdateResult(response: TableQuiz.RowChoiceUpdate.Response)
    func presentQuizStatusUpdateResult(response: TableQuiz.QuizStatusUpdate.Response)
}

final class TableQuizPresenter: TableQuizPresenterProtocol {
    weak var viewController: TableQuizViewControllerProtocol?

    func presentReply(response: TableQuiz.ReplyLoad.Response) {
        let state = self.mapQuizStatusToTableQuizState(status: response.status)

        let viewModel = TableQuizViewModel(
            title: NSLocalizedString("TableQuizTitle", comment: ""),
            rows: response.rows,
            columns: response.columns,
            isMultipleChoice: response.isMultipleChoice,
            finalState: state
        )

        self.viewController?.displayReply(viewModel: .init(data: viewModel))
    }

    func presentRowChoiceUpdateResult(response: TableQuiz.RowChoiceUpdate.Response) {
        self.viewController?.displayRowChoiceUpdateResult(viewModel: .init(row: response.row))
    }

    func presentQuizStatusUpdateResult(response: TableQuiz.QuizStatusUpdate.Response) {
        let state = self.mapQuizStatusToTableQuizState(status: response.status)
        self.viewController?.displayQuizStatusUpdateResult(viewModel: .init(state: state))
    }

    private func mapQuizStatusToTableQuizState(status: QuizStatus?) -> TableQuizViewModel.State? {
        guard let status = status else {
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
    }
}
