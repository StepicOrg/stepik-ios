import Foundation
import PromiseKit

protocol FillBlanksQuizInteractorProtocol {
    func doSomeAction(request: FillBlanksQuiz.SomeAction.Request)
}

final class FillBlanksQuizInteractor: FillBlanksQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: FillBlanksQuizPresenterProtocol

    init(presenter: FillBlanksQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doSomeAction(request: FillBlanksQuiz.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension FillBlanksQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {}

    func update(status: QuizStatus?) {}

    func update(dataset: Dataset?) {}

    func update(feedback: SubmissionFeedback?) {}

    func update(quizTitleVisibility isVisible: Bool) {}
}
