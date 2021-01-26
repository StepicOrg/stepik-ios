import Foundation
import SwiftyJSON

protocol StorageRecordData {
    init(json: JSON)
    var dictValue: [String: Any] { get }
}

// MARK: - Deadlines -

final class DeadlineStorageRecordData: StorageRecordData {
    var courseID: Int
    var deadlines: [SectionDeadline]

    var dictValue: [String: Any] {
        [
            JSONKey.course.rawValue: self.courseID,
            JSONKey.deadlines.rawValue: self.deadlines.map { $0.dictValue }
        ]
    }

    init(courseID: Int, deadlines: [SectionDeadline]) {
        self.courseID = courseID
        self.deadlines = deadlines
    }

    required init(json: JSON) {
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.deadlines = []
        for deadlineJSON in json[JSONKey.deadlines.rawValue].arrayValue {
            if let deadline = SectionDeadline(json: deadlineJSON) {
                self.deadlines += [deadline]
            }
        }
    }

    enum JSONKey: String {
        case course
        case deadlines
    }
}

struct SectionDeadline {
    var section: Int
    var deadlineDate: Date

    var dictValue: [String: Any] {
        [
            JSONKey.section.rawValue: self.section,
            JSONKey.deadline.rawValue: Parser.shared.timedateStringFromDate(date: self.deadlineDate)
        ]
    }

    init(section: Int, deadlineDate: Date) {
        self.section = section
        self.deadlineDate = deadlineDate
    }

    init?(json: JSON) {
        guard let section = json[JSONKey.section.rawValue].int,
              let deadlineDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.deadline.rawValue]) else {
            return nil
        }

        self.section = section
        self.deadlineDate = deadlineDate
    }

    enum JSONKey: String {
        case section
        case deadline
    }
}

// MARK: - Personal Offers -

final class PersonalOfferStorageRecordData: StorageRecordData {
    var promoStories: [Story.IdType]

    var dictValue: [String : Any] {
        [
            JSONKey.promoStories.rawValue: self.promoStories
        ]
    }

    init(promoStories: [Story.IdType]) {
        self.promoStories = promoStories
    }

    init(json: JSON) {
        self.promoStories = json[JSONKey.promoStories.rawValue].arrayValue.map(\.intValue)
    }

    enum JSONKey: String {
        case promoStories = "promo_stories"
    }
}
