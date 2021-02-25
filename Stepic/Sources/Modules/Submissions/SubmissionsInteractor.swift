import Foundation
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request)
    func doNextSubmissionsLoad(request: Submissions.NextSubmissionsLoad.Request)
    func doSubmissionPresentation(request: Submissions.SubmissionPresentation.Request)
    func doFilterPresentation(request: Submissions.FilterPresentation.Request)
    func doSearchSubmissions(request: Submissions.SearchSubmissions.Request)
}

final class SubmissionsInteractor: SubmissionsInteractorProtocol {
    typealias PaginationState = (page: Int, hasNext: Bool)

    private static let searchDebounceInterval: TimeInterval = 1

    weak var moduleOutput: SubmissionsOutputProtocol?

    private let stepID: Step.IdType
    private let isTeacher: Bool

    private let presenter: SubmissionsPresenterProtocol
    private let provider: SubmissionsProviderProtocol

    private var currentStep: Step?
    private var currentSubmissions: [Submission] = []
    private var paginationState = PaginationState(page: 1, hasNext: true)

    private var currentFilterQuery: SubmissionsFilterQuery
    private var currentFilters: [SubmissionsFilter.Filter] = []

    private let searchDebouncer = Debouncer(delay: SubmissionsInteractor.searchDebounceInterval)

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
                isTeacher: self.isTeacher,
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
                isTeacher: self.isTeacher,
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
            self.getCurrentStep()
                .compactMap { $0 }
                .done { self.presenter.doSubmissionPresentation(response: .init(step: $0, submission: submission)) }
                .cauterize()
        }
    }

    func doFilterPresentation(request: Submissions.FilterPresentation.Request) {
        self.getCurrentStep()
            .compactMap { $0 }
            .done { self.presenter.presentFilter(response: .init(step: $0, filters: self.currentFilters)) }
            .cauterize()
    }

    func doSearchSubmissions(request: Submissions.SearchSubmissions.Request) {
        let newFilterQuery = SubmissionsFilterQuery(
            user: self.currentFilterQuery.user,
            status: self.currentFilterQuery.status,
            order: self.currentFilterQuery.order,
            reviewStatus: self.currentFilterQuery.reviewStatus,
            search: request.text.trimmed()
        )

        let shouldDoSearch = self.currentFilterQuery != newFilterQuery
        self.currentFilterQuery = newFilterQuery

        guard shouldDoSearch else {
            return
        }

        if request.forceSearch {
            self.searchDebouncer.action = nil

            self.presenter.presentLoadingState(response: .init())
            self.doSubmissionsLoad(request: .init())
        } else {
            self.searchDebouncer.action = { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.presenter.presentLoadingState(response: .init())
                strongSelf.doSubmissionsLoad(request: .init())
            }
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

    private func getCurrentStep() -> Promise<Step?> {
        if let currentStep = self.currentStep {
            return .value(currentStep)
        }

        return self.provider.fetchStep(id: self.stepID).then { step -> Promise<Step?> in
            self.currentStep = step
            return .value(step)
        }
    }

    private func updateCurrentUserSubmissionsFilterQuery() -> Promise<Void> {
        self.provider
            .fetchCurrentUser()
            .compactMap { $0 }
            .then { currentUser -> Promise<Void> in
                self.currentFilterQuery = SubmissionsFilterQuery(
                    user: currentUser.id,
                    status: self.currentFilterQuery.status,
                    order: self.currentFilterQuery.order,
                    reviewStatus: self.currentFilterQuery.reviewStatus,
                    search: self.currentFilterQuery.search
                )
                return .value(())
            }
    }
}

// MARK: - SubmissionsInteractor: SubmissionsFilterOutputProtocol -

extension SubmissionsInteractor: SubmissionsFilterOutputProtocol {
    func handleSubmissionsFilterDidFinishWithFilters(_ filters: [SubmissionsFilter.Filter]) {
        self.currentFilters = filters

        let selectedFilterQuery = SubmissionsFilterQuery(filters: filters)
        let newFilterQuery = SubmissionsFilterQuery(
            user: self.currentFilterQuery.user,
            status: selectedFilterQuery.status,
            order: selectedFilterQuery.order,
            reviewStatus: selectedFilterQuery.reviewStatus,
            search: self.currentFilterQuery.search
        )

        if newFilterQuery != self.currentFilterQuery {
            self.presenter.presentLoadingState(response: .init())
            self.doSubmissionsLoad(request: .init())
        }

        self.currentFilterQuery = newFilterQuery
    }

    func handleSubmissionsFilterActive(_ isActive: Bool) {
        self.presenter.presentFilterButtonActiveState(response: .init(isActive: isActive))
    }
}
