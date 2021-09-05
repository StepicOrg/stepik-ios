import Foundation

struct CourseSearchSuggestionViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType
    let title: String
}

struct CourseSearchResultViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let title: String
    let coverImageURL: URL?

    let likesCount: Int?
    let learnersLabelText: String
    let progressLabelText: String?
    let timeToCompleteLabelText: String?

    let comment: Comment?

    struct Comment {
        let avatarImageURL: URL?
        let username: String
        let text: String
    }
}
