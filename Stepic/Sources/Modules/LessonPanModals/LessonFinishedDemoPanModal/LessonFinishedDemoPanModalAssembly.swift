import UIKit

final class LessonFinishedDemoPanModalAssembly: Assembly {
    private let sectionID: Section.IdType
    private let promoCodeName: String?

    private weak var moduleOutput: LessonFinishedDemoPanModalOutputProtocol?

    init(
        sectionID: Section.IdType,
        promoCodeName: String? = nil,
        output: LessonFinishedDemoPanModalOutputProtocol? = nil
    ) {
        self.sectionID = sectionID
        self.promoCodeName = promoCodeName
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = LessonFinishedDemoPanModalProvider(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            mobileTiersRepository: MobileTiersRepository.default,
            wishlistRepository: WishlistRepository.default
        )
        let presenter = LessonFinishedDemoPanModalPresenter()
        let interactor = LessonFinishedDemoPanModalInteractor(
            presenter: presenter,
            provider: provider,
            sectionID: self.sectionID,
            promoCodeName: self.promoCodeName,
            iapService: IAPService.shared,
            remoteConfig: RemoteConfig.shared,
            analytics: StepikAnalytics.shared
        )
        let viewController = LessonFinishedDemoPanModalViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
