import Agrume
import UIKit

protocol NewStepViewControllerProtocol: class {
    func displayStep(viewModel: NewStep.StepLoad.ViewModel)
    func displayControlsUpdate(viewModel: NewStep.ControlsUpdate.ViewModel)
}

final class NewStepViewController: UIViewController, ControllerWithStepikPlaceholder {
    private static let stepPassedDelay: TimeInterval = 1.0

    lazy var newStepView = self.view as? NewStepView

    var placeholderContainer = StepikPlaceholderControllerContainer()

    private let interactor: NewStepInteractorProtocol

    private var state: NewStep.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    private var didInitRequestsSend = false
    private var sendStepDidPassedGroup = DispatchGroup()

    private var isFirstAppearance = true

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
        self.view = NewStepView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionQuiz,
                action: { [weak self] in
                    self?.interactor.doStepLoad(request: .init())
                }
            ),
            for: .connectionError
        )

        self.newStepView?.delegate = self

        // Enter group, leave when content did load & in view did appear
        self.sendStepDidPassedGroup.enter()
        self.sendStepDidPassedGroup.enter()

        self.updateState()
        self.sendStepDidPassedGroup.notify(queue: .main) { [weak self] in
            self?.sendInitStepStatusRequests()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        defer {
            self.isFirstAppearance = false
        }

        // TODO: Move this request to viewDidLoad, but we should deal with WKWebView behavior before
        if self.isFirstAppearance {
            self.interactor.doStepLoad(request: .init())
        }

        if !self.didInitRequestsSend {
            self.sendStepDidPassedGroup.leave()
        }
    }

    // MARK: Private API

    private func updateState() {
        switch self.state {
        case .result:
            self.isPlaceholderShown = false
            self.showContent()
        case .loading:
            self.isPlaceholderShown = false
            self.newStepView?.startLoading()
        case .error:
            self.showPlaceholder(for: .connectionError)
        }
    }

    private func sendInitStepStatusRequests() {
        defer {
            self.didInitRequestsSend = true
        }

        self.interactor.doStepViewRequest(request: .init())

        guard case .result(let viewModel) = self.state, viewModel.quizType == nil else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + NewStepViewController.stepPassedDelay) { [weak self] in
            self?.interactor.doStepDoneRequest(request: .init())
        }
    }

    @objc
    private func showContent() {
        // swiftlint:disable:next cyclomatic_complexity
        func initQuizController(type: NewStep.QuizType, step: Step) -> QuizViewController? {
            let quizController: QuizViewController? = {
                switch type {
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
                case .code:
                    return CodeQuizViewController(nibName: "QuizViewController", bundle: nil)
                case .sql:
                    return SQLQuizViewController(nibName: "QuizViewController", bundle: nil)
                default:
                    return nil
                }
            }()

            if let controller = quizController {
                controller.step = step
                controller.delegate = self
                return controller
            }
            return nil
        }

        guard case .result(let viewModel) = self.state else {
            return
        }

        if !self.didInitRequestsSend {
            self.sendStepDidPassedGroup.leave()
        }

        guard let quizType = viewModel.quizType else {
            // Video & text steps
            self.newStepView?.configure(viewModel: viewModel, quizView: nil)
            return
        }

        let quizController: UIViewController? = {
            switch quizType {
            case .string, .number, .math, .freeAnswer, .choice, .code:
                let assembly = BaseQuizAssembly(step: viewModel.step, output: self)
                return assembly.makeModule()
            default:
                return initQuizController(type: quizType, step: viewModel.step)
            }
        }()

        if let controller = quizController {
            self.addChild(controller)
            self.newStepView?.configure(viewModel: viewModel, quizView: controller.view)
        } else {
            let controller = UnknownTypeQuizViewController(nibName: "UnknownTypeQuizViewController", bundle: nil)
            controller.stepUrl = viewModel.stepURLPath
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

        let isVideoPlayingReachable = ConnectionHelper.shared.reachability.isReachableViaWiFi()
            || ConnectionHelper.shared.reachability.isReachableViaWWAN()
        if video.state == VideoState.cached || isVideoPlayingReachable {
            let player = StepicVideoPlayerViewController(nibName: "StepicVideoPlayerViewController", bundle: nil)
            player.video = video
            AnalyticsReporter.reportEvent(AnalyticsEvents.VideoPlayer.opened, parameters: nil)
            self.present(player, animated: true)
        }
    }

    func newStepViewDidRequestPrevious(_ view: NewStepView) {
        self.interactor.doLessonNavigationRequest(request: .init(direction: .previous))
    }

    func newStepViewDidRequestNext(_ view: NewStepView) {
        self.interactor.doLessonNavigationRequest(request: .init(direction: .next))
    }

    func newStepViewDidRequestDiscussions(_ view: NewStepView) {
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

    func newStepView(_ view: NewStepView, didRequestOpenURL url: URL) {
        guard case .result(let viewModel) = self.state else {
            return
        }

        // Check if the request is a navigation inside a lesson
        if url.absoluteString.range(of: "\(viewModel.lessonID)/step/") != nil {
            let components = url.pathComponents
            if let index = components.index(of: "step") {
                if index + 1 < components.count {
                    let urlStepIndexString = components[index + 1]
                    if let urlStepIndex = Int(urlStepIndexString) {
                        self.interactor.doStepNavigationRequest(request: .init(index: urlStepIndex))
                        return
                    }
                }
            }
        }

        WebControllerManager.sharedManager.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: "external link",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func newStepView(_ view: NewStepView, didRequestFullscreenImage url: URL) {
        let agrume = Agrume(url: url)
        agrume.show(from: self)
    }

    func newStepViewDidLoadContent(_ view: NewStepView) {
        self.newStepView?.endLoading()
    }
}

extension NewStepViewController: QuizControllerDelegate {
    func submissionDidCorrect() {
        self.interactor.doStepDoneRequest(request: .init())
    }
}

extension NewStepViewController: BaseQuizOutputProtocol {
    func handleCorrectSubmission() {
        self.interactor.doStepDoneRequest(request: .init())
    }
}
