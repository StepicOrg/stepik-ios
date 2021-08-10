import SVProgressHUD
import UIKit

protocol StepQuizReviewViewControllerProtocol: AnyObject {
    func displayStepQuizReview(viewModel: StepQuizReview.QuizReviewLoad.ViewModel)
    func displayTeacherReview(viewModel: StepQuizReview.TeacherReviewPresentation.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: StepQuizReview.BlockingWaitingIndicatorUpdate.ViewModel)
}

final class StepQuizReviewViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: StepQuizReviewInteractorProtocol

    private let step: Step
    private let isTeacher: Bool
    private let canNavigateToNextStep: Bool
    private var state: StepQuizReview.ViewControllerState

    var placeholderContainer = StepikPlaceholderControllerContainer()

    var stepQuizReviewView: StepQuizReviewViewProtocol? { self.view as? StepQuizReviewViewProtocol }

    init(
        interactor: StepQuizReviewInteractorProtocol,
        step: Step,
        isTeacher: Bool,
        canNavigateToNextStep: Bool,
        initialState: StepQuizReview.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.step = step
        self.isTeacher = isTeacher
        self.canNavigateToNextStep = canNavigateToNextStep
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

    private func setupQuizChildModule() {
        let assembly = BaseQuizAssembly(
            step: self.step,
            hasNextStep: self.canNavigateToNextStep,
            output: self.interactor as? BaseQuizOutputProtocol
        )
        let quizChildViewController = assembly.makeModule()

        self.addChild(quizChildViewController)
        self.stepQuizReviewView?.addQuiz(view: quizChildViewController.view)
        quizChildViewController.didMove(toParent: self)
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
