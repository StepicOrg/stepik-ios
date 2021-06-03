import UIKit

final class WishlistWidgetAssembly: Assembly {
    var moduleInput: WishlistWidgetInputProtocol?

    func makeModule() -> UIViewController {
        let provider = WishlistWidgetProvider()
        let presenter = WishlistWidgetPresenter()
        let interactor = WishlistWidgetInteractor(presenter: presenter, provider: provider)
        let viewController = WishlistWidgetViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
