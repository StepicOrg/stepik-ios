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
