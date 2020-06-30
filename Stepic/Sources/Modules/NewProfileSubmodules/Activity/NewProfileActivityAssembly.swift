import UIKit

final class NewProfileActivityAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileActivityProvider(
            userActivitiesNetworkService: UserActivitiesNetworkService(userActivitiesAPI: UserActivitiesAPI()),
            userActivitiesPersistenceService: UserActivitiesPersistenceService()
        )
        let presenter = NewProfileActivityPresenter()
        let interactor = NewProfileActivityInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileActivityViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
