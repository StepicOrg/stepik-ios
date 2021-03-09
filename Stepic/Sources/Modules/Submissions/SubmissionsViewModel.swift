import Foundation

struct SubmissionViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType
    let userID: User.IdType
    let avatarImageURL: URL?
    let formattedUsername: String
    let formattedDate: String
    let submissionTitle: String
    let score: String?
    let quizStatus: QuizStatus
    let isMoreActionAvailable: Bool
    let reviewState: Submissions.ReviewState?
}
