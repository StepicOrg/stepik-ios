import Foundation
import PromiseKit

protocol NewStringQuizInteractorProtocol {
    func doReplyUpdate(request: NewStringQuiz.ReplyConvert.Request)
}

final class NewStringQuizInteractor: NewStringQuizInteractorProtocol {
    weak var moduleOutput: NewStringQuizOutputProtocol?

    private let presenter: NewStringQuizPresenterProtocol
    private let provider: NewStringQuizProviderProtocol
    private let type: NewStringQuiz.DataType

    private var currentStatus: QuizStatus?
    private var currentText: String?

    init(
        type: NewStringQuiz.DataType,
        presenter: NewStringQuizPresenterProtocol,
        provider: NewStringQuizProviderProtocol
    ) {
        self.type = type
        self.presenter = presenter
        self.provider = provider
    }

    func doReplyUpdate(request: NewStringQuiz.ReplyConvert.Request) {
        self.currentText = request.text

        let reply: Reply = {
            switch self.type {
            case .number:
                return NumberReply(number: request.text)
            case .string:
                return TextReply(text: request.text)
            case .math:
                return MathReply(formula: request.text)
            }
        }()

        self.moduleOutput?.update(reply: reply)
    }

    private func presentNewData() {
        self.presenter.presentReply(response: .init(text: self.currentText, status: self.currentStatus))
    }
}

extension NewStringQuizInteractor: NewStringQuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            self.currentText = nil
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? TextReply {
            self.currentText = reply.text
            return
        }

        if let reply = reply as? MathReply {
            self.currentText = reply.formula
            return
        }

        if let reply = reply as? NumberReply {
            self.currentText = reply.number
            return
        }

        fatalError("Unexpected reply type")
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }
}
