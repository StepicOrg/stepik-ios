import Foundation

struct CourseInfoTabNewsViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let subject: String
    let processedContent: ProcessedContent
}
