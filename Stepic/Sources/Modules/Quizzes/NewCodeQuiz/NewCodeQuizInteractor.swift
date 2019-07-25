import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request)
    func doLanguageSelect(request: NewCodeQuiz.LanguageSelect.Request)
}

final class NewCodeQuizInteractor: NewCodeQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewCodeQuizPresenterProtocol

    private var currentCode: String? {
        didSet {
            self.updateUserCodeTemplate()
        }
    }
    private var currentLanguageName: String?
    private var currentCodeLanguage: CodeLanguage? {
        return CodeLanguage(rawValue: self.currentLanguageName ?? "")
    }
    private var currentOptions: StepOptions?
    private var currentStatus: QuizStatus?

    init(presenter: NewCodeQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request) {
        guard let codeLanguage = self.currentCodeLanguage else {
            return print("NewCodeQuizInteractor :: code language should be selected at this point.")
        }

        self.currentCode = request.code

        let reply = CodeReply(code: request.code, language: codeLanguage)
        self.moduleOutput?.update(reply: reply)
    }

    func doLanguageSelect(request: NewCodeQuiz.LanguageSelect.Request) {
        defer {
            self.presentNewData()
        }

        AnalyticsReporter.reportEvent(
            AnalyticsEvents.Code.languageChosen,
            parameters: [
                "size": "standard",
                "language": request.language
            ]
        )

        self.currentLanguageName = request.language.rawValue

        guard let options = self.currentOptions else {
            return
        }

        if let userTemplate = options.template(language: request.language, userGenerated: true) {
            self.currentCode = userTemplate.templateString
        } else if let template = options.template(language: request.language, userGenerated: false) {
            self.currentCode = template.templateString
        }
    }

    // MARK: - Private API

    private func presentNewData() {
        guard let options = self.currentOptions else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                code: self.currentCode,
                language: self.currentCodeLanguage,
                languageName: self.currentLanguageName,
                options: options,
                status: self.currentStatus
            )
        )
    }

    private func updateUserCodeTemplate() {
        guard let options = self.currentOptions,
              let code = self.currentCode,
              let codeLanguage = self.currentCodeLanguage else {
            return
        }

        if let userTemplate = options.template(language: codeLanguage, userGenerated: true) {
            userTemplate.templateString = code
        } else {
            let newTemplate = CodeTemplate(language: codeLanguage, template: code)
            newTemplate.isUserGenerated = true
            options.templates += [newTemplate]
        }

        CoreDataHelper.instance.save()
    }
}

extension NewCodeQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            self.currentLanguageName = nil
            self.currentCode = nil
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? CodeReply {
            self.currentLanguageName = reply.languageName
            self.currentCode = reply.code
            return
        }

        fatalError("Unexpected reply type")
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    func update(options: StepOptions?) {
        self.currentOptions = options
    }
}
