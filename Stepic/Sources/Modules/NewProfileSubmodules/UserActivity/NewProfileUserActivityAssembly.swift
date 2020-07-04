import UIKit

final class NewProfileUserActivityAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileUserActivityProvider(
            userActivitiesNetworkService: UserActivitiesNetworkService(userActivitiesAPI: UserActivitiesAPI()),
            userActivitiesPersistenceService: UserActivitiesPersistenceService()
        )
        let presenter = NewProfileUserActivityPresenter()
        let interactor = NewProfileUserActivityInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileUserActivityViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
