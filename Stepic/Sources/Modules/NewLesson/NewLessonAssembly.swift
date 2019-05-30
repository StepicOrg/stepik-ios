import UIKit

final class NewLessonAssembly: Assembly {
    var moduleInput: NewLessonInputProtocol?
    private var initialContext: NewLesson.Context

    private weak var moduleOutput: NewLessonOutputProtocol?

    init(initialContext: NewLesson.Context, output: NewLessonOutputProtocol? = nil) {
        self.initialContext = initialContext
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let unitNavigationService = UnitNavigationService(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI())
        )

        let provider = NewLessonProvider(
            lessonsPersistenceService: LessonsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(lessonsAPI: LessonsAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            assignmentsNetworkService: AssignmentsNetworkService(assignmentsAPI: AssignmentsAPI()),
            assignmentsPersistenceService: AssignmentsPersistenceService(),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            viewsNetworkService: ViewsNetworkService(viewsAPI: ViewsAPI())
        )
        let presenter = NewLessonPresenter()
        let interactor = NewLessonInteractor(
            initialContext: self.initialContext,
            presenter: presenter,
            provider: provider,
            unitNavigationService: unitNavigationService,
            persistenceQueuesService: PersistenceQueuesService()
        )
        let viewController = NewLessonViewController(interactor: interactor)
        viewController.hidesBottomBarWhenPushed = true

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
