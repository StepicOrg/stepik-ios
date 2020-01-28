import UIKit

final class SolutionAssembly: Assembly {
    private let stepID: Step.IdType
    private let submissionID: Submission.IdType

    init(stepID: Step.IdType, submissionID: Submission.IdType) {
        self.stepID = stepID
        self.submissionID = submissionID
    }

    func makeModule() -> UIViewController {
        let provider = SolutionProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            submissionsNetworkService: SubmissionsNetworkService(submissionsAPI: SubmissionsAPI()),
            attemptsNetworkService: AttemptsNetworkService(attemptsAPI: AttemptsAPI())
        )
        let presenter = SolutionPresenter()
        let interactor = SolutionInteractor(
            stepID: self.stepID,
            submissionID: self.submissionID,
            presenter: presenter,
            provider: provider
        )
        let viewController = SolutionViewController(interactor: interactor)
        viewController.title = String(
            format: NSLocalizedString("SolutionTitle", comment: ""),
            arguments: ["\(self.submissionID)"]
        )

        presenter.viewController = viewController

        return viewController
    }
}
