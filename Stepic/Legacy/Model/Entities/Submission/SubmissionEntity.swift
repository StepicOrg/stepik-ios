import CoreData

final class SubmissionEntity: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = Int

    static var idAttributeName: String { #keyPath(managedID) }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedID), ascending: false)]
    }
}

// MARK: - SubmissionEntity (PlainObject Support) -

extension SubmissionEntity {
    var plainObject: Submission {
        Submission(
            id: self.id,
            status: self.status,
            score: self.score,
            hint: self.hint,
            feedback: self.feedback,
            time: self.time,
            reply: self.reply,
            attemptID: self.attemptID,
            attempt: self.attempt?.plainObject,
            isLocal: self.isLocal
        )
    }

    static func insert(into context: NSManagedObjectContext, submission: Submission) -> SubmissionEntity {
        let object: SubmissionEntity = context.insertObject()

        object.id = submission.id
        object.attemptID = submission.attemptID
        object.reply = submission.reply
        object.isLocal = submission.isLocal
        object.score = submission.score
        object.hint = submission.hint
        object.statusString = submission.statusString
        object.feedback = submission.feedback
        object.time = submission.time

        return object
    }
}
