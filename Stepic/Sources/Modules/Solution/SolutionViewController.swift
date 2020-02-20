import UIKit

protocol SolutionViewControllerProtocol: AnyObject {
    func displaySolution(viewModel: Solution.SolutionLoad.ViewModel)
}

final class SolutionViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: SolutionInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()

    lazy var solutionView = self.view as? SolutionView

    private lazy var shareBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(self.shareButtonClicked)
        )
        item.isEnabled = false
        return item
    }()

    private var state: Solution.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    private var solutionURL: URL? {
        didSet {
            self.shareBarButtonItem.isEnabled = self.solutionURL != nil
        }
    }

    init(
        interactor: SolutionInteractorProtocol,
        initialState state: Solution.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SolutionView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.updateState()

        self.interactor.doSolutionLoad(request: .init())
    }

    // MARK: Private API

    private func setup() {
        self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionQuiz,
                action: { [weak self] in
                    self?.state = .loading
                    self?.interactor.doSolutionLoad(request: .init())
                }
            ),
            for: .connectionError
        )
    }

    private func updateState() {
        switch self.state {
        case .result:
            self.isPlaceholderShown = false
            self.showContent()
        case .loading:
            self.isPlaceholderShown = false
            self.solutionView?.startLoading()
        case .error:
            self.showPlaceholder(for: .connectionError)
        }
    }

    private func showContent() {
        guard case .result(let data) = self.state else {
            return
        }

        self.solutionURL = data.solutionURL

        let quizType = StepDataFlow.QuizType(blockName: data.step.block.name)

        if case .unknown = quizType {
            self.solutionView?.actionTitle = NSLocalizedString("UnsupportedSolutionActionTitle", comment: "")
            self.solutionView?.actionIsHidden = false
            self.solutionView?.showFeedback(
                state: .validation,
                title: NSLocalizedString("UnsupportedSolutionTitle", comment: "")
            )
        } else {
            let quizAssembly = QuizAssemblyFactory().make(for: quizType)
            let quizController = quizAssembly.makeModule()

            self.addChild(quizController)
            self.solutionView?.addQuiz(view: quizController.view)

            switch data.quizStatus {
            case .correct:
                self.solutionView?.showFeedback(state: .correct, title: data.feedbackTitle, hint: data.hintContent)
            case .wrong:
                self.solutionView?.showFeedback(state: .wrong, title: data.feedbackTitle, hint: data.hintContent)
            case .evaluation:
                self.solutionView?.showFeedback(state: .evaluation, title: data.feedbackTitle, hint: data.hintContent)
            }

            self.solutionView?.actionIsHidden = true

            let quizModuleInput = quizAssembly.moduleInput
            quizModuleInput?.update(quizTitleVisibility: false)
            quizModuleInput?.update(dataset: data.dataset)
            quizModuleInput?.update(feedback: data.feedback)
            quizModuleInput?.update(codeDetails: data.codeDetails)
            quizModuleInput?.update(reply: data.reply)
            quizModuleInput?.update(status: data.quizStatus)

            let isUserInteractionEnabled: Bool = {
                if case .code = quizType {
                    return true
                }
                return false
            }()

            quizController.view.isUserInteractionEnabled = isUserInteractionEnabled

            if let codeQuizViewController = quizController as? CodeQuizViewController {
                codeQuizViewController.newCodeQuizView?.setCodeEditorActionControlsEnabled(false)
            }
        }

        self.solutionView?.endLoading()
    }

    @objc
    private func shareButtonClicked() {
        guard let link = self.solutionURL?.absoluteString else {
            return
        }

        DispatchQueue.global().async {
            let sharingViewController = SharingHelper.getSharingController(link)
            DispatchQueue.main.async {
                sharingViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
                self.present(sharingViewController, animated: true, completion: nil)
            }
        }
    }
}

extension SolutionViewController: SolutionViewControllerProtocol {
    func displaySolution(viewModel: Solution.SolutionLoad.ViewModel) {
        self.state = viewModel.state
    }
}

extension SolutionViewController: SolutionViewDelegate {
    func solutionView(_ view: SolutionView, didRequestOpenURL url: URL) {
        let scheme = url.scheme?.lowercased() ?? ""
        if ["http", "https"].contains(scheme) {
            WebControllerManager.sharedManager.presentWebControllerWithURL(
                url,
                inController: self,
                withKey: "external link",
                allowsSafari: true,
                backButtonStyle: .done
            )
        }
    }

    func solutionViewDidClickAction(_ view: SolutionView) {
        guard let url = self.solutionURL else {
            return
        }

        WebControllerManager.sharedManager.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: "solution",
            allowsSafari: true,
            backButtonStyle: .done
        )
    }
}
