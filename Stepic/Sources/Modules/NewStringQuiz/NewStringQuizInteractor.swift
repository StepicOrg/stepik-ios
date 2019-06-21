import Foundation
import PromiseKit

protocol NewStringQuizInteractorProtocol { }

final class NewStringQuizInteractor: NewStringQuizInteractorProtocol {
    weak var moduleOutput: NewStringQuizOutputProtocol?

    private let presenter: NewStringQuizPresenterProtocol
    private let provider: NewStringQuizProviderProtocol
    private let type: NewStringQuiz.DataType

    private var currentStatus: QuizStatus? {
        didSet {
            self.presentNewData()
        }
    }

    private var currentText: String? {
        didSet {
            self.presentNewData()
        }
    }

    init(
        type: NewStringQuiz.DataType,
        presenter: NewStringQuizPresenterProtocol,
        provider: NewStringQuizProviderProtocol
    ) {
        self.type = type
        self.presenter = presenter
        self.provider = provider
    }

    private func presentNewData() {
        self.presenter.presentReply(response: .init(text: self.currentText, status: self.currentStatus))
    }
}

extension NewStringQuizInteractor: NewStringQuizInputProtocol {
    func update(reply: Reply?) {
        guard let reply = reply else {
            self.currentText = nil
            return
        }

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
    }
}
