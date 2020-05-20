import Foundation
import PromiseKit

protocol ProfileEditInteractorProtocol {
    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request)
    func doRemoteProfileUpdate(request: ProfileEdit.RemoteProfileUpdate.Request)
}

final class ProfileEditInteractor: ProfileEditInteractorProtocol {
    private let presenter: ProfileEditPresenterProtocol
    private let provider: ProfileEditProviderProtocol
    private let analytics: Analytics
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var currentProfile: Profile

    init(
        initialProfile: Profile,
        presenter: ProfileEditPresenterProtocol,
        provider: ProfileEditProviderProtocol,
        analytics: Analytics,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
        self.currentProfile = initialProfile
        self.dataBackUpdateService = dataBackUpdateService
    }

    func doProfileEditLoad(request: ProfileEdit.ProfileEditLoad.Request) {
        self.analytics.send(.profileEditScreenOpened)

        firstly {
            self.currentProfile.emailAddresses.isEmpty
                ? self.fetchEmailAddresses()
                : Guarantee()
        }.done {
            self.presenter.presentProfileEditForm(response: .init(profile: self.currentProfile))
        }
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

            self.analytics.send(.profileEditSaved)
        }.catch { error in
            print("profile edit interactor: unable to update profile, error = \(error)")
            self.presenter.presentProfileEditResult(response: .init(isSuccessful: false))
        }
    }

    private func fetchEmailAddresses() -> Guarantee<Void> {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        return Guarantee { seal in
            self.provider.fetchEmailAddresses(ids: self.currentProfile.emailAddressesArray).done { emailAddresses in
                self.currentProfile.emailAddresses = emailAddresses
                seal(())
            }.ensure {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            }.catch { _ in
                seal(())
            }
        }
    }
}
