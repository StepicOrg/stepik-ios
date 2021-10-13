import Foundation
import PromiseKit

protocol StepQuizReviewProviderProtocol {
    func fetchReviewSession(id: Int) -> Promise<ReviewSessionDataPlainObject?>
    func createReviewSession(submissionID: Submission.IdType) -> Promise<ReviewSessionDataPlainObject?>
    func createReviewSession(instructionID: Int) -> Promise<ReviewSessionDataPlainObject?>

    func createReview(sessionID: Int) -> Promise<ReviewDataPlainObject?>

    func fetchInstruction(id: Int) -> Promise<InstructionDataPlainObject?>
}

final class StepQuizReviewProvider: StepQuizReviewProviderProtocol {
    private let stepBlockName: String

    private let reviewSessionsNetworkService: ReviewSessionsNetworkServiceProtocol
    private let reviewsNetworkService: ReviewsNetworkServiceProtocol
    private let instructionsNetworkService: InstructionsNetworkServiceProtocol

    init(
        stepBlockName: String,
        reviewSessionsNetworkService: ReviewSessionsNetworkServiceProtocol,
        reviewsNetworkService: ReviewsNetworkServiceProtocol,
        instructionsNetworkService: InstructionsNetworkServiceProtocol
    ) {
        self.stepBlockName = stepBlockName
        self.reviewSessionsNetworkService = reviewSessionsNetworkService
        self.reviewsNetworkService = reviewsNetworkService
        self.instructionsNetworkService = instructionsNetworkService
    }

    func fetchReviewSession(id: Int) -> Promise<ReviewSessionDataPlainObject?> {
        self.reviewSessionsNetworkService.fetch(id: id, blockName: self.stepBlockName)
    }

    func createReviewSession(submissionID: Submission.IdType) -> Promise<ReviewSessionDataPlainObject?> {
        self.reviewSessionsNetworkService.create(submissionID: submissionID, blockName: self.stepBlockName)
    }

    func createReviewSession(instructionID: Int) -> Promise<ReviewSessionDataPlainObject?> {
        self.reviewSessionsNetworkService.create(instructionID: instructionID, blockName: self.stepBlockName)
    }

    func createReview(sessionID: Int) -> Promise<ReviewDataPlainObject?> {
        self.reviewsNetworkService.create(sessionID: sessionID, blockName: self.stepBlockName)
    }

    func fetchInstruction(id: Int) -> Promise<InstructionDataPlainObject?> {
        self.instructionsNetworkService.fetch(id: id)
    }
}
