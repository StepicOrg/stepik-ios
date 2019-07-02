import Foundation
import PromiseKit

protocol SubmissionsNetworkServiceProtocol: class {
    func create(attemptID: Attempt.IdType, blockName: String, reply: Reply) -> Promise<Submission?>
    func fetch(stepID: Step.IdType, blockName: String, page: Int) -> Promise<([Submission], Meta)>
    func fetch(attemptID: Attempt.IdType, blockName: String) -> Promise<([Submission], Meta)>
    func fetch(submissionID: Submission.IdType, blockName: String) -> Promise<Submission?>
}

final class SubmissionsNetworkService: SubmissionsNetworkServiceProtocol {
    private let submissionsAPI: SubmissionsAPI

    init(submissionsAPI: SubmissionsAPI) {
        self.submissionsAPI = submissionsAPI
    }

    func fetch(stepID: Step.IdType, blockName: String, page: Int) -> Promise<([Submission], Meta)> {
        return Promise { seal in
            self.submissionsAPI.retrieve(stepName: blockName, stepID: stepID, page: page).done { submissions, meta in
                seal.fulfill((submissions, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(attemptID: Attempt.IdType, blockName: String) -> Promise<([Submission], Meta)> {
        return Promise { seal in
            self.submissionsAPI.retrieve(stepName: blockName, attemptID: attemptID).done { submissions, meta in
                seal.fulfill((submissions, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(submissionID: Submission.IdType, blockName: String) -> Promise<Submission?> {
        return Promise { seal in
            self.submissionsAPI.retrieve(stepName: blockName, submissionId: submissionID).done { submission in
                seal.fulfill(submission)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func create(attemptID: Attempt.IdType, blockName: String, reply: Reply) -> Promise<Submission?> {
        return Promise { seal in
            self.submissionsAPI.create(stepName: blockName, attemptId: attemptID, reply: reply).done { submission in
                seal.fulfill(submission)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
