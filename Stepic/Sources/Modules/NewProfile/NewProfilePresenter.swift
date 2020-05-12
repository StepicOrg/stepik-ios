import UIKit

protocol NewProfilePresenterProtocol {
    func presentProfile(response: NewProfile.ProfileLoad.Response)
    func presentNavigationControls(response: NewProfile.NavigationControlsPresentation.Response)
    func presentAuthorization(response: NewProfile.AuthorizationPresentation.Response)
    func presentProfileSharing(response: NewProfile.ProfileShareAction.Response)
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

    func presentAuthorization(response: NewProfile.AuthorizationPresentation.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentProfileSharing(response: NewProfile.ProfileShareAction.Response) {
        let urlPath = "\(StepikApplicationsInfo.stepikURL)/users/\(response.userID)"
        self.viewController?.displayProfileSharing(viewModel: .init(urlPath: urlPath))
    }

    // MARK: Private API

    private func makeViewModel(user: User) -> NewProfileViewModel {
        let headerViewModel = self.makeHeaderViewModel(user: user)
        let formattedUserID = "User ID: \(user.id)"

        return NewProfileViewModel(
            headerViewModel: headerViewModel,
            formattedUserID: formattedUserID
        )
    }

    private func makeHeaderViewModel(user: User) -> NewProfileHeaderViewModel {
        let username = user.fullName.isEmpty ? "User \(user.id)" : user.fullName
        let shortBio = user.bio.trimmingCharacters(in: .whitespacesAndNewlines)

        let reputationCount = user.reputation > 0 ? user.reputation : nil
        let knowledgeCount = user.knowledge > 0 ? user.knowledge : nil

        return NewProfileHeaderViewModel(
            avatarURL: URL(string: user.avatarURL),
            username: username,
            shortBio: shortBio,
            reputationCount: reputationCount,
            knowledgeCount: knowledgeCount
        )
    }
}
