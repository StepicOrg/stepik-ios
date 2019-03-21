import Foundation
import PromiseKit

protocol ProfileEditInteractorProtocol {
    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request)
    func doRemoteProfileUpdate(request: ProfileEdit.RemoteProfileUpdate.Request)
}

final class ProfileEditInteractor: ProfileEditInteractorProtocol {
    private let presenter: ProfileEditPresenterProtocol
    private let provider: ProfileEditProviderProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var currentProfile: Profile

    init(
        initialProfile: Profile,
        presenter: ProfileEditPresenterProtocol,
        provider: ProfileEditProviderProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.currentProfile = initialProfile
        self.dataBackUpdateService = dataBackUpdateService
    }

    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request) {
        AmplitudeAnalyticsEvents.Profile.editOpened.send()
        self.presenter.presentProfileEditForm(response: .init(profile: self.currentProfile))
    }

    func doRemoteProfileUpdate(request: ProfileEdit.RemoteProfileUpdate.Request) {
        self.currentProfile.firstName = request.firstName
        self.currentProfile.lastName = request.lastName
        self.currentProfile.shortBio = request.shortBio
        self.currentProfile.details = request.details

        self.provider.update(profile: self.currentProfile).done { updatedProfile in
            self.currentProfile = updatedProfile
            self.dataBackUpdateService.triggerProfileUpdate(updatedProfile: updatedProfile)
            self.presenter.presentProfileEditResult(response: .init(isSuccessful: true))

            AmplitudeAnalyticsEvents.Profile.editSaved.send()
        }.catch { error in
            print("profile edit interactor: unable to update profile, error = \(error)")
            self.presenter.presentProfileEditResult(response: .init(isSuccessful: false))
        }
    }
}
