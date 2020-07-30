import UIKit

final class NewProfileSocialProfilesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileSocialProfilesProvider(
            socialProfilesNetworkService: SocialProfilesNetworkService(socialProfilesAPI: SocialProfilesAPI()),
            socialProfilesPersistenceService: SocialProfilesPersistenceService(),
            usersPersistenceService: UsersPersistenceService()
        )
        let presenter = NewProfileSocialProfilesPresenter()
        let interactor = NewProfileSocialProfilesInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileSocialProfilesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
