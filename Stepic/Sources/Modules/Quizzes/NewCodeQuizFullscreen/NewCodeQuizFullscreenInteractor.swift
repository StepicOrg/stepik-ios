import Foundation
import PromiseKit

protocol NewCodeQuizFullscreenInteractorProtocol {
    func doSomeAction(request: NewCodeQuizFullscreen.SomeAction.Request)
}

final class NewCodeQuizFullscreenInteractor: NewCodeQuizFullscreenInteractorProtocol {
    weak var moduleOutput: NewCodeQuizFullscreenOutputProtocol?

    private let presenter: NewCodeQuizFullscreenPresenterProtocol

    init(presenter: NewCodeQuizFullscreenPresenterProtocol) {
        self.presenter = presenter
    }

    func doSomeAction(request: NewCodeQuizFullscreen.SomeAction.Request) { }
}
