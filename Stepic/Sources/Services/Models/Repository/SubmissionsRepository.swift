import Foundation
import PromiseKit

protocol SubmissionsRepositoryProtocol: AnyObject {
    func createSubmission(
        _ submission: Submission,
        blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<Submission?>
    func fetchSubmission(
        id: Submission.IdType,
        blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<Submission?>
    func fetchAttemptSubmissions(
        attemptID: Attempt.IdType,
        blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<([Submission], Meta)>
    func fetchStepSubmissions(
        stepID: Step.IdType,
        userID: User.IdType?,
        blockName: String,
        page: Int
    ) -> Promise<([Submission], Meta)>
}

extension SubmissionsRepositoryProtocol {
    func createSubmission(_ submission: Submission, blockName: String) -> Promise<Submission?> {
        self.createSubmission(submission, blockName: blockName, dataSourceType: .remote)
    }

    func fetchSubmission(id: Submission.IdType, blockName: String) -> Promise<Submission?> {
        self.fetchSubmission(id: id, blockName: blockName, dataSourceType: .remote)
    }

    func fetchAttemptSubmissions(attemptID: Attempt.IdType, blockName: String) -> Promise<([Submission], Meta)> {
        self.fetchAttemptSubmissions(attemptID: attemptID, blockName: blockName, dataSourceType: .remote)
    }
}

final class SubmissionsRepository: SubmissionsRepositoryProtocol {
    private let submissionsNetworkService: SubmissionsNetworkServiceProtocol
    private let submissionsPersistenceService: SubmissionsPersistenceServiceProtocol

    init(
        submissionsNetworkService: SubmissionsNetworkServiceProtocol,
        submissionsPersistenceService: SubmissionsPersistenceServiceProtocol
    ) {
        self.submissionsNetworkService = submissionsNetworkService
        self.submissionsPersistenceService = submissionsPersistenceService
    }

    func createSubmission(
        _ submission: Submission,
        blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<Submission?> {
        guard let reply = submission.reply else {
            return Promise(error: Error.noReply)
        }

        switch dataSourceType {
        case .cache:
            return self.submissionsPersistenceService
                .save(submissions: [submission])
                .map { submission }
        case .remote:
            return self.submissionsNetworkService
                .create(attemptID: submission.attemptID, blockName: blockName, reply: reply)
                .then { submission -> Promise<Submission?> in
                    if let submission = submission {
                        return self.submissionsPersistenceService
                            .save(submissions: [submission])
                            .map { submission }
                    }
                    return .value(submission)
                }
        }
    }

    func fetchSubmission(
        id: Submission.IdType,
        blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<Submission?> {
        switch dataSourceType {
        case .cache:
            return Promise { seal in
                self.submissionsPersistenceService
                    .fetch(ids: [id])
                    .done {
                        seal.fulfill($0.first?.plainObject)
                    }
            }
        case .remote:
            return self.submissionsNetworkService
                .fetch(submissionID: id, blockName: blockName)
                .then { submission -> Promise<Submission?> in
                    if let submission = submission {
                        return self.submissionsPersistenceService
                            .save(submissions: [submission])
                            .map { submission }
                    }
                    return .value(submission)
                }
        }
    }

    func fetchAttemptSubmissions(
        attemptID: Attempt.IdType,
        blockName: String,
        dataSourceType: DataSourceType
    ) -> Promise<([Submission], Meta)> {
        switch dataSourceType {
        case .cache:
            return self.submissionsPersistenceService
                .fetchAttemptSubmissions(attemptID: attemptID)
                .map { ($0.map { $0.plainObject }, Meta.oneAndOnlyPage) }
        case .remote:
            return self.submissionsNetworkService
                .fetch(attemptID: attemptID, blockName: blockName)
                .then { submissions, meta -> Promise<([Submission], Meta)> in
                    if let submission = submissions.first {
                        return self.submissionsPersistenceService
                            .save(submissions: [submission])
                            .map { (submissions, meta) }
                    }
                    return .value((submissions, meta))
                }
        }
    }

    // Fetches all available submissions if `userID` not provided
    func fetchStepSubmissions(
        stepID: Step.IdType,
        userID: User.IdType?,
        blockName: String,
        page: Int
    ) -> Promise<([Submission], Meta)> {
        if let userID = userID {
            return self.submissionsNetworkService.fetch(
                stepID: stepID,
                blockName: blockName,
                userID: userID,
                page: page
            )
        } else {
            return self.submissionsNetworkService.fetch(stepID: stepID, blockName: blockName, page: page)
        }
    }

    enum Error: Swift.Error {
        case noReply
    }
}
