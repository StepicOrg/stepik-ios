import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doSomeAction(request: NewCodeQuiz.SomeAction.Request)
}

final class NewCodeQuizInteractor: NewCodeQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewCodeQuizPresenterProtocol

    private var currentStatus: QuizStatus?

    init(
        presenter: NewCodeQuizPresenterProtocol
    ) {
        self.presenter = presenter
    }

    func doSomeAction(request: NewCodeQuiz.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension NewCodeQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        guard let reply = reply else {
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? CodeReply {
            print(reply)
            return
        }

        fatalError("Unexpected reply type")
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
    }

    func update(dataset: Dataset?) {
        guard let dataset = dataset else {
            return
        }
        print(dataset)
    }

    func update(feedback: SubmissionFeedback?) {
        print("feedback: \(feedback)")
    }
}
