import UIKit

protocol ProfileEditPresenterProtocol {
    func presentProfileEditForm(response: ProfileEdit.ProfileEditLoad.Response)
    func presentProfileEditResult(response: ProfileEdit.RemoteProfileUpdate.Response)
}

final class ProfileEditPresenter: ProfileEditPresenterProtocol {
    weak var viewController: ProfileEditViewControllerProtocol?

    func presentProfileEditForm(response: ProfileEdit.ProfileEditLoad.Response) {
        let viewModel = ProfileEditViewModel(
            firstName: response.profile.firstName,
            lastName: response.profile.lastName
        )

        self.viewController?.displayProfileEditForm(viewModel: .init(viewModel: viewModel))
    }

    func presentProfileEditResult(response: ProfileEdit.RemoteProfileUpdate.Response) {
        self.viewController?.displayProfileEditResult(viewModel: .init(isSuccessful: response.isSuccessful))
    }
}
