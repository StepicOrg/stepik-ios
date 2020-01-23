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
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI())
        )
        let presenter = CourseInfoTabSyllabusPresenter()
        let interactor = CourseInfoTabSyllabusInteractor(
            presenter: presenter,
            provider: provider,
            personalDeadlinesService: PersonalDeadlinesService(),
            nextLessonService: NextLessonService(),
            tooltipStorageManager: TooltipStorageManager(),
            syllabusDownloadsService: SyllabusDownloadsService(
                videoDownloadingService: VideoDownloadingService.shared,
                videoFileManager: VideoStoredFileManager(fileManager: .default),
                imageDownloadingService: DownloadingServiceFactory.makeDownloadingService(type: .image),
                imageFileManager: ImageStoredFileManager(fileManager: .default),
                stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
                storageUsageService: StorageUsageService(
                    videoFileManager: VideoStoredFileManager(fileManager: FileManager.default)
                )
            )
        )
        let viewController = CourseInfoTabSyllabusViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput
        self.moduleInput = interactor

        return viewController
    }
}
