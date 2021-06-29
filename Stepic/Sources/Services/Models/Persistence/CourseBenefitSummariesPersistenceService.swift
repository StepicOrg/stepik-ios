import CoreData
import Foundation
import PromiseKit

protocol CourseBenefitSummariesPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseBenefitSummary.IdType) -> Guarantee<[CourseBenefitSummary]>
    func fetchAll() -> Guarantee<[CourseBenefitSummary]>

    func deleteAll() -> Promise<Void>
}

extension CourseBenefitSummariesPersistenceServiceProtocol {
    func fetch(id: CourseBenefitSummary.IdType) -> Guarantee<CourseBenefitSummary?> {
        self.fetch(id: id).map(\.first)
    }
}

final class CourseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(id: CourseBenefitSummary.IdType) -> Guarantee<[CourseBenefitSummary]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitSummary.fetchRequest
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefitSummary.managedId),
                NSNumber(value: id)
            )
            fetchRequest.sortDescriptors = CourseBenefitSummary.defaultSortDescriptors

            do {
                let courseBenefitSummaries = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitSummaries)
            } catch {
                print("CourseBenefitSummariesPersistenceService :: failed fetch by id = \(id)")
                seal([])
            }
        }
    }

    func fetchAll() -> Guarantee<[CourseBenefitSummary]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitSummary.fetchRequest
            fetchRequest.sortDescriptors = CourseBenefitSummary.defaultSortDescriptors

            do {
                let courseBenefitSummaries = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitSummaries)
            } catch {
                print("CourseBenefitSummariesPersistenceService :: failed fetch all")
                seal([])
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseBenefitSummary")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.executeAndMergeChanges(using: batchDeleteRequest)
                    try? self.managedObjectContext.save()
                    seal.fulfill(())
                } catch {
                    print("CourseBenefitSummariesPersistenceService :: failed delete all with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
