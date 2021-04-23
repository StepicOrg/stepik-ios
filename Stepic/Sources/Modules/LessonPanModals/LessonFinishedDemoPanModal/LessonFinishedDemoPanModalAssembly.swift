import UIKit

final class LessonFinishedDemoPanModalAssembly: Assembly {
    private let sectionID: Section.IdType

    private weak var moduleOutput: LessonFinishedDemoPanModalOutputProtocol?

    init(
        sectionID: Section.IdType,
        output: LessonFinishedDemoPanModalOutputProtocol? = nil
    ) {
        self.sectionID = sectionID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = LessonFinishedDemoPanModalProvider(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI())
        )
        let presenter = LessonFinishedDemoPanModalPresenter()
        let interactor = LessonFinishedDemoPanModalInteractor(
            presenter: presenter,
            provider: provider,
            sectionID: self.sectionID
        )
        let viewController = LessonFinishedDemoPanModalViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
