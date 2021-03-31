import UIKit

final class CourseInfoTabSyllabusAssembly: Assembly {
    // Input
    var moduleInput: CourseInfoTabSyllabusInputProtocol?

    // Output
    private weak var moduleOutput: CourseInfoTabSyllabusOutputProtocol?

    init(output: CourseInfoTabSyllabusOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabSyllabusProvider(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            lessonsPersistenceService: LessonsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(lessonsAPI: LessonsAPI()),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            examSessionsNetworkService: ExamSessionsNetworkService(examSessionsAPI: ExamSessionsAPI()),
            proctorSessionsNetworkService: ProctorSessionsNetworkService(proctorSessionsAPI: ProctorSessionsAPI())
        )
        let presenter = CourseInfoTabSyllabusPresenter()
        let interactor = CourseInfoTabSyllabusInteractor(
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            personalDeadlinesService: PersonalDeadlinesService(),
            nextLessonService: NextLessonService(),
            networkReachabilityService: NetworkReachabilityService(),
            tooltipStorageManager: TooltipStorageManager(),
            useCellularDataForDownloadsStorageManager: UseCellularDataForDownloadsStorageManager(),
            syllabusDownloadsService: SyllabusDownloadsService(
                videoDownloadingService: VideoDownloadingService.shared,
                videoFileManager: VideoStoredFileManager(fileManager: .default),
                imageDownloadingService: DownloadingServiceFactory.makeDownloadingService(type: .image),
                imageFileManager: ImageStoredFileManager(fileManager: .default),
                attemptsRepository: AttemptsRepository(
                    attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI()),
                    attemptsPersistenceService: AttemptsPersistenceService(
                        managedObjectContext: CoreDataHelper.shared.context,
                        stepsPersistenceService: StepsPersistenceService()
                    )
                ),
                submissionsRepository: SubmissionsRepository(
                    submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
                    submissionsPersistenceService: SubmissionsPersistenceService(
                        managedObjectContext: CoreDataHelper.shared.context,
                        attemptsPersistenceService: AttemptsPersistenceService(
                            managedObjectContext: CoreDataHelper.shared.context,
                            stepsPersistenceService: StepsPersistenceService()
                        )
                    )
                ),
                stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
                storageUsageService: StorageUsageService(
                    videoFileManager: VideoStoredFileManager(fileManager: FileManager.default),
                    imageFileManager: ImageStoredFileManager(fileManager: .default)
                ),
                userAccountService: UserAccountService()
            )
        )
        let viewController = CourseInfoTabSyllabusViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput
        self.moduleInput = interactor

        return viewController
    }
}
