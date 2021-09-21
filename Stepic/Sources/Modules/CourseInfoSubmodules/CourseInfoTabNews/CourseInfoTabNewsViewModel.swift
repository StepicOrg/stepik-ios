import Foundation

struct CourseInfoTabNewsViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let processedContent: ProcessedContent
}
