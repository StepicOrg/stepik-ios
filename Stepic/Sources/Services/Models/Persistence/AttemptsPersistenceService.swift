import CoreData
import PromiseKit

protocol AttemptsPersistenceServiceProtocol: AnyObject {
    func fetchStepAttempts(stepID: Step.IdType) -> Guarantee<[AttemptEntity]>
    func fetch(id: Attempt.IdType) -> Guarantee<AttemptEntity?>
    func fetch(ids: [Attempt.IdType]) -> Guarantee<[AttemptEntity]>

    func save(attempts: [Attempt]) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

final class AttemptsPersistenceService: BasePersistenceService<AttemptEntity>, AttemptsPersistenceServiceProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context,
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService()
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        super.init(managedObjectContext: managedObjectContext)
    }

    // MARK: Protocol Conforming

    func fetchStepAttempts(stepID: Step.IdType) -> Guarantee<[AttemptEntity]> {
        Guarantee { seal in
            self.fetchStep(id: stepID).done { stepOrNil in
                let request = AttemptEntity.sortedFetchRequest
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    #keyPath(AttemptEntity.managedStepID),
                    NSNumber(value: stepID)
                )
                request.returnsObjectsAsFaults = false

                self.managedObjectContext.perform {
                    do {
                        let attempts = try self.managedObjectContext.fetch(request)

                        if let step = stepOrNil {
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

    // MARK: Private API

    private func fetchStep(id: Step.IdType) -> Guarantee<Step?> {
        Guarantee { seal in
            self.stepsPersistenceService.fetch(id: id).done { stepOrNil in
                seal(stepOrNil)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    private func insertOrReplace(attempt: Attempt) -> Guarantee<Void> {
        Guarantee { seal in
            DispatchQueue.main.promise { () -> Guarantee<Step?> in
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

                    let newAttempt = AttemptEntity.insert(into: self.managedObjectContext, attempt: attempt)

                    if let step = cachedStepOrNil {
                        newAttempt.step = step
                    }

                    self.managedObjectContext.saveOrRollback()

                    seal(())
                }
            }.catch { _ in
                seal(())
            }
        }
    }
}
