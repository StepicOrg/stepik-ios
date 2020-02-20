import UIKit

protocol CodeQuizFullscreenRunCodePresenterProtocol {
    func presentSomeActionResult(response: CodeQuizFullscreenRunCode.SomeAction.Response)
}

final class CodeQuizFullscreenRunCodePresenter: CodeQuizFullscreenRunCodePresenterProtocol {
    weak var viewController: CodeQuizFullscreenRunCodeViewControllerProtocol?

    func presentSomeActionResult(response: CodeQuizFullscreenRunCode.SomeAction.Response) {}
}
