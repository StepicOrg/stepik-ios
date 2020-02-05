import Foundation
import Logging
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request)
}

final class SubmissionsInteractor: SubmissionsInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    private static let logger = Logger(label: "com.AlexKarpov.Stepic.SubmissionsInteractor")

    weak var moduleOutput: SubmissionsOutputProtocol?

    private let stepID: Step.IdType

    private let presenter: SubmissionsPresenterProtocol
    private let provider: SubmissionsProviderProtocol

    private var paginationState = PaginationState(page: 1, hasNext: true)

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
        Self.logger.info("SubmissionsInteractor :: started fetching submissions")

        firstly {
            self.provider.fetchCurrentUser()
        }.then { currentUser -> Promise<User> in
            guard let currentUser = currentUser else {
                throw Error.noUser
            }

            return .value(currentUser)
        }.then { currentUser -> Promise<(User, ([Submission], Meta))> in
            self.provider.fetchSubmissions(stepID: self.stepID, page: 1).map { (currentUser, $0) }
        }.then { currentUser, submissionsFetchResult -> Promise<(User, ([Submission], Meta), [Attempt])> in
            self.provider.fetchAttempts(
                ids: submissionsFetchResult.0.map { $0.attemptID },
                stepID: self.stepID
            ).map { (currentUser, submissionsFetchResult, $0) }
        }.done(on: .global(qos: .userInitiated)) { currentUser, submissionsFetchResult, attempts in
            self.paginationState = PaginationState(page: 1, hasNext: submissionsFetchResult.1.hasNext)

            let submissions = submissionsFetchResult.0
            submissions.forEach { submission in
                if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                    submission.attempt = attempt
                }
            }

            Self.logger.info("SubmissionsInteractor :: done fetching submissions")

            DispatchQueue.main.async {
                let responseData = Submissions.SubmissionsLoad.Data(
                    user: currentUser,
                    submissions: submissions,
                    hasNextPage: self.paginationState.hasNext
                )
                self.presenter.presentSubmissions(response: .init(result: .success(responseData)))
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
