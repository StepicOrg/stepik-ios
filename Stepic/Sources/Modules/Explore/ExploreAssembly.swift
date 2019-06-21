import UIKit

class ExploreAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ExplorePresenter()
        let interactor = ExploreInteractor(
            presenter: presenter,
            contentLanguageService: ContentLanguageService(),
            networkReachabilityService: NetworkReachabilityService(),
            languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityService()
        )
        let viewController = ExploreViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
