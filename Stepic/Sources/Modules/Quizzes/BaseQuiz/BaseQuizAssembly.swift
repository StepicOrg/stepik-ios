import UIKit

final class BaseQuizAssembly: Assembly {
    private weak var moduleOutput: BaseQuizOutputProtocol?

    private let step: Step
    private let config: BaseQuiz.Config

    init(
        step: Step,
        config: BaseQuiz.Config = .init(hasNextStep: false),
        output: BaseQuizOutputProtocol? = nil
    ) {
        self.moduleOutput = output
        self.step = step
        self.config = config
    }

    convenience init(
        step: Step,
        hasNextStep: Bool = false,
        output: BaseQuizOutputProtocol? = nil
    ) {
        self.init(step: step, config: .init(hasNextStep: hasNextStep), output: output)
    }

    func makeModule() -> UIViewController {
        let provider = BaseQuizProvider(
            attemptsRepository: AttemptsRepository(
                attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI()),
                attemptsPersistenceService: AttemptsPersistenceService(
                    stepsPersistenceService: StepsPersistenceService()
                )
            ),
            submissionsRepository: SubmissionsRepository(
                submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
                submissionsPersistenceService: SubmissionsPersistenceService(
                    attemptsPersistenceService: AttemptsPersistenceService(
                        stepsPersistenceService: StepsPersistenceService()
                    )
                )
            ),
            attemptsPersistenceService: AttemptsPersistenceService(stepsPersistenceService: StepsPersistenceService()),
            submissionsPersistenceService: SubmissionsPersistenceService(),
            userActivitiesNetworkService: UserActivitiesNetworkService(userActivitiesAPI: UserActivitiesAPI())
        )
        let presenter = BaseQuizPresenter()
        let interactor = BaseQuizInteractor(
            step: self.step,
            config: self.config,
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
            quizAssembly: QuizAssemblyFactory().make(for: StepDataFlow.QuizType(blockName: self.step.block.name)),
            withHorizontalInsets: self.config.withHorizontalInsets
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
