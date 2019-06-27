import UIKit

protocol NewFreeAnswerQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewFreeAnswerQuiz.ReplyLoad.ViewModel)
}

final class NewFreeAnswerQuizViewController: UIViewController {
    private let interactor: NewFreeAnswerQuizInteractorProtocol

    lazy var newFreeAnswerQuizView = self.view as? NewFreeAnswerQuizView

    init(interactor: NewFreeAnswerQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newFreeAnswerQuizView?.delegate = self
    }

    override func loadView() {
        self.view = NewFreeAnswerQuizView(frame: UIScreen.main.bounds)
    }
}

extension NewFreeAnswerQuizViewController: NewFreeAnswerQuizViewControllerProtocol {
    func displayReply(viewModel: NewFreeAnswerQuiz.ReplyLoad.ViewModel) {
        self.newFreeAnswerQuizView?.text = viewModel.data.text
        self.newFreeAnswerQuizView?.placeholder = viewModel.data.placeholderText
        self.newFreeAnswerQuizView?.isTextViewEnabled = viewModel.data.isEnabled
    }
}

extension NewFreeAnswerQuizViewController: NewFreeAnswerQuizViewDelegate {
    func newFreeAnswerQuizView(_ view: NewFreeAnswerQuizView, didUpdate text: String) {
        self.interactor.doReplyUpdate(request: .init(text: text))
    }
}
