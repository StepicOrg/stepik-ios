import Foundation
import PromiseKit

protocol NewProfileAchievementsInteractorProtocol {
    func doSomeAction(request: NewProfileAchievements.SomeAction.Request)
}

final class NewProfileAchievementsInteractor: NewProfileAchievementsInteractorProtocol {
    private let presenter: NewProfileAchievementsPresenterProtocol
    private let provider: NewProfileAchievementsProviderProtocol

    init(
        presenter: NewProfileAchievementsPresenterProtocol,
        provider: NewProfileAchievementsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewProfileAchievements.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension NewProfileAchievementsInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {}
}
