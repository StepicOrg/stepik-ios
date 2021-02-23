import Foundation
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request)
    func doNextSubmissionsLoad(request: Submissions.NextSubmissionsLoad.Request)
    func doSubmissionPresentation(request: Submissions.SubmissionPresentation.Request)
}

final class SubmissionsInteractor: SubmissionsInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    weak var moduleOutput: SubmissionsOutputProtocol?

    private let stepID: Step.IdType
    private let isTeacher: Bool

    private let presenter: SubmissionsPresenterProtocol
    private let provider: SubmissionsProviderProtocol

    private var currentSubmissions: [Submission] = []
    private var currentFilterQuery: SubmissionsFilterQuery
    private var paginationState = PaginationState(page: 1, hasNext: true)

    init(
        stepID: Step.IdType,
        isTeacher: Bool,
        submissionsFilterQuery: SubmissionsFilterQuery?,
        presenter: SubmissionsPresenterProtocol,
        provider: SubmissionsProviderProtocol
    ) {
        self.stepID = stepID
        self.isTeacher = isTeacher
        self.presenter = presenter
        self.provider = provider

        if let submissionsFilterQuery = submissionsFilterQuery {
            self.currentFilterQuery = SubmissionsFilterQuery(
                user: submissionsFilterQuery.user,
                status: submissionsFilterQuery.status,
                order: submissionsFilterQuery.order ?? .desc,
                reviewStatus: submissionsFilterQuery.reviewStatus,
                search: submissionsFilterQuery.search
            )
        } else {
            self.currentFilterQuery = .default
        }
    }

    // MARK: Protocol Conforming

    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request) {
        print("SubmissionsInteractor :: started fetching submissions")

        self.fetchSubmissions(page: 1).done { users, submissions, meta in
            print("SubmissionsInteractor :: done fetching submissions")

            self.currentSubmissions = submissions
            self.paginationState = PaginationState(page: 1, hasNext: meta.hasNext)

            let responseData = Submissions.SubmissionsData(
                users: users,
                submissions: submissions,
                hasNextPage: meta.hasNext
            )
            self.presenter.presentSubmissions(response: .init(result: .success(responseData)))
        }.catch { error in
            print("SubmissionsInteractor :: failed fetch submissions, error: \(error)")
            self.presenter.presentSubmissions(response: .init(result: .failure(error)))
        }
    }

    func doNextSubmissionsLoad(request: Submissions.NextSubmissionsLoad.Request) {
        let nextPageIndex = self.paginationState.page + 1
        print("SubmissionsInteractor :: started fetching next submissions, page: \(nextPageIndex)")

        self.fetchSubmissions(page: nextPageIndex).done { users, submissions, meta in
            print("SubmissionsInteractor :: done fetching next submissions")

            self.currentSubmissions.append(contentsOf: submissions)
            self.paginationState = PaginationState(page: nextPageIndex, hasNext: meta.hasNext)

            let responseData = Submissions.SubmissionsData(
                users: users,
                submissions: submissions,
                hasNextPage: meta.hasNext
            )
            self.presenter.presentNextSubmissions(response: .init(result: .success(responseData)))
        }.catch { error in
            print("SubmissionsInteractor :: failed fetch next submissions, error: \(error)")
            self.presenter.presentNextSubmissions(response: .init(result: .failure(error)))
        }
    }

    func doSubmissionPresentation(request: Submissions.SubmissionPresentation.Request) {
        guard let submission = self.currentSubmissions.first(
            where: { $0.uniqueIdentifier == request.uniqueIdentifier }
        ) else {
            return
        }

        if let moduleOutput = self.moduleOutput {
            DispatchQueue.main.async {
                moduleOutput.handleSubmissionSelected(submission)
            }
        } else {
            self.provider
                .fetchStep(id: self.stepID)
                .compactMap { $0 }
                .done { self.presenter.doSubmissionPresentation(response: .init(step: $0, submission: submission)) }
                .cauterize()
        }
    }

    // MARK: Private API

    private func fetchSubmissions(page: Int) -> Promise<([User], [Submission], Meta)> {
        firstly { () -> Promise<Void> in
            if self.isTeacher {
                return .value(())
            } else {
                return self.updateCurrentUserSubmissionsFilterQuery()
            }
        }.then { () -> Promise<([Submission], Meta)> in
            self.provider.fetchSubmissions(stepID: self.stepID, filterQuery: self.currentFilterQuery, page: page)
        }.then { submissionsFetchResult -> Promise<(([Submission], Meta), [Attempt])> in
            self.provider
                .fetchAttempts(ids: submissionsFetchResult.0.map(\.attemptID), stepID: self.stepID)
                .map { (submissionsFetchResult, $0) }
        }.then { submissionsFetchResult, attempts -> Promise<([User], [Submission], Meta)> in
            let submissions = submissionsFetchResult.0
            submissions.forEach { submission in
                if let attempt = attempts.first(where: { $0.id == submission.attemptID }) {
                    submission.attempt = attempt
                }
            }

            let usersIDs = Set(attempts.compactMap(\.userID))

            return self.provider
                .fetchUsers(ids: Array(usersIDs))
                .map { ($0, submissions, submissionsFetchResult.1) }
        }
    }

    private func updateCurrentUserSubmissionsFilterQuery() -> Promise<Void> {
        self.provider
            .fetchCurrentUser()
            .compactMap { $0 }
            .then { currentUser -> Promise<Void> in
                self.currentFilterQuery.user = currentUser.id
                return .value(())
            }
    }
}
