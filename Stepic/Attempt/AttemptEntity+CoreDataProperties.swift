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

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<AttemptEntity> {
        return NSFetchRequest<AttemptEntity>(entityName: "AttemptEntity")
    }
}
