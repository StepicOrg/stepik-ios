import UIKit

protocol SubmissionsPresenterProtocol {
    func presentSubmissions(response: Submissions.SubmissionsLoad.Response)
    func presentNextSubmissions(response: Submissions.NextSubmissionsLoad.Response)
}

final class SubmissionsPresenter: SubmissionsPresenterProtocol {
    weak var viewController: SubmissionsViewControllerProtocol?

    func presentSubmissions(response: Submissions.SubmissionsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel: Submissions.SubmissionsLoad.ViewModel = .init(
                state: Submissions.ViewControllerState.result(
                    data: .init(
                        submissions: data.submissions.map { self.makeViewModel(user: data.user, submission: $0) },
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
                state: Submissions.PaginationState.result(
                    data: .init(
                        submissions: data.submissions.map { self.makeViewModel(user: data.user, submission: $0) },
                        hasNextPage: data.hasNextPage
                    )
                )
            )
            self.viewController?.displayNextSubmissions(viewModel: viewModel)
        case .failure:
            self.viewController?.displayNextSubmissions(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(user: User, submission: Submission) -> SubmissionsViewModel {
        let username: String = {
            let fullName = "\(user.firstName) \(user.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
            return fullName.isEmpty ? "User \(user.id)" : fullName
        }()

        let submissionTitle = String(
            format: NSLocalizedString("DiscussionThreadCommentSolutionTitle", comment: ""),
            arguments: ["\(submission.id)"]
        )

        return SubmissionsViewModel(
            uniqueIdentifier: submission.uniqueIdentifier,
            userID: user.id,
            avatarImageURL: URL(string: user.avatarURL),
            formattedUsername: username,
            formattedDate: "3 месяца назад",
            submissionTitle: submissionTitle,
            isSubmissionCorrect: submission.isCorrect
        )
    }
}
