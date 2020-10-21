import PanModal
import UIKit

protocol TableQuizViewControllerProtocol: AnyObject {
    func displayReply(viewModel: TableQuiz.ReplyLoad.ViewModel)
    func displayRowChoiceUpdateResult(viewModel: TableQuiz.RowChoiceUpdate.ViewModel)
    func displayQuizStatusUpdateResult(viewModel: TableQuiz.QuizStatusUpdate.ViewModel)
}

final class TableQuizViewController: UIViewController {
    private let interactor: TableQuizInteractorProtocol

    var tableQuizView: TableQuizView? { self.view as? TableQuizView }

    private var storedViewModel: TableQuizViewModel?

    init(interactor: TableQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = TableQuizView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }
}

extension TableQuizViewController: TableQuizViewControllerProtocol {
    func displayReply(viewModel: TableQuiz.ReplyLoad.ViewModel) {
        self.storedViewModel = viewModel.data

        self.tableQuizView?.title = viewModel.data.title
        self.tableQuizView?.set(rows: viewModel.data.rows)
        self.tableQuizView?.isEnabled = viewModel.data.finalState == nil
    }

    func displayRowChoiceUpdateResult(viewModel: TableQuiz.RowChoiceUpdate.ViewModel) {
        self.tableQuizView?.updateRowAnswers(row: viewModel.row)
    }

    func displayQuizStatusUpdateResult(viewModel: TableQuiz.QuizStatusUpdate.ViewModel) {
        self.tableQuizView?.isEnabled = viewModel.state == nil
    }
}

extension TableQuizViewController: TableQuizViewDelegate {
    func tableQuizView(_ view: TableQuizView, didSelectRow row: TableQuiz.Row) {
        guard let storedViewModel = self.storedViewModel else {
            return
        }

        let assembly = TableQuizSelectColumnsAssembly(
            row: row,
            columns: storedViewModel.columns,
            selectedColumnsIDs: Set(row.answers.map(\.uniqueIdentifier)),
            isMultipleChoice: storedViewModel.isMultipleChoice,
            output: self.interactor as? TableQuizSelectColumnsOutputProtocol
        )
        let viewController = assembly.makeModule()

        if let panModalPresentableViewController = viewController as? UIViewController & PanModalPresentable {
            self.presentPanModal(panModalPresentableViewController)
        }
    }
}
