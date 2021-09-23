import UIKit

protocol BaseQuizViewControllerProtocol: AnyObject {
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel)
    func displayRateAppAlert(viewModel: BaseQuiz.RateAppAlertPresentation.ViewModel)
    func displayStreakAlert(viewModel: BaseQuiz.StreakAlertPresentation.ViewModel)
}

final class BaseQuizViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: BaseQuizInteractorProtocol

    private let analytics: Analytics

    private let withHorizontalInsets: Bool

    var placeholderContainer = StepikPlaceholderControllerContainer()

    lazy var baseQuizView = self.view as? BaseQuizView

    private lazy var streaksAlertPresentationManager = StreaksAlertPresentationManager(source: .submission)

    private var quizAssembly: QuizAssembly

    private var childQuizModuleInput: QuizInputProtocol? { self.quizAssembly.moduleInput }

    private var currentReply: Reply?
    private var shouldRetryWithNewAttempt = true

    private var state: BaseQuiz.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    init(
        interactor: BaseQuizInteractorProtocol,
        quizAssembly: QuizAssembly,
        analytics: Analytics,
        withHorizontalInsets: Bool,
        initialState: BaseQuiz.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.quizAssembly = quizAssembly
        self.analytics = analytics
        self.withHorizontalInsets = withHorizontalInsets
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = BaseQuizView(
            frame: UIScreen.main.bounds,
            withHorizontalInsets: self.withHorizontalInsets
        )
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
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionPollQuiz,
                action: { [weak self] in
                    self?.state = .loading
                    self?.interactor.doRetryPollSubmission(request: .init())
                }
            ),
            for: .connectionErrorPollQuiz
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
        case .error(let domain):
            switch domain {
            case .networkConnection:
                self.showPlaceholder(for: .connectionError)
            case .evaluateSubmission:
                self.showPlaceholder(for: .connectionErrorPollQuiz)
            }
        }
    }

    private func showContent() {
        guard case .result(let data) = self.state else {
            return
        }

        self.currentReply = data.reply

        self.baseQuizView?.isTopSeparatorHidden = data.isTopSeparatorHidden
        self.baseQuizView?.isSubmitButtonEnabled = data.isSubmitButtonEnabled
        self.baseQuizView?.submitButtonTitle = data.submitButtonTitle
        self.baseQuizView?.isNextStepAvailable = data.canNavigateToNextStep
        self.baseQuizView?.isRetryAvailable = data.canRetry
        self.baseQuizView?.isDiscountPolicyAvailable = data.isDiscountingPolicyVisible
        self.baseQuizView?.discountPolicyTitle = data.discountingPolicyTitle
        self.baseQuizView?.isReviewAvailable = data.shouldPassReview
        self.baseQuizView?.isReviewControlsAvailable = data.isReviewControlsAvailable

        if let quizStatus = data.quizStatus {
            self.baseQuizView?.showFeedback(
                state: .init(quizStatus: quizStatus),
                title: data.feedbackTitle,
                hint: data.hintContent
            )
        } else {
            self.baseQuizView?.hideFeedback()
        }

        self.childQuizModuleInput?.update(dataset: data.dataset)
        self.childQuizModuleInput?.update(feedback: data.feedback)
        self.childQuizModuleInput?.update(codeDetails: data.codeDetails)
        self.childQuizModuleInput?.update(reply: data.reply)
        self.childQuizModuleInput?.update(status: data.quizStatus)

        self.shouldRetryWithNewAttempt = data.retryWithNewAttempt

        if data.isTitleHidden,
           let titlePresentableView = baseQuizView?.childQuizView as? TitlePresentable {
            titlePresentableView.title = nil
        }

        self.baseQuizView?.endLoading()
    }
}

// MARK: - BaseQuizViewController: BaseQuizViewControllerProtocol -

extension BaseQuizViewController: BaseQuizViewControllerProtocol {
    func displaySubmission(viewModel: BaseQuiz.SubmissionLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayRateAppAlert(viewModel: BaseQuiz.RateAppAlertPresentation.ViewModel) {
        Alerts.rate.present(alert: Alerts.rate.construct(lessonProgress: nil), inController: self)
    }

    func displayStreakAlert(viewModel: BaseQuiz.StreakAlertPresentation.ViewModel) {
        self.streaksAlertPresentationManager.controller = self
        self.streaksAlertPresentationManager.suggestStreak(streak: viewModel.streak)
    }
}

// MARK: - BaseQuizViewController: BaseQuizViewDelegate -

extension BaseQuizViewController: BaseQuizViewDelegate {
    func baseQuizViewDidRequestSubmit(_ view: BaseQuizView) {
        self.submitCurrentReply()
    }

    func baseQuizViewDidRequestNextStep(_ view: BaseQuizView) {
        self.interactor.doNextStepNavigationRequest(request: .init())
    }

    func baseQuizViewDidRequestReviewCreateSession(_ view: BaseQuizView) {
        self.analytics.send(.reviewSendCurrentSubmissionClicked)
        self.interactor.doReviewCreateSession(request: .init())
    }

    func baseQuizViewDidRequestReviewSolveAgain(_ view: BaseQuizView) {
        self.analytics.send(.reviewSolveAgainClicked)
        self.submitCurrentReply()
    }

    func baseQuizViewDidRequestReviewSelectDifferentSubmission(_ view: BaseQuizView) {
        self.analytics.send(.reviewSelectDifferentSubmissionClicked)
        self.interactor.doReviewSelectDifferentSubmission(request: .init())
    }

    func baseQuizView(_ view: BaseQuizView, didRequestFullscreenImage url: URL) {
        FullscreenImageViewer.show(url: url, from: self)
    }

    func baseQuizView(_ view: BaseQuizView, didRequestOpenURL url: URL) {
        let scheme = url.scheme?.lowercased() ?? ""
        if ["http", "https"].contains(scheme) {
            WebControllerManager.shared.presentWebControllerWithURL(
                url,
                inController: self,
                withKey: .externalLink,
                allowsSafari: true,
                backButtonStyle: .done
            )
        }
    }

    // MARK: Private Helpers

    private func submitCurrentReply() {
        guard let reply = self.currentReply else {
            return
        }

        self.view.endEditing(true)

        if self.shouldRetryWithNewAttempt {
            self.interactor.doSubmissionLoad(request: .init(shouldRefreshAttempt: true))
        } else if let replyValidationResult = self.childQuizModuleInput?.isReplyValid(reply) {
            switch replyValidationResult {
            case .success:
                self.interactor.doSubmissionSubmit(request: .init(reply: reply))
            case .error(let message):
                self.presentReplyValidationErrorAlert(message: message)
            }
        }
    }

    private func presentReplyValidationErrorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - BaseQuizViewController: QuizOutputProtocol -

extension BaseQuizViewController: QuizOutputProtocol {
    func update(reply: Reply) {
        self.currentReply = reply
        self.interactor.doReplyCache(request: .init(reply: reply))
    }

    func submit(reply: Reply) {
        self.update(reply: reply)
        self.submitCurrentReply()
    }
}

// MARK: - StepikPlaceholderControllerContainer.PlaceholderState -

private extension StepikPlaceholderControllerContainer.PlaceholderState {
    static let connectionErrorPollQuiz = StepikPlaceholderControllerContainer.PlaceholderState(
        id: "connectionErrorPollQuiz"
    )
}
