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

        let searchText = self.currentFilterQuery.search ?? ""

        if !searchText.isEmpty {
            DispatchQueue.main.async {
                self.presenter.presentSearchTextUpdate(response: .init(searchText: searchText))
            }
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
                .done { self.presenter.presentSubmission(response: .init(step: $0, submission: submission)) }
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
        }.then { submissionsFetchResult -> Promise<([Submission], Meta)> in
            self.loadAttempts(submissions: submissionsFetchResult.0)
                .map { ($0, submissionsFetchResult.1) }
        }.then { submissionsFetchResult -> Promise<([Submission], Meta)> in
            self.loadReviewSessions(submissions: submissionsFetchResult.0)
                .map { ($0, submissionsFetchResult.1) }
        }.then { submissionsFetchResult -> Promise<([User], [Submission], Meta)> in
            let attempts = submissionsFetchResult.0.compactMap(\.attempt)
            let usersIDs = Set(attempts.compactMap(\.userID))

            return self.provider
                .fetchUsers(ids: Array(usersIDs))
                .map { ($0, submissionsFetchResult.0, submissionsFetchResult.1) }
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

    private func getCurrentStep() -> Promise<Step?> {
        if let currentStep = self.currentStep {
            return .value(currentStep)
        }

        return self.provider.fetchStep(id: self.stepID).then { step -> Promise<Step?> in
            self.currentStep = step
            return .value(step)
        }
    }

    private func loadAttempts(submissions: [Submission]) -> Promise<[Submission]> {
        self.provider.fetchAttempts(
            ids: submissions.map(\.attemptID),
            stepID: self.stepID
        ).then { attempts -> Promise<[Submission]> in
            let attemptsMap = attempts.reduce(into: [:]) { $0[$1.id] = $1 }

            for submission in submissions {
                submission.attempt = attemptsMap[submission.attemptID]
            }

            return .value(submissions)
        }
    }

    private func loadReviewSessions(submissions: [Submission]) -> Promise<[Submission]> {
        Promise { seal in
            self.getCurrentStep().compactMap { $0 }.done { step in
                guard step.hasReview else {
                    return seal.fulfill(submissions)
                }

                self.loadReviewSessionsBySessionsIDs(submissions: submissions).then { submissions in
                    self.loadReviewSessionsWithoutSessionID(submissions: submissions)
                }.done { submissions in
                    seal.fulfill(submissions)
                }.catch { error in
                    seal.reject(error)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func loadReviewSessionsBySessionsIDs(submissions: [Submission]) -> Promise<[Submission]> {
        self.provider.fetchReviewSessions(
            ids: submissions.compactMap(\.sessionID),
            stepID: self.stepID
        ).then { sessions -> Promise<[Submission]> in
            let sessionsMap: [Int: ReviewSessionDataPlainObject] = sessions.reduce(into: [:]) { result, session in
                if let submissionID = session.reviewSession.submission {
                    result[submissionID] = session
                }
            }

            for submission in submissions {
                if let sessionID = submission.sessionID {
                    submission.session = sessionsMap[sessionID]
                }
            }

            return .value(submissions)
        }
    }

    private func loadReviewSessionsWithoutSessionID(submissions: [Submission]) -> Promise<[Submission]> {
        let promises = submissions
            .filter { $0.sessionID == nil && $0.status == .correct }
            .map { submission -> Promise<Void> in
                Promise { seal in
                    firstly { () -> Promise<Step?> in
                        if let stepID = submission.attempt?.stepID {
                            return self.provider.fetchStep(id: stepID)
                        } else {
                            return .value(nil)
                        }
                    }.then { stepOrNil -> Promise<Void> in
                        guard let step = stepOrNil,
                              let instructionID = step.instructionID,
                              let userID = submission.attempt?.userID else {
                            return .value(())
                        }

                        return self.provider.fetchReviewSession(
                            userID: userID,
                            instructionID: instructionID,
                            stepID: step.id
                        ).then { session -> Promise<Void> in
                            submission.session = session
                            return .value(())
                        }
                    }.done { _ in
                        seal.fulfill(())
                    }.catch { error in
                        seal.reject(error)
                    }
                }
            }
        return when(fulfilled: promises).map { submissions }
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
