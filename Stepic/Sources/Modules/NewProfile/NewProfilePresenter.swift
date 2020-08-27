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

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

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
        if let userURL = self.urlFactory.makeUser(id: response.userID) {
            self.viewController?.displayProfileSharing(viewModel: .init(urlPath: userURL.absoluteString))
        }
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
            isCurrentUserProfile: isCurrentUserProfile,
            socialProfilesCount: user.socialProfilesArray.count
        )
    }

    private func makeHeaderViewModel(user: User) -> NewProfileHeaderViewModel {
        let coverURL: URL? = {
            if let cover = user.cover {
                let urlString = "\(StepikApplicationsInfo.stepikURL)\(cover)"
                return URL(string: urlString)
            }
            return nil
        }()

        let username: String = {
            if user.fullName.isEmpty {
                return user.isOrganization ? "Organization \(user.id)" : "User \(user.id)"
            }
            return user.fullName
        }()

        let shortBio = user.bio.trimmingCharacters(in: .whitespacesAndNewlines)

        return NewProfileHeaderViewModel(
            avatarURL: URL(string: user.avatarURL),
            coverURL: coverURL,
            username: username,
            shortBio: shortBio,
            reputationCount: user.reputation,
            knowledgeCount: user.knowledge,
            issuedCertificatesCount: user.issuedCertificatesCount,
            createdCoursesCount: user.createdCoursesCount,
            isOrganization: user.isOrganization
        )
    }
}
