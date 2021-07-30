import CoreData
import PromiseKit

protocol SubmissionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Submission.IdType]) -> Guarantee<[SubmissionEntity]>
    func save(submissions: [Submission]) -> Guarantee<Void>

    func fetchAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<[SubmissionEntity]>
    func deleteAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

final class SubmissionsPersistenceService: BasePersistenceService<SubmissionEntity>,
                                           SubmissionsPersistenceServiceProtocol {
    private let attemptsPersistenceService: AttemptsPersistenceServiceProtocol

    init(
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context,
        attemptsPersistenceService: AttemptsPersistenceServiceProtocol = AttemptsPersistenceService()
    ) {
        self.attemptsPersistenceService = attemptsPersistenceService
        super.init(managedObjectContext: managedObjectContext)
    }

    func fetchAttemptSubmissions(attemptID: Attempt.IdType) -> Guarantee<[SubmissionEntity]> {
        Guarantee { seal in
            firstly { () -> Guarantee<AttemptEntity?> in
                self.attemptsPersistenceService.fetch(id: attemptID)
            }.done { cachedAttemptOrNil in
                let request = SubmissionEntity.sortedFetchRequest
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(SubmissionEntity.managedAttemptID),
                    NSNumber(value: attemptID)
                )
                request.returnsObjectsAsFaults = false

                self.managedObjectContext.performAndWait {
                    do {
                        let submissions = try self.managedObjectContext.fetch(request)

                        guard let attempt = cachedAttemptOrNil else {
                            return seal(submissions)
                        }

                        for submission in submissions {
                            if submission.managedObjectContext != nil
                                && submission.managedObjectContext == attempt.managedObjectContext {
                                submission.attempt = attempt
                            }
                        }

                        if self.managedObjectContext.hasChanges {
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
            firstly { () -> Guarantee<[SubmissionEntity]> in
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

    private func insertOrReplace(submission: Submission) -> Guarantee<Void> {
        Guarantee { seal in
            DispatchQueue.main.promise { () -> Guarantee<AttemptEntity?> in
                self.attemptsPersistenceService.fetch(id: submission.attemptID)
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

                    let newSubmission = SubmissionEntity.insert(
                        into: self.managedObjectContext,
                        submission: submission
                    )

                    try? self.managedObjectContext.save()

                    if let attempt = cachedAttemptOrNil {
                        if newSubmission.managedObjectContext != attempt.managedObjectContext {
                            guard let attemptCopy = newSubmission.managedObjectContext?.object(
                                with: attempt.objectID
                            ) as? AttemptEntity else {
                                return seal(())
                            }

                            newSubmission.attempt = attemptCopy
                        } else {
                            newSubmission.attempt = attempt
                        }
                    }

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    seal(())
                }
            }.catch { _ in
                seal(())
            }
        }
    }
}
