import UIKit

protocol NewProfilePresenterProtocol {
    func presentProfile(response: NewProfile.ProfileLoad.Response)
    func presentNavigationControls(response: NewProfile.NavigationControlsPresentation.Response)
}

final class NewProfilePresenter: NewProfilePresenterProtocol {
    weak var viewController: NewProfileViewControllerProtocol?

    func presentProfile(response: NewProfile.ProfileLoad.Response) {
        switch response.result {
        case .success(let user):
            let viewModel = NewProfile.ProfileLoad.ViewModel(
                state: .result(data: self.makeViewModel(user: user))
            )
            self.viewController?.displayProfile(viewModel: viewModel)
        case .failure(let error):
            if case NewProfileInteractor.Error.unauthorized = error {
                self.viewController?.displayProfile(viewModel: .init(state: .anonymous))
            } else {
                self.viewController?.displayProfile(viewModel: .init(state: .error))
            }
        }
    }

    func presentNavigationControls(response: NewProfile.NavigationControlsPresentation.Response) {
        self.viewController?.displayNavigationControls(
            viewModel: .init(
                isSettingsAvailable: response.shoouldPresentSettings,
                isEditProfileAvailable: response.shoouldPresentEditProfile,
                isShareProfileAvailable: response.shoouldPresentShareProfile
            )
        )
    }

    private func makeViewModel(user: User) -> NewProfileViewModel {
        let headerViewModel = self.makeHeaderViewModel(user: user)
        let formattedUserID = "User ID: \(user.id)"

        return NewProfileViewModel(
            headerViewModel: headerViewModel,
            formattedUserID: formattedUserID
        )
    }

    private func makeHeaderViewModel(user: User) -> NewProfileHeaderViewModel {
        let shortBio = user.bio.trimmingCharacters(in: .whitespacesAndNewlines)

        return NewProfileHeaderViewModel(
            avatarURL: URL(string: user.avatarURL),
            username: user.fullName,
            shortBio: shortBio,
            reputationCount: user.reputation,
            knowledgeCount: user.knowledge
        )
    }
}
