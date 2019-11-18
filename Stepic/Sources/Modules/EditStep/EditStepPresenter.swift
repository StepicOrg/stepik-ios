import UIKit

protocol EditStepPresenterProtocol {
    func presentSomeActionResult(response: EditStep.SomeAction.Response)
}

final class EditStepPresenter: EditStepPresenterProtocol {
    weak var viewController: EditStepViewControllerProtocol?

    func presentSomeActionResult(response: EditStep.SomeAction.Response) { }
}