import Foundation
import PromiseKit

protocol NewCodeQuizFullscreenInteractorProtocol {
    func doSomeAction(request: NewCodeQuizFullscreen.SomeAction.Request)
}

final class NewCodeQuizFullscreenInteractor: NewCodeQuizFullscreenInteractorProtocol {
    weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    private let presenter: NewCodeQuizFullscreenPresenterProtocol

    private let content: String
    private let language: CodeLanguage
    private let options: StepOptions
    private let codeEditorTheme: CodeEditorView.Theme

    private var codeTemplate: String? {
        return self.options.template(language: language, userGenerated: false)?.templateString
    }

    private var currentCode: String?

    init(
        presenter: NewCodeQuizFullscreenPresenterProtocol,
        content: String,
        language: CodeLanguage,
        options: StepOptions,
        codeEditorTheme: CodeEditorView.Theme
    ) {
        self.presenter = presenter
        self.content = content
        self.language = language
        self.options = options
        self.codeEditorTheme = codeEditorTheme

        if let userTemplate = options.template(language: language, userGenerated: true) {
            self.currentCode = userTemplate.templateString
        } else if let template = options.template(language: language, userGenerated: false) {
            self.currentCode = template.templateString
        }
    }

    func doSomeAction(request: NewCodeQuizFullscreen.SomeAction.Request) {
        self.presenter.presentSomeActionResult(
            response: .init(
                content: self.content,
                language: self.language,
                options: self.options,
                code: self.currentCode,
                codeTemplate: self.codeTemplate,
                codeEditorTheme: self.codeEditorTheme
            )
        )
    }
}
