import Agrume
import UIKit

protocol NewStepViewControllerProtocol: class {
    func displayStep(viewModel: NewStep.StepLoad.ViewModel)
    func displayControlsUpdate(viewModel: NewStep.ControlsUpdate.ViewModel)
}

final class NewStepViewController: UIViewController {
    lazy var newStepView = self.view as? NewStepView

    private let interactor: NewStepInteractorProtocol

    private var state: NewStep.ViewControllerState {
        didSet {
            switch state {
            case .result:
                self.showContent()
            default:
                break
            }
        }
    }

    init(interactor: NewStepInteractorProtocol) {
        self.interactor = interactor
        self.state = .loading
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewStepView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.newStepView?.delegate = self
        self.interactor.doStepLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.interactor.doStepViewRequest(request: .init())
    }

    // MARK: Private API

    @objc
    // swiftlint:disable:next cyclomatic_complexity
    private func showContent() {
        guard case .result(let viewModel) = self.state else {
            return
        }

        guard let quizType = viewModel.quizType else {
            self.newStepView?.configure(viewModel: viewModel, quizView: nil)
            return
        }

        let quizController: QuizViewController? = {
            switch quizType {
            case .choice:
                return ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .string:
                return StringQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .number:
                return NumberQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .freeAnswer:
                return FreeAnswerQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .math:
                return MathQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .sorting:
                return SortingQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .matching:
                return MatchingQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .fillBlanks:
                return FillBlanksQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .code:
                return CodeQuizViewController(nibName: "QuizViewController", bundle: nil)
            case .sql:
                return SQLQuizViewController(nibName: "QuizViewController", bundle: nil)
            default:
                return nil
            }
        }()

        if let controller = quizController {
            controller.step = viewModel.step
            self.addChild(controller)
            self.newStepView?.configure(viewModel: viewModel, quizView: controller.view)
        } else {
            let controller = UnknownTypeQuizViewController(nibName: "UnknownTypeQuizViewController", bundle: nil)
            // TODO: make url
            // quizController.stepUrl = self.stepUrl
            self.addChild(controller)
            self.newStepView?.configure(viewModel: viewModel, quizView: controller.view)
        }
    }
}

extension NewStepViewController: NewStepViewControllerProtocol {
    func displayStep(viewModel: NewStep.StepLoad.ViewModel) {
        self.state = viewModel.state
    }

    func displayControlsUpdate(viewModel: NewStep.ControlsUpdate.ViewModel) {
        self.newStepView?.updateNavigationButtons(
            hasPreviousButton: viewModel.canNavigateToPreviousUnit,
            hasNextButton: viewModel.canNavigateToNextUnit
        )
    }
}

extension NewStepViewController: NewStepViewDelegate {
    func newStepViewDidRequestVideo(_ view: NewStepView) {
        guard case .result(let viewModel) = self.state,
              case .video(let videoViewModel) = viewModel.content,
              let video = videoViewModel?.video else {
            return
        }

        // Should show alert
        if video.urls.isEmpty {
            // presentNoVideoAlert()
            return
        }

        let isVideoPlayingReachable = ConnectionHelper.shared.reachability.isReachableViaWiFi()
            || ConnectionHelper.shared.reachability.isReachableViaWWAN()
        if video.state == VideoState.cached || isVideoPlayingReachable {
            let player = StepicVideoPlayerViewController(nibName: "StepicVideoPlayerViewController", bundle: nil)
            player.video = video
            self.present(player, animated: true)
        }
    }

    func newStepViewDidRequestPrevious(_ view: NewStepView) {
        self.interactor.doLessonNavigationRequest(request: .init(direction: .previous))
    }

    func newStepViewDidRequestNext(_ view: NewStepView) {
        self.interactor.doLessonNavigationRequest(request: .init(direction: .next))
    }

    func newStepViewDidRequestComments(_ view: NewStepView) {
        guard case .result(let viewModel) = self.state,
              let discussionProxyID = viewModel.discussionProxyID else {
            return
        }

        let assembly = DiscussionsLegacyAssembly(
            discussionProxyID: discussionProxyID,
            stepID: viewModel.step.id
        )
        self.push(module: assembly.makeModule())
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) {
        let agrume = Agrume(url: url)
        agrume.show(from: self)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) {
        WebControllerManager.sharedManager.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: "external link",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        
    }
}
