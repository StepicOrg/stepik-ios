import Foundation
import PromiseKit

protocol NewProfileStreakNotificationsInteractorProtocol {
    func doSomeAction(request: NewProfileStreakNotifications.SomeAction.Request)
}

final class NewProfileStreakNotificationsInteractor: NewProfileStreakNotificationsInteractorProtocol {
    private let presenter: NewProfileStreakNotificationsPresenterProtocol
    private let provider: NewProfileStreakNotificationsProviderProtocol

    init(
        presenter: NewProfileStreakNotificationsPresenterProtocol,
        provider: NewProfileStreakNotificationsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewProfileStreakNotifications.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension NewProfileStreakNotificationsInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isOnline: Bool) {}
}
