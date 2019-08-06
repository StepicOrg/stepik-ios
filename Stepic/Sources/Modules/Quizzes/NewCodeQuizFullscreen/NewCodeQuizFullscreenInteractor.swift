import Foundation
import PromiseKit

protocol NewCodeQuizFullscreenInteractorProtocol {
    func doReplyUpdate(request: NewCodeQuizFullscreen.ReplyConvert.Request)
    func doReplySubmit(request: NewCodeQuizFullscreen.ReplySubmit.Request)
}

final class NewCodeQuizFullscreenInteractor: NewCodeQuizFullscreenInteractorProtocol {
    weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    private let presenter: NewCodeQuizFullscreenPresenterProtocol
    private let provider: NewCodeQuizProviderProtocol

    private let codeDetails: CodeDetails
    private let language: CodeLanguage

    private var currentCode: String?

    init(
        presenter: NewCodeQuizFullscreenPresenterProtocol,
        provider: NewCodeQuizProviderProtocol,
        codeDetails: CodeDetails,
        language: CodeLanguage
    ) {
        self.presenter = presenter
        self.provider = provider
        self.codeDetails = codeDetails
        self.language = language

        self.provider.fetchUserOrCodeTemplate(by: codeDetails.stepID, language: language).done { codeTemplate in
            self.currentCode = codeTemplate?.templateString
        }.ensure {
            self.presentNewData()
        }.catch { error in
            print("NewCodeQuizFullscreenInteractor :: failed fetch code template \(error)")
        }
    }

    func doReplyUpdate(request: NewCodeQuizFullscreen.ReplyConvert.Request) {
        self.currentCode = request.code
        self.moduleOutput?.update(code: request.code)
    }

    func doReplySubmit(request: NewCodeQuizFullscreen.ReplySubmit.Request) {
        let reply = CodeReply(code: self.currentCode ?? "", language: self.language)
        self.moduleOutput?.submit(reply: reply)
    }

    private func presentNewData() {
        self.presenter.presentContent(
            response: .init(
                code: self.currentCode,
                language: self.language,
                codeDetails: self.codeDetails
            )
        )
    }
}
