import Foundation
import PromiseKit

protocol BaseQuizProviderProtocol {
    func createAttempt(for step: Step) -> Promise<Attempt?>
    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)>
    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)>
    func fetchSubmissions(for step: Step, page: Int) -> Promise<([Submission], Meta)>
    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?>
}

final class BaseQuizProvider: BaseQuizProviderProtocol {
    private let submissionsNetworkService: SubmissionsNetworkServiceProtocol
    private let attemptsNetworkService: AttemptsNetworkServiceProtocol

    init(
        submissionsNetworkService: SubmissionsNetworkServiceProtocol,
        attemptsNetworkService: AttemptsNetworkServiceProtocol
    ) {
        self.submissionsNetworkService = submissionsNetworkService
        self.attemptsNetworkService = attemptsNetworkService
    }

    func createAttempt(for step: Step) -> Promise<Attempt?> {
        return self.attemptsNetworkService.create(stepID: step.id, blockName: step.block.name)
    }

    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)> {
        return self.attemptsNetworkService.fetch(stepID: step.id, blockName: step.block.name)
    }

    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)> {
        return self.submissionsNetworkService.fetch(attemptID: attempt.id, blockName: step.block.name)
    }

    func fetchSubmissions(for step: Step, page: Int = 1) -> Promise<([Submission], Meta)> {
        return self.submissionsNetworkService.fetch(stepID: step.id, blockName: step.block.name, page: page)
    }

    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?> {
        return self.submissionsNetworkService.fetch(submissionID: id, blockName: step.block.name)
    }
}
