import UIKit

protocol BaseQuizViewControllerProtocol: class {
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel)
}

final class BaseQuizViewController: UIViewController {
    private let interactor: BaseQuizInteractorProtocol

    lazy var baseQuizView = self.view as? BaseQuizView

    private var quizAssembly: QuizAssembly

    private var childQuizModuleInput: QuizInputProtocol? {
        return self.quizAssembly.moduleInput
    }

    private var currentReply: Reply?
    private var shouldRetryWithNewAttempt = true
    private var stepURL: URL?

    init(interactor: BaseQuizInteractorProtocol, quizAssembly: QuizAssembly) {
        self.interactor = interactor
        self.quizAssembly = quizAssembly

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

        self.quizAssembly.moduleOutput = self
        self.baseQuizView?.delegate = self

        self.interactor.doSubmissionLoad(request: .init(shouldRefreshAttempt: false))

        let quizController = self.quizAssembly.makeModule()
        self.addChild(quizController)
        self.baseQuizView?.addQuiz(view: quizController.view)
    }
}

extension BaseQuizViewController: BaseQuizViewControllerProtocol {
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel) {
        guard case .result(let data) = viewModel.state else {
            return
        }

        self.stepURL = data.stepURL

        self.baseQuizView?.isSubmitButtonEnabled = data.isSubmitButtonEnabled
        self.baseQuizView?.submitButtonTitle = data.submitButtonTitle
        self.baseQuizView?.isPeerReviewAvailable = data.shouldPassPeerReview

        if let status = data.quizStatus {
            switch status {
            case .correct:
                self.baseQuizView?.showFeedback(state: .correct, title: data.feedbackTitle)
            case .wrong:
                self.baseQuizView?.showFeedback(state: .wrong, title: data.feedbackTitle)
            case .evaluation:
                self.baseQuizView?.showFeedback(state: .evaluation, title: data.feedbackTitle)
            }
        } else {
            self.baseQuizView?.hideFeedback()
        }

        self.childQuizModuleInput?.update(reply: data.reply)
        self.childQuizModuleInput?.update(status: data.quizStatus)

        self.shouldRetryWithNewAttempt = data.retryWithNewAttempt
    }
}

extension BaseQuizViewController: BaseQuizViewDelegate {
    func baseQuizViewDidRequestSubmit(_ view: BaseQuizView) {
        guard let reply = self.currentReply else {
            return
        }

        if self.shouldRetryWithNewAttempt {
            self.interactor.doSubmissionLoad(request: .init(shouldRefreshAttempt: true))
        } else {
            self.interactor.doSubmissionSubmit(request: .init(reply: reply))
        }
    }

    func baseQuizViewDidRequestPeerReview(_ view: BaseQuizView) {
        guard let url = self.stepURL else {
            return
        }

        WebControllerManager.sharedManager.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: "peer review",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}

extension BaseQuizViewController: QuizOutputProtocol {
    func update(reply: Reply) {
        self.currentReply = reply
    }
}
