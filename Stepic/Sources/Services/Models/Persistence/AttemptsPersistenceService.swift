import CoreData
import Foundation
import PromiseKit

protocol AttemptsPersistenceServiceProtocol: AnyObject {
    func fetchStepAttempts(stepID: Step.IdType) -> Guarantee<[AttemptEntity]>
    func fetch(ids: [Attempt.IdType]) -> Guarantee<[AttemptEntity]>

    func save(attempts: [Attempt]) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

final class AttemptsPersistenceService: AttemptsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context,
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService()
    ) {
        self.managedObjectContext = managedObjectContext
        self.stepsPersistenceService = stepsPersistenceService
    }

    // MARK: Protocol Conforming

    func fetchStepAttempts(stepID: Step.IdType) -> Guarantee<[AttemptEntity]> {
        Guarantee { seal in
            firstly {
                self.fetchStep(id: stepID)
            }.done { step in
                let request = NSFetchRequest<AttemptEntity>(entityName: "AttemptEntity")
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(AttemptEntity.managedStepID),
                    NSNumber(value: stepID)
                )
                request.sortDescriptors = AttemptEntity.defaultSortDescriptors
                request.returnsObjectsAsFaults = false

                self.managedObjectContext.performAndWait {
                    do {
                        let attempts = try self.managedObjectContext.fetch(request)

                        if let step = step {
                            attempts.forEach { $0.step = step }
                            try? self.managedObjectContext.save()
                        }

                        seal(attempts)
                    } catch {
                        print("Error while fetching attempts for step = \(stepID), error = \(error)")
                        seal([])
                    }
                }
            }
        }
    }

    func fetch(ids: [Attempt.IdType]) -> Guarantee<[AttemptEntity]> {
        Guarantee { seal in
            let request = NSFetchRequest<AttemptEntity>(entityName: "AttemptEntity")

            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(AttemptEntity.managedID), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            request.predicate = compoundPredicate
            request.sortDescriptors = AttemptEntity.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let attempts = try self.managedObjectContext.fetch(request)
                    seal(attempts)
                } catch {
                    print("Error while fetching attempts = \(ids)")
                    seal([])
                }
            }
        }
    }

    func save(attempts: [Attempt]) -> Guarantee<Void> {
        Guarantee { seal in
            // Inserts all attempts sequentially, not parallel
            let sortedAttempts = attempts.sorted { $0.id > $1.id }
            var attemptsIterator = sortedAttempts.makeIterator()

            let insertGuaranteesIterator = AnyIterator<Guarantee<Void>> {
                guard let nextAttempt = attemptsIterator.next() else {
                    return nil
                }

                return self.insertOrReplace(attempt: nextAttempt)
            }

            when(fulfilled: insertGuaranteesIterator, concurrently: 1).done { _ in
                seal(())
            }.catch { _ in
                seal(())
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<AttemptEntity> = AttemptEntity.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let attempts = try self.managedObjectContext.fetch(request)
                    for attempt in attempts {
                        self.managedObjectContext.delete(attempt)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("AttemptsPersistenceService :: failed delete all attempts with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    // MARK: Private API

    private func fetchStep(id: Step.IdType) -> Guarantee<Step?> {
        Guarantee { seal in
            self.stepsPersistenceService.fetch(ids: [id]).done { steps in
                seal(steps.first)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    private func insertOrReplace(attempt: Attempt) -> Guarantee<Void> {
        Guarantee { seal in
            firstly {
                self.fetchStep(id: attempt.stepID)
            }.then { cachedStepOrNil -> Guarantee<(Step?, [AttemptEntity])> in
                self.fetchStepAttempts(stepID: attempt.stepID)
                    .map { (cachedStepOrNil, $0) }
            }.done { (cachedStepOrNil: Step?, cachedAttempts: [AttemptEntity]) in
                let hasNewerAttempt = cachedAttempts.contains { $0.id > attempt.id && $0.userID == attempt.userID }

                if hasNewerAttempt {
                    return seal(())
                }

                self.managedObjectContext.performAndWait {
                    cachedAttempts.forEach { self.managedObjectContext.delete($0) }

                    let newAttempt = AttemptEntity(
                        attempt: attempt,
                        managedObjectContext: self.managedObjectContext
                    )

                    if let step = cachedStepOrNil {
                        newAttempt.step = step
                    }

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    seal(())
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
