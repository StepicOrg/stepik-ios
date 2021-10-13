import CoreData

final class AttemptEntity: NSManagedObject, ManagedObject, Identifiable {
    typealias IdType = Int

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedID), ascending: false)]
    }

    static var idAttributeName: String { #keyPath(managedID) }

    var time: Date? {
        if let timeString = self.timeString,
           let timeInterval = TimeInterval(timeString: timeString) {
            return Date(timeIntervalSince1970: timeInterval)
        } else {
            return nil
        }
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

    static func insert(into context: NSManagedObjectContext, attempt: Attempt) -> AttemptEntity {
        let attemptEntity: AttemptEntity = context.insertObject()

        attemptEntity.id = attempt.id
        attemptEntity.stepID = attempt.stepID
        attemptEntity.dataset = attempt.dataset
        attemptEntity.datasetURL = attempt.datasetURL
        attemptEntity.status = attempt.status
        attemptEntity.timeString = attempt.time
        attemptEntity.timeLeftString = attempt.timeLeft

        if let userID = attempt.userID {
            attemptEntity.userID = userID
        }

        return attemptEntity
    }
}
