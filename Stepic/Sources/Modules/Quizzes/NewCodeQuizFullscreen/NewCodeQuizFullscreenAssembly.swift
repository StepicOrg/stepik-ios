import UIKit

final class NewCodeQuizFullscreenAssembly: Assembly {
    private weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    private let content: String
    private let language: CodeLanguage
    private let options: StepOptions
    private let codeEditorTheme: CodeEditorView.Theme

    init(
        content: String,
        language: CodeLanguage,
        options: StepOptions,
        codeEditorTheme: CodeEditorView.Theme,
        output: NewCodeQuizFullscreenOutputProtocol? = nil
    ) {
        self.content = content
        self.language = language
        self.options = options
        self.codeEditorTheme = codeEditorTheme
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = NewCodeQuizFullscreenPresenter()
        let interactor = NewCodeQuizFullscreenInteractor(
            presenter: presenter,
            content: self.content,
            language: self.language,
            options: self.options,
            codeEditorTheme: self.codeEditorTheme
        )
        let viewController = NewCodeQuizFullscreenViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
