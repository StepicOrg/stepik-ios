import UIKit

final class LessonAssembly: Assembly {
    private var initialContext: LessonDataFlow.Context
    private var startStep: LessonDataFlow.StartStep?

    init(initialContext: LessonDataFlow.Context, startStep: LessonDataFlow.StartStep? = nil) {
        self.initialContext = initialContext
        self.startStep = startStep
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

        let dataBackUpdateService = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )

        let provider = LessonProvider(
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
        let presenter = LessonPresenter()
        let interactor = LessonInteractor(
            initialContext: self.initialContext,
            startStep: self.startStep,
            presenter: presenter,
            provider: provider,
            unitNavigationService: unitNavigationService,
            persistenceQueuesService: PersistenceQueuesService(),
            dataBackUpdateService: dataBackUpdateService
        )
        let viewController = LessonViewController(interactor: interactor)
        viewController.hidesBottomBarWhenPushed = true

        presenter.viewController = viewController

        return viewController
    }
}
