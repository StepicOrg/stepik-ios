import Foundation
import PromiseKit

protocol BaseQuizInteractorProtocol {
    func doSomeAction(request: BaseQuiz.SomeAction.Request)
}

final class BaseQuizInteractor: BaseQuizInteractorProtocol {
    weak var moduleOutput: BaseQuizOutputProtocol?

    private let presenter: BaseQuizPresenterProtocol
    private let provider: BaseQuizProviderProtocol

    init(
        presenter: BaseQuizPresenterProtocol,
        provider: BaseQuizProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: BaseQuiz.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension BaseQuizInteractor: BaseQuizInputProtocol { }