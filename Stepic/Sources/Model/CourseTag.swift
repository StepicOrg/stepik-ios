import Foundation

final class CourseTag {
    var uniqueIdentifier: Int
    var titleForLanguage: [ContentLanguage: String] = [:]
    var summaryForLanguage: [ContentLanguage: String] = [:]

    init(uniqueIdentifier: Int, ruTitle: String, enTitle: String, ruSummary: String, enSummary: String) {
        self.uniqueIdentifier = uniqueIdentifier
        self.titleForLanguage[ContentLanguage.english] = enTitle
        self.titleForLanguage[ContentLanguage.russian] = ruTitle
    }

    static let featuredTags: [CourseTag] = [
        CourseTag(
            uniqueIdentifier: 22760,
            ruTitle: "математика",
            enTitle: "mathematics",
            ruSummary: "наука о структурах, порядке и отношениях",
            enSummary: "abstract study of numbers, quantity, structure, relationships, etc."
        ),
        CourseTag(
            uniqueIdentifier: 866,
            ruTitle: "статистика",
            enTitle: "statistics",
            ruSummary: "отрасль знаний о сборе, измерении, анализе, толковании и представлении данных",
            enSummary: "study of the collection, organization, analysis, interpretation, and presentation of data"
        ),
        CourseTag(
            uniqueIdentifier: 22872,
            ruTitle: "информатика",
            enTitle: "computer science",
            ruSummary: "дисциплина о применении компьютерной техники",
            enSummary: "study of the theoretical foundations of information and computation"
        ),
        CourseTag(
            uniqueIdentifier: 485_282,
            ruTitle: "естественные науки",
            enTitle: "natural science",
            ruSummary: "разделы науки, отвечающие за изучение природных явлений",
            enSummary: "branch of science about the natural world"
        ),
        CourseTag(
            uniqueIdentifier: 20521,
            ruTitle: "общественные науки",
            enTitle: "social science",
            ruSummary: "науки об обществе и взаимоотношениях",
            enSummary: "academic discipline concerned with society and the relationships"
        ),
        CourseTag(
            uniqueIdentifier: 33808,
            ruTitle: "гуманитарные науки",
            enTitle: "humanities",
            // swiftlint:disable:next line_length
            ruSummary: "дисциплины, изучающие человека в сфере его духовной, умственной, нравственной, культурной и общественной деятельности",
            enSummary: "academic disciplines that study human culture"
        )
    ]
}
