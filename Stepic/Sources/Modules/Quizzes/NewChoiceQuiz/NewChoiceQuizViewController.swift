import UIKit

protocol NewChoiceQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewChoiceQuiz.ReplyLoad.ViewModel)
}

final class NewChoiceQuizViewController: UIViewController {
    private let interactor: NewChoiceQuizInteractorProtocol

    lazy var newChoiceQuizView = self.view as? NewChoiceQuizView

    // Store options to smart reset quiz
    private var lastChoiceDataset: [String] = []

    init(interactor: NewChoiceQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newChoiceQuizView?.delegate = self
    }

    override func loadView() {
        let view = NewChoiceQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension NewChoiceQuizViewController: NewChoiceQuizViewControllerProtocol {
    func displayReply(viewModel: NewChoiceQuiz.ReplyLoad.ViewModel) {
        if self.lastChoiceDataset != viewModel.data.choices.map { $0.text } {
            self.lastChoiceDataset = viewModel.data.choices.map { $0.text }
            self.newChoiceQuizView?.set(
                choices: viewModel.data.choices.map { (text: $0.text, isSelected: $0.isSelected) }
            )
        }

        self.newChoiceQuizView?.title = viewModel.data.title
        self.newChoiceQuizView?.isSingleChoice = !viewModel.data.isMultipleChoice

        if let state = viewModel.data.finalState {
            switch state {
            case .correct:
                self.newChoiceQuizView?.markSelectedAsCorrect()
            case .wrong:
                self.newChoiceQuizView?.markSelectedAsWrong()
            case .evaluation:
                break
            }
        } else {
            self.newChoiceQuizView?.reset()
        }
    }
}

extension NewChoiceQuizViewController: NewChoiceQuizViewDelegate {
    func newChoiceQuizView(_ view: NewChoiceQuizView, didReport selectionMask: [Bool]) {
        self.interactor.doReplyUpdate(request: .init(choices: selectionMask))
    }
}
