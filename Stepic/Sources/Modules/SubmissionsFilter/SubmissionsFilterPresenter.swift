import UIKit

protocol SubmissionsFilterPresenterProtocol {
    func presentSomeActionResult(response: SubmissionsFilter.SomeAction.Response)
}

final class SubmissionsFilterPresenter: SubmissionsFilterPresenterProtocol {
    weak var viewController: SubmissionsFilterViewControllerProtocol?

    func presentSomeActionResult(response: SubmissionsFilter.SomeAction.Response) {}
}
