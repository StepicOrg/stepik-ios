import UIKit

final class ProfileEditAssembly: Assembly {
    // We should init assembly with profile to open
    private let profile: Profile
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    init(
        profile: Profile,
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()
    ) {
        self.profile = profile
        self.navigationBarAppearance = navigationBarAppearance
    }

    func makeModule() -> UIViewController {
        let provider = ProfileEditProvider(
            profilesNetworkService: ProfilesNetworkService(profilesAPI: ProfilesAPI()),
            emailAddressesNetworkService: EmailAddressesNetworkService(emailAddressesAPI: EmailAddressesAPI())
        )
        let presenter = ProfileEditPresenter()
        let interactor = ProfileEditInteractor(
            initialProfile: self.profile,
            presenter: presenter,
            provider: provider,
            dataBackUpdateService: DataBackUpdateService(
                unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
                sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
                coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
                progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
            )
        )
        let viewController = ProfileEditViewController(
            interactor: interactor,
            appearance: .init(
                navigationBarAppearance: self.navigationBarAppearance
            )
        )

        presenter.viewController = viewController
        viewController.hidesBottomBarWhenPushed = true

        return viewController
    }
}
