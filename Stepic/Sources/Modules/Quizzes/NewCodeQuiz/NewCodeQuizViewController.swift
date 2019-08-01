import UIKit

protocol NewCodeQuizViewControllerProtocol: class {
    func displayReply(viewModel: NewCodeQuiz.ReplyLoad.ViewModel)
    func displayFullscreen(viewModel: NewCodeQuiz.FullscreenPresentation.ViewModel)
}

final class NewCodeQuizViewController: UIViewController {
    private let interactor: NewCodeQuizInteractorProtocol

    lazy var newCodeQuizView = self.view as? NewCodeQuizView

    init(interactor: NewCodeQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewCodeQuizView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
}

extension NewCodeQuizViewController: NewCodeQuizViewControllerProtocol {
    func displayReply(viewModel: NewCodeQuiz.ReplyLoad.ViewModel) {
        self.newCodeQuizView?.configure(viewModel: viewModel.data)
    }

    func displayFullscreen(viewModel: NewCodeQuiz.FullscreenPresentation.ViewModel) {
        let data = viewModel.data
        let assembly = NewCodeQuizFullscreenAssembly(
            content: data.content,
            language: data.language,
            options: data.options,
            codeEditorTheme: .init(name: viewModel.codeEditorTheme.name, font: viewModel.codeEditorTheme.font),
            output: nil
        )
        self.present(moduleStack: [assembly.makeModule()])
    }
}

extension NewCodeQuizViewController: NewCodeQuizViewDelegate {
    func newCodeQuizView(_ view: NewCodeQuizView, didSelectLanguage language: CodeLanguage) {
        self.interactor.doLanguageSelect(request: .init(language: language))
    }

    func newCodeQuizView(_ view: NewCodeQuizView, didUpdateCode code: String) {
        self.interactor.doReplyUpdate(request: .init(code: code))
    }

    func newCodeQuizViewDidRequestFullscreen(_ view: NewCodeQuizView) {
        self.interactor.doFullscreenAction(request: .init())
    }

    func newCodeQuizViewDidRequestPresentationController(_ view: NewCodeQuizView) -> UIViewController? {
        return self
    }
}
