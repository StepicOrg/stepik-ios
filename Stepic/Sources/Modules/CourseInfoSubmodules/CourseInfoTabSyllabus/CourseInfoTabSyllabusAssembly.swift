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
        let increasedTimeoutIntervalForRequest = APIDefaults.Configuration.increasedTimeoutIntervalForRequest

        let provider = CourseInfoTabSyllabusProvider(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(
                sectionsAPI: SectionsAPI(timeoutIntervalForRequest: increasedTimeoutIntervalForRequest)
            ),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(
                progressesAPI: ProgressesAPI(timeoutIntervalForRequest: increasedTimeoutIntervalForRequest)
            ),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(
                unitsAPI: UnitsAPI(timeoutIntervalForRequest: increasedTimeoutIntervalForRequest)
            ),
            lessonsPersistenceService: LessonsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(
                lessonsAPI: LessonsAPI(timeoutIntervalForRequest: increasedTimeoutIntervalForRequest)
            ),
            examSessionsNetworkService: ExamSessionsNetworkService(
                examSessionsAPI: ExamSessionsAPI(timeoutIntervalForRequest: increasedTimeoutIntervalForRequest)
            ),
            proctorSessionsNetworkService: ProctorSessionsNetworkService(
                proctorSessionsAPI: ProctorSessionsAPI(timeoutIntervalForRequest: increasedTimeoutIntervalForRequest)
            )
        )
        let presenter = CourseInfoTabSyllabusPresenter()
        let interactor = CourseInfoTabSyllabusInteractor(
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            personalDeadlinesService: PersonalDeadlinesService(),
            networkReachabilityService: NetworkReachabilityService(),
            tooltipStorageManager: TooltipStorageManager(),
            useCellularDataForDownloadsStorageManager: UseCellularDataForDownloadsStorageManager(),
            dataBackUpdateService: DataBackUpdateService.default,
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
