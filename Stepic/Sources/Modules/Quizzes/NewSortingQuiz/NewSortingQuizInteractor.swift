import Foundation
import PromiseKit

protocol NewSortingQuizInteractorProtocol {
    func doSomeAction(request: NewSortingQuiz.SomeAction.Request)
}

final class NewSortingQuizInteractor: NewSortingQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewSortingQuizPresenterProtocol

    init(presenter: NewSortingQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doSomeAction(request: NewSortingQuiz.SomeAction.Request) { }
}

extension NewSortingQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
    }

    func update(status: QuizStatus?) {
    }

    func update(dataset: Dataset?) {
    }

    func update(feedback: SubmissionFeedback?) {
    }
}

