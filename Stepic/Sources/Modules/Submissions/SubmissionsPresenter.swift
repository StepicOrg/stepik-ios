import UIKit

protocol SubmissionsPresenterProtocol {
    func presentSubmissions(response: Submissions.SubmissionsLoad.Response)
    func presentNextSubmissions(response: Submissions.NextSubmissionsLoad.Response)
    func presentSubmission(response: Submissions.SubmissionPresentation.Response)
    func presentFilter(response: Submissions.FilterPresentation.Response)
    func presentLoadingState(response: Submissions.LoadingStatePresentation.Response)
    func presentFilterButtonActiveState(response: Submissions.FilterButtonActiveStatePresentation.Response)
    func presentSearchTextUpdate(response: Submissions.SearchTextUpdate.Response)
}

final class SubmissionsPresenter: SubmissionsPresenterProtocol {
    weak var viewController: SubmissionsViewControllerProtocol?

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
        isTeacher: Bool
    ) -> SubmissionViewModel {
        let username: String = {
            let fullName = "\(user.firstName) \(user.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
            return fullName.isEmpty ? "User \(user.id)" : fullName
        }()

        let relativeDateString = FormatterHelper.dateToRelativeString(submission.time)

        let score: String? = {
            if submission.status == .correct {
                return FormatterHelper.submissionScore(submission.score)
            }
            return nil
        }()

        let reviewState: Submissions.ReviewState? = {
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
        }()

        return SubmissionViewModel(
            uniqueIdentifier: submission.uniqueIdentifier,
            userID: user.id,
            avatarImageURL: URL(string: user.avatarURL),
            formattedUsername: username,
            formattedDate: relativeDateString,
            submissionTitle: "#\(submission.id)",
            score: score,
            quizStatus: QuizStatus(submission: submission) ?? .wrong,
            isMoreActionAvailable: isTeacher,
            reviewState: reviewState
        )
    }
}
