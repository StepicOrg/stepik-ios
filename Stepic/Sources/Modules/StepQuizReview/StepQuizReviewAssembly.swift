import UIKit

final class StepQuizReviewAssembly: Assembly {
    var moduleInput: StepQuizReviewInputProtocol?

    private let step: Step
    private let instructionType: InstructionType
    private let isTeacher: Bool
    private let canNavigateToNextStep: Bool
    private weak var moduleOutput: StepQuizReviewOutputProtocol?

    init(
        step: Step,
        instructionType: InstructionType,
        isTeacher: Bool,
        canNavigateToNextStep: Bool = false,
        output: StepQuizReviewOutputProtocol? = nil
    ) {
        self.step = step
        self.instructionType = instructionType
        self.isTeacher = isTeacher
        self.canNavigateToNextStep = canNavigateToNextStep
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepQuizReviewProvider(
            stepBlockName: self.step.block.name,
            reviewSessionsNetworkService: ReviewSessionsNetworkService(reviewSessionsAPI: ReviewSessionsAPI()),
            reviewsNetworkService: ReviewsNetworkService(reviewsAPI: ReviewsAPI()),
            instructionsNetworkService: InstructionsNetworkService(instructionsAPI: InstructionsAPI())
        )
        let presenter = StepQuizReviewPresenter()
        let interactor = StepQuizReviewInteractor(
            step: self.step,
            instructionType: self.instructionType,
            isTeacher: self.isTeacher,
            presenter: presenter,
            provider: provider
        )
        let viewController = StepQuizReviewViewController(
            interactor: interactor,
            step: self.step,
            isTeacher: self.isTeacher,
            canNavigateToNextStep: self.canNavigateToNextStep
        )

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
