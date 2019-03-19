import Foundation
import PromiseKit

protocol ProfileEditInteractorProtocol {
    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request)
    func doRemoteProfileUpdate(request: ProfileEdit.RemoteProfileUpdate.Request)
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

    func doRemoteProfileUpdate(request: ProfileEdit.RemoteProfileUpdate.Request) {
        self.currentProfile.firstName = request.firstName
        self.currentProfile.lastName = request.lastName
        self.currentProfile.shortBio = request.shortBio
        self.currentProfile.details = request.details

        self.provider.update(profile: self.currentProfile).done { updatedProfile in
            self.currentProfile = updatedProfile
            self.presenter.presentProfileEditResult(response: .init(isSuccessful: true))
        }.catch { error in
            print("profile edit interactor: unable to update profile, error = \(error)")
            self.presenter.presentProfileEditResult(response: .init(isSuccessful: false))
        }
    }
}
