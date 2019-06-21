import UIKit

protocol NewStringQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewStringQuiz.ReplyLoad.ViewModel)
}

final class NewStringQuizViewController: UIViewController {
    private let interactor: NewStringQuizInteractorProtocol

    lazy var newStringQuizView = self.view as? NewStringQuizView

    init(interactor: NewStringQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newStringQuizView?.delegate = self
    }

    override func loadView() {
        self.view = NewStringQuizView(frame: UIScreen.main.bounds)
    }
}

extension NewStringQuizViewController: NewStringQuizViewControllerProtocol {
    func displayReply(viewModel: NewStringQuiz.ReplyLoad.ViewModel) {
        self.newStringQuizView?.title = viewModel.data.title
        self.newStringQuizView?.placeholder = viewModel.data.placeholderText
        self.newStringQuizView?.text = viewModel.data.text
        self.newStringQuizView?.state = viewModel.data.finalState
        self.newStringQuizView?.isTextFieldEnabled = viewModel.data.isEnabled
    }
}

extension NewStringQuizViewController: NewStringQuizViewDelegate {
    func newStringQuizView(_ view: NewStringQuizView, didUpdate text: String) {
        self.interactor.doReplyUpdate(request: .init(text: text))
    }
}
