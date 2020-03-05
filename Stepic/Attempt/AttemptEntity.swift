import CoreData
import Foundation

final class AttemptEntity: NSManagedObject {
    typealias IdType = Int

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "AttemptEntity", in: CoreDataHelper.shared.context)!
    }

    var id: Int {
        get {
            self.managedID.intValue
        }
        set {
            self.managedID = NSNumber(value: newValue)
        }
    }

    var stepID: Step.IdType {
        get {
            self.managedStepID.intValue
        }
        set {
            self.managedStepID = NSNumber(value: newValue)
        }
    }

    var step: Step? {
        get {
            self.managedStep
        }
        set {
            self.managedStep = newValue
        }
    }

    var userID: User.IdType {
        get {
            self.managedUserID.intValue
        }
        set {
            self.managedUserID = NSNumber(value: newValue)
        }
    }

    var user: User? {
        get {
            self.managedUser
        }
        set {
            self.managedUser = newValue
        }
    }

    var dataset: Dataset? {
        get {
            self.managedDataset
        }
        set {
            self.managedDataset = newValue
        }
    }

    var datasetURL: String? {
        get {
            self.managedDatasetURL
        }
        set {
            self.managedDatasetURL = newValue
        }
    }

    var status: String? {
        get {
            self.managedStatus
        }
        set {
            self.managedStatus = newValue
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

    var timeLeftString: String? {
        get {
            self.managedTimeLeft
        }
        set {
            self.managedTimeLeft = newValue
        }
    }

    var submission: SubmissionEntity? {
        get {
            self.managedSubmission
        }
        set {
            self.managedSubmission = newValue
        }
    }

    // MARK: Init

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }
}

// MARK: - AttemptEntity (PlainObject Support) -

extension AttemptEntity {
    var plainObject: Attempt {
        Attempt(
            id: self.id,
            dataset: self.dataset,
            datasetURL: self.datasetURL,
            time: self.timeString,
            status: self.status,
            stepID: self.stepID,
            timeLeft: self.timeLeftString,
            userID: self.userID
        )
    }

    convenience init(attempt: Attempt, managedObjectContext: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(
            forEntityName: "AttemptEntity", in: managedObjectContext
        ) else {
            fatalError("Wrong object type")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        self.id = attempt.id
        self.stepID = attempt.stepID
        self.dataset = attempt.dataset
        self.datasetURL = attempt.datasetURL
        self.status = attempt.status
        self.timeString = attempt.time
        self.timeLeftString = attempt.timeLeft

        if let userID = attempt.userID {
            self.userID = userID
        }
    }
}
