import Foundation
import PromiseKit

protocol ProfileEditInteractorProtocol {
    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request)
}

final class ProfileEditInteractor: ProfileEditInteractorProtocol {
    private let presenter: ProfileEditPresenterProtocol
    private let provider: ProfileEditProviderProtocol

    private var currentProfile: Profile

    init(
        presenter: ProfileEditPresenterProtocol,
        provider: ProfileEditProviderProtocol,
        initialProfile: Profile
    ) {
        self.presenter = presenter
        self.provider = provider
        self.currentProfile = initialProfile
    }

    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request) {
        self.presenter.presentProfileEditForm(response: .init(profile: self.currentProfile))
    }
}
