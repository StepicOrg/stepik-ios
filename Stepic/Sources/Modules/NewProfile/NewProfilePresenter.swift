import UIKit

protocol NewProfilePresenterProtocol {
    func presentProfile(response: NewProfile.ProfileLoad.Response)
    func presentNavigationControls(response: NewProfile.NavigationControlsPresentation.Response)
    func presentSubmoduleEmptyState(response: NewProfile.SubmoduleEmptyStatePresentation.Response)
    func presentAuthorization(response: NewProfile.AuthorizationPresentation.Response)
    func presentProfileSharing(response: NewProfile.ProfileShareAction.Response)
    func presentProfileEditing(response: NewProfile.ProfileEditAction.Response)
    func presentAchievementsList(response: NewProfile.AchievementsListPresentation.Response)
    func presentCertificatesList(response: NewProfile.CertificatesListPresentation.Response)
}

final class NewProfilePresenter: NewProfilePresenterProtocol {
    weak var viewController: NewProfileViewControllerProtocol?

    func presentProfile(response: NewProfile.ProfileLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(user: data.user, isCurrentUserProfile: data.isCurrentUserProfile)
            self.viewController?.displayProfile(viewModel: .init(state: .result(data: viewModel)))
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
                isSettingsAvailable: response.shouldPresentSettings,
                isEditProfileAvailable: response.shouldPresentEditProfile,
                isShareProfileAvailable: response.shouldPresentShareProfile
            )
        )
    }

    func presentSubmoduleEmptyState(response: NewProfile.SubmoduleEmptyStatePresentation.Response) {
        self.viewController?.displaySubmoduleEmptyState(viewModel: .init(module: response.module))
    }

    func presentAuthorization(response: NewProfile.AuthorizationPresentation.Response) {
        self.viewController?.displayAuthorization(viewModel: .init())
    }

    func presentProfileSharing(response: NewProfile.ProfileShareAction.Response) {
        let urlPath = "\(StepikApplicationsInfo.stepikURL)/users/\(response.userID)"
        self.viewController?.displayProfileSharing(viewModel: .init(urlPath: urlPath))
    }

    func presentProfileEditing(response: NewProfile.ProfileEditAction.Response) {
        self.viewController?.displayProfileEditing(viewModel: .init(profile: response.profile))
    }

    func presentAchievementsList(response: NewProfile.AchievementsListPresentation.Response) {
        self.viewController?.displayAchievementsList(viewModel: .init(userID: response.userID))
    }

    func presentCertificatesList(response: NewProfile.CertificatesListPresentation.Response) {
        self.viewController?.displayCertificatesList(viewModel: .init(userID: response.userID))
    }

    // MARK: Private API

    private func makeViewModel(user: User, isCurrentUserProfile: Bool) -> NewProfileViewModel {
        NewProfileViewModel(
            headerViewModel: self.makeHeaderViewModel(user: user),
            userID: user.id,
            userDetails: user.details,
            isCurrentUserProfile: isCurrentUserProfile
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
