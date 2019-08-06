import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request)
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

    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request) {
        self.currentCode = request.code
        self.outputCurrentReply()
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
    }

    func doFullscreenAction(request: NewCodeQuiz.FullscreenPresentation.Request) {
        guard let language = self.language,
              let codeDetails = self.codeDetails else {
            return
        }

        self.provider.fetchStepOptions(by: codeDetails.stepID).done { stepOptions in
            guard let stepOptions = stepOptions else {
                return
            }

            let data = NewCodeQuiz.FullscreenPresentation.Data(
                content: codeDetails.stepContent,
                language: language,
                options: stepOptions
            )

            self.presenter.presentFullscreen(response: .init(data: data))
        }.cauterize()
    }

    // MARK: - Private API

    private func presentNewData() {
        guard let codeDetails = self.codeDetails else {
            return
        }

        let codeTemplate: String? = {
            if let language = self.codeLanguage {
                return codeDetails.stepOptions.templates
                    .first(where: { $0.language == language.rawValue && !$0.isUserGenerated })?
                    .template
            }
            return nil
        }()

        self.provider.fetchStepOptions(by: codeDetails.stepID).done { stepOptions in
            guard let stepOptions = stepOptions else {
                return
            }

            self.presenter.presentReply(
                response: .init(
                    code: self.currentCode,
                    codeTemplate: codeTemplate,
                    language: self.codeLanguage,
                    languageName: self.languageName,
                    options: stepOptions,
                    status: self.currentStatus
                )
            )
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
        }
    }
}
