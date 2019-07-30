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
        self.currentCode = request.code
        self.outputCurrentReply()
    }

    func doLanguageSelect(request: NewCodeQuiz.LanguageSelect.Request) {
        defer {
            self.presentNewData()
        }

        AnalyticsReporter.reportEvent(
            AnalyticsEvents.Code.languageChosen,
            parameters: [
                "size": "standard",
                "language": request.language.rawValue
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

        self.outputCurrentReply()
    }

    // MARK: - Private API

    private func presentNewData() {
        guard let options = self.currentOptions else {
            return
        }

        let codeTemplate: String? = {
            if let language = self.currentCodeLanguage {
                return options.template(language: language, userGenerated: false)?.templateString
            }
            return nil
        }()

        self.presenter.presentReply(
            response: .init(
                code: self.currentCode,
                codeTemplate: codeTemplate,
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

    private func outputCurrentReply() {
        guard let code = self.currentCode,
              let language = self.currentCodeLanguage else {
            return
        }

        let reply = CodeReply(code: code, language: language)
        self.moduleOutput?.update(reply: reply)
    }
}

extension NewCodeQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            return self.handleEmptyReply()
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

    private func handleEmptyReply() {
        let isCurrentLanguageUnsupported = self.currentLanguageName != self.currentCodeLanguage?.rawValue
        if isCurrentLanguageUnsupported {
            self.currentLanguageName = nil
            self.currentCode = nil
        } else if self.currentOptions?.languages.count == 1,
                  let language = self.currentOptions?.languages.first {
            self.doLanguageSelect(request: .init(language: language))
        }
    }
}
