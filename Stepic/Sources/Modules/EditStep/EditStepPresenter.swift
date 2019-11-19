import UIKit

protocol EditStepPresenterProtocol {
    func presentSomeActionResult(response: EditStep.LoadStepSource.Response)
}

// MARK: - EditStepPresenter: EditStepPresenterProtocol -

final class EditStepPresenter: EditStepPresenterProtocol {
    weak var viewController: EditStepViewControllerProtocol?

    func presentSomeActionResult(response: EditStep.LoadStepSource.Response) { }
}
