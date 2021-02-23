import UIKit

protocol SubmissionsPresenterProtocol {
    func presentSubmissions(response: Submissions.SubmissionsLoad.Response)
    func presentNextSubmissions(response: Submissions.NextSubmissionsLoad.Response)
    func doSubmissionPresentation(response: Submissions.SubmissionPresentation.Response)
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

                            return self.makeViewModel(user: user, submission: submission)
                        },
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

                            return self.makeViewModel(user: user, submission: submission)
                        },
                        hasNextPage: data.hasNextPage
                    )
                )
            )
            self.viewController?.displayNextSubmissions(viewModel: viewModel)
        case .failure:
            self.viewController?.displayNextSubmissions(viewModel: .init(state: .error))
        }
    }

    func doSubmissionPresentation(response: Submissions.SubmissionPresentation.Response) {
        self.viewController?.displaySubmission(
            viewModel: .init(stepID: response.step.id, submission: response.submission)
        )
    }

    // MARK: Private API

    private func makeViewModel(user: User, submission: Submission) -> SubmissionViewModel {
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

        return SubmissionViewModel(
            uniqueIdentifier: submission.uniqueIdentifier,
            userID: user.id,
            avatarImageURL: URL(string: user.avatarURL),
            formattedUsername: username,
            formattedDate: relativeDateString,
            submissionTitle: "#\(submission.id)",
            score: score,
            quizStatus: QuizStatus(submission: submission) ?? .wrong
        )
    }
}
