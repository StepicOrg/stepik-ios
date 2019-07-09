import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doSomeAction(request: NewCodeQuiz.SomeAction.Request)
}

final class NewCodeQuizInteractor: NewCodeQuizInteractorProtocol {
    weak var moduleOutput: NewCodeQuizOutputProtocol?

    private let presenter: NewCodeQuizPresenterProtocol
    private let provider: NewCodeQuizProviderProtocol

    init(
        presenter: NewCodeQuizPresenterProtocol,
        provider: NewCodeQuizProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewCodeQuiz.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension NewCodeQuizInteractor: NewCodeQuizInputProtocol { }