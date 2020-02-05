import Foundation
import Logging
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request)
}

final class SubmissionsInteractor: SubmissionsInteractorProtocol {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.SubmissionsInteractor")

    weak var moduleOutput: SubmissionsOutputProtocol?

    private let stepID: Step.IdType

    private let presenter: SubmissionsPresenterProtocol
    private let provider: SubmissionsProviderProtocol

    init(
        stepID: Step.IdType,
        presenter: SubmissionsPresenterProtocol,
        provider: SubmissionsProviderProtocol
    ) {
        self.stepID = stepID
        self.presenter = presenter
        self.provider = provider
    }

    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request) {
        Self.logger.error("SubmissionsInteractor :: started fetching submissions")

        firstly {
            self.provider.fetchCurrentUser()
        }.then { currentUser -> Promise<User> in
            guard let currentUser = currentUser else {
                throw Error.noUser
            }

            return .value(currentUser)
        }.then { currentUser -> Promise<(User, ([Submission], Meta))> in
            self.provider.fetchSubmissions(stepID: self.stepID, page: 1).map { (currentUser, $0) }
        }.then { currentUser, submissionsFetchResult -> Promise<(User, [Submission], [Attempt])> in
            self.provider.fetchAttempts(
                ids: submissionsFetchResult.0.map { $0.attemptID },
                stepID: self.stepID
            ).map { (currentUser, submissionsFetchResult.0, $0) }
        }.done(on: .global(qos: .userInitiated)) { currentUser, submissions, attempts in
            submissions.forEach { submission in
                if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                    submission.attempt = attempt
                }
            }

            Self.logger.error("SubmissionsInteractor :: done fetching submissions: \(submissions)")

            DispatchQueue.main.async {
                self.presenter.presentSubmissions(
                    response: .init(
                        result: .success(
                            .init(
                                user: currentUser,
                                submissions: submissions
                            )
                        )
                    )
                )
            }
        }.catch { error in
            Self.logger.error("SubmissionsInteractor :: failed fetch submissions, error: \(error)")
            self.presenter.presentSubmissions(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case noUser
    }
}
