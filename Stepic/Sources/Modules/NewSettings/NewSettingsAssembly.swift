import UIKit

final class NewSettingsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = NewSettingsProvider()
        let presenter = NewSettingsPresenter()
        let interactor = NewSettingsInteractor(presenter: presenter, provider: provider)
        let viewController = NewSettingsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
