import UIKit

protocol NewSettingsPresenterProtocol {
    func presentSettings(response: NewSettings.SettingsLoad.Response)
}

final class NewSettingsPresenter: NewSettingsPresenterProtocol {
    weak var viewController: NewSettingsViewControllerProtocol?

    func presentSettings(response: NewSettings.SettingsLoad.Response) {
        self.viewController?.displaySettings(viewModel: .init())
    }
}
