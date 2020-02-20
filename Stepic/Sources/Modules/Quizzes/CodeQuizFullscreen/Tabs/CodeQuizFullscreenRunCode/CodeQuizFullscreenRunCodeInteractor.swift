import Foundation
import PromiseKit

protocol CodeQuizFullscreenRunCodeInteractorProtocol {
    func doSomeAction(request: CodeQuizFullscreenRunCode.SomeAction.Request)
}

final class CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInteractorProtocol {
    weak var moduleOutput: CodeQuizFullscreenRunCodeOutputProtocol?

    private let presenter: CodeQuizFullscreenRunCodePresenterProtocol
    private let provider: CodeQuizFullscreenRunCodeProviderProtocol

    init(
        presenter: CodeQuizFullscreenRunCodePresenterProtocol,
        provider: CodeQuizFullscreenRunCodeProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CodeQuizFullscreenRunCode.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol {}
