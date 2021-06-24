import CoreData
import Foundation
import PromiseKit

protocol CourseBenefitsPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseBenefit.IdType) -> Guarantee<[CourseBenefit]>
    func fetch(ids: [CourseBenefit.IdType]) -> Guarantee<[CourseBenefit]>
    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefit]>
    func fetchAll() -> Guarantee<[CourseBenefit]>

    func deleteAll() -> Promise<Void>
}

extension CourseBenefitsPersistenceServiceProtocol {
    func fetch(id: CourseBenefit.IdType) -> Guarantee<CourseBenefit?> {
        self.fetch(id: id).map(\.first)
    }
}

final class CourseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(id: CourseBenefit.IdType) -> Guarantee<[CourseBenefit]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefit.fetchRequest
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefit.managedId),
                NSNumber(value: id)
            )
            fetchRequest.sortDescriptors = CourseBenefit.defaultSortDescriptors

            do {
                let courseBenefits = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefits)
            } catch {
                print("CourseBenefitsPersistenceService :: failed fetch by id = \(id)")
                seal([])
            }
        }
    }

    func fetch(ids: [CourseBenefit.IdType]) -> Guarantee<[CourseBenefit]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefit.fetchRequest
            let idSubpredicates = ids.map { id in
                NSPredicate(
                    format: "%K == %@",
                    #keyPath(CourseBenefit.managedId),
                    NSNumber(value: id)
                )
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            fetchRequest.predicate = compoundPredicate
            fetchRequest.sortDescriptors = CourseBenefit.defaultSortDescriptors

            do {
                let courseBenefits = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefits)
            } catch {
                print("CourseBenefitsPersistenceService :: failed fetch by ids = \(ids)")
                seal([])
            }
        }
    }

    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefit]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefit.fetchRequest
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefit.managedCourseId),
                NSNumber(value: courseID)
            )
            fetchRequest.sortDescriptors = CourseBenefit.defaultSortDescriptors

            do {
                let courseBenefits = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefits)
            } catch {
                print("CourseBenefitsPersistenceService :: failed fetch by course id = \(courseID)")
                seal([])
            }
        }
    }

    func fetchAll() -> Guarantee<[CourseBenefit]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefit.fetchRequest
            fetchRequest.sortDescriptors = CourseBenefit.defaultSortDescriptors

            do {
                let courseBenefits = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefits)
            } catch {
                print("CourseBenefitsPersistenceService :: failed fetch all")
                seal([])
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseBenefit")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try self.managedObjectContext.executeAndMergeChanges(using: batchDeleteRequest)
                seal.fulfill(())
            } catch {
                print("CourseBenefitsPersistenceService :: failed delete all with error = \(error)")
                seal.reject(Error.deleteFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
