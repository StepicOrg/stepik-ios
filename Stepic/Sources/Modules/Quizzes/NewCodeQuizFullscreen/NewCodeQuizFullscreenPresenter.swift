import UIKit

protocol NewCodeQuizFullscreenPresenterProtocol {
    func presentSomeActionResult(response: NewCodeQuizFullscreen.SomeAction.Response)
}

final class NewCodeQuizFullscreenPresenter: NewCodeQuizFullscreenPresenterProtocol {
    weak var viewController: NewCodeQuizFullscreenViewControllerProtocol?

    func presentSomeActionResult(response: NewCodeQuizFullscreen.SomeAction.Response) { }
}