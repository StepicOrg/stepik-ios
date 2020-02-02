import UIKit

final class SolutionAssembly: Assembly {
    private let stepID: Step.IdType
    private let submission: Submission
    private let discussionID: DiscussionThread.IdType

    init(stepID: Step.IdType, submission: Submission, discussionID: DiscussionThread.IdType) {
        self.stepID = stepID
        self.submission = submission
        self.discussionID = discussionID
    }

    func makeModule() -> UIViewController {
        let provider = SolutionProvider(
            stepsPersistenceService: StepsPersistenceService(),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI())
        )
        let presenter = SolutionPresenter()
        let interactor = SolutionInteractor(
            stepID: self.stepID,
            submission: self.submission,
            discussionID: self.discussionID,
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
