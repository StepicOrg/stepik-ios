import SVProgressHUD
import UIKit

protocol StepQuizReviewViewControllerProtocol: AnyObject {
    func displayStepQuizReview(viewModel: StepQuizReview.QuizReviewLoad.ViewModel)
    func displayTeacherReview(viewModel: StepQuizReview.TeacherReviewPresentation.ViewModel)
    func displayInstructorReview(viewModel: StepQuizReview.InstructorReviewPresentation.ViewModel)
    func displaySubmissions(viewModel: StepQuizReview.SubmissionsPresentation.ViewModel)
    func displayChangeCurrentSubmissionResult(viewModel: StepQuizReview.ChangeCurrentSubmission.ViewModel)
    func displaySubmittedForReviewSubmission(
        viewModel: StepQuizReview.SubmittedForReviewSubmissionPresentation.ViewModel
    )
    func displayBlockingLoadingIndicator(viewModel: StepQuizReview.BlockingWaitingIndicatorUpdate.ViewModel)
}

final class StepQuizReviewViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: StepQuizReviewInteractorProtocol

    private let step: Step
    private let isTeacher: Bool
    private var state: StepQuizReview.ViewControllerState

    private var childQuizModuleInput: BaseQuizInputProtocol?

    private var didDisplayTeacherReview = false

    var placeholderContainer = StepikPlaceholderControllerContainer()

    var stepQuizReviewView: StepQuizReviewViewProtocol? { self.view as? StepQuizReviewViewProtocol }

    init(
        interactor: StepQuizReviewInteractorProtocol,
        step: Step,
        isTeacher: Bool,
        initialState: StepQuizReview.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.step = step
        self.isTeacher = isTeacher
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view: UIView & StepQuizReviewViewProtocol = self.isTeacher
            ? StepQuizReviewTeacherView()
            : StepQuizReviewView()
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionQuiz,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doStepQuizReviewLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.updateState(newState: self.state)
        self.interactor.doStepQuizReviewLoad(request: .init())

        self.setupQuizChildModule()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.didDisplayTeacherReview {
            self.didDisplayTeacherReview = false
            self.interactor.doStepQuizReviewRefresh(request: .init(afterTeacherReviewPresentation: true))
        }
    }

    // MARK: Private API

    private func setupQuizChildModule() {
        let assembly = BaseQuizAssembly(
            step: self.step,
            config: .init(
                hasNextStep: false,
                isTopSeparatorHidden: true,
                isTitleHidden: true,
                isReviewControlsAvailable: true,
                withHorizontalInsets: false
            ),
            output: self.interactor as? BaseQuizOutputProtocol
        )
        let quizChildViewController = assembly.makeModule()

        self.addChild(quizChildViewController)
        self.stepQuizReviewView?.addQuiz(view: quizChildViewController.view)
        quizChildViewController.didMove(toParent: self)

        self.childQuizModuleInput = assembly.moduleInput
    }

    private func updateState(newState: StepQuizReview.ViewControllerState) {
        defer {
            self.state = newState
        }

        switch newState {
        case .loading:
            self.isPlaceholderShown = false
            self.stepQuizReviewView?.showLoading()
        case .error:
            self.stepQuizReviewView?.hideLoading()
            self.showPlaceholder(for: .connectionError)
        case .result(let viewModel):
            self.isPlaceholderShown = false
            self.stepQuizReviewView?.hideLoading()
            self.stepQuizReviewView?.configure(viewModel: viewModel)
        }
    }
}

// MARK: - StepQuizReviewViewController: StepQuizReviewViewControllerProtocol -

extension StepQuizReviewViewController: StepQuizReviewViewControllerProtocol {
    func displayStepQuizReview(viewModel: StepQuizReview.QuizReviewLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayTeacherReview(viewModel: StepQuizReview.TeacherReviewPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .peerReview,
            allowsSafari: true,
            backButtonStyle: .done
        )
        self.didDisplayTeacherReview = true
    }

    func displayInstructorReview(viewModel: StepQuizReview.InstructorReviewPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .peerReview,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func displaySubmissions(viewModel: StepQuizReview.SubmissionsPresentation.ViewModel) {
        let modalPresentationStyle = UIModalPresentationStyle.stepikAutomatic

        let assembly = SubmissionsAssembly(
            stepID: viewModel.stepID,
            isTeacher: viewModel.isTeacher,
            submissionsFilterQuery: viewModel.filterQuery,
            isSelectionEnabled: viewModel.isSelectionEnabled,
            navigationBarAppearance: modalPresentationStyle.isSheetStyle ? .pageSheetAppearance() : .init(),
            output: self
        )
        let navigationController = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(
            module: navigationController,
            embedInNavigation: false,
            modalPresentationStyle: modalPresentationStyle
        )
    }

    func displayChangeCurrentSubmissionResult(viewModel: StepQuizReview.ChangeCurrentSubmission.ViewModel) {
        self.childQuizModuleInput?.changeCurrent(attempt: viewModel.attempt, submission: viewModel.submission)
    }

    func displaySubmittedForReviewSubmission(
        viewModel: StepQuizReview.SubmittedForReviewSubmissionPresentation.ViewModel
    ) {
        if let currentSolutionViewController = self.children.first(where: { $0 is SolutionViewControllerProtocol }) {
            currentSolutionViewController.willMove(toParent: nil)
            currentSolutionViewController.removeFromParent()
            currentSolutionViewController.view.removeFromSuperview()
        }

        let assembly = SolutionAssembly(
            stepID: self.step.id,
            submission: viewModel.submission,
            submissionURLProvider: nil
        )

        let solutionViewController = assembly.makeModule()

        self.stepQuizReviewView?.addSolution(view: solutionViewController.view)
        self.addChild(solutionViewController)
        solutionViewController.didMove(toParent: self)

        if let solutionView = solutionViewController.view as? SolutionViewProtocol {
            solutionView.setOnlyQuizVisible()
            solutionView.setContentInsets(.zero)
        }
    }

    func displayBlockingLoadingIndicator(viewModel: StepQuizReview.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.showError {
            SVProgressHUD.showError(withStatus: nil)
        } else if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }
}

// MARK: - StepQuizReviewViewController: StepQuizReviewViewDelegate -

extension StepQuizReviewViewController: StepQuizReviewViewDelegate {
    func stepQuizReviewViewView(
        _ view: StepQuizReviewViewProtocol,
        didClickButtonWith uniqueIdentifier: UniqueIdentifierType?
    ) {
        guard let uniqueIdentifier = uniqueIdentifier else {
            return print("StepQuizReviewViewController :: unknown button action")
        }

        self.interactor.doButtonAction(request: .init(actionUniqueIdentifier: uniqueIdentifier))
    }
}

// MARK: - StepQuizReviewViewController: SubmissionsOutputProtocol -

extension StepQuizReviewViewController: SubmissionsOutputProtocol {
    func handleSubmissionSelected(_ submission: Submission) {
        self.dismiss(
            animated: true,
            completion: { [weak self] in
                guard let strongSelf = self,
                      strongSelf.childQuizModuleInput != nil else {
                    return
                }

                strongSelf.interactor.doChangeCurrentSubmission(request: .init(submission: submission))
            }
        )
    }
}
