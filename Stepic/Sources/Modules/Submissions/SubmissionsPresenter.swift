import UIKit

protocol SubmissionsPresenterProtocol {
    func presentSubmissions(response: Submissions.SubmissionsLoad.Response)
    func presentNextSubmissions(response: Submissions.NextSubmissionsLoad.Response)
    func presentSubmission(response: Submissions.SubmissionPresentation.Response)
    func presentReview(response: Submissions.ReviewPresentation.Response)
    func presentFilter(response: Submissions.FilterPresentation.Response)
    func presentLoadingState(response: Submissions.LoadingStatePresentation.Response)
    func presentFilterButtonActiveState(response: Submissions.FilterButtonActiveStatePresentation.Response)
    func presentSearchTextUpdate(response: Submissions.SearchTextUpdate.Response)
}

final class SubmissionsPresenter: SubmissionsPresenterProtocol {
    weak var viewController: SubmissionsViewControllerProtocol?

    private let urlFactory: StepikURLFactory

    init(urlFactory: StepikURLFactory) {
        self.urlFactory = urlFactory
    }

    // MARK: Protocol Conforming

    func presentSubmissions(response: Submissions.SubmissionsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel: Submissions.SubmissionsLoad.ViewModel = .init(
                state: .result(
                    data: .init(
                        submissions: data.submissions.compactMap { submission in
                            guard let user = data.users.first(where: { $0.id == submission.attempt?.userID }) else {
                                return nil
                            }

                            return self.makeViewModel(
                                user: user,
                                currentUserID: data.currentUserID,
                                submission: submission,
                                instruction: data.instruction,
                                isTeacher: data.isTeacher
                            )
                        },
                        isSubmissionsFilterAvailable: data.isTeacher,
                        hasNextPage: data.hasNextPage
                    )
                )
            )
            self.viewController?.displaySubmissions(viewModel: viewModel)
        case .failure:
            self.viewController?.displaySubmissions(viewModel: .init(state: .error))
        }
    }

    func presentNextSubmissions(response: Submissions.NextSubmissionsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel: Submissions.NextSubmissionsLoad.ViewModel = .init(
                state: .result(
                    data: .init(
                        submissions: data.submissions.compactMap { submission in
                            guard let user = data.users.first(where: { $0.id == submission.attempt?.userID }) else {
                                return nil
                            }

                            return self.makeViewModel(
                                user: user,
                                currentUserID: data.currentUserID,
                                submission: submission,
                                instruction: data.instruction,
                                isTeacher: data.isTeacher
                            )
                        },
                        isSubmissionsFilterAvailable: data.isTeacher,
                        hasNextPage: data.hasNextPage
                    )
                )
            )
            self.viewController?.displayNextSubmissions(viewModel: viewModel)
        case .failure:
            self.viewController?.displayNextSubmissions(viewModel: .init(state: .error))
        }
    }

    func presentSubmission(response: Submissions.SubmissionPresentation.Response) {
        self.viewController?.displaySubmission(
            viewModel: .init(stepID: response.step.id, submission: response.submission)
        )
    }

    func presentReview(response: Submissions.ReviewPresentation.Response) {
        guard let reviewState = self.getSubmissionReviewState(
            submission: response.submission,
            isTeacher: response.isTeacher,
            currentUserID: response.currentUserID
        ) else {
            return
        }

        let targetURL: URL? = {
            if case .notSubmittedForReview = reviewState {
                return self.urlFactory.makeSubmission(
                    stepID: response.stepID,
                    submissionID: response.submission.id,
                    unitID: response.unitID
                )
            } else if let sessionID = response.submission.sessionID {
                return self.urlFactory.makeReviewSession(sessionID: sessionID, unitID: response.unitID)
            } else {
                return nil
            }
        }()

        if let targetURL = targetURL {
            self.viewController?.displayReview(viewModel: .init(url: targetURL))
        }
    }

    func presentFilter(response: Submissions.FilterPresentation.Response) {
        self.viewController?.displayFilter(
            viewModel: .init(hasReview: response.step.hasReview, filters: response.filters)
        )
    }

    func presentLoadingState(response: Submissions.LoadingStatePresentation.Response) {
        self.viewController?.displayLoadingState(viewModel: .init(state: .loading))
    }

    func presentFilterButtonActiveState(response: Submissions.FilterButtonActiveStatePresentation.Response) {
        self.viewController?.displayFilterButtonActiveState(viewModel: .init(isActive: response.isActive))
    }

    func presentSearchTextUpdate(response: Submissions.SearchTextUpdate.Response) {
        self.viewController?.displaySearchTextUpdate(viewModel: .init(searchText: response.searchText))
    }

    // MARK: Private API

    private func makeViewModel(
        user: User,
        currentUserID: User.IdType?,
        submission: Submission,
        instruction: InstructionDataPlainObject?,
        isTeacher: Bool
    ) -> SubmissionViewModel {
        let username = FormatterHelper.username(user)
        let relativeDateString = FormatterHelper.dateToRelativeString(submission.time)

        let reviewViewModel = self.makeReviewViewModel(
            currentUserID: currentUserID,
            submission: submission,
            instruction: instruction,
            isTeacher: isTeacher,
            username: username
        )

        let formattedScore: String? = {
            if reviewViewModel != nil {
                let hasValue = (submission.session?.reviewSession.isFinished ?? false)
                    && (submission.sessionID != nil && submission.session != nil)
                    && instruction != nil

                if hasValue {
                    let value = submission.score
                        * submission.session.require().reviewSession.score
                        / Float(instruction.require().maxScore)

                    return FormatterHelper.submissionScore(value)
                } else {
                    return nil
                }
            } else if submission.status == .correct {
                return FormatterHelper.submissionScore(submission.score)
            } else {
                return nil
            }
        }()

        return SubmissionViewModel(
            uniqueIdentifier: submission.uniqueIdentifier,
            userID: user.id,
            avatarImageURL: URL(string: user.avatarURL),
            formattedUsername: username,
            formattedDate: relativeDateString,
            submissionTitle: "#\(submission.id)",
            score: formattedScore,
            quizStatus: QuizStatus(submission: submission) ?? .wrong,
            isMoreActionAvailable: isTeacher,
            review: reviewViewModel
        )
    }

    private func makeReviewViewModel(
        currentUserID: User.IdType?,
        submission: Submission,
        instruction: InstructionDataPlainObject?,
        isTeacher: Bool,
        username: String
    ) -> SubmissionReviewViewModel? {
        guard let reviewState = self.getSubmissionReviewState(
            submission: submission,
            isTeacher: isTeacher,
            currentUserID: currentUserID
        ) else {
            return nil
        }

        let takenReviewCount = submission.session?.takenReviews.count ?? 0
        let givenReviewsCount = submission.session?.givenReviews.count ?? 0
        let minReviewsCount = instruction?.instruction.minReviews ?? 0

        let title: String = {
            switch reviewState {
            case .inProgress, .finished:
                return String(
                    format: reviewState.title,
                    arguments: ["\(takenReviewCount)", "\(minReviewsCount)"]
                )
            default:
                return reviewState.title
            }
        }()
        let message: String = {
            if reviewState == .inProgress {
                if givenReviewsCount < minReviewsCount && takenReviewCount < minReviewsCount {
                    return String(
                        format: NSLocalizedString("SubmissionsReviewStateInProgressNotGiveNotTakeMessage", comment: ""),
                        arguments: [username]
                    )
                } else if givenReviewsCount < minReviewsCount {
                    return String(
                        format: NSLocalizedString("SubmissionsReviewStateInProgressNotGiveMessage", comment: ""),
                        arguments: [username]
                    )
                }
            }
            return reviewState.message
        }()
        let formattedTitle = "\(title)\n\(message)".trimmed()

        let isEnabled: Bool = {
            switch reviewState {
            case .evaluation, .cantReviewWrong, .cantReviewTeacher, .cantReviewAnother:
                return false
            case .finished, .inProgress, .notSubmittedForReview:
                return true
            }
        }()

        return SubmissionReviewViewModel(
            title: formattedTitle,
            actionButtonTitle: reviewState.actionTitle,
            isEnabled: isEnabled
        )
    }

    private func getSubmissionReviewState(
        submission: Submission,
        isTeacher: Bool,
        currentUserID: User.IdType?
    ) -> Submissions.ReviewState? {
        guard let attempt = submission.attempt,
              let step = attempt.step else {
            return nil
        }

        if step.instructionID == nil {
            return nil
        }

        if submission.status == .evaluation {
            return .evaluation
        }

        if submission.sessionID != nil,
           let session = submission.session {
            if session.reviewSession.isFinished {
                return .finished
            } else {
                return .inProgress
            }
        }

        if !submission.isCorrect {
            return .cantReviewWrong
        }

        if attempt.userID == currentUserID && isTeacher {
            return .cantReviewTeacher
        }

        if submission.session == nil {
            return .notSubmittedForReview
        }

        if submission.session?.submission != nil {
            return .cantReviewAnother
        } else {
            return .cantReviewTeacher
        }
    }
}
