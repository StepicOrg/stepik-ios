import UIKit

final class BaseQuizAssembly: Assembly {
    private weak var moduleOutput: BaseQuizOutputProtocol?
    private let step: Step
    private let hasNextStep: Bool

    init(step: Step, hasNextStep: Bool = false, output: BaseQuizOutputProtocol? = nil) {
        self.moduleOutput = output
        self.step = step
        self.hasNextStep = hasNextStep
    }

    func makeModule() -> UIViewController {
        let provider = BaseQuizProvider(
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
            userActivitiesNetworkService: UserActivitiesNetworkService(userActivitiesAPI: UserActivitiesAPI())
        )
        let presenter = BaseQuizPresenter(urlFactory: StepikURLFactory())
        let interactor = BaseQuizInteractor(
            step: self.step,
            hasNextStep: self.hasNextStep,
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            notificationSuggestionManager: NotificationSuggestionManager(),
            rateAppManager: RateAppManager(),
            userAccountService: UserAccountService(),
            adaptiveStorageManager: AdaptiveStorageManager()
        )
        let viewController = BaseQuizViewController(
            interactor: interactor,
            quizAssembly: QuizAssemblyFactory().make(for: StepDataFlow.QuizType(blockName: self.step.block.name))
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
