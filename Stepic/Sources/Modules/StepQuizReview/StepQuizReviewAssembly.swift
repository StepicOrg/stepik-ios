import UIKit

final class StepQuizReviewAssembly: Assembly {
    var moduleInput: StepQuizReviewInputProtocol?

    private let step: Step
    private let instructionType: InstructionType
    private weak var moduleOutput: StepQuizReviewOutputProtocol?

    init(step: Step, instructionType: InstructionType, output: StepQuizReviewOutputProtocol? = nil) {
        self.step = step
        self.instructionType = instructionType
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = StepQuizReviewProvider()
        let presenter = StepQuizReviewPresenter()
        let interactor = StepQuizReviewInteractor(
            step: self.step,
            instructionType: self.instructionType,
            presenter: presenter,
            provider: provider
        )
        let viewController = StepQuizReviewViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
