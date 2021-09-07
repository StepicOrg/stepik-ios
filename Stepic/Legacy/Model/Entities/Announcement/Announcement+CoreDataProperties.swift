import CoreData
import Foundation

extension Announcement {
    @NSManaged var managedId: NSNumber
    @NSManaged var managedCourseId: NSNumber
    @NSManaged var managedUserId: NSNumber?

    @NSManaged var managedSubject: String
    @NSManaged var managedText: String

    @NSManaged var managedCreateDate: Date?
    @NSManaged var managedNextDate: Date?
    @NSManaged var managedSentDate: Date?

    @NSManaged var managedStatusString: String

    @NSManaged var managedIsRestrictedByScore: NSNumber
    @NSManaged var managedScorePercentMin: NSNumber
    @NSManaged var managedScorePercentMax: NSNumber

    @NSManaged var managedEmailTemplate: String?
    @NSManaged var managedIsScheduled: NSNumber
    @NSManaged var managedStartDate: Date?
    @NSManaged var managedMailPeriodDays: NSNumber
    @NSManaged var managedMailQuantity: NSNumber
    @NSManaged var managedIsInfinite: NSNumber
    @NSManaged var managedOnEnroll: NSNumber

    @NSManaged var managedPublishCount: NSNumber?
    @NSManaged var managedQueueCount: NSNumber?
    @NSManaged var managedSentCount: NSNumber?
    @NSManaged var managedOpenCount: NSNumber?
    @NSManaged var managedClickCount: NSNumber?

    @NSManaged var managedEstimatedStartDate: Date?
    @NSManaged var managedEstimatedFinishDate: Date?
    @NSManaged var managedNoticeDates: NSObject?

    var id: Int {
        get {
            self.managedId.intValue
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var courseID: Course.IdType {
        get {
            self.managedCourseId.intValue
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var userID: User.IdType? {
        get {
            self.managedUserId?.intValue
        }
        set {
            self.managedUserId = newValue as NSNumber?
        }
    }

    var subject: String {
        get {
            self.managedSubject
        }
        set {
            self.managedSubject = newValue
        }
    }

    var text: String {
        get {
            self.managedText
        }
        set {
            self.managedText = newValue
        }
    }

    var createDate: Date? {
        get {
            self.managedCreateDate
        }
        set {
            self.managedCreateDate = newValue
        }
    }

    var nextDate: Date? {
        get {
            self.managedNextDate
        }
        set {
            self.managedNextDate = newValue
        }
    }

    var sentDate: Date? {
        get {
            self.managedSentDate
        }
        set {
            self.managedSentDate = newValue
        }
    }

    var statusString: String {
        get {
            self.managedStatusString
        }
        set {
            self.managedStatusString = newValue
        }
    }

    var isRestrictedByScore: Bool {
        get {
            self.managedIsRestrictedByScore.boolValue
        }
        set {
            self.managedIsRestrictedByScore = NSNumber(value: newValue)
        }
    }

    var scorePercentMin: Int {
        get {
            self.managedScorePercentMin.intValue
        }
        set {
            self.managedScorePercentMin = NSNumber(value: newValue)
        }
    }

    var scorePercentMax: Int {
        get {
            self.managedScorePercentMax.intValue
        }
        set {
            self.managedScorePercentMax = NSNumber(value: newValue)
        }
    }

    var emailTemplate: String? {
        get {
            self.managedEmailTemplate
        }
        set {
            self.managedEmailTemplate = newValue
        }
    }

    var isScheduled: Bool {
        get {
            self.managedIsScheduled.boolValue
        }
        set {
            self.managedIsScheduled = NSNumber(value: newValue)
        }
    }

    var startDate: Date? {
        get {
            self.managedStartDate
        }
        set {
            self.managedStartDate = newValue
        }
    }

    var mailPeriodDays: Int {
        get {
            self.managedMailPeriodDays.intValue
        }
        set {
            self.managedMailPeriodDays = NSNumber(value: newValue)
        }
    }

    var mailQuantity: Int {
        get {
            self.managedMailQuantity.intValue
        }
        set {
            self.managedMailQuantity = NSNumber(value: newValue)
        }
    }

    var isInfinite: Bool {
        get {
            self.managedIsInfinite.boolValue
        }
        set {
            self.managedIsInfinite = NSNumber(value: newValue)
        }
    }

    var onEnroll: Bool {
        get {
            self.managedOnEnroll.boolValue
        }
        set {
            self.managedOnEnroll = NSNumber(value: newValue)
        }
    }

    var publishCount: Int? {
        get {
            self.managedPublishCount?.intValue
        }
        set {
            self.managedPublishCount = newValue as NSNumber?
        }
    }

    var queueCount: Int? {
        get {
            self.managedQueueCount?.intValue
        }
        set {
            self.managedQueueCount = newValue as NSNumber?
        }
    }

    var sentCount: Int? {
        get {
            self.managedSentCount?.intValue
        }
        set {
            self.managedSentCount = newValue as NSNumber?
        }
    }

    var openCount: Int? {
        get {
            self.managedOpenCount?.intValue
        }
        set {
            self.managedOpenCount = newValue as NSNumber?
        }
    }

    var clickCount: Int? {
        get {
            self.managedClickCount?.intValue
        }
        set {
            self.managedClickCount = newValue as NSNumber?
        }
    }

    var estimatedStartDate: Date? {
        get {
            self.managedEstimatedStartDate
        }
        set {
            self.managedEstimatedStartDate = newValue
        }
    }

    var estimatedFinishDate: Date? {
        get {
            self.managedEstimatedFinishDate
        }
        set {
            self.managedEstimatedFinishDate = newValue
        }
    }

    var noticeDates: [Date] {
        get {
            self.managedNoticeDates as? [Date] ?? []
        }
        set {
            self.managedNoticeDates = NSArray(array: newValue)
        }
    }
}
