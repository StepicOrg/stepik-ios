import Foundation
import PromiseKit

protocol StepQuizReviewInteractorProtocol {
    func doSomeAction(request: StepQuizReview.SomeAction.Request)
}

final class StepQuizReviewInteractor: StepQuizReviewInteractorProtocol {
    weak var moduleOutput: StepQuizReviewOutputProtocol?

    private let presenter: StepQuizReviewPresenterProtocol
    private let provider: StepQuizReviewProviderProtocol

    private let step: Step
    private let instructionType: InstructionType

    init(
        step: Step,
        instructionType: InstructionType,
        presenter: StepQuizReviewPresenterProtocol,
        provider: StepQuizReviewProviderProtocol
    ) {
        self.step = step
        self.instructionType = instructionType
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: StepQuizReview.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension StepQuizReviewInteractor: StepQuizReviewInputProtocol {}
