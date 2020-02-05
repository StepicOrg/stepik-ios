import Foundation
import Logging
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request)
    func doNextSubmissionsLoad(request: Submissions.NextSubmissionsLoad.Request)
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

        self.fetchCurrentUserSubmissionsWithAttempts(page: 1).done { currentUser, submissions, meta in
            Self.logger.info("SubmissionsInteractor :: done fetching submissions")

            self.paginationState = PaginationState(page: 1, hasNext: meta.hasNext)

            let responseData = Submissions.SubmissionsData(
                user: currentUser,
                submissions: submissions,
                hasNextPage: meta.hasNext
            )
            self.presenter.presentSubmissions(response: .init(result: .success(responseData)))
        }.catch { error in
            Self.logger.error("SubmissionsInteractor :: failed fetch submissions, error: \(error)")
            self.presenter.presentSubmissions(response: .init(result: .failure(error)))
        }
    }

    func doNextSubmissionsLoad(request: Submissions.NextSubmissionsLoad.Request) {
        let nextPageIndex = self.paginationState.page + 1
        Self.logger.info("SubmissionsInteractor :: started fetching next submissions, page: \(nextPageIndex)")

        self.fetchCurrentUserSubmissionsWithAttempts(page: nextPageIndex).done { currentUser, submissions, meta in
            Self.logger.info("SubmissionsInteractor :: done fetching next submissions")

            self.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)

            let responseData = Submissions.SubmissionsData(
                user: currentUser,
                submissions: submissions,
                hasNextPage: meta.hasNext
            )
            self.presenter.presentNextSubmissions(response: .init(result: .success(responseData)))
        }.catch { error in
            Self.logger.error("SubmissionsInteractor :: failed fetch next submissions, error: \(error)")
            self.presenter.presentNextSubmissions(response: .init(result: .failure(error)))
        }
    }

    private func fetchCurrentUserSubmissionsWithAttempts(page: Int) -> Promise<(User, [Submission], Meta)> {
        firstly {
            self.provider.fetchCurrentUser()
        }.then { currentUser -> Promise<User> in
            guard let currentUser = currentUser else {
                throw Error.noUser
            }

            return .value(currentUser)
        }.then { currentUser -> Promise<(User, ([Submission], Meta))> in
            self.provider.fetchSubmissions(
                stepID: self.stepID,
                page: page
            ).map { (currentUser, $0) }
        }.then { currentUser, submissionsFetchResult -> Promise<(User, ([Submission], Meta), [Attempt])> in
            self.provider.fetchAttempts(
                ids: submissionsFetchResult.0.map { $0.attemptID },
                stepID: self.stepID
            ).map { (currentUser, submissionsFetchResult, $0) }
        }.then(on: .global(qos: .userInitiated)) {
            currentUser, submissionsFetchResult, attempts -> Promise<(User, [Submission], Meta)> in
            let submissions = submissionsFetchResult.0
            submissions.forEach { submission in
                if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                    submission.attempt = attempt
                }
            }

            return .value((currentUser, submissions, submissionsFetchResult.1))
        }
    }

    enum Error: Swift.Error {
        case noUser
    }
}
