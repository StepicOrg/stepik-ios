import Foundation

struct SubmissionsViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType
    let avatarImageURL: URL?
    let formattedUsername: String
    let formattedDate: String
    let submissionTitle: String
    let isSubmissionCorrect: Bool
}
