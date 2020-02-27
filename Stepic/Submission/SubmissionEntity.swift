import CoreData
import Foundation

final class SubmissionEntity: NSManagedObject {
    typealias IdType = Int

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "SubmissionEntity", in: CoreDataHelper.shared.context)!
    }

    var id: Int {
        get {
            self.managedID.intValue
        }
        set {
            self.managedID = NSNumber(value: newValue)
        }
    }

    var attemptID: AttemptEntity.IdType {
        get {
            self.managedAttemptID.intValue
        }
        set {
            self.managedAttemptID = NSNumber(value: newValue)
        }
    }

    var reply: Reply? {
        get {
            self.managedReply
        }
        set {
            self.managedReply = newValue
        }
    }

    var hint: String? {
        get {
            self.managedHint
        }
        set {
            self.managedHint = newValue
        }
    }

    var statusString: String? {
        get {
            self.managedStatus
        }
        set {
            self.managedStatus = newValue
        }
    }

    var status: SubmissionStatus? {
        if let statusString = self.statusString {
            return SubmissionStatus(rawValue: statusString)
        } else {
            return nil
        }
    }

    var feedback: SubmissionFeedback? {
        get {
            self.managedFeedback
        }
        set {
            self.managedFeedback = newValue
        }
    }

    var timeString: String? {
        get {
            self.managedTime
        }
        set {
            self.managedTime = newValue
        }
    }

    var time: Date? {
        if let timeString = self.timeString {
            return Date(timeIntervalSince1970: TimeInterval(timeString: timeString))
        } else {
            return nil
        }
    }

    var attempt: AttemptEntity? {
        get {
            self.managedAttempt
        }
        set {
            self.managedAttempt = newValue
        }
    }

    // MARK: Init

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }
}
