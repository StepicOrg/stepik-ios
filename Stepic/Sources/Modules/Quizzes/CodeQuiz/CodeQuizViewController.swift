import UIKit

protocol CodeQuizViewControllerProtocol: AnyObject {
    func displayReply(viewModel: CodeQuiz.ReplyLoad.ViewModel)
    func displayFullscreen(viewModel: CodeQuiz.FullscreenPresentation.ViewModel)
}

final class CodeQuizViewController: UIViewController {
    private let interactor: CodeQuizInteractorProtocol
    private let analytics: Analytics

    lazy var codeQuizView = self.view as? CodeQuizView

    init(interactor: CodeQuizInteractorProtocol, analytics: Analytics) {
        self.interactor = interactor
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CodeQuizView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension CodeQuizViewController: CodeQuizViewControllerProtocol {
    func displayReply(viewModel: CodeQuiz.ReplyLoad.ViewModel) {
        self.codeQuizView?.configure(viewModel: viewModel.data)
    }

    func displayFullscreen(viewModel: CodeQuiz.FullscreenPresentation.ViewModel) {
        let assembly = CodeQuizFullscreenAssembly(
            codeDetails: viewModel.codeDetails,
            language: viewModel.language,
            output: self
        )

        let viewController = assembly.makeModule()
        viewController.title = viewModel.lessonTitle

        self.present(moduleStack: [viewController], modalPresentationStyle: .fullScreen)
    }
}

extension CodeQuizViewController: CodeQuizViewDelegate {
    func codeQuizView(_ view: CodeQuizView, didSelectLanguage language: CodeLanguage) {
        self.interactor.doLanguageSelect(request: .init(language: language))
    }

    func codeQuizView(_ view: CodeQuizView, didUpdateCode code: String) {
        self.interactor.doReplyUpdate(request: .init(code: code))
    }

    func codeQuizViewDidRequestFullscreen(_ view: CodeQuizView) {
        self.analytics.send(.codeFullscreenClicked)
        self.interactor.doFullscreenAction(request: .init())
    }

    func codeQuizViewDidRequestPresentationController(_ view: CodeQuizView) -> UIViewController? { self }
}

extension CodeQuizViewController: CodeQuizFullscreenOutputProtocol {
    func update(code: String) {
        self.interactor.doReplyUpdate(request: .init(code: code))
        self.interactor.doReplyLoad(request: .init())
    }

    func submit(reply: Reply) {
        self.interactor.doReplySubmit(request: .init(reply: reply))
    }
}
