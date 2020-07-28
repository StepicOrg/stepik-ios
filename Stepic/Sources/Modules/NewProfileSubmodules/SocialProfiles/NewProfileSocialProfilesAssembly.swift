import UIKit

final class NewProfileSocialProfilesAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileSocialProfilesProvider()
        let presenter = NewProfileSocialProfilesPresenter()
        let interactor = NewProfileSocialProfilesInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileSocialProfilesViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
