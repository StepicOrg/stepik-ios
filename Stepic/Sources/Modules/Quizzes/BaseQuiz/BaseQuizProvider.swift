import Foundation
import PromiseKit

protocol BaseQuizProviderProtocol {
    func createAttempt(for step: Step) -> Promise<Attempt?>
    func fetchAttempts(for step: Step) -> Promise<([Attempt], Meta)>

    func fetchSubmissionsForAttempt(
        attemptID: Attempt.IdType,
        stepBlockName blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<[Submission]>
    func fetchSubmissions(for step: Step, page: Int) -> Promise<([Submission], Meta)>
    func fetchSubmission(id: Submission.IdType, step: Step) -> Promise<Submission?>
    func createSubmission(for step: Step, attempt: Attempt, reply: Reply) -> Promise<Submission?>
    func createLocalSubmission(_ submission: Submission) -> Guarantee<Submission>

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
            return Promise(error: Error.unknownUser)
        }

        return self.attemptsRepository.fetch(stepID: step.id, userID: userID, blockName: step.block.name)
    }

    func fetchSubmissions(for step: Step, attempt: Attempt) -> Promise<([Submission], Meta)> {
        self.submissionsRepository.fetchSubmissionsForAttempt(
            attemptID: attempt.id,
            blockName: step.block.name,
            dataSourceType: .remote
        )
    }

    func fetchSubmissionsForAttempt(
        attemptID: Attempt.IdType,
        stepBlockName blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<[Submission]> {
        self.submissionsRepository
            .fetchSubmissionsForAttempt(attemptID: attemptID, blockName: blockName, dataSourceType: dataSourceType)
            .map { $0.0 }
    }

    func fetchSubmissions(for step: Step, page: Int = 1) -> Promise<([Submission], Meta)> {
        self.submissionsRepository.fetchSubmissionsForStep(
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

    func createLocalSubmission(_ submission: Submission) -> Guarantee<Submission> {
        Guarantee { seal in
            self.submissionsRepository
                .createSubmission(submission, blockName: "", dataSourceType: .cache)
                .done { seal(($0 ?? submission)) }
                .catch { _ in seal((submission)) }
        }
    }

    func fetchActivity(for user: User.IdType) -> Promise<UserActivity> {
        self.userActivitiesNetworkService.retrieve(for: user)
    }

    enum Error: Swift.Error {
        case unknownUser
    }
}
