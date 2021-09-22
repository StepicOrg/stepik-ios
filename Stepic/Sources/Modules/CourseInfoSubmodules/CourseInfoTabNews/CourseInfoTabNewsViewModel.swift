import Foundation

struct CourseInfoTabNewsViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let formattedDate: String
    let subject: String
    let processedContent: ProcessedContent

    var statistics: CourseInfoTabNewsStatisticsViewModel?
}

struct CourseInfoTabNewsStatisticsViewModel {
    let publishCount: Int // рассылок сделано
    let queueCount: Int // видят на странице
    let sentCount: Int // получили на почту
    let openCount: Int // открыли письмо
    let clickCount: Int // кликнули по ссылкам
}
