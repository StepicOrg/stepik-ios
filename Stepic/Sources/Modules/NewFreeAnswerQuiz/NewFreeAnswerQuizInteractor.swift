import Foundation
import PromiseKit

protocol NewFreeAnswerQuizInteractorProtocol {
    func doReplyUpdate(request: NewFreeAnswerQuiz.ReplyConvert.Request)
}

final class NewFreeAnswerQuizInteractor: NewFreeAnswerQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewFreeAnswerQuizPresenterProtocol
    
    private var currentText: String?
    private var currentStatus: QuizStatus?

    init(presenter: NewFreeAnswerQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewFreeAnswerQuiz.ReplyConvert.Request) {
        self.currentText = request.text
        let reply = FreeAnswerReply(text: request.text)
        self.moduleOutput?.update(reply: reply)
    }

    private func presentNewData() {
        self.presenter.presentReply(response: .init(text: self.currentText, status: self.currentStatus))
    }
}

extension NewFreeAnswerQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            self.currentText = nil
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? FreeAnswerReply {
            self.currentText = reply.text
            return
        }

        fatalError("Unsupported reply")
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }
}
