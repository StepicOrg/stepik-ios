import UIKit

protocol BaseQuizViewControllerProtocol: class {
    func displaySomeActionResult(viewModel: BaseQuiz.SomeAction.ViewModel)
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel)
}

final class BaseQuizViewController: UIViewController {
    private let interactor: BaseQuizInteractorProtocol

    lazy var baseQuizView = self.view as? BaseQuizView

    private lazy var assembly = NewStringQuizAssembly(type: .string)

    private var childQuizModuleInput: QuizInputProtocol? {
        return self.assembly.moduleInput
    }

    init(interactor: BaseQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = BaseQuizView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.doSubmissionLoad(request: .init())

        let controller = self.assembly.makeModule()
        self.addChild(controller)
        self.baseQuizView?.addQuiz(view: controller.view)
    }
}

extension BaseQuizViewController: BaseQuizViewControllerProtocol {
    func displaySomeActionResult(viewModel: BaseQuiz.SomeAction.ViewModel) { }

    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel) {
        guard case .result(let data) = viewModel.state else {
            return
        }

        self.baseQuizView?.isSubmitButtonEnabled = (data.submissionsLeft ?? Int.max) > 0
        self.baseQuizView?.submitButtonTitle = data.submitButtonTitle

        if let status = data.quizStatus {
            switch status {
            case .correct:
                self.baseQuizView?.updateFeedback(state: .correct)
            case .wrong:
                self.baseQuizView?.updateFeedback(state: .wrong)
            case .evaluation:
                self.baseQuizView?.updateFeedback(state: .evaluation)
            }
        } else {
            self.baseQuizView?.updateFeedback(state: nil)
        }

        self.childQuizModuleInput?.update(reply: data.reply)
        self.childQuizModuleInput?.update(status: data.quizStatus)
    }
}
