import UIKit

protocol TableQuizViewControllerProtocol: AnyObject {
    func displayReply(viewModel: TableQuiz.ReplyLoad.ViewModel)
}

final class TableQuizViewController: UIViewController {
    private let interactor: TableQuizInteractorProtocol

    var tableQuizView: TableQuizView? { self.view as? TableQuizView }

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
    }
}

extension TableQuizViewController: TableQuizViewControllerProtocol {
    func displayReply(viewModel: TableQuiz.ReplyLoad.ViewModel) {
        self.tableQuizView?.set(rows: viewModel.data.rows)
    }
}
