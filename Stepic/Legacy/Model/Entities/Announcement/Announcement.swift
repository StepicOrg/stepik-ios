import CoreData
import Foundation

final class Announcement: NSManagedObject, ManagedObject {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedSentDate), ascending: false)]
    }

    var status: AnnouncementStatus? { AnnouncementStatus(rawValue: self.statusString) }
}

// MARK: - Announcement (PlainObject Support) -

extension Announcement {
    var plainObject: AnnouncementPlainObject {
        AnnouncementPlainObject(
            id: self.id,
            courseID: self.courseID,
            userID: self.userID,
            subject: self.subject,
            text: self.text,
            createDate: self.createDate,
            nextDate: self.nextDate,
            sentDate: self.sentDate,
            statusString: self.statusString,
            isRestrictedByScore: self.isRestrictedByScore,
            scorePercentMin: self.scorePercentMin,
            scorePercentMax: self.scorePercentMax,
            emailTemplate: self.emailTemplate,
            isScheduled: self.isScheduled,
            startDate: self.startDate,
            mailPeriodDays: self.mailPeriodDays,
            mailQuantity: self.mailQuantity,
            isInfinite: self.isInfinite,
            onEnroll: self.onEnroll,
            publishCount: self.publishCount,
            queueCount: self.queueCount,
            sentCount: self.sentCount,
            openCount: self.openCount,
            clickCount: self.clickCount,
            estimatedStartDate: self.estimatedStartDate,
            estimatedFinishDate: self.estimatedFinishDate,
            noticeDates: self.noticeDates
        )
    }

    static func insert(into context: NSManagedObjectContext, announcement: AnnouncementPlainObject) -> Announcement {
        let entity: Announcement = context.insertObject()
        entity.update(announcement: announcement)
        return entity
    }

    func update(announcement: AnnouncementPlainObject) {
        self.id = announcement.id
        self.courseID = announcement.courseID
        self.userID = announcement.userID

        self.subject = announcement.subject
        self.text = announcement.text

        self.createDate = announcement.createDate
        self.nextDate = announcement.nextDate
        self.sentDate = announcement.sentDate

        self.statusString = announcement.statusString

        self.isRestrictedByScore = announcement.isRestrictedByScore
        self.scorePercentMin = announcement.scorePercentMin
        self.scorePercentMax = announcement.scorePercentMax

        self.emailTemplate = announcement.emailTemplate
        self.isScheduled = announcement.isScheduled
        self.startDate = announcement.startDate
        self.mailPeriodDays = announcement.mailPeriodDays
        self.mailQuantity = announcement.mailQuantity
        self.isInfinite = announcement.isInfinite
        self.onEnroll = announcement.onEnroll

        self.publishCount = announcement.publishCount
        self.queueCount = announcement.queueCount
        self.sentCount = announcement.sentCount
        self.openCount = announcement.openCount
        self.clickCount = announcement.clickCount

        self.estimatedStartDate = announcement.estimatedStartDate
        self.estimatedFinishDate = announcement.estimatedFinishDate
        self.noticeDates = announcement.noticeDates
    }
}
