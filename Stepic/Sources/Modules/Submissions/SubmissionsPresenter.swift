import UIKit

protocol SubmissionsPresenterProtocol {
    func presentSomeActionResult(response: Submissions.SomeAction.Response)
}

final class SubmissionsPresenter: SubmissionsPresenterProtocol {
    weak var viewController: SubmissionsViewControllerProtocol?

    func presentSomeActionResult(response: Submissions.SomeAction.Response) {}
}
