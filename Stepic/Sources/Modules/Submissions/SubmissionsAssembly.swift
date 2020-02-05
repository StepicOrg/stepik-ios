import UIKit

final class SubmissionsAssembly: Assembly {
    private let stepID: Step.IdType
    private weak var moduleOutput: SubmissionsOutputProtocol?

    init(stepID: Step.IdType, output: SubmissionsOutputProtocol? = nil) {
        self.stepID = stepID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = SubmissionsProvider(
            submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
            attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI()),
            userAccountService: UserAccountService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        let presenter = SubmissionsPresenter()
        let interactor = SubmissionsInteractor(stepID: self.stepID, presenter: presenter, provider: provider)
        let viewController = SubmissionsViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
