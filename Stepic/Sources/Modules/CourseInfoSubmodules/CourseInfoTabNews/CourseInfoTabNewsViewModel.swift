import Foundation

struct CourseInfoTabNewsViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let subject: String
    let processedContent: ProcessedContent

    var badge: CourseInfoTabNewsBadgeViewModel?
    var statistics: CourseInfoTabNewsStatisticsViewModel?
}

struct CourseInfoTabNewsBadgeViewModel {
    let status: AnnouncementStatus
    let isOneTimeEvent: Bool
    let isActiveEvent: Bool
}

struct CourseInfoTabNewsStatisticsViewModel {
    let publishCount: Int
    let queueCount: Int
    let sentCount: Int
    let openCount: Int
    let clickCount: Int
}
