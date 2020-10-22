import Foundation
import PromiseKit

protocol CodeQuizInteractorProtocol {
    func doReplyLoad(request: CodeQuiz.ReplyLoad.Request)
    func doReplyUpdate(request: CodeQuiz.ReplyConvert.Request)
    func doReplySubmit(request: CodeQuiz.ReplySubmit.Request)
    func doLanguageSelect(request: CodeQuiz.LanguageSelect.Request)
    func doFullscreenAction(request: CodeQuiz.FullscreenPresentation.Request)
}

final class CodeQuizInteractor: CodeQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: CodeQuizPresenterProtocol
    private let provider: CodeQuizProviderProtocol
    private let analytics: Analytics

    private var codeDetails: CodeDetails?
    private var currentStatus: QuizStatus?

    private var languageName: String?
    private var language: CodeLanguage? { CodeLanguage(rawValue: self.languageName ?? "") }

    private var currentCode: String? {
        didSet {
            if self.isCurrentUserCodeTemplateUpdateEnabled {
                self.updateUserCodeTemplate()
            }
        }
    }

    private var isQuizTitleVisible = true

    var isCurrentUserCodeTemplateUpdateEnabled: Bool = true

    init(
        presenter: CodeQuizPresenterProtocol,
        provider: CodeQuizProviderProtocol,
        analytics: Analytics,
        language: CodeLanguage?
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
        self.languageName = language?.rawValue
    }

    func doReplyLoad(request: CodeQuiz.ReplyLoad.Request) {
        self.presentNewData()
    }

    func doReplyUpdate(request: CodeQuiz.ReplyConvert.Request) {
        self.currentCode = request.code
        self.outputCurrentReply()
    }

    func doReplySubmit(request: CodeQuiz.ReplySubmit.Request) {
        guard let reply = request.reply else {
            return
        }

        self.update(reply: reply)
        self.moduleOutput?.submit(reply: reply)
    }

    func doLanguageSelect(request: CodeQuiz.LanguageSelect.Request) {
        self.analytics.send(.codeLanguageChosen(language: request.language))

        self.languageName = request.language.rawValue

        guard let codeDetails = self.codeDetails,
              let language = self.language else {
            return self.presentNewData()
        }

        self.fetchUserOrCodeTemplate()
        self.provider.updateAutoSuggestedCodeLanguage(language: language, stepID: codeDetails.stepID).cauterize()
    }

    func doFullscreenAction(request: CodeQuiz.FullscreenPresentation.Request) {
        guard let language = self.language,
              let codeDetails = self.codeDetails else {
            return
        }

        self.provider.fetchLessonTitle(by: codeDetails.stepID).done { lessonTitle in
            self.presenter.presentFullscreen(
                response: .init(
                    language: language,
                    codeDetails: codeDetails,
                    lessonTitle: lessonTitle
                )
            )
        }
    }

    // MARK: - Private API

    private func presentNewData() {
        guard let codeDetails = self.codeDetails else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                code: self.currentCode,
                language: self.language,
                languageName: self.languageName,
                codeDetails: codeDetails,
                status: self.currentStatus,
                isQuizTitleVisible: self.isQuizTitleVisible
            )
        )
    }

    private func fetchUserOrCodeTemplate() {
        guard let codeDetails = self.codeDetails,
              let language = self.language else {
            return
        }

        self.provider.fetchUserOrCodeTemplate(
            by: codeDetails.stepID,
            language: language
        ).done { [weak self] codeTemplate in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentCode = codeTemplate?.templateString
            strongSelf.outputCurrentReply()
            strongSelf.presentNewData()
        }.cauterize()
    }

    private func updateUserCodeTemplate() {
        guard let codeDetails = self.codeDetails,
              let language = self.language,
              let code = self.currentCode else {
            return
        }

        self.provider.updateUserCodeTemplate(
            stepID: codeDetails.stepID,
            language: language,
            code: code
        ).cauterize()
    }

    private func outputCurrentReply() {
        guard let code = self.currentCode,
              let language = self.language else {
            return
        }

        let reply: Reply = {
            switch language {
            case .sql:
                return SQLReply(code: code)
            default:
                return CodeReply(code: code, language: language)
            }
        }()

        self.moduleOutput?.update(reply: reply)
    }
}

extension CodeQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.outputCurrentReply()
            self.presentNewData()
        }

        guard let reply = reply else {
            return self.handleEmptyReply()
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? CodeReply {
            self.languageName = reply.languageName
            self.currentCode = reply.code
            return
        }

        if let reply = reply as? SQLReply {
            self.languageName = CodeLanguage.sql.rawValue
            self.currentCode = reply.code
            return
        }

        fatalError("Unexpected reply type")
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    func update(codeDetails: CodeDetails?) {
        self.codeDetails = codeDetails
    }

    func update(quizTitleVisibility isVisible: Bool) {
        self.isQuizTitleVisible = isVisible
    }

    private func handleEmptyReply() {
        if self.language == CodeLanguage.sql {
            guard self.currentCode?.isEmpty ?? true else {
                return
            }

            return self.fetchUserOrCodeTemplate()
        }

        let isCurrentLanguageUnsupported = self.languageName != self.language?.rawValue
        if isCurrentLanguageUnsupported {
            self.languageName = nil
            self.currentCode = nil
        } else if self.codeDetails?.stepOptions.getLanguages().count == 1,
                  let language = self.codeDetails?.stepOptions.getLanguages().first {
            self.doLanguageSelect(request: .init(language: language))
        } else if let stepID = self.codeDetails?.stepID {
            self.provider.fetchAutoSuggestedCodeLanguage(by: stepID).done { language in
                guard let language = language else {
                    return
                }

                self.doLanguageSelect(request: .init(language: language))
            }
        }
    }
}
