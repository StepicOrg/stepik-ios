import Foundation
import PromiseKit

protocol UnsupportedQuizInteractorProtocol {
    func doSomeAction(request: UnsupportedQuiz.SomeAction.Request)
}

final class UnsupportedQuizInteractor: UnsupportedQuizInteractorProtocol {
    weak var moduleOutput: UnsupportedQuizOutputProtocol?

    private let presenter: UnsupportedQuizPresenterProtocol
    private let provider: UnsupportedQuizProviderProtocol

    init(
        presenter: UnsupportedQuizPresenterProtocol,
        provider: UnsupportedQuizProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: UnsupportedQuiz.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension UnsupportedQuizInteractor: UnsupportedQuizInputProtocol { }