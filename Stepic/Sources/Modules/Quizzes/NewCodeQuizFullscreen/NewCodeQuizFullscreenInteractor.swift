import Foundation
import PromiseKit

protocol NewCodeQuizFullscreenInteractorProtocol {
    func doReplyUpdate(request: NewCodeQuizFullscreen.ReplyConvert.Request)
    func doReplySubmit(request: NewCodeQuizFullscreen.ReplySubmit.Request)
    func doCodeReset(request: NewCodeQuizFullscreen.ResetCode.Request)
}

final class NewCodeQuizFullscreenInteractor: NewCodeQuizFullscreenInteractorProtocol {
    weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    private let presenter: NewCodeQuizFullscreenPresenterProtocol
    private let provider: NewCodeQuizFullscreenProviderProtocol

    private let codeDetails: CodeDetails
    private let language: CodeLanguage

    private var currentCode: String?

    init(
        presenter: NewCodeQuizFullscreenPresenterProtocol,
        provider: NewCodeQuizFullscreenProviderProtocol,
        codeDetails: CodeDetails,
        language: CodeLanguage
    ) {
        self.presenter = presenter
        self.provider = provider
        self.codeDetails = codeDetails
        self.language = language

        self.refresh()
    }

    func doReplyUpdate(request: NewCodeQuizFullscreen.ReplyConvert.Request) {
        self.currentCode = request.code
        self.moduleOutput?.update(code: request.code)
    }

    func doReplySubmit(request: NewCodeQuizFullscreen.ReplySubmit.Request) {
        let reply = CodeReply(code: self.currentCode ?? "", language: self.language)
        self.moduleOutput?.submit(reply: reply)
    }

    func doCodeReset(request: NewCodeQuizFullscreen.ResetCode.Request) {
        AnalyticsReporter.reportEvent(
            AnalyticsEvents.Code.resetPressed,
            parameters: [
                "size": "standard"
            ]
        )

        let stepID = self.codeDetails.stepID
        let language = self.language

        self.provider.deleteUserCodeTemplate(by: stepID, language: language).then { _ in
            self.provider.fetchCodeTemplate(by: stepID, language: language)
        }.done { codeTemplate in
            self.doReplyUpdate(request: .init(code: codeTemplate?.templateString ?? ""))
        }.ensure {
            self.presenter.presentCodeReset(response: .init(code: self.currentCode))
        }.catch { _ in
            self.currentCode = ""
        }
    }

    private func refresh() {
        self.provider.fetchUserOrCodeTemplate(
            by: self.codeDetails.stepID,
            language: self.language
        ).done { codeTemplate in
            self.currentCode = codeTemplate?.templateString
        }.ensure {
            self.presenter.presentContent(
                response: .init(
                    code: self.currentCode,
                    language: self.language,
                    codeDetails: self.codeDetails
                )
            )
        }.catch { error in
            print("NewCodeQuizFullscreenInteractor :: failed fetch code template \(error)")
        }
    }
}
