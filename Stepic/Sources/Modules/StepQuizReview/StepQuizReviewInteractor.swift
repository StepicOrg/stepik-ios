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
        }.compactMap { reviewSession, instruction -> (ReviewSessionDataPlainObject?, InstructionDataPlainObject)? in
            if let instruction = instruction {
                return (reviewSession, instruction)
            }
            return nil
        }.then { reviewSession, instruction -> Promise<(ReviewSessionDataPlainObject?, InstructionDataPlainObject)> in
            if self.step.sessionID == nil && instruction.instruction.isFrozen {
                return self.provider
                    .createReviewSession(instructionID: instruction.instruction.id)
                    .then { reviewSession -> Promise<ReviewSessionDataPlainObject?> in
                        self.step.sessionID = reviewSession?.id
                        CoreDataHelper.shared.save()
                        return .value(reviewSession)
                    }
                    .map { ($0, instruction) }
            }
            return .value((reviewSession, instruction))
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

        switch action {
        case .teacherReviewSubmissions:
            self.startTeacherReview()
        case .teacherViewSubmissions:
            break
        }
    }

    // MARK: Private API

    private func startTeacherReview() {
        guard let sessionID = self.step.sessionID else {
            return print("StepQuizReviewInteractor :: failed \(#function) no session")
        }

        self.presenter.presentBlockingLoadingIndicator(response: .init(shouldDismiss: false))

        self.provider.createReview(sessionID: sessionID).compactMap { $0 }.done { review in
            self.presenter.presentBlockingLoadingIndicator(response: .init(shouldDismiss: true))
            self.presenter.presentTeacherReview(response: .init(review: review, unitID: self.step.lesson?.unit?.id))
        }.catch { error in
            print("StepQuizReviewInteractor :: failed \(#function) with error = \(error)")
            self.presenter.presentBlockingLoadingIndicator(response: .init(shouldDismiss: true, showError: true))
        }
    }

    enum Error: Swift.Error {
        case something
    }
}

extension StepQuizReviewInteractor: StepQuizReviewInputProtocol {}

extension StepQuizReviewInteractor: BaseQuizOutputProtocol {
    func handleCorrectSubmission() {
        self.moduleOutput?.handleCorrectSubmission()
    }

    func handleSubmissionEvaluated() {
        self.moduleOutput?.handleSubmissionEvaluated()
    }

    func handleNextStepNavigation() {
        self.moduleOutput?.handleNextStepNavigation()
    }
}
