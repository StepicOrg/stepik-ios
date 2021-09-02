import Foundation

struct CourseSearchViewModel {
    let placeholderText: String
    let suggestions: [Suggestion]

    struct Suggestion: UniqueIdentifiable {
        let uniqueIdentifier: UniqueIdentifierType
        let title: String
    }
}
