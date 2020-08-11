import CoreData
import Foundation

extension SubmissionEntity {
    @NSManaged var managedID: NSNumber
    @NSManaged var managedAttemptID: NSNumber
    @NSManaged var managedReply: Reply?
    @NSManaged var managedLocal: NSNumber
    @NSManaged var managedScore: NSNumber

    @NSManaged var managedHint: String?
    @NSManaged var managedStatus: String?
    @NSManaged var managedFeedback: SubmissionFeedback?

    @NSManaged var managedTime: Date?

    @NSManaged var managedAttempt: AttemptEntity?

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedID), ascending: false)]
    }

    static var fetchRequest: NSFetchRequest<SubmissionEntity> {
        NSFetchRequest<SubmissionEntity>(entityName: "SubmissionEntity")
    }
}
