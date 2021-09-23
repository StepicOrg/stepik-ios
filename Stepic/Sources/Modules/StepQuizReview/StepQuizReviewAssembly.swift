import UIKit

final class StepQuizReviewAssembly: Assembly {
    private let step: Step
    private let instructionType: InstructionType
    private let isTeacher: Bool
    private let hasNextStep: Bool

    private weak var moduleOutput: StepQuizReviewOutputProtocol?

    init(
        step: Step,
        instructionType: InstructionType,
        isTeacher: Bool,
        hasNextStep: Bool,
        output: StepQuizReviewOutputProtocol? = nil
    ) {
        self.step = step
        self.instructionType = instructionType
        self.isTeacher = isTeacher
        self.hasNextStep = hasNextStep
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepQuizReviewProvider(
            stepBlockName: self.step.block.name,
            reviewSessionsNetworkService: ReviewSessionsNetworkService(reviewSessionsAPI: ReviewSessionsAPI()),
            reviewsNetworkService: ReviewsNetworkService(reviewsAPI: ReviewsAPI()),
            instructionsNetworkService: InstructionsNetworkService(instructionsAPI: InstructionsAPI())
        )
        let presenter = StepQuizReviewPresenter(urlFactory: StepikURLFactory())
        let interactor = StepQuizReviewInteractor(
            step: self.step,
            instructionType: self.instructionType,
            isTeacher: self.isTeacher,
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared
        )
        let viewController = StepQuizReviewViewController(
            interactor: interactor,
            step: self.step,
            isTeacher: self.isTeacher,
            hasNextStep: self.hasNextStep,
            analytics: StepikAnalytics.shared
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
