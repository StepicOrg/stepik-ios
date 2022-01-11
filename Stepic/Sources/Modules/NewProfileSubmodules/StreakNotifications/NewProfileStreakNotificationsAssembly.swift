import UIKit

final class NewProfileStreakNotificationsAssembly: Assembly {
    var moduleInput: NewProfileSubmoduleProtocol?

    func makeModule() -> UIViewController {
        let presenter = NewProfileStreakNotificationsPresenter()
        let provider = NewProfileStreakNotificationsProvider(
            submissionsPersistenceService: SubmissionsPersistenceService(),
            userActivitiesPersistenceService: UserActivitiesPersistenceService()
        )
        let interactor = NewProfileStreakNotificationsInteractor(
            presenter: presenter,
            provider: provider,
            streakNotificationsStorageManager: StreakNotificationsStorageManager(),
            notificationsService: NotificationsService(),
            tooltipStorageManager: TooltipStorageManager()
        )
        let viewController = NewProfileStreakNotificationsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
