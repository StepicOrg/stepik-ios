import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doReplyLoad(request: NewCodeQuiz.ReplyLoad.Request)
    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request)
    func doReplySubmit(request: NewCodeQuiz.ReplySubmit.Request)
    func doLanguageSelect(request: NewCodeQuiz.LanguageSelect.Request)
    func doFullscreenAction(request: NewCodeQuiz.FullscreenPresentation.Request)
}

final class NewCodeQuizInteractor: NewCodeQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewCodeQuizPresenterProtocol
    private let provider: NewCodeQuizProviderProtocol

    private var codeDetails: CodeDetails?
    private var currentStatus: QuizStatus?

    private var languageName: String?
    private var language: CodeLanguage? {
        return CodeLanguage(rawValue: self.languageName ?? "")
    }

    private var currentCode: String? {
        didSet {
            self.updateUserCodeTemplate()
        }
    }

    init(
        presenter: NewCodeQuizPresenterProtocol,
        provider: NewCodeQuizProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doReplyLoad(request: NewCodeQuiz.ReplyLoad.Request) {
        self.presentNewData()
    }

    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request) {
        self.currentCode = request.code
        self.outputCurrentReply()
    }

    func doReplySubmit(request: NewCodeQuiz.ReplySubmit.Request) {
        guard let reply = request.reply else {
            return
        }

        self.update(reply: reply)
        self.moduleOutput?.submit(reply: reply)
    }

    func doLanguageSelect(request: NewCodeQuiz.LanguageSelect.Request) {
        AnalyticsReporter.reportEvent(
            AnalyticsEvents.Code.languageChosen,
            parameters: [
                "size": "standard",
                "language": request.language.rawValue
            ]
        )

        self.languageName = request.language.rawValue

        guard let codeDetails = self.codeDetails,
              let language = self.language else {
            return self.presentNewData()
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

        self.provider.updateAutoSuggestedCodeLanguage(language: language, stepID: codeDetails.stepID).cauterize()
    }

    func doFullscreenAction(request: NewCodeQuiz.FullscreenPresentation.Request) {
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
                status: self.currentStatus
            )
        )
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
            self.languageName = reply.languageName
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

    private func handleEmptyReply() {
        let isCurrentLanguageUnsupported = self.languageName != self.language?.rawValue
        if isCurrentLanguageUnsupported {
            self.languageName = nil
            self.currentCode = nil
        } else if self.codeDetails?.stepOptions.languages.count == 1,
                  let language = self.codeDetails?.stepOptions.languages.first {
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
