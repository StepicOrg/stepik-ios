import Foundation
import PromiseKit

protocol CodeQuizFullscreenInteractorProtocol {
    func doReplyUpdate(request: CodeQuizFullscreen.ReplyConvert.Request)
    func doReplySubmit(request: CodeQuizFullscreen.ReplySubmit.Request)
    func doCodeReset(request: CodeQuizFullscreen.ResetCode.Request)
    func doRunCodeTooltipAvailabilityCheck(request: CodeQuizFullscreen.RunCodeTooltipAvailabilityCheck.Request)
}

final class CodeQuizFullscreenInteractor: CodeQuizFullscreenInteractorProtocol {
    weak var moduleOutput: CodeQuizFullscreenOutputProtocol?

    private let presenter: CodeQuizFullscreenPresenterProtocol
    private let provider: CodeQuizFullscreenProviderProtocol
    private let tooltipStorageManager: TooltipStorageManagerProtocol

    private let codeDetails: CodeDetails
    private let language: CodeLanguage

    private var currentCode: String?

    init(
        presenter: CodeQuizFullscreenPresenterProtocol,
        provider: CodeQuizFullscreenProviderProtocol,
        tooltipStorageManager: TooltipStorageManagerProtocol,
        codeDetails: CodeDetails,
        language: CodeLanguage
    ) {
        self.presenter = presenter
        self.provider = provider
        self.tooltipStorageManager = tooltipStorageManager
        self.codeDetails = codeDetails
        self.language = language

        self.refresh()
    }

    // MARK: Protocol Conforming

    func doReplyUpdate(request: CodeQuizFullscreen.ReplyConvert.Request) {
        self.currentCode = request.code
        self.moduleOutput?.update(code: request.code)
    }

    func doReplySubmit(request: CodeQuizFullscreen.ReplySubmit.Request) {
        let reply: Reply = {
            switch self.language {
            case .sql:
                return SQLReply(code: self.currentCode ?? "")
            default:
                return CodeReply(code: self.currentCode ?? "", language: self.language)
            }
        }()

        self.moduleOutput?.submit(reply: reply)
    }

    func doCodeReset(request: CodeQuizFullscreen.ResetCode.Request) {
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

    func doRunCodeTooltipAvailabilityCheck(request: CodeQuizFullscreen.RunCodeTooltipAvailabilityCheck.Request) {
        self.presenter.presentRunCodeTooltip(
            response: .init(shouldShowTooltip: !self.tooltipStorageManager.didShowOnFullscreenCodeQuizTabRun)
        )
        self.tooltipStorageManager.didShowOnFullscreenCodeQuizTabRun = true
    }

    // MARK: Private API

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
            print("CodeQuizFullscreenInteractor :: failed fetch code template \(error)")
        }
    }
}
