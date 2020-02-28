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
    private let attemptsRepository: AttemptsRepositoryProtocol
    private let submissionsRepository: SubmissionsRepositoryProtocol
    private let userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        attemptsRepository: AttemptsRepositoryProtocol,
        submissionsRepository: SubmissionsRepositoryProtocol,
        userActivitiesNetworkService: UserActivitiesNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.attemptsRepository = attemptsRepository
        self.submissionsRepository = submissionsRepository
        self.userActivitiesNetworkService = userActivitiesNetworkService
        self.userAccountService = userAccountService
    }

    func createAttempt(for step: Step) -> Promise<Attempt?> {
        self.attemptsRepository.create(stepID: step.id, blockName: step.block.name)
    }

    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)> {
        guard let userID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.fetchFailed)
        }

        return self.attemptsRepository.fetch(stepID: step.id, userID: userID, blockName: step.block.name)
    }

    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)> {
        self.submissionsRepository.fetchAttemptSubmissions(
            attemptID: attempt.id,
            blockName: step.block.name,
            dataSourceType: .remote
        )
    }

    func fetchSubmissions(for step: Step, page: Int = 1) -> Promise<([Submission], Meta)> {
        self.submissionsRepository.fetchStepSubmissions(
            stepID: step.id,
            userID: nil,
            blockName: step.block.name,
            page: page
        )
    }

    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?> {
        self.submissionsRepository.fetchSubmission(id: id, blockName: step.block.name, dataSourceType: .remote)
    }

    func createSubmission(for step: Step, attempt: Attempt, reply: Reply) -> Promise<Submission?> {
        self.submissionsRepository.createSubmission(
            Submission(attempt: attempt.id, reply: reply),
            blockName: step.block.name,
            dataSourceType: .remote
        )
    }

    func fetchActivity(for user: User.IdType) -> Promise<UserActivity> {
        self.userActivitiesNetworkService.retrieve(for: user)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
