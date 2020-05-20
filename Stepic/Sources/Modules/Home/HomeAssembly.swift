import UIKit

final class HomeAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = HomeProvider(userActivitiesAPI: UserActivitiesAPI())
        let presenter = HomePresenter()
        let interactor = HomeInteractor(
            presenter: presenter,
            provider: provider,
            userAccountService: UserAccountService(),
            networkReachabilityService: NetworkReachabilityService(),
            contentLanguageService: ContentLanguageService()
        )
        let viewController = HomeViewController(interactor: interactor, analytics: StepikAnalytics.shared)

        presenter.viewController = viewController
        return viewController
    }
}
