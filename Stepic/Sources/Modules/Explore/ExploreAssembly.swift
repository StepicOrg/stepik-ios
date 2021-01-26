import UIKit

class ExploreAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ExplorePresenter(urlFactory: StepikURLFactory())
        let interactor = ExploreInteractor(
            presenter: presenter,
            contentLanguageService: ContentLanguageService(),
            networkReachabilityService: NetworkReachabilityService(),
            userAccountService: UserAccountService(),
            personalOffersService: PersonalOffersService(
                storageRecordsNetworkService: StorageRecordsNetworkService(storageRecordsAPI: StorageRecordsAPI())
            ),
            languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityService()
        )
        let viewController = ExploreViewController(interactor: interactor, analytics: StepikAnalytics.shared)

        presenter.viewController = viewController
        return viewController
    }
}
