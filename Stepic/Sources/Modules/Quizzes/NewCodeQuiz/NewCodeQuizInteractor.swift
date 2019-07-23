import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request)
}

final class NewCodeQuizInteractor: NewCodeQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewCodeQuizPresenterProtocol

    private var currentCode: String?
    private var currentLanguage: CodeLanguage?
    private var currentOptions: StepOptions?
    private var currentStatus: QuizStatus?

    init(presenter: NewCodeQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request) {
        self.currentCode = request.code
        self.currentLanguage = CodeLanguage(rawValue: request.language)

        guard let language = self.currentLanguage else {
            fatalError("language should exists at this point")
        }

        let reply = CodeReply(code: request.code, language: language)
        self.moduleOutput?.update(reply: reply)
    }

    private func presentNewData() {
        guard let options = self.currentOptions else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                code: self.currentCode,
                language: self.currentLanguage,
                options: options,
                status: self.currentStatus
            )
        )
    }
}

extension NewCodeQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? CodeReply {
            self.currentCode = reply.code
            self.currentLanguage = reply.language
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
