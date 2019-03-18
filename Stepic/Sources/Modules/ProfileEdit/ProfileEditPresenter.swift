import UIKit

protocol ProfileEditPresenterProtocol {
    func presentProfileEditForm(response: ProfileEdit.ProfileEditLoad.Response)
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
}
