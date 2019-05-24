import UIKit

protocol NewStepViewControllerProtocol: class {
    func displayStep(viewModel: NewStep.StepLoad.ViewModel)
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

    // MARK: Private API

    @objc
    private func showContent() {
        guard case .result(let viewModel) = self.state else {
            return
        }

        guard let quizType = viewModel.quizType else {
            self.newStepView?.configure(viewModel: viewModel, quizView: nil)
            return
        }

        switch quizType {
        case .choice:
            let quizController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
            quizController.step = viewModel.step
            self.addChild(quizController)
            self.newStepView?.configure(viewModel: viewModel, quizView: quizController.view)
        default:
            self.newStepView?.configure(viewModel: viewModel, quizView: nil)
        }
    }
}

extension NewStepViewController: NewStepViewControllerProtocol {
    func displayStep(viewModel: NewStep.StepLoad.ViewModel) {
        self.state = viewModel.state
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
}
