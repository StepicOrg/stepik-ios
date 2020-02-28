import CoreData
import Foundation
import PromiseKit

protocol SubmissionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Submission.IdType]) -> Guarantee<[SubmissionEntity]>
    func save(submissions: [Submission]) -> Guarantee<Void>

    func fetchAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<[SubmissionEntity]>
    func deleteAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<Void>
}

final class SubmissionsPersistenceService: SubmissionsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext
    private let attemptsPersistenceService: AttemptsPersistenceServiceProtocol

    init(
        managedObjectContext: NSManagedObjectContext,
        attemptsPersistenceService: AttemptsPersistenceServiceProtocol
    ) {
        self.managedObjectContext = managedObjectContext
        self.attemptsPersistenceService = attemptsPersistenceService
    }

    // MARK: Protocol Conforming

    func fetch(ids: [Submission.IdType]) -> Guarantee<[SubmissionEntity]> {
        Guarantee { seal in
            let request = NSFetchRequest<SubmissionEntity>(entityName: "SubmissionEntity")

            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(SubmissionEntity.managedID), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            request.predicate = compoundPredicate
            request.sortDescriptors = SubmissionEntity.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let submissions = try self.managedObjectContext.fetch(request)
                    seal(submissions)
                } catch {
                    print("Error while fetching submissions = \(ids)")
                    seal([])
                }
            }
        }
    }

    func fetchAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<[SubmissionEntity]> {
        Guarantee { seal in
            firstly {
                self.fetchAttempt(id: attemptID)
            }.done { cachedAttemptOrNil in
                let request = NSFetchRequest<SubmissionEntity>(entityName: "SubmissionEntity")
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(SubmissionEntity.managedAttemptID),
                    NSNumber(value: attemptID)
                )
                request.sortDescriptors = SubmissionEntity.defaultSortDescriptors
                request.returnsObjectsAsFaults = false

                self.managedObjectContext.performAndWait {
                    do {
                        let submissions = try self.managedObjectContext.fetch(request)

                        if let attempt = cachedAttemptOrNil {
                            submissions.forEach { $0.attempt = attempt }
                            try? self.managedObjectContext.save()
                        }

                        seal(submissions)
                    } catch {
                        print("Error while fetching submissions for attempt = \(attemptID), error = \(error)")
                        seal([])
                    }
                }
            }
        }
    }

    func deleteAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<Void> {
        Guarantee { seal in
            firstly {
                self.fetchAttemptSubmissions(attemptID: attemptID)
            }.done { submissions in
                self.managedObjectContext.performAndWait {
                    for submission in submissions {
                        self.managedObjectContext.delete(submission)
                    }

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    seal(())
                }
            }
        }
    }

    func save(submissions: [Submission]) -> Guarantee<Void> {
        Guarantee { seal in
            // Inserts all submissions sequentially, not parallel
            let sortedSubmissions = submissions.sorted { $0.id > $1.id }
            var submissionsIterator = sortedSubmissions.makeIterator()

            let insertGuaranteesIterator = AnyIterator<Guarantee<Void>> {
                guard let nextSubmission = submissionsIterator.next() else {
                    return nil
                }

                return self.insertOrReplace(submission: nextSubmission)
            }

            when(fulfilled: insertGuaranteesIterator, concurrently: 1).done { _ in
                seal(())
            }.catch { _ in
                seal(())
            }
        }
    }

    // MARK: Private API

    private func fetchAttempt(id: Attempt.IdType) -> Guarantee<AttemptEntity?> {
        Guarantee { seal in
            self.attemptsPersistenceService.fetch(ids: [id]).done { cachedAttempts in
                seal(cachedAttempts.first)
            }
        }
    }

    private func insertOrReplace(submission: Submission) -> Guarantee<Void> {
        Guarantee { seal in
            firstly {
                self.fetchAttempt(id: submission.attemptID)
            }.then { cachedAttemptOrNil -> Guarantee<(AttemptEntity?, [SubmissionEntity])> in
                self.fetchAttemptSubmissions(attemptID: submission.attemptID)
                    .map { (cachedAttemptOrNil, $0) }
            }.done { (cachedAttemptOrNil: AttemptEntity?, cachedSubmissions: [SubmissionEntity]) in
                let hasNewerSubmission = cachedSubmissions.contains { cachedSubmission in
                    cachedSubmission.id > submission.id && cachedSubmission.attemptID == submission.attemptID
                }

                if hasNewerSubmission {
                    return seal(())
                }

                self.managedObjectContext.performAndWait {
                    cachedSubmissions.forEach { self.managedObjectContext.delete($0) }

                    let newSubmission = SubmissionEntity(
                        submission: submission,
                        managedObjectContext: self.managedObjectContext
                    )

                    if let attempt = cachedAttemptOrNil {
                        newSubmission.attempt = attempt
                    }

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    seal(())
                }
            }
        }
    }
}
