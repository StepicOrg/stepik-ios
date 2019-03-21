import UIKit

final class ProfileEditAssembly: Assembly {
    // We should init assembly with profile to open
    private let profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }

    func makeModule() -> UIViewController {
        let provider = ProfileEditProvider(
            profilesNetworkService: ProfilesNetworkService(profilesAPI: ProfilesAPI())
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
        let viewController = ProfileEditViewController(interactor: interactor)

        presenter.viewController = viewController
        viewController.hidesBottomBarWhenPushed = true

        return viewController
    }
}
