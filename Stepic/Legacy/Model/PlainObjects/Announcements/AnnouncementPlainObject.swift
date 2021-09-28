import Foundation
import SwiftyJSON

struct AnnouncementPlainObject: JSONSerializable {
    let id: Int
    let courseID: Int
    let userID: Int?

    let subject: String
    let text: String

    let createDate: Date?
    let nextDate: Date?
    let sentDate: Date?

    let statusString: String
    var status: AnnouncementStatus? { AnnouncementStatus(rawValue: self.statusString) }

    let isRestrictedByScore: Bool
    let scorePercentMin: Int
    let scorePercentMax: Int

    let emailTemplate: String?
    let isScheduled: Bool
    let startDate: Date?
    let mailPeriodDays: Int
    let mailQuantity: Int
    let isInfinite: Bool
    let onEnroll: Bool

    let publishCount: Int?
    let queueCount: Int?
    let sentCount: Int?
    let openCount: Int?
    let clickCount: Int?

    let estimatedStartDate: Date?
    let estimatedFinishDate: Date?
    let noticeDates: [Date]

    var isOneTimeEvent: Bool { !self.isInfinite && !self.onEnroll }

    var isActiveEvent: Bool {
        self.onEnroll
            || (self.isInfinite && (self.startDate == nil || self.startDate.require() < Date()))
    }
}

extension AnnouncementPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].int

        self.subject = json[JSONKey.subject.rawValue].stringValue
        self.text = json[JSONKey.text.rawValue].stringValue

        self.createDate = Parser.dateFromTimedateJSON(json[JSONKey.createDate.rawValue])
        self.nextDate = Parser.dateFromTimedateJSON(json[JSONKey.nextDate.rawValue])
        self.sentDate = Parser.dateFromTimedateJSON(json[JSONKey.sentDate.rawValue])

        self.statusString = json[JSONKey.status.rawValue].stringValue

        self.isRestrictedByScore = json[JSONKey.isRestrictedByScore.rawValue].boolValue
        self.scorePercentMin = json[JSONKey.scorePercentMin.rawValue].int ?? 0
        self.scorePercentMax = json[JSONKey.scorePercentMax.rawValue].int ?? 100

        self.emailTemplate = json[JSONKey.emailTemplate.rawValue].string
        self.isScheduled = json[JSONKey.isScheduled.rawValue].boolValue
        self.startDate = Parser.dateFromTimedateJSON(json[JSONKey.startDate.rawValue])
        self.mailPeriodDays = json[JSONKey.mailPeriodDays.rawValue].int ?? 7
        self.mailQuantity = json[JSONKey.mailQuantity.rawValue].int ?? 1
        self.isInfinite = json[JSONKey.isInfinite.rawValue].boolValue
        self.onEnroll = json[JSONKey.onEnroll.rawValue].boolValue

        self.publishCount = json[JSONKey.publishCount.rawValue].int
        self.queueCount = json[JSONKey.queueCount.rawValue].int
        self.sentCount = json[JSONKey.sentCount.rawValue].int
        self.openCount = json[JSONKey.openCount.rawValue].int
        self.clickCount = json[JSONKey.clickCount.rawValue].int

        self.estimatedStartDate = Parser.dateFromTimedateJSON(json[JSONKey.estimatedStartDate.rawValue])
        self.estimatedFinishDate = Parser.dateFromTimedateJSON(json[JSONKey.estimatedFinishDate.rawValue])
        self.noticeDates = json[JSONKey.noticeDates.rawValue].arrayValue.compactMap(Parser.dateFromTimedateJSON(_:))
    }

    func update(json: JSON) {}

    enum JSONKey: String {
        case id
        case course
        case user
        case subject
        case text
        case createDate = "create_date"
        case nextDate = "next_date"
        case sentDate = "sent_date"
        case status
        case isRestrictedByScore = "is_restricted_by_score"
        case scorePercentMin = "score_percent_min"
        case scorePercentMax = "score_percent_max"
        case emailTemplate = "email_template"
        case isScheduled = "is_scheduled"
        case startDate = "start_date"
        case mailPeriodDays = "mail_period_days"
        case mailQuantity = "mail_quantity"
        case isInfinite = "is_infinite"
        case onEnroll = "on_enroll"
        case publishCount = "publish_count"
        case queueCount = "queue_count"
        case sentCount = "sent_count"
        case openCount = "open_count"
        case clickCount = "click_count"
        case estimatedStartDate = "estimated_start_date"
        case estimatedFinishDate = "estimated_finish_date"
        case noticeDates = "notice_dates"
    }
}
