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
            submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
            attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI()),
            userActivitiesNetworkService: UserActivitiesNetworkService(userActivitiesAPI: UserActivitiesAPI())
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
            quizAssembly: QuizAssemblyFactory().make(for: NewStep.QuizType(blockName: self.step.block.name))
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
