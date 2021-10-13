import Foundation
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSubmissionsLoad(request: Submissions.SubmissionsLoad.Request)
    func doNextSubmissionsLoad(request: Submissions.NextSubmissionsLoad.Request)
    func doSubmissionPresentation(request: Submissions.SubmissionPresentation.Request)
    func doSubmissionSelection(request: Submissions.SubmissionSelection.Request)
    func doReviewPresentation(request: Submissions.ReviewPresentation.Request)
    func doFilterPresentation(request: Submissions.FilterPresentation.Request)
    func doSearchSubmissions(request: Submissions.SearchSubmissions.Request)
}

final class SubmissionsInteractor: SubmissionsInteractorProtocol {
    private static let searchDebounceInterval: TimeInterval = 1

    weak var moduleOutput: SubmissionsOutputProtocol?

    private let stepID: Step.IdType
    private let isTeacher: Bool
    private let isSelectionEnabled: Bool

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
        isSelectionEnabled: Bool,
        presenter: SubmissionsPresenterProtocol,
        provider: SubmissionsProviderProtocol
    ) {
        self.stepID = stepID
        self.isTeacher = isTeacher
        self.isSelectionEnabled = isSelectionEnabled
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

        if self.currentFilterQuery != .default {
            DispatchQueue.main.async {
                self.presenter.presentFilterButtonActiveState(response: .init(isActive: true))
            }
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

        self.fetchSubmissions(page: 1).done { fetchResult in
            print("SubmissionsInteractor :: done fetching submissions")

            self.currentSubmissions = fetchResult.submissions
            self.paginationState = PaginationState(page: 1, hasNext: fetchResult.meta.hasNext)

            let responseData = Submissions.SubmissionsData(
                users: fetchResult.users,
                currentUserID: self.provider.getCurrentUserID(),
                submissions: fetchResult.submissions,
                instruction: fetchResult.instruction,
                isTeacher: self.isTeacher,
                isSelectionAvailable: self.isSelectionEnabled,
                hasNextPage: fetchResult.meta.hasNext
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

        self.fetchSubmissions(page: nextPageIndex).done { fetchResult in
            print("SubmissionsInteractor :: done fetching next submissions")

            self.currentSubmissions.append(contentsOf: fetchResult.submissions)
            self.paginationState = PaginationState(page: nextPageIndex, hasNext: fetchResult.meta.hasNext)

            let responseData = Submissions.SubmissionsData(
                users: fetchResult.users,
                currentUserID: self.provider.getCurrentUserID(),
                submissions: fetchResult.submissions,
                instruction: fetchResult.instruction,
                isTeacher: self.isTeacher,
                isSelectionAvailable: self.isSelectionEnabled,
                hasNextPage: fetchResult.meta.hasNext
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

        self.getCurrentStep()
            .compactMap { $0 }
            .done { self.presenter.presentSubmission(response: .init(step: $0, submission: submission)) }
            .cauterize()
    }

    func doSubmissionSelection(request: Submissions.SubmissionSelection.Request) {
        guard let submission = self.currentSubmissions.first(
            where: { $0.uniqueIdentifier == request.uniqueIdentifier }
        ) else {
            return
        }

        DispatchQueue.main.async {
            self.moduleOutput?.handleSubmissionSelected(submission)
        }
    }

    func doReviewPresentation(request: Submissions.ReviewPresentation.Request) {
        guard let submission = self.currentSubmissions.first(
            where: { $0.uniqueIdentifier == request.uniqueIdentifier }
        ) else {
            return
        }

        self.presenter.presentReview(
            response: .init(
                stepID: self.stepID,
                unitID: self.currentStep?.lesson?.unit?.id,
                submission: submission,
                isTeacher: self.isTeacher,
                currentUserID: self.provider.getCurrentUserID()
            )
        )
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

    private func fetchSubmissions(page: Int) -> Promise<SubmissionsFetchResult> {
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
            self.loadSteps(submissions: submissionsFetchResult.0)
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
        }.then { users, submissions, meta in
            self.fetchInstruction(submissions: submissions)
                .map { SubmissionsFetchResult(users: users, submissions: submissions, instruction: $0, meta: meta) }
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

    private func loadSteps(submissions: [Submission]) -> Promise<[Submission]> {
        self.provider.fetchSteps(
            ids: submissions.compactMap { $0.attempt?.stepID }
        ).then { steps -> Promise<[Submission]> in
            let stepsMap = steps.reduce(into: [:]) { $0[$1.id] = StepPlainObject(step: $1) }

            for submission in submissions {
                if let attempt = submission.attempt {
                    attempt.step = stepsMap[attempt.stepID]
                }
            }

            return .value(submissions)
        }
    }

    private func loadReviewSessions(submissions: [Submission]) -> Promise<[Submission]> {
        Promise { seal in
            self.getCurrentStep().compactMap { $0 }.done { step in
                guard step.hasReview && !self.isSelectionEnabled else {
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
            let sessionsMap = sessions.reduce(into: [:]) { $0[$1.id] = $1 }

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
                    guard let step = submission.attempt?.step,
                          let instructionID = step.instructionID,
                          let userID = submission.attempt?.userID else {
                        return seal.fulfill(())
                    }

                    self.provider.fetchReviewSession(
                        userID: userID,
                        instructionID: instructionID,
                        stepID: step.id
                    ).done { session in
                        submission.session = session
                        seal.fulfill(())
                    }.catch { error in
                        seal.reject(error)
                    }
                }
            }
        return when(fulfilled: promises).map { submissions }
    }

    private func fetchInstruction(submissions: [Submission]) -> Promise<InstructionDataPlainObject?> {
        guard let submission = submissions.first(where: { $0.session != nil }),
              let instructionID = submission.session?.reviewSession.instruction else {
            return .value(nil)
        }

        return self.provider.fetchInstruction(id: instructionID)
    }

    // MARK: Types

    struct SubmissionsFetchResult {
        let users: [User]
        let submissions: [Submission]
        let instruction: InstructionDataPlainObject?
        let meta: Meta
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
