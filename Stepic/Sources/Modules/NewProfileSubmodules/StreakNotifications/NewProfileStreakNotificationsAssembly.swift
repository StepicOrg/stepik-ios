import UIKit

final class NewProfileStreakNotificationsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let provider = NewProfileStreakNotificationsProvider()
        let presenter = NewProfileStreakNotificationsPresenter()
        let interactor = NewProfileStreakNotificationsInteractor(presenter: presenter, provider: provider)
        let viewController = NewProfileStreakNotificationsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
