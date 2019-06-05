import UIKit

final class NewLessonAssembly: Assembly {
    private var initialContext: NewLesson.Context
    private var startStep: NewLesson.StartStep?

    init(initialContext: NewLesson.Context, startStep: NewLesson.StartStep? = nil) {
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
            startStep: self.startStep,
            presenter: presenter,
            provider: provider,
            unitNavigationService: unitNavigationService,
            persistenceQueuesService: PersistenceQueuesService(),
            dataBackUpdateService: dataBackUpdateService
        )
        let viewController = NewLessonViewController(interactor: interactor)
        viewController.hidesBottomBarWhenPushed = true

        presenter.viewController = viewController

        return viewController
    }
}
