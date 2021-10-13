import Foundation

struct UserCoursesReviewsItemViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let title: String
    let text: String?
    let dateRepresentation: String?
    let score: Int
    let coverImageURL: URL?
    let shouldShowAdaptiveMark: Bool
}
