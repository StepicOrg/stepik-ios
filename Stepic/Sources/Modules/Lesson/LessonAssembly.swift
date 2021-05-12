import UIKit

final class LessonAssembly: Assembly {
    private var initialContext: LessonDataFlow.Context
    private var startStep: LessonDataFlow.StartStep?

    private weak var moduleOutput: LessonOutputProtocol?

    init(
        initialContext: LessonDataFlow.Context,
        startStep: LessonDataFlow.StartStep? = nil,
        moduleOutput: LessonOutputProtocol?
    ) {
        self.initialContext = initialContext
        self.startStep = startStep
        self.moduleOutput = moduleOutput
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
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            assignmentsNetworkService: AssignmentsNetworkService(assignmentsAPI: AssignmentsAPI()),
            assignmentsPersistenceService: AssignmentsPersistenceService(),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            viewsNetworkService: ViewsNetworkService(viewsAPI: ViewsAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI())
        )
        let presenter = LessonPresenter(urlFactory: StepikURLFactory())
        let interactor = LessonInteractor(
            initialContext: self.initialContext,
            startStep: self.startStep,
            presenter: presenter,
            provider: provider,
            unitNavigationService: unitNavigationService,
            persistenceQueuesService: PersistenceQueuesService(),
            dataBackUpdateService: dataBackUpdateService
        )
        let viewController = LessonViewController(
            interactor: interactor,
            deepLinkRoutingService: DeepLinkRoutingService()
        )
        viewController.hidesBottomBarWhenPushed = true

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
