import UIKit

final class DebugMenuAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = DebugMenuProvider()
        let presenter = DebugMenuPresenter()
        let interactor = DebugMenuInteractor(presenter: presenter, provider: provider)
        let viewController = DebugMenuViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
