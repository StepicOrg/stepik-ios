import UIKit

final class ContentLanguageSwitchAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = ContentLanguageSwitchProvider(
            contentLanguageService: ContentLanguageService()
        )
        let presenter = ContentLanguageSwitchPresenter()
        let interactor = ContentLanguageSwitchInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = ContentLanguageSwitchViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
