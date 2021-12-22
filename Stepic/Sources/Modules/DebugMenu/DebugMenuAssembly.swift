import UIKit

final class DebugMenuAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = DebugMenuProvider(iapSettingsStorageManager: IAPSettingsStorageManager())
        let presenter = DebugMenuPresenter()
        let interactor = DebugMenuInteractor(
            presenter: presenter,
            provider: provider,
            iapService: IAPService.shared
        )
        let viewController = DebugMenuViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
