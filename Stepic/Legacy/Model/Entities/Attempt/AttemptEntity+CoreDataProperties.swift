import CoreData
import Foundation

extension AttemptEntity {
    @NSManaged var managedID: NSNumber
    @NSManaged var managedStepID: NSNumber
    @NSManaged var managedUserID: NSNumber

    @NSManaged var managedDataset: Dataset?
    @NSManaged var managedDatasetURL: String?

    @NSManaged var managedTime: String?
    @NSManaged var managedStatus: String?
    @NSManaged var managedTimeLeft: String?

    @NSManaged var managedStep: Step?
    @NSManaged var managedUser: User?
    @NSManaged var managedSubmission: SubmissionEntity?

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
}
