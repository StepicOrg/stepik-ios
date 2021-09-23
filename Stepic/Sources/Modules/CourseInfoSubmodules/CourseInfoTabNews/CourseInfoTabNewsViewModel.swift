import Foundation

struct CourseInfoTabNewsViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let subject: String
    let processedContent: ProcessedContent

    var statistics: CourseInfoTabNewsStatisticsViewModel?
}

struct CourseInfoTabNewsStatisticsViewModel {
    let publishCount: Int
    let queueCount: Int
    let sentCount: Int
    let openCount: Int
    let clickCount: Int
}
