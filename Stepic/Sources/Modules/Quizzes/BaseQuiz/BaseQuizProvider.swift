import Foundation
import PromiseKit

protocol BaseQuizProviderProtocol {
    func createAttempt(for step: Step) -> Promise<Attempt?>
    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)>

    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)>
    func fetchSubmissions(for step: Step, page: Int) -> Promise<([Submission], Meta)>
    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?>
    func createSubmission(for step: Step, attempt: Attempt, reply: Reply) -> Promise<Submission?>

    func fetchActivity(for user: User.IdType) -> Promise<UserActivity>
}

final class BaseQuizProvider: BaseQuizProviderProtocol {
    private let attemptsProvider: AttemptsProviderProtocol
    private let submissionsNetworkService: SubmissionsNetworkServiceProtocol
    private let userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        attemptsProvider: AttemptsProviderProtocol,
        submissionsNetworkService: SubmissionsNetworkServiceProtocol,
        userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.attemptsProvider = attemptsProvider
        self.submissionsNetworkService = submissionsNetworkService
        self.userActivitiesNetworkService = userActivitiesNetworkService
        self.userAccountService = userAccountService
    }

    func createAttempt(for step: Step) -> Promise<Attempt?> {
        self.attemptsProvider.create(stepID: step.id, blockName: step.block.name)
    }

    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)> {
        guard let userID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.fetchFailed)
        }

        return self.attemptsProvider.fetch(stepID: step.id, userID: userID, blockName: step.block.name)
    }

    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)> {
        self.submissionsNetworkService.fetch(attemptID: attempt.id, blockName: step.block.name)
    }

    func fetchSubmissions(for step: Step, page: Int = 1) -> Promise<([Submission], Meta)> {
        self.submissionsNetworkService.fetch(stepID: step.id, blockName: step.block.name, page: page)
    }

    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?> {
        self.submissionsNetworkService.fetch(submissionID: id, blockName: step.block.name)
    }

    func createSubmission(for step: Step, attempt: Attempt, reply: Reply) -> Promise<Submission?> {
        self.submissionsNetworkService.create(attemptID: attempt.id, blockName: step.block.name, reply: reply)
    }

    func fetchActivity(for user: User.IdType) -> Promise<UserActivity> {
        self.userActivitiesNetworkService.retrieve(for: user)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
