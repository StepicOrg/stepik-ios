import UIKit

final class StepAssembly: Assembly {
    var moduleInput: StepInputProtocol?

    private let stepID: Step.IdType
    private weak var moduleOutput: StepOutputProtocol?

    init(stepID: Step.IdType, output: StepOutputProtocol? = nil) {
        self.stepID = stepID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepFontSizeStorageManager: StepFontSizeStorageManager(),
            imageStoredFileManager: StoredFileManagerFactory.makeStoredFileManager(type: .image),
            arQuickLookStoredFileManager: ARQuickLookStoredFileManager(fileManager: .default),
            discussionThreadsNetworkService: DiscussionThreadsNetworkService(
                discussionThreadsAPI: DiscussionThreadsAPI()
            ),
            discussionThreadsPersistenceService: DiscussionThreadsPersistenceService(),
            lessonsNetworkService: LessonsNetworkService(lessonsAPI: LessonsAPI()),
            lessonsPersistenceService: LessonsPersistenceService()
        )
        let presenter = StepPresenter(urlFactory: StepikURLFactory())
        let interactor = StepInteractor(
            stepID: self.stepID,
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            remoteConfig: RemoteConfig.shared
        )
        let viewController = StepViewController(
            interactor: interactor,
            networkReachabilityService: NetworkReachabilityService()
        )

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput
        self.moduleInput = interactor

        return viewController
    }
}
