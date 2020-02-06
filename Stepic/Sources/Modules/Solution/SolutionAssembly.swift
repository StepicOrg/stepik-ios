import UIKit

final class SolutionAssembly: Assembly {
    private let stepID: Step.IdType
    private let submission: Submission
    private var submissionURLProvider: SubmissionURLProvider?

    init(stepID: Step.IdType, submission: Submission, submissionURLProvider: SubmissionURLProvider? = nil) {
        self.stepID = stepID
        self.submission = submission
        self.submissionURLProvider = submissionURLProvider
    }

    func makeModule() -> UIViewController {
        let provider = SolutionProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            submissionURLProvider: self.submissionURLProvider
        )
        let presenter = SolutionPresenter()
        let interactor = SolutionInteractor(
            stepID: self.stepID,
            submission: self.submission,
            presenter: presenter,
            provider: provider
        )
        let viewController = SolutionViewController(interactor: interactor)
        viewController.title = String(
            format: NSLocalizedString("SolutionTitle", comment: ""),
            arguments: ["\(self.submission.id)"]
        )

        presenter.viewController = viewController

        return viewController
    }
}
