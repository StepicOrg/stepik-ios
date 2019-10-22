import UIKit

protocol WriteCommentPresenterProtocol {
    func presentSomeActionResult(response: WriteComment.SomeAction.Response)
}

final class WriteCommentPresenter: WriteCommentPresenterProtocol {
    weak var viewController: WriteCommentViewControllerProtocol?

    func presentSomeActionResult(response: WriteComment.SomeAction.Response) { }
}