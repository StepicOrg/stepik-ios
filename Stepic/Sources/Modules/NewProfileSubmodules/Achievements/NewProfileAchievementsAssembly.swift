import UIKit

final class NewProfileAchievementsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileAchievementsProvider()
        let presenter = NewProfileAchievementsPresenter()
        let interactor = NewProfileAchievementsInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileAchievementsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
