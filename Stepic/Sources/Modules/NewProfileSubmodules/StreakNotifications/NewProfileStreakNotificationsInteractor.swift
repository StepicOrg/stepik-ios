import Foundation
import PromiseKit

protocol NewProfileStreakNotificationsInteractorProtocol {
    func doStreakNotificationsLoad(request: NewProfileStreakNotifications.StreakNotificationsLoad.Request)
    func doStreakNotificationsPreferenceUpdate(
        request: NewProfileStreakNotifications.StreakNotificationsPreferenceUpdate.Request
    )
}

final class NewProfileStreakNotificationsInteractor: NewProfileStreakNotificationsInteractorProtocol {
    private let presenter: NewProfileStreakNotificationsPresenterProtocol
    private let streakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol

    init(
        presenter: NewProfileStreakNotificationsPresenterProtocol,
        streakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol
    ) {
        self.presenter = presenter
        self.streakNotificationsStorageManager = streakNotificationsStorageManager
    }

    func doStreakNotificationsLoad(request: NewProfileStreakNotifications.StreakNotificationsLoad.Request) {
        DispatchQueue.main.async {
            self.presentStreakNotifications()
        }
    }

    func doStreakNotificationsPreferenceUpdate(
        request: NewProfileStreakNotifications.StreakNotificationsPreferenceUpdate.Request
    ) {
        DispatchQueue.main.async {
            self.streakNotificationsStorageManager.isStreakNotificationsEnabled = request.isOn
            self.presentStreakNotifications()
        }
    }

    private func presentStreakNotifications() {
        self.presenter.presentStreakNotifications(
            response: .init(
                isStreakNotificationsEnabled: self.streakNotificationsStorageManager.isStreakNotificationsEnabled,
                streaksNotificationsStartHour: self.streakNotificationsStorageManager.streakNotificationsStartHourUTC
            )
        )
    }
}

extension NewProfileStreakNotificationsInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isOnline: Bool) {
        self.doStreakNotificationsLoad(request: .init())
    }
}
