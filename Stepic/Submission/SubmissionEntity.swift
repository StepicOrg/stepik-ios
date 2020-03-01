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

    var time: Date {
        get {
            self.managedTime ?? Date()
        }
        set {
            self.managedTime = newValue
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

// MARK: - SubmissionEntity (PlainObject Support) -

extension SubmissionEntity {
    var plainObject: Submission {
        Submission(
            id: self.id,
            status: self.status,
            hint: self.hint,
            feedback: self.feedback,
            time: self.time,
            reply: self.reply,
            attemptID: self.attemptID,
            attempt: self.attempt?.plainObject
        )
    }

    convenience init(submission: Submission, managedObjectContext: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(
            forEntityName: "SubmissionEntity", in: managedObjectContext
        ) else {
            fatalError("Wrong object type")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        self.id = submission.id
        self.attemptID = submission.attemptID
        self.reply = submission.reply
        self.hint = submission.hint
        self.statusString = submission.statusString
        self.feedback = submission.feedback
        self.time = submission.time
    }
}
