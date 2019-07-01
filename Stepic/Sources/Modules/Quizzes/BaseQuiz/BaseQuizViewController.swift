import UIKit

protocol BaseQuizViewControllerProtocol: class {
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel)
    func displayRateAppAlert(viewModel: BaseQuiz.RateAppAlertPresentation.ViewModel)
    func displayStreakAlert(viewModel: BaseQuiz.StreakAlertPresentation.ViewModel)
}

final class BaseQuizViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: BaseQuizInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()

    lazy var baseQuizView = self.view as? BaseQuizView

    private var quizAssembly: QuizAssembly

    private var childQuizModuleInput: QuizInputProtocol? {
        return self.quizAssembly.moduleInput
    }

    private var currentReply: Reply?
    private var shouldRetryWithNewAttempt = true
    private var stepURL: URL?

    private var state: BaseQuiz.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    init(interactor: BaseQuizInteractorProtocol, quizAssembly: QuizAssembly) {
        self.interactor = interactor
        self.quizAssembly = quizAssembly
        self.state = .loading

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

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionQuiz,
                action: { [weak self] in
                    self?.state = .loading
                    self?.interactor.doSubmissionLoad(request: .init(shouldRefreshAttempt: false))
                }
            ),
            for: .connectionError
        )
        self.updateState()

        self.quizAssembly.moduleOutput = self
        self.baseQuizView?.delegate = self

        self.interactor.doSubmissionLoad(request: .init(shouldRefreshAttempt: false))

        let quizController = self.quizAssembly.makeModule()
        self.addChild(quizController)
        self.baseQuizView?.addQuiz(view: quizController.view)
    }

    // MARK: - Private API

    private func updateState() {
        switch self.state {
        case .result:
            self.isPlaceholderShown = false
            self.showContent()
        case .loading:
            self.isPlaceholderShown = false
            self.baseQuizView?.startLoading()
        case .error:
            self.showPlaceholder(for: .connectionError)
        }
    }

    private func showContent() {
        guard case .result(let data) = self.state else {
            return
        }

        self.stepURL = data.stepURL

        self.baseQuizView?.isSubmitButtonEnabled = data.isSubmitButtonEnabled
        self.baseQuizView?.submitButtonTitle = data.submitButtonTitle
        self.baseQuizView?.isPeerReviewAvailable = data.shouldPassPeerReview

        if let status = data.quizStatus {
            switch status {
            case .correct:
                self.baseQuizView?.showFeedback(state: .correct, title: data.feedbackTitle, hint: data.hintContent)
            case .wrong:
                self.baseQuizView?.showFeedback(state: .wrong, title: data.feedbackTitle, hint: data.hintContent)
            case .evaluation:
                self.baseQuizView?.showFeedback(state: .evaluation, title: data.feedbackTitle, hint: data.hintContent)
            }
        } else {
            self.baseQuizView?.hideFeedback()
        }

        self.childQuizModuleInput?.update(dataset: data.dataset)
        self.childQuizModuleInput?.update(feedback: data.feedback)
        self.childQuizModuleInput?.update(reply: data.reply)
        self.childQuizModuleInput?.update(status: data.quizStatus)

        self.shouldRetryWithNewAttempt = data.retryWithNewAttempt

        self.baseQuizView?.endLoading()
    }
}

extension BaseQuizViewController: BaseQuizViewControllerProtocol {
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayRateAppAlert(viewModel: BaseQuiz.RateAppAlertPresentation.ViewModel) {
        Alerts.rate.present(alert: Alerts.rate.construct(lessonProgress: nil), inController: self)
    }

    func displayStreakAlert(viewModel: BaseQuiz.StreakAlertPresentation.ViewModel) {
        let streaksAlertPresentationManager = StreaksAlertPresentationManager(source: .submission)
        streaksAlertPresentationManager.controller = self
        streaksAlertPresentationManager.suggestStreak(streak: viewModel.streak)
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
