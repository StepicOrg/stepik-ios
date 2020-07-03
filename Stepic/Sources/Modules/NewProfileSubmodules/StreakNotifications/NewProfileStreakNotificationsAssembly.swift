import UIKit

final class NewProfileStreakNotificationsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let presenter = NewProfileStreakNotificationsPresenter()
        let interactor = NewProfileStreakNotificationsInteractor(
            presenter: presenter,
            streakNotificationsStorageManager: StreakNotificationsStorageManager(),
            notificationsService: NotificationsService()
        )
        let viewController = NewProfileStreakNotificationsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
