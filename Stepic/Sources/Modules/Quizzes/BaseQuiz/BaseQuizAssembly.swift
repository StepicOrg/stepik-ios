import CoreData
import UIKit

final class BaseQuizAssembly: Assembly {
    private weak var moduleOutput: BaseQuizOutputProtocol?
    private let step: Step
    private let hasNextStep: Bool

    private let managedObjectContext: NSManagedObjectContext

    init(
        step: Step,
        hasNextStep: Bool = false,
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context,
        output: BaseQuizOutputProtocol? = nil
    ) {
        self.moduleOutput = output
        self.step = step
        self.hasNextStep = hasNextStep
        self.managedObjectContext = managedObjectContext
    }

    func makeModule() -> UIViewController {
        let provider = BaseQuizProvider(
            attemptsRepository: AttemptsRepository(
                attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI()),
                attemptsPersistenceService: AttemptsPersistenceService(
                    managedObjectContext: self.managedObjectContext,
                    stepsPersistenceService: StepsPersistenceService()
                )
            ),
            submissionsRepository: SubmissionsRepository(
                submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
                submissionsPersistenceService: SubmissionsPersistenceService(
                    managedObjectContext: self.managedObjectContext,
                    attemptsPersistenceService: AttemptsPersistenceService(
                        managedObjectContext: self.managedObjectContext,
                        stepsPersistenceService: StepsPersistenceService()
                    )
                )
            ),
            userActivitiesNetworkService: UserActivitiesNetworkService(userActivitiesAPI: UserActivitiesAPI()),
            userAccountService: UserAccountService()
        )
        let presenter = BaseQuizPresenter()
        let interactor = BaseQuizInteractor(
            step: self.step,
            hasNextStep: self.hasNextStep,
            presenter: presenter,
            provider: provider,
            notificationSuggestionManager: NotificationSuggestionManager(),
            rateAppManager: RateAppManager(),
            userService: UserAccountService()
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
