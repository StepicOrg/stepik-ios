import UIKit

final class NewProfileAssembly: Assembly {
    private let presentationDescription: NewProfile.PresentationDescription

    init(presentationDescription: NewProfile.PresentationDescription) {
        self.presentationDescription = presentationDescription
    }

    convenience init(otherUserID: User.IdType) {
        self.init(presentationDescription: .init(profileType: .otherUser(profileUserID: otherUserID)))
    }

    func makeModule() -> UIViewController {
        let provider = NewProfileProvider(
            usersPersistenceService: UsersPersistenceService(),
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI()),
            profilesPersistenceService: ProfilesPersistenceService(),
            profilesNetworkService: ProfilesNetworkService(profilesAPI: ProfilesAPI())
        )
        let presenter = NewProfilePresenter()

        let dataBackUpdateService = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )

        let interactor = NewProfileInteractor(
            presentationDescription: self.presentationDescription,
            presenter: presenter,
            provider: provider,
            userAccountService: UserAccountService(),
            networkReachabilityService: NetworkReachabilityService(),
            dataBackUpdateService: dataBackUpdateService
        )
        let viewController = NewProfileViewController(interactor: interactor, analytics: StepikAnalytics.shared)

        presenter.viewController = viewController

        return viewController
    }
}
