import UIKit

protocol SubmissionsPresenterProtocol {
    func presentSubmissions(response: Submissions.SubmissionsLoad.Response)
}

final class SubmissionsPresenter: SubmissionsPresenterProtocol {
    weak var viewController: SubmissionsViewControllerProtocol?

    func presentSubmissions(response: Submissions.SubmissionsLoad.Response) {
        switch response.result {
        case .success(let data):
            let submissionViewModels = data.submissions.map { self.makeViewModel(user: data.user, submission: $0) }
            self.viewController?.displaySubmissions(
                viewModel: .init(
                    state: .result(
                        data: .init(
                            submissions: submissionViewModels,
                            hasNextPage: false
                        )
                    )
                )
            )
        case .failure:
            self.viewController?.displaySubmissions(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(user: User, submission: Submission) -> SubmissionsViewModel {
        let username: String = {
            let fullName = "\(user.firstName) \(user.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
            return fullName.isEmpty
                ? "User \(user.id)"
                : fullName
        }()

        let submissionTitle = String(
            format: NSLocalizedString("DiscussionThreadCommentSolutionTitle", comment: ""),
            arguments: ["\(submission.id)"]
        )

        return SubmissionsViewModel(
            uniqueIdentifier: submission.uniqueIdentifier,
            avatarImageURL: URL(string: user.avatarURL),
            formattedUsername: username,
            formattedDate: "3 месяца назад",
            submissionTitle: submissionTitle,
            isSubmissionCorrect: submission.isCorrect
        )
    }
}
