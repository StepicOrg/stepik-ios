import UIKit

protocol ProfileEditPresenterProtocol {
    func presentProfileEditForm(response: ProfileEdit.ProfileEditLoad.Response)
    func presentProfileEditResult(response: ProfileEdit.RemoteProfileUpdate.Response)
    func presentWaitingState(response: ProfileEdit.BlockingWaitingIndicatorUpdate.Response)
}

final class ProfileEditPresenter: ProfileEditPresenterProtocol {
    weak var viewController: ProfileEditViewControllerProtocol?

    func presentProfileEditForm(response: ProfileEdit.ProfileEditLoad.Response) {
        let email: String? = {
            if let primaryEmail = response.profile.emailAddresses.first(where: { $0.isPrimary }) {
                return primaryEmail.email
            }
            return response.profile.emailAddresses.first?.email
        }()

        let viewModel = ProfileEditViewModel(
            firstName: response.profile.firstName,
            lastName: response.profile.lastName,
            shortBio: response.profile.shortBio,
            details: response.profile.details,
            email: (email?.isEmpty ?? true) ? nil : email
        )

        self.viewController?.displayProfileEditForm(viewModel: .init(viewModel: viewModel))
    }

    func presentProfileEditResult(response: ProfileEdit.RemoteProfileUpdate.Response) {
        self.viewController?.displayProfileEditResult(viewModel: .init(isSuccessful: response.isSuccessful))
    }

    func presentWaitingState(response: ProfileEdit.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(
            viewModel: ProfileEdit.BlockingWaitingIndicatorUpdate.ViewModel(shouldDismiss: response.shouldDismiss)
        )
    }
}
