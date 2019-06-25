import Foundation
import PromiseKit

protocol BaseQuizProviderProtocol {
    func createAttempt(for step: Step) -> Promise<Attempt?>
    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)>
    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)>
    func fetchSubmissions(for step: Step, page: Int) -> Promise<([Submission], Meta)>
    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?>
    func fetchActivity(for user: User.IdType) -> Promise<UserActivity>

    func createSubmission(for step: Step, attempt: Attempt, reply: Reply) -> Promise<Submission?>
}

final class BaseQuizProvider: BaseQuizProviderProtocol {
    private let submissionsNetworkService: SubmissionsNetworkServiceProtocol
    private let attemptsNetworkService: AttemptsNetworkServiceProtocol
    private let userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol

    init(
        submissionsNetworkService: SubmissionsNetworkServiceProtocol,
        attemptsNetworkService: AttemptsNetworkServiceProtocol,
        userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol
    ) {
        self.submissionsNetworkService = submissionsNetworkService
        self.attemptsNetworkService = attemptsNetworkService
        self.userActivitiesNetworkService = userActivitiesNetworkService
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

    func createSubmission(for step: Step, attempt: Attempt, reply: Reply) -> Promise<Submission?> {
        return self.submissionsNetworkService.create(attemptID: attempt.id, blockName: step.block.name, reply: reply)
    }

    func fetchActivity(for user: User.IdType) -> Promise<UserActivity> {
        return self.userActivitiesNetworkService.retrieve(for: user)
    }
}
