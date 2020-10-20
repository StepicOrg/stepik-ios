import Foundation
import PromiseKit

protocol TableQuizInteractorProtocol {
    func doSomeAction(request: TableQuiz.SomeAction.Request)
}

final class TableQuizInteractor: TableQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: TableQuizPresenterProtocol

    init(
        presenter: TableQuizPresenterProtocol
    ) {
        self.presenter = presenter
    }

    func doSomeAction(request: TableQuiz.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension TableQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {}

    func update(status: QuizStatus?) {}

    func update(dataset: Dataset?) {}

    func update(feedback: SubmissionFeedback?) {}
}
