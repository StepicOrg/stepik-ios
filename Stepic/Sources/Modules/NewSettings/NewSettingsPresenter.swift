import UIKit

protocol NewSettingsPresenterProtocol {
    func presentSomeActionResult(response: NewSettings.SomeAction.Response)
}

final class NewSettingsPresenter: NewSettingsPresenterProtocol {
    weak var viewController: NewSettingsViewControllerProtocol?

    func presentSomeActionResult(response: NewSettings.SomeAction.Response) { }
}
