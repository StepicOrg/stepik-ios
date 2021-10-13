import UIKit

final class WishlistWidgetAssembly: Assembly {
    var moduleInput: WishlistWidgetInputProtocol?

    func makeModule() -> UIViewController {
        let provider = WishlistWidgetProvider(
            wishlistService: WishlistService.default,
            userAccountService: UserAccountService()
        )
        let presenter = WishlistWidgetPresenter()
        let interactor = WishlistWidgetInteractor(
            presenter: presenter,
            provider: provider,
            dataBackUpdateService: DataBackUpdateService.default
        )
        let viewController = WishlistWidgetViewController(interactor: interactor, analytics: StepikAnalytics.shared)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
