import UIKit

protocol NewDiscussionsPresenterProtocol {
    func presentSomeActionResult(response: NewDiscussions.SomeAction.Response)
}

final class NewDiscussionsPresenter: NewDiscussionsPresenterProtocol {
    weak var viewController: NewDiscussionsViewControllerProtocol?

    func presentSomeActionResult(response: NewDiscussions.SomeAction.Response) { }
}