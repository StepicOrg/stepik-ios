import Foundation
import PromiseKit

protocol StepQuizReviewInteractorProtocol {
    func doStepQuizReviewLoad(request: StepQuizReview.QuizReviewLoad.Request)
    func doButtonAction(request: StepQuizReview.ButtonAction.Request)
}

final class StepQuizReviewInteractor: StepQuizReviewInteractorProtocol {
    weak var moduleOutput: StepQuizReviewOutputProtocol?

    private let presenter: StepQuizReviewPresenterProtocol
    private let provider: StepQuizReviewProviderProtocol

    private let step: Step
    private let instructionType: InstructionType
    private let isTeacher: Bool

    init(
        step: Step,
        instructionType: InstructionType,
        isTeacher: Bool,
        presenter: StepQuizReviewPresenterProtocol,
        provider: StepQuizReviewProviderProtocol
    ) {
        self.step = step
        self.instructionType = instructionType
        self.isTeacher = isTeacher
        self.presenter = presenter
        self.provider = provider
    }

    func doStepQuizReviewLoad(request: StepQuizReview.QuizReviewLoad.Request) {
        firstly { () -> Promise<ReviewSessionDataPlainObject?> in
            if let sessionID = self.step.sessionID {
                return self.provider.fetchReviewSession(id: sessionID)
            }
            return .value(nil)
        }.then { reviewSession -> Promise<(ReviewSessionDataPlainObject?, InstructionDataPlainObject?)> in
            if let instructionID = self.step.instructionID {
                return self.provider.fetchInstruction(id: instructionID).map { (reviewSession, $0) }
            }
            return .value((reviewSession, nil))
        }.compactMap {
            reviewSessionOrNil, instructionOrNil -> (ReviewSessionDataPlainObject?, InstructionDataPlainObject)? in
            if let instruction = instructionOrNil {
                return (reviewSessionOrNil, instruction)
            }
            return nil
        }.done { reviewSessionOrNil, instruction in
            print(
                """
StepQuizReviewInteractor :: session = \(String(describing: reviewSessionOrNil)), instruction = \(instruction)
"""
            )

            let data = StepQuizReview.QuizReviewLoad.Data(
                step: self.step,
                instructionType: self.instructionType,
                isTeacher: self.isTeacher,
                session: reviewSessionOrNil,
                instruction: instruction
            )

            self.presenter.presentStepQuizReview(response: .init(result: .success(data)))
        }.catch { error in
            print("StepQuizReviewInteractor :: failed \(#function) with error = \(error)")
            self.presenter.presentStepQuizReview(response: .init(result: .failure(error)))
        }
    }

    func doButtonAction(request: StepQuizReview.ButtonAction.Request) {
        guard let action = StepQuizReview.ActionType(rawValue: request.actionUniqueIdentifier) else {
            return
        }

        print(action)
    }

    enum Error: Swift.Error {
        case something
    }
}

extension StepQuizReviewInteractor: StepQuizReviewInputProtocol {}
