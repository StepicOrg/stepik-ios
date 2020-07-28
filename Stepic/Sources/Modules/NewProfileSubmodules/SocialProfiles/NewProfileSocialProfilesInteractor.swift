import Foundation
import PromiseKit

protocol NewProfileSocialProfilesInteractorProtocol {
    func doSomeAction(request: NewProfileSocialProfiles.SomeAction.Request)
}

final class NewProfileSocialProfilesInteractor: NewProfileSocialProfilesInteractorProtocol {
    private let presenter: NewProfileSocialProfilesPresenterProtocol
    private let provider: NewProfileSocialProfilesProviderProtocol

    init(
        presenter: NewProfileSocialProfilesPresenterProtocol,
        provider: NewProfileSocialProfilesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewProfileSocialProfiles.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension NewProfileSocialProfilesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {}
}
