import CoreData
import Foundation

extension SubmissionEntity {
    @NSManaged var managedID: NSNumber
    @NSManaged var managedAttemptID: NSNumber
    @NSManaged var managedReply: Reply?

    @NSManaged var managedHint: String?
    @NSManaged var managedStatus: String?
    @NSManaged var managedFeedback: SubmissionFeedback?

    @NSManaged var managedTime: String?

    @NSManaged var managedAttempt: AttemptEntity?

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<SubmissionEntity> {
        return NSFetchRequest<SubmissionEntity>(entityName: "SubmissionEntity")
    }
}
